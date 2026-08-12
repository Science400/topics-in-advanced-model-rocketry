#!/usr/bin/env python3
"""
Read the per-chapter section maps in pipeline/sections/*.toml.

Each map lists only the START page of every section; the end is implied by the
next section's start, so gaps and overlaps are impossible by construction. A
section's range is [start, next_start] inclusive on both ends — the boundary
page is shared because a section can begin partway down a page.

    python pipeline/sections.py ch1
"""

from __future__ import annotations

import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path

SECTIONS_DIR = Path(__file__).parent / "sections"


@dataclass(frozen=True)
class Section:
    id: str          # manuscript number, verbatim: "2", "2.1"
    title: str
    start: int
    end: int
    level: int       # 1 for "2", 2 for "2.1"

    @property
    def label(self) -> str:
        """Typst label body, chapter prefix applied by the caller."""
        return f"sec:{{chapter}}-{self.id}"

    @property
    def pages(self) -> range:
        return range(self.start, self.end + 1)


def load(chapter: str) -> dict:
    path = SECTIONS_DIR / f"{chapter}.toml"
    if not path.exists():
        raise SystemExit(f"No section map at {path}")
    with path.open("rb") as fh:
        return tomllib.load(fh)


def sections(chapter: str) -> list[Section]:
    """
    All sections and subsections, ordered by start page.

    TOML keeps [[section]] and [[subsection]] as separate arrays, so document
    order between them is not preserved by the parser. The hierarchy is
    recovered from the id prefix ("2.1" belongs to "2") and the ordering from
    `start`, which is why the ids must be accurate.
    """
    data = load(chapter)
    raw = [
        (str(e["id"]), str(e.get("title", "")), int(e["start"]))
        for key in ("section", "subsection")
        for e in data.get(key, [])
    ]
    if not raw:
        raise SystemExit(f"{chapter}.toml defines no sections")
    raw.sort(key=lambda t: t[2])

    # The last body page, not the last page of the PDF: references and any
    # trailing matter are not part of the final section.
    front = data.get("frontmatter", {})
    refs = front.get("references")
    last_page = int(refs) - 1 if refs else int(data.get("pages", raw[-1][2]))

    levels = [sid.count(".") + 1 for sid, _, _ in raw]
    out: list[Section] = []
    for i, (sid, title, start) in enumerate(raw):
        # A section ends where the next section at the same or a shallower level
        # begins. Using "the next section of any level" would end a parent at its
        # own first child, so section 2 would stop at 2.2 instead of at section 3.
        later = [s for j, (_, _, s) in enumerate(raw[i + 1:], start=i + 1)
                 if levels[j] <= levels[i] and s > start]
        end = min(later) if later else last_page
        out.append(Section(sid, title, start, min(end, last_page), levels[i]))
    return out


def tiles(chapter: str) -> list[Section]:
    """
    Non-overlapping units of work covering the chapter body exactly once.

    `sections()` is hierarchical, so a parent overlaps its children — OCRing
    every entry would transcribe most pages twice. This tiles the body by
    consecutive distinct start pages instead, attributing each tile to the
    deepest section that begins there. A parent's own preamble pages (section 1
    from page 6 before 1.1 begins on 8) come out as their own tile.
    """
    all_secs = sections(chapter)
    last_page = max(s.end for s in all_secs)
    starts = sorted({s.start for s in all_secs})

    out: list[Section] = []
    for i, start in enumerate(starts):
        end = starts[i + 1] if i + 1 < len(starts) else last_page
        if end <= start and i + 1 < len(starts):
            continue  # two sections share a start page; the deeper one wins
        here = [s for s in all_secs if s.start == start]
        owner = max(here, key=lambda s: s.level)
        out.append(Section(owner.id, owner.title, start, min(end, last_page), owner.level))
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


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    chapter = sys.argv[1]
    data = load(chapter)
    print(f"{chapter}: {data.get('pdf')}, {data.get('pages')} pages")
    print(f"body pages {body_range(chapter)}\n")
    for sec in sections(chapter):
        indent = "  " * sec.level
        span = sec.end - sec.start + 1
        warn = "  <- long" if span > 15 else ""
        print(f"{indent}{sec.id:<6} {sec.start:>3}-{sec.end:<3} ({span:>2}p) {sec.title}{warn}")
