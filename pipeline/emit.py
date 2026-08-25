#!/usr/bin/env python3
"""
Emit the assembled chapter as Typst, behind a compile gate.

`stream.py` joins the cached pages and cuts them at their headings; this turns
each cut into Typst and writes the chapter in one pass. Conversion happens at
write time, so a chapter that will not compile is never left on disk.

What changed from the previous version, and why:

  no section markers      The body between the symbol table and the bibliography
                          is regenerated wholesale. The headings delimit the
                          sections; a `// <<< section 2.1` comment above each one
                          said nothing the heading did not.

  page marks kept         `// === page 18 ===` still marks every seam, because
                          that is what lets you read the .typ against the scan.
                          It is emitted *between* two sentence lines with no
                          blank line either side, so Typst folds it away and the
                          paragraph renders unbroken.

  numbers are literal     A numbered equation is written `#eqn("21")[...]`, never
                          a bare `$ ... $` relying on Typst's counter. One
                          equation missed by the transcriber would otherwise
                          shift every number after it, silently. An equation
                          whose number was not recovered comes out as `$! ... $`
                          — visibly unnumbered rather than plausibly misnumbered.

  figures are placed      A caption plate is bound wherever the printer put it,
                          usually splitting a sentence. Figures are collected by
                          `stream.py` and re-inserted after the paragraph that
                          first mentions them.

  coverage is proved      Every word of the scan is accounted for in the output.

Usage
-----
    python pipeline/emit.py --chapter ch1
    python pipeline/emit.py --chapter ch1 --section 2.1 --dry-run
"""

from __future__ import annotations

import argparse
import re
import subprocess
import tempfile
from dataclasses import dataclass, field
from pathlib import Path

import corrections as C
import mathconv
import sections as S
import stream as ST
import symtab
import units as U
from config import CHAPTER_PDFS
from term import console

_HERE = Path(__file__).parent
CHAPTERS_DIR = _HERE.parent / "src" / "chapters"
REPO_ROOT = _HERE.parent
FIGURES_REL = "../../assets/figures-original"
FIGURES_DIR = REPO_ROOT / "assets" / "figures-original"

# Abbreviations that end in a period without ending a sentence.
_ABBREV = {
    "O.G.", "Fig.", "Figs.", "Eq.", "Eqs.", "Sec.", "No.", "Ref.", "Refs.",
    "Dr.", "Mr.", "Mrs.", "St.", "vs.", "etc.", "i.e.", "e.g.", "cf.",
    "approx.", "Inc.", "Co.", "Jr.", "Ch.", "pp.", "Vol.", "C.G.", "C.P.",
}
# Variable-width lookbehind is not allowed, so split first and rejoin after.
# The page sentinel is admitted to the lookahead: a seam falling exactly at a
# sentence boundary puts the mark between the two, and without this the split
# would not fire and the sentences would be run together on one line.
_SENTENCE_RE = re.compile(rf"(?<=[.!?])[ ]+(?=[A-Z\"'(]|{ST.MARK_OPEN})")


@dataclass
class Emitted:
    typst: str
    warnings: list[str] = field(default_factory=list)
    eq_numbers: list[str] = field(default_factory=list)
    unknown: list[str] = field(default_factory=list)
    flags: list[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Prose
# ---------------------------------------------------------------------------

def split_sentences(paragraph: str) -> list[str]:
    """
    One sentence per line — the convention that makes git diffs meaningful.

    Done here rather than asked of the model: the transcriber ignored the
    instruction, and sentence boundaries are a deterministic text operation that
    should not depend on a model's mood.
    """
    text = " ".join(paragraph.split())
    parts = [p.strip() for p in _SENTENCE_RE.split(text) if p.strip()]

    # Rejoin where the split landed after an abbreviation rather than a sentence
    # end — "the forces on the O.G. due to..." is one sentence.
    merged: list[str] = []
    for part in parts:
        if merged and merged[-1].rsplit(" ", 1)[-1] in _ABBREV:
            merged[-1] = f"{merged[-1]} {part}"
        else:
            merged.append(part)
    return merged


def escape_markup(line: str) -> str:
    """
    Escape characters Typst reads as markup at the start of a line.

    A transcribed sentence beginning with "=" becomes a level-1 heading, which
    silently invents a chapter. The same applies to list and enum markers.

    "#" is deliberately NOT escaped: this runs after linkify, so a leading "#"
    is one of our own generated calls. Escaping it turned #ref(<fig:1-5>) into
    \\#ref(<fig:1-5>), which makes the label a second *definition* rather than a
    reference — Typst then reports the label as occurring twice.
    """
    return re.sub(r"^(\s*)([=+]|[-/](?=\s))", r"\1\\\2", line)


def fix_prose(text: str) -> str:
    """Typographic conventions applied to prose runs, outside math."""
    text = re.sub(r"(?<![-\\])--(?!-)", "---", text)   # manuscript uses -- for em dash
    text = text.replace("...", "…")
    return text


def convert_inline_math(text: str, index: dict, warnings: list[str],
                        unknown: list[str], fixes: C.Corrections) -> str:
    """Rewrite $...$ inline spans from LaTeX to Typst, leaving prose alone."""
    def replace(match: re.Match) -> str:
        result = mathconv.convert(match.group(1), index)
        if not result.typst:
            warnings.append(f"inline math not converted: {match.group(1)[:60]}")
            # Raw LaTeX inside $...$ does not compile — Typst reads \D as an
            # escape and leaves "elta". Quote it so the page still builds.
            escaped = match.group(1).replace('"', "'")
            return f'#conflict[#raw("{escaped}")]'
        unknown.extend(result.unknown)
        return f"${fixes.fix_math(result.typst)}$"

    return re.sub(r"(?<!\$)\$([^$\n]+)\$(?!\$)", replace, text)


# Prose mentions that become Typst references. Only rewritten when the target
# label actually exists in this chapter — a reference to a label that is never
# defined does not compile, and "Chapter 4" cannot be linked while ch4 is empty.
_REF_PATTERNS = [
    (re.compile(r"\b(Sections?)\s+(\d+(?:\.\d+)*)"), "sec", "at"),
    (re.compile(r"\b(Figures?|Figs?\.)\s+(\d+)"), "fig", "at"),
    # Keep the manuscript's own wording and capitalisation for equations — only
    # the number becomes the reference, via the bare-number eqref helper.
    (re.compile(r"\b([Ee]quations?|Eqs?\.)\s+\((\d+[a-z]?)\)"), "eq", "eqref"),
]


def linkify(text: str, labels: set[str], chapter_num: int) -> str:
    """Turn prose mentions into references, skipping math spans."""
    def one(chunk: str) -> str:
        for pattern, kind, style in _REF_PATTERNS:
            def replace(match: re.Match) -> str:
                word, number = match.group(1), match.group(2)
                label = f"{kind}:{chapter_num}-{number}"
                if label not in labels:
                    return match.group(0)      # target does not exist; leave prose
                if style == "eqref":
                    return f"{word} #eqref(<{label}>)"
                # "Figure 4a" refers to a panel of Figure 4. The @label form
                # would swallow the trailing letter into the label itself
                # (@fig:1-4 + "a" parses as fig:1-4a), so delimit it explicitly
                # whenever an alphanumeric follows.
                tail = match.string[match.end():match.end() + 1]
                if tail.isalnum():
                    return f"#ref(<{label}>)"
                return f"@{label}"
            chunk = pattern.sub(replace, chunk)
        return chunk

    # Never rewrite inside $...$; a reference there would be read as math.
    parts = re.split(r"(\$[^$\n]+\$)", text)
    return "".join(part if part.startswith("$") else one(part) for part in parts)


# ---------------------------------------------------------------------------
# Blocks
# ---------------------------------------------------------------------------

def blocks_of(text: str) -> list[tuple[str, str]]:
    """Split a section into ('math'|'table'|'prose', content) blocks in order."""
    out: list[tuple[str, str]] = []
    pos = 0
    pattern = re.compile(r"\$\$(.+?)\$\$|(<table>.*?</table>)", re.S | re.I)
    for match in pattern.finditer(text):
        before = text[pos:match.start()].strip()
        if before:
            out.append(("prose", before))
        if match.group(1) is not None:
            out.append(("math", match.group(1).strip()))
        else:
            out.append(("table", match.group(2)))
        pos = match.end()
    tail = text[pos:].strip()
    if tail:
        out.append(("prose", tail))
    return out


def page_comment(page: int) -> str:
    return f"// === page {page} ==="


def with_page_marks(lines: list[str]) -> list[str]:
    """
    Replace page sentinels with comment lines, without breaking paragraphs.

    A mark inside a sentence becomes a comment line placed *before* that
    sentence, with no blank line on either side. Typst treats the comment as
    nothing, so the paragraph still renders as one unbroken block — which is the
    whole reason the marks can be left in.
    """
    out: list[str] = []
    for line in lines:
        pages = ST.marks_in(line)
        body = ST.strip_marks(line).strip()
        for page in pages:
            out.append(page_comment(page))
        if body:
            out.append(body)
        elif not pages:
            out.append(line)
    return out


# ---------------------------------------------------------------------------
# Equations
# ---------------------------------------------------------------------------

# Long or multi-line equations are worth a look regardless of what any model
# says about them: ch2 has several that run the width of the page, and a
# transcription error inside one is invisible in a diff.
_BIG_EQUATION = 200


def emit_equation(result: mathconv.Converted, chapter_num: int,
                  page: int, flags: list[str]) -> str:
    """
    One display equation, numbered literally or visibly not numbered at all.

    `$ ... $` is never emitted. Typst would number it from a counter, and the
    counter only agrees with the manuscript for as long as no equation is
    missed — after one omission every later number is wrong and nothing says so.
    `#eqn("21")` writes the manuscript's own number beside the label, so the two
    cannot disagree; `$! ... $` is the preamble's unnumbered form.
    """
    body = result.typst
    if len(body) > _BIG_EQUATION or "\\" in body:
        flags.append(f"p{page}: long or multi-line equation, check it against "
                     f"the scan: {body[:70]}…")
    if result.eq_number:
        return (f'#eqn("{result.eq_number}")[$ {body} $] '
                f"<eq:{chapter_num}-{result.eq_number}>")
    return f"$! {body} $"


# ---------------------------------------------------------------------------
# Labels
# ---------------------------------------------------------------------------

def collect_labels(chapter: str, chapter_num: int,
                   stream: ST.Stream) -> set[str]:
    """
    Every label the chapter will define, so references can be checked first.

    A reference to a label that is never defined does not compile, so linkify
    needs the full set before the first section is written. Equation numbers are
    read straight off the display blocks with the same regex mathconv uses, which
    is cheap and needs no conversion.
    """
    labels = {f"sec:{chapter_num}-{sec.id}" for sec in S.sections(chapter)}
    labels |= {f"fig:{chapter_num}-{fig.number}" for fig in stream.figures}
    for block in re.findall(r"\$\$(.+?)\$\$", ST.promote_bare_equations(stream.text), re.S):
        number = mathconv._EQNUM_RE.match(block.strip())
        if number:
            labels.add(f"eq:{chapter_num}-{number.group(1) or number.group(2)}")
    return labels


# ---------------------------------------------------------------------------
# Figures
# ---------------------------------------------------------------------------

def figure_block(chapter_num: int, fig: ST.Figure, caption: str) -> str:
    """A #figure with the caption transcribed verbatim and the scan art."""
    stem = f"fig{chapter_num}-{fig.number}"
    # A figure may be cropped into several files — fig1-4(1).png and
    # fig1-4(2).png are the two panels of Figure 4 — so take every match in
    # order rather than assuming one image per figure.
    found = sorted(list(FIGURES_DIR.glob(f"{stem}.png"))
                   + list(FIGURES_DIR.glob(f"{stem}(*).png")),
                   key=lambda p: p.name)
    if len(found) == 1:
        art = f'image("{FIGURES_REL}/{found[0].name}")'
        todo = ""
    elif found:
        # #figure takes a single body, so stack the panels of a split figure
        # into one block.
        panels = "\n    ".join(f'image("{FIGURES_REL}/{p.name}"),' for p in found)
        art = f"stack(dir: ttb, spacing: 1em,\n    {panels}\n  )"
        todo = ""
    else:
        art = (f'rect(width: 100%, height: 4cm, stroke: 0.5pt + gray)[\n'
               f'    #align(center + horizon)[#text(gray)[missing {stem}.png]]\n  ]')
        todo = f"// TODO crop {stem}.png from the scan\n"
    return (f"{todo}#figure(\n"
            f"  {art},\n"
            f"  caption: [{caption}]\n"
            f") <fig:{chapter_num}-{fig.number}>")


_PARA_BREAK = ""


def place_figures(body: str, blocks: dict[str, str], chapter_num: int,
                  flags: list[str]) -> str:
    """
    Move each figure to just after the paragraph that first mentions it.

    Chapter-level, and it has to be: a plate bound into section 2.4 is often
    first discussed in 2.3, so no section can decide this alone. A figure nobody
    mentions is left at the end and flagged rather than guessed at.
    """
    lines = body.split("\n")
    placed: set[str] = set()

    # Paragraph index of the first mention of each figure. Comments do not count
    # as a mention — a `// === page N ===` line is not prose.
    first_mention: dict[str, int] = {}
    para = 0
    for line in lines:
        if not line.strip():
            para += 1
            continue
        if line.lstrip().startswith("//"):
            continue
        for number in re.findall(rf"<?fig:{chapter_num}-(\d+)>?", line):
            first_mention.setdefault(number, para)

    out: list[str] = []
    para = 0
    for line in lines:
        out.append(line)
        if not line.strip():
            # End of a paragraph: drop in any figure first mentioned inside it.
            for number, at in sorted(first_mention.items(), key=lambda kv: kv[1]):
                if at == para and number in blocks and number not in placed:
                    out.append(blocks[number])
                    out.append("")
                    placed.add(number)
            para += 1

    for number, block in blocks.items():
        if number in placed:
            continue
        if number not in first_mention:
            flags.append(f"Figure {number} is never mentioned in the text; "
                         f"left at the end of the chapter")
        out += ["", block, ""]
    return "\n".join(out)


# ---------------------------------------------------------------------------
# Section emission
# ---------------------------------------------------------------------------

def emit_section(cut: ST.Cut, chapter_num: int, index: dict,
                 fixes: C.Corrections, labels: set[str],
                 accepted_units: set[str]) -> Emitted:
    sec = cut.section
    warnings: list[str] = []
    eq_numbers: list[str] = []
    unknown: list[str] = []
    flags: list[str] = []

    depth = sec.level + 1                    # level 1 is the chapter heading
    lines = [f"{'=' * depth} {sec.title} <sec:{chapter_num}-{sec.id}>", ""]

    text = ST.promote_bare_equations(cut.text)
    for kind, content in blocks_of(text):
        page = cut.page
        marks = ST.marks_in(content)
        if marks:
            page = marks[-1]

        if kind == "math":
            expression = " ".join(ST.strip_marks(content).split())
            result = mathconv.convert(expression, index)
            if not result.typst:
                warnings.append(f"p{page}: display math not converted: "
                                f"{expression[:60]}")
                lines += [f"#conflict[unconverted: `{expression[:100]}`]", ""]
                continue
            unknown.extend(result.unknown)
            result.typst = fixes.fix_math(result.typst)
            if result.eq_number:
                eq_numbers.append(result.eq_number)
            lines += with_page_marks([ST.mark(m) for m in marks])
            lines += [emit_equation(result, chapter_num, page, flags), ""]

        elif kind == "table":
            warnings.append(f"p{page}: HTML table left for manual conversion")
            lines += [f"// TODO convert this table to Typst (page {page})",
                      "#conflict[table omitted — see scan]", ""]

        else:
            for para in re.split(r"\n\s*\n", content):
                para = para.strip()
                if not para:
                    continue
                para = fixes.fix_prose(fix_prose(para))
                para = linkify(para, labels, chapter_num)
                para, unit_flags = U.convert(para, accepted_units)
                flags.extend(f"p{page}: {f}" for f in unit_flags)
                para = convert_inline_math(para, index, warnings, unknown, fixes)
                lines += with_page_marks(
                    [escape_markup(l) for l in split_sentences(para)])
                lines.append("")

    body = fixes.fix_any("\n".join(lines).rstrip() + "\n")
    return Emitted(body, warnings, eq_numbers, unknown, flags)


# ---------------------------------------------------------------------------
# Writing the chapter
# ---------------------------------------------------------------------------

def chapter_file(chapter: str) -> Path:
    return CHAPTERS_DIR / f"{Path(CHAPTER_PDFS[chapter]).stem}.typ"


IMPORT_LINE = (
    '#import "../preamble.typ": conflict, minor, unit, qty, qtyrange, num, eq, '
    'eqref, symbol-table, chapter-setup, AR\n'
    '#show: chapter-setup'
)


def ensure_imports(chapter_path: Path) -> None:
    """
    Guarantee the chapter imports what the emitted Typst uses.

    Typst's #include does not inherit imports from the including file, so each
    chapter needs its own import line even though main.typ imports the preamble.
    """
    src = chapter_path.read_text()
    if "../preamble.typ" not in src:
        chapter_path.write_text(f"{IMPORT_LINE}\n\n{src.lstrip()}")


def write_body(chapter_path: Path, body: str) -> None:
    """
    Replace the generated body, leaving the hand-written front and back matter.

    The file's own structure marks the boundaries, so no comment has to: the
    front matter ends at the closing paren of the symbol table, and the back
    matter begins at #bibliography. Everything between is ours to regenerate.
    """
    src = chapter_path.read_text()
    span = symtab.table_span(src)
    if span is None:
        raise SystemExit(f"{chapter_path.name}: no symbol table found, so there "
                         f"is no way to tell front matter from body")
    head_end = span[1]
    tail_at = src.find("#bibliography(")
    if tail_at < 0:
        tail_at = len(src)
    chapter_path.write_text(
        src[:head_end].rstrip() + "\n\n" + body.strip() + "\n\n" + src[tail_at:].lstrip())


def chapter_compiles(chapter_path: Path) -> tuple[bool, str]:
    """
    Typeset the real chapter file, not a fragment in isolation.

    Compiling a section on its own gets two things wrong: relative image paths
    resolve against the probe's directory rather than src/chapters, and a
    cross-section reference looks undefined because its target is in another
    fragment. The chapter builds in about a second.
    """
    with tempfile.TemporaryDirectory() as tmp:
        proc = subprocess.run(
            ["typst", "compile", "--root", str(REPO_ROOT),
             str(chapter_path), str(Path(tmp) / "probe.pdf")],
            capture_output=True, text=True, timeout=300,
        )
    return proc.returncode == 0, proc.stderr.strip()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def figures_in(cut: ST.Cut, cuts: list[ST.Cut],
               stream: ST.Stream) -> list[ST.Figure]:
    """
    The caption plates bound inside one section's pages, for a `--section` run.

    Bounded by heading pages, not by the page marks inside the cut. A plate page
    holds nothing but the caption, so it contributes no prose and gets no mark —
    §1.1 of ch2 spans pages 15 to 17 but its cut carries the single mark [17],
    and bounding by marks put Figure 1 on page 16 outside its own section. The
    figure was then never written while prose still referenced it, which is
    exactly the dangling `@fig:2-1` this is fixing.
    """
    lo = cut.page or min((f.page for f in stream.figures), default=0)
    later = [c.page for c in cuts if c.located and c.page > cut.page]
    hi = min(later) if later else (stream.pages[-1] if stream.pages else lo)
    return [f for f in stream.figures if lo <= f.page <= hi]


def build(chapter: str, only: str | None = None) -> tuple[str, Emitted]:
    """Assemble, cut, convert. Returns the chapter body and a merged report."""
    chapter_num = int(re.search(r"\d+", chapter).group())
    path = chapter_file(chapter)
    if not path.exists():
        raise SystemExit(f"No chapter source at {path}")

    stream, stream_warnings = ST.assemble(chapter)
    cuts, cut_warnings = ST.cut(chapter, stream)
    fixes = C.load(chapter)
    index = mathconv.build_symbol_index(symtab.parse(path))
    labels = collect_labels(chapter, chapter_num, stream)

    console.print(f"[dim]{len(stream.pages)} pages, {len(labels)} labels, "
                  f"{len(stream.figures)} figures[/]")
    accepted = U.prepare(ST.strip_marks(stream.text))

    targets = [c for c in cuts if not only or c.section.id == only]
    wanted = (stream.figures if not only
              else (figures_in(targets[0], cuts, stream) if targets else []))

    def one_pass(labels: set[str]) -> tuple[str, Emitted]:
        report = Emitted("", list(stream_warnings) + list(cut_warnings))
        figures: dict[str, str] = {}
        for fig in wanted:
            caption = fixes.fix_prose(fix_prose(fig.caption))
            caption = linkify(caption, labels, chapter_num)
            caption, _ = U.convert(caption, accepted)
            caption = convert_inline_math(caption, index, report.warnings,
                                          report.unknown, fixes)
            figures[fig.number] = figure_block(chapter_num, fig, caption)

        parts: list[str] = []
        for cut in targets:
            if not cut.located:
                report.warnings.append(
                    f"{cut.section.id}: heading not found, section skipped")
                continue
            result = emit_section(cut, chapter_num, index, fixes, labels, accepted)
            parts.append(result.typst)
            report.warnings += result.warnings
            report.eq_numbers += result.eq_numbers
            report.unknown += result.unknown
            report.flags += result.flags

        # Figures are placed even for a single section. Skipping this was what
        # let a section reference @fig:2-1 that nothing ever wrote: the label
        # was in the set because the plate had been transcribed, but the plate
        # itself only reaches the file through here.
        body = place_figures("\n\n".join(parts), figures, chapter_num, report.flags)
        report.typst = body
        return body, report

    body, report = one_pass(labels)

    # A reference whose target is not in the output does not compile, and the
    # optimistic label set is chapter-wide: emitting one section leaves every
    # other section's headings, equations and figures undefined. Narrow the set
    # to what was actually written and emit again. This converges after one
    # extra pass — dropping a reference can only remove references, never
    # definitions, so the defined set is the same the second time.
    written = ST.defined_labels(body)
    dangling = ST.referenced_labels(body) - written
    if dangling:
        report.warnings.append(
            f"{len(dangling)} reference(s) had no target in this output and were "
            f"left as plain prose: {', '.join(sorted(dangling)[:8])}")
        body, report2 = one_pass(labels & written)
        report2.warnings = report.warnings + [
            w for w in report2.warnings if w not in report.warnings]
        report = report2
        report.typst = body
    return body, report


def check_numbering(numbers: list[str]) -> list[str]:
    """Equation numbers should ascend without repeating."""
    problems: list[str] = []
    seen: dict[str, int] = {}
    for n in numbers:
        seen[n] = seen.get(n, 0) + 1
    for n, count in seen.items():
        if count > 1:
            problems.append(f"equation number ({n}) is used {count} times")

    def key(n: str) -> tuple[int, str]:
        digits = re.match(r"(\d+)([a-z]?)", n)
        return (int(digits.group(1)), digits.group(2)) if digits else (0, "")

    ordered = [key(n) for n in numbers]
    for i in range(1, len(ordered)):
        if ordered[i] < ordered[i - 1]:
            problems.append(f"equation ({numbers[i]}) comes after "
                            f"({numbers[i - 1]}) — out of order")
    return problems


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--chapter", default="ch1", choices=list(CHAPTER_PDFS))
    ap.add_argument("--section", help="emit only this section (skips figure placement)")
    ap.add_argument("--dry-run", action="store_true",
                    help="print the Typst instead of writing it")
    ap.add_argument("--out", metavar="NAME",
                    help="write to src/chapters/NAME.typ instead of the chapter "
                         "itself, for comparing a run against hand-edited work "
                         "without destroying it")
    args = ap.parse_args()

    path = chapter_file(args.chapter)
    ensure_imports(path)
    body, report = build(args.chapter, args.section)

    if args.out:
        # A sibling of the real chapter, so relative image paths and the compile
        # gate behave identically. main.typ does not include it.
        path = CHAPTERS_DIR / f"{args.out}.typ"
        if not path.exists():
            path.write_text(chapter_file(args.chapter).read_text())

    if args.dry_run:
        print(body)
    else:
        before = path.read_text()
        write_body(path, body)
        ok, err = chapter_compiles(path)
        if not ok:
            path.write_text(before)      # the chapter always compiles
            console.print("\n[red]DOES NOT COMPILE — rolled back[/]")
            for line in err.splitlines()[:15]:
                console.print(f"  {line}")
            raise SystemExit(1)
        console.print(f"\n[green]written to {path.name}, compiles[/]")

    if report.eq_numbers:
        console.print(f"\n[bold]{len(report.eq_numbers)} numbered equations[/]: "
                      f"{', '.join(report.eq_numbers[:20])}"
                      f"{' …' if len(report.eq_numbers) > 20 else ''}")
        for problem in check_numbering(report.eq_numbers):
            console.print(f"  [yellow]![/] {problem}")

    if not args.dry_run and not args.section:
        stream, _ = ST.assemble(args.chapter)
        gaps = ST.coverage(args.chapter, body) + ST.caption_drift(stream, body)
        if gaps:
            console.print("\n[bold]coverage[/]")
            for gap in gaps:
                console.print(f"  [yellow]![/] {gap}")
        else:
            console.print("\n[green]coverage: every run of transcribed prose is "
                          "in the output exactly once, captions included[/]")

    if report.unknown:
        console.print(f"\n[yellow]not in symbol table:[/] "
                      f"{', '.join(sorted(set(report.unknown))[:25])}")
    for warning in report.warnings:
        console.print(f"  [yellow]![/] {warning}")
    for flag in report.flags[:40]:
        console.print(f"  [cyan]⚠[/] {flag}")
    if len(report.flags) > 40:
        console.print(f"  [dim]… and {len(report.flags) - 40} more flags[/]")


if __name__ == "__main__":
    main()
