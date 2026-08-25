#!/usr/bin/env python3
"""
Read the per-chapter section maps in pipeline/sections/*.toml.

The map is an ordered list of the chapter's headings. Page numbers are a *hint*,
not a cut point: `emit.py` locates each section by matching its heading text in
the assembled chapter stream, so a start page only narrows the search and may be
approximate or omitted entirely.

That is a deliberate change from the previous design, where a section's range was
[start, next_start] inclusive at both ends. Sharing the boundary page between two
sections meant every boundary page was processed twice and then split apart again
by a regex match on the heading — which doubled a half-paragraph when the heading
matched in both halves and dropped one when it matched in neither.

Ordering: if every entry declares a start page, entries are sorted by it (this is
what ch1.toml does). If any start is missing or zero, the order written in the
file is the document order and is preserved as-is — which is what `--scaffold`
produces, since it reads the headings out of the chapter in document order.

    python pipeline/sections.py ch1
    python pipeline/sections.py ch2 --scaffold
"""

from __future__ import annotations

import argparse
import re
import tomllib
from dataclasses import dataclass
from pathlib import Path

SECTIONS_DIR = Path(__file__).parent / "sections"
CHAPTERS_DIR = Path(__file__).parent.parent / "src" / "chapters"

_ARRAYS = ("section", "subsection", "subsubsection")


@dataclass(frozen=True)
class Section:
    id: str          # manuscript number, verbatim: "2", "2.1"
    title: str
    start: int       # page hint; 0 means "unknown, locate by heading text"
    end: int         # 0 when start is unknown
    level: int       # 1 for "2", 2 for "2.1", 3 for "2.1.1"

    @property
    def pages(self) -> range:
        return range(self.start, self.end + 1) if self.start else range(0)

    @property
    def has_pages(self) -> bool:
        return self.start > 0 and self.end >= self.start


def load(chapter: str) -> dict:
    path = SECTIONS_DIR / f"{chapter}.toml"
    if not path.exists():
        raise SystemExit(f"No section map at {path}")
    with path.open("rb") as fh:
        return tomllib.load(fh)


def sections(chapter: str) -> list[Section]:
    """All headings in document order."""
    data = load(chapter)
    raw = [
        (str(e["id"]), str(e.get("title", "")), int(e.get("start", 0) or 0))
        for key in _ARRAYS
        for e in data.get(key, [])
    ]
    if not raw:
        raise SystemExit(f"{chapter}.toml defines no sections")

    # TOML keeps the arrays separate, so document order between them is lost.
    # Page numbers recover it when they are all present; otherwise the file must
    # use one array and its own order is authoritative.
    if all(start > 0 for _, _, start in raw):
        raw.sort(key=lambda t: t[2])

    # The last body page, not the last page of the PDF: references and any
    # trailing matter are not part of the final section.
    front = data.get("frontmatter", {})
    refs = front.get("references")
    last_page = int(refs) - 1 if refs else int(data.get("pages", 0) or 0)

    levels = [sid.count(".") + 1 for sid, _, _ in raw]
    out: list[Section] = []
    for i, (sid, title, start) in enumerate(raw):
        if not start:
            out.append(Section(sid, title, 0, 0, levels[i]))
            continue
        # A section ends where the next section at the same or a shallower level
        # begins. "The next section of any level" would end a parent at its own
        # first child, so section 2 would stop at 2.2 instead of at section 3.
        later = [s for j, (_, _, s) in enumerate(raw[i + 1:], start=i + 1)
                 if levels[j] <= levels[i] and s > start]
        end = min(later) if later else last_page
        out.append(Section(sid, title, start, min(end, last_page) if last_page else end,
                           levels[i]))
    return out


def find(chapter: str, section_id: str) -> Section:
    for sec in sections(chapter):
        if sec.id == section_id:
            return sec
    known = ", ".join(s.id for s in sections(chapter))
    raise SystemExit(f"Section {section_id!r} not in {chapter}.toml. Known: {known}")


def body_range(chapter: str) -> tuple[int, int]:
    """Pages of actual body text, excluding front matter and references."""
    data = load(chapter)
    front = data.get("frontmatter", {})
    start = int(front.get("body_starts", 1))
    end = int(front.get("references", data.get("pages", start))) - 1
    return start, max(start, end)


def body_pages(chapter: str) -> list[int]:
    start, end = body_range(chapter)
    return list(range(start, end + 1))


def page_offset(chapter: str) -> int:
    """
    printed page number − PDF page number.

    ch1's split PDF happens to start at printed page 1, so the two agree and the
    distinction never came up. ch2's does not: its PDF page 11 is stamped "-63-".
    Everything internal (cache filenames, section hints, page markers) uses the
    PDF number; reports cite the printed one alongside it, because that is what
    is written on the page you are reading from.
    """
    return int(load(chapter).get("frontmatter", {}).get("page_offset", 0))


def printed(chapter: str, page: int) -> int:
    return page + page_offset(chapter)


def parse_pages(arg: str) -> list[int]:
    """'12-19', '12,15,18', or a mix."""
    pages: list[int] = []
    for chunk in arg.split(","):
        chunk = chunk.strip()
        if "-" in chunk:
            lo, hi = chunk.split("-", 1)
            pages.extend(range(int(lo), int(hi) + 1))
        elif chunk:
            pages.append(int(chunk))
    return sorted(set(pages))


def sample(start: int, end: int, count: int) -> list[int]:
    """Evenly spaced pages across [start, end], including both ends."""
    span = list(range(start, end + 1))
    if count >= len(span):
        return span
    if count == 1:
        return [span[len(span) // 2]]
    step = (len(span) - 1) / (count - 1)
    return sorted({span[round(i * step)] for i in range(count)})


# ---------------------------------------------------------------------------
# Scaffolding a map from the chapter's own headings
# ---------------------------------------------------------------------------

# `== Title <sec:2-1.1>` and the #heading() form the unnumbered Introduction uses.
_MARKUP_HEADING_RE = re.compile(
    r"^(={2,})\s+(.+?)\s*<sec:\d+-([\d.]+)>\s*$", re.M)
_CALL_HEADING_RE = re.compile(
    r"^#heading\([^)]*\)\[(.+?)\]\s*<sec:\d+-([\d.]+)>\s*$", re.M)


def headings_from_typst(path: Path) -> list[tuple[str, str]]:
    """(id, title) for every labelled heading in a chapter source, in order."""
    found: list[tuple[int, str, str]] = []
    for match in _MARKUP_HEADING_RE.finditer(path.read_text()):
        found.append((match.start(), match.group(3), match.group(2).strip()))
    for match in _CALL_HEADING_RE.finditer(path.read_text()):
        found.append((match.start(), match.group(2), match.group(1).strip()))
    found.sort(key=lambda t: t[0])
    return [(sid, title) for _, sid, title in found]


def scaffold(chapter: str, typ_path: Path) -> str:
    """A ch<N>.toml skeleton built from the chapter stub's headings."""
    headings = headings_from_typst(typ_path)
    if not headings:
        raise SystemExit(f"No labelled headings found in {typ_path}")

    lines = [
        f"# Section map — {chapter}, scaffolded from {typ_path.name}",
        "#",
        "# `start` is a HINT that narrows the search for a heading in the OCR'd",
        "# text; emit.py cuts sections at the heading itself, so an approximate",
        "# number is fine and 0 means \"search the whole chapter\". Fill them in",
        "# to make heading matching more robust on a long chapter.",
        "#",
        "# The order below is the document order and is authoritative while any",
        "# start is still 0. Do not reorder.",
        "",
        f'chapter = {int(re.search(r"[0-9]+", chapter).group())}',
        f'pdf = "{typ_path.stem}.pdf"',
        "",
        "[frontmatter]",
        "# body_starts: first page of body text. references: page the",
        "# bibliography begins on; everything before it is body.",
        "body_starts = 0",
        "references = 0",
        "",
    ]
    for sid, title in headings:
        lines += ["[[section]]",
                  f'id = "{sid}"',
                  f'title = "{title}"',
                  "start = 0",
                  ""]
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("chapter")
    ap.add_argument("--scaffold", action="store_true",
                    help="write sections/<chapter>.toml from the chapter's headings")
    ap.add_argument("--typ", help="chapter source to scaffold from "
                                  "(default: the one matching the chapter)")
    args = ap.parse_args()

    if args.scaffold:
        from config import CHAPTER_PDFS
        typ = Path(args.typ) if args.typ else \
            CHAPTERS_DIR / f"{Path(CHAPTER_PDFS[args.chapter]).stem}.typ"
        out = SECTIONS_DIR / f"{args.chapter}.toml"
        if out.exists():
            raise SystemExit(f"{out} already exists — delete it first if you mean to redo it")
        out.write_text(scaffold(args.chapter, typ))
        n = len(headings_from_typst(typ))
        print(f"{out}: {n} headings scaffolded from {typ.name}")
        print("Now fill in [frontmatter] body_starts and references.")
        return

    data = load(args.chapter)
    print(f"{args.chapter}: {data.get('pdf')}, {data.get('pages', '?')} pages")
    try:
        print(f"body pages {body_range(args.chapter)}\n")
    except Exception:
        print()
    for sec in sections(args.chapter):
        indent = "  " * sec.level
        if sec.has_pages:
            span = sec.end - sec.start + 1
            where = f"{sec.start:>3}-{sec.end:<3} ({span:>2}p)"
        else:
            where = "  by heading  "
        print(f"{indent}{sec.id:<8} {where} {sec.title}")


if __name__ == "__main__":
    main()
