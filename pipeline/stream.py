#!/usr/bin/env python3
"""
Assemble a chapter's cached pages into one continuous stream, then cut it into
sections at their headings.

OCR happens a page at a time, but a page is the wrong unit for everything after
that. A sentence runs across the seam, a paragraph runs across a figure plate
bound in the middle of it, and a section boundary falls partway down a page. The
previous design gave each section the range [start, next_start] inclusive at both
ends and split the shared boundary page by regex-matching the heading in it —
which emitted a half-paragraph twice when the heading matched in both halves and
dropped one when it matched in neither.

Here the chapter is joined once and cut once, so every character lands in exactly
one section. `coverage()` proves it rather than assuming it.

Three things this has to get right, all of them visible in ch1:

  page seams      p16 ends "...the exhaust stream", p18 opens "is directed dead
                  astern". Joined, or the sentence splitter cuts mid-sentence.

  figure plates   p17, between those two, is nothing but the caption of Figure 3.
                  Lifted out of the prose stream entirely — otherwise it lands in
                  the middle of that sentence. It is placed later, next to the
                  paragraph that first mentions it.

  provenance      `// === page N ===` still has to come out in the Typst. Pages
                  are marked with a sentinel that survives paragraph joining and
                  sentence splitting, and becomes a comment at emit time.

    python pipeline/stream.py ch1
    python pipeline/stream.py ch1 --section 2.1
"""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass, field
from pathlib import Path

import ocrlib
import sections as S
from term import console

CACHE_ROOT = Path(__file__).parent / "cache"

# Private-use sentinels. They pass through every regex in the emitter untouched
# (nothing matches a private-use codepoint) and cannot collide with book text.
MARK_OPEN, MARK_CLOSE = "\ue010", "\ue011"
_MARK_RE = re.compile(f"{MARK_OPEN}(\\d+){MARK_CLOSE}")


def mark(page: int) -> str:
    return f"{MARK_OPEN}{page}{MARK_CLOSE}"


def strip_marks(text: str) -> str:
    return _MARK_RE.sub("", text)


def marks_in(text: str) -> list[int]:
    return [int(m.group(1)) for m in _MARK_RE.finditer(text)]


# A caption plate: the paragraph opens "Figure 7:" or "Figure 7." — the number
# followed immediately by a colon or period. Deliberately strict, because prose
# genuinely opens with the word: ch1 p29 begins "Figure 5b represents the
# thrust-time curve of the NAR type B", which is body text, not a caption.
_CAPTION_RE = re.compile(r"^Figure\s+(\d+)\s*[:.]\s*(.+)", re.S)

# The page number the transcriber sometimes keeps despite being told not to,
# stamped "-63-" or "63" and centred above everything else.
_PAGENUM_RE = re.compile(r"^\s*[-–—]?\s*\d{1,3}\s*[-–—]?\s*$")


@dataclass
class Figure:
    number: str
    caption: str          # exactly as transcribed; never reworded
    page: int


@dataclass
class Stream:
    """The chapter body as one string, with page sentinels embedded."""
    text: str
    figures: list[Figure] = field(default_factory=list)
    pages: list[int] = field(default_factory=list)

    def page_of(self, offset: int) -> int:
        """The manuscript page the character at `offset` came from."""
        page = self.pages[0] if self.pages else 0
        for m in _MARK_RE.finditer(self.text):
            if m.start() > offset:
                break
            page = int(m.group(1))
        return page


# ---------------------------------------------------------------------------
# Page furniture
# ---------------------------------------------------------------------------

def strip_furniture(text: str) -> str:
    """Drop the page number and the running chapter title reprinted at the top."""
    lines = text.split("\n")
    while lines:
        head = lines[0].strip()
        if not head:
            lines.pop(0)
            continue
        if _PAGENUM_RE.match(head):
            lines.pop(0)
            continue
        # A running head is a short all-caps line with no sentence punctuation.
        letters = [c for c in head if c.isalpha()]
        if (letters and len(head) < 70
                and all(c.isupper() for c in letters)
                and not head.endswith((".", ":", "?"))):
            lines.pop(0)
            continue
        break
    return "\n".join(lines).strip()


def read_page(chapter: str, page: int) -> str | None:
    """
    Normalized text for a page, regenerated from the raw capture when needed.

    Only the raw OCR is committed; the .md is a pure derivation of it via
    ocrlib.normalize(), costing nothing and needing no GPU, so keeping both in
    git would be redundant. Regenerating here lets a fresh clone rebuild the
    chapter with no model and no scans.
    """
    cache = CACHE_ROOT / chapter
    md = cache / f"p{page:03d}.md"
    if md.exists():
        return md.read_text().strip()
    raw = cache / f"p{page:03d}.raw.txt"
    if not raw.exists():
        return None
    text = ocrlib.normalize("olmocr", raw.read_text())
    md.write_text(text)
    return text.strip()


# ---------------------------------------------------------------------------
# Assembly
# ---------------------------------------------------------------------------

_SENTENCE_END = ('.', '!', '?', '"', "'", ')', '…')

# A paragraph that is really a block, not prose: a display equation, a table, or
# a heading. These never continue across a seam.
_BLOCK_START_RE = re.compile(r"^\s*(?:\$\$|<table|#|\||!\[)", re.I)


# A display equation the transcriber left undelimited, e.g.
#   (13) \quad m_b = m_0 - m_f
# olmocr wraps most display math in $$...$$ but drops the delimiters when the
# equation number sits in the left margin — so exactly the numbered equations,
# the ones worth having, arrive as plain text.
_BARE_EQ_RE = re.compile(
    r"^[ \t]*(\(\d{1,3}[a-z]?\)[ \t]*(?:\\quad|\\qquad)?[ \t]*[^\n]*"
    r"(?:=|\\frac|\\int|\\sum|\\lim|\\vec)[^\n]*)$",
    re.M)


def promote_bare_equations(text: str) -> str:
    """
    Wrap undelimited display equations so they take the math path.

    Must run before paragraphs are collapsed to single spaces: the pattern is
    anchored to line starts, and the equation's own line is the only thing
    marking it as display rather than prose. Collapsing first left `(11) \\quad
    m_b = m_0 - \\int...` sitting in the middle of a sentence as raw LaTeX.

    Wrapped in blank lines rather than newlines so the equation becomes its own
    paragraph and cannot be joined to the prose around it.
    """
    return _BARE_EQ_RE.sub(lambda m: f"\n\n$${m.group(1).strip()}$$\n\n", text)


def _paragraphs(text: str) -> list[str]:
    """
    Blank-line-separated paragraphs, each collapsed to single spaces.

    Collapsing matters beyond tidiness: a paragraph's line wrapping is an
    artifact of the typewriter, and leaving it in means the same paragraph has
    two spellings — one with newlines in the page cache and one with spaces
    after joining — so nothing can be located in the stream by searching for it.
    Sentence splitting re-wraps everything anyway.
    """
    return [" ".join(p.split()) for p in re.split(r"\n\s*\n", text) if p.strip()]


def _continues(prev: str, nxt: str) -> bool:
    """
    Whether a paragraph ending page N and one opening page N+1 are the same one.

    Continuation is the default, and deliberately so. At a page seam the
    transcriber gives no signal either way — the manuscript marks a new paragraph
    by indenting, which normalization discards — so one of the two errors has to
    be chosen. A wrongly *joined* paragraph shows a `// === page N ===` comment
    sitting at the join, which is visible while editing and costs one keystroke
    to split. A wrongly *split* paragraph looks exactly like a real one and is
    invisible. So: join, unless the shape of either side says otherwise.

    `edit.py`'s continuity pass resolves the ambiguous ones properly, by looking
    at whether the incoming page's first line is indented.
    """
    if _BLOCK_START_RE.match(nxt) or _BLOCK_START_RE.match(prev):
        return False
    if prev.rstrip().endswith(("$$", ":")):
        return False
    # Ends mid-sentence: unambiguous, whatever the next page starts with.
    if not prev.rstrip().endswith(_SENTENCE_END):
        return True
    return True


def _join(prev: str, nxt: str) -> str:
    """Join two halves of one paragraph, healing a word split by the seam."""
    left, right = prev.rstrip(), nxt.lstrip()
    if left.endswith("-") and right[:1].islower():
        return left[:-1] + right          # "sub-" + "sequently"
    return f"{left} {right}"


def assemble(chapter: str) -> tuple[Stream, list[str]]:
    """The chapter body as one stream, plus warnings."""
    warnings: list[str] = []
    figures: list[Figure] = []
    seen_pages: list[int] = []

    # (text, page) for each prose paragraph, in document order.
    paras: list[tuple[str, int]] = []

    missing: list[int] = []
    for page in S.body_pages(chapter):
        text = read_page(chapter, page)
        if text is None:
            missing.append(page)
            continue
        text = promote_bare_equations(strip_furniture(text))
        if not text:
            continue
        seen_pages.append(page)

        first_on_page = True
        for para in _paragraphs(text):
            caption = _CAPTION_RE.match(para)
            if caption:
                # A caption plate is lifted out of the prose stream. Leaving it
                # in would drop a figure page into the middle of the sentence
                # that runs across it — ch1 p16/p17/p18 is exactly that.
                figures.append(Figure(caption.group(1),
                                      " ".join(caption.group(2).split()),
                                      page))
                continue
            if (first_on_page and paras
                    and _continues(paras[-1][0], para)):
                paras[-1] = (_join(paras[-1][0], para), paras[-1][1])
            else:
                paras.append((para, page))
            first_on_page = False

    # One line, not one per page: a chapter that has not been transcribed yet is
    # every page, and 196 identical warnings bury everything else.
    if missing:
        span = (f"{missing[0]}–{missing[-1]}" if len(missing) > 1
                else str(missing[0]))
        warnings.append(f"{len(missing)} page(s) not in cache ({span}) — "
                        f"run `ocr.py --chapter {chapter} --all` first")

    # Build the text, marking where each page's contribution begins. The mark is
    # placed at the join rather than at a paragraph boundary, so it lands inside
    # the sentence it interrupts and the emitter can put a comment line there.
    chunks: list[str] = []
    current_page = None
    for text, page in paras:
        if chunks:
            chunks.append("\n\n")
        if page != current_page:
            chunks.append(mark(page))
            current_page = page
        chunks.append(text)

    # Re-mark inside joined paragraphs: the loop above only marks a paragraph's
    # first page, so a paragraph spanning three pages would lose two marks. They
    # are recovered by re-walking the pages against the assembled text.
    stream = Stream("".join(chunks), figures, seen_pages)
    stream = _remark(chapter, stream, warnings)
    return stream, warnings


def _remark(chapter: str, stream: Stream, warnings: list[str]) -> Stream:
    """
    Insert a page mark at every seam, including seams inside a joined paragraph.

    Each page's first few words are located in the stream, searching forward from
    the previous page's position so a repeated phrase cannot match backwards. A
    page whose opening cannot be found is reported — it means its text was either
    dropped or altered during assembly, which is exactly what `coverage()` checks
    for at the other end.
    """
    text = strip_marks(stream.text)
    out: list[str] = []
    cursor = 0
    for page in stream.pages:
        raw = read_page(chapter, page)
        if raw is None:
            continue
        body = strip_furniture(raw)
        paras = [p for p in _paragraphs(body) if not _CAPTION_RE.match(p)]
        if not paras:
            continue
        # The first words of the page, normalized the way assembly normalizes.
        probe = " ".join(paras[0].split())[:40]
        if not probe:
            continue
        at = text.find(probe, cursor)
        if at < 0:
            # A seam healed a hyphenated word, so the page's own first token no
            # longer appears; try again from the second word.
            tail = probe.split(" ", 1)
            at = text.find(tail[1], cursor) if len(tail) > 1 else -1
        if at < 0:
            warnings.append(f"page {page}: could not locate its text in the stream")
            continue
        out.append(text[cursor:at])
        out.append(mark(page))
        cursor = at
    out.append(text[cursor:])
    return Stream("".join(out), stream.figures, stream.pages)


# ---------------------------------------------------------------------------
# Cutting into sections
# ---------------------------------------------------------------------------

@dataclass
class Cut:
    section: S.Section
    text: str
    page: int             # page the heading was found on, 0 if not found
    located: bool


def heading_pattern(title: str, sid: str) -> re.Pattern | None:
    """
    Match a heading as the transcriber rendered it.

    Observed forms, all from ch1: "1.1 Point-Mass and Rigid-Body Dynamics" on
    its own line, "3.1 _Aerodynamic Disturbances_" with emphasis markers, and a
    section whose number was dropped entirely — so the number is optional and
    the words tolerate underscores and asterisks between them.
    """
    if not title:
        return None
    words = r"[\s_*]+".join(re.escape(w) for w in title.split())
    return re.compile(
        rf"(?:^|\n|{re.escape(MARK_CLOSE)})[ \t]*(?:{re.escape(sid)}[.:]?[\s]*)?"
        rf"[_*]{{0,2}}{words}[_*]{{0,2}}[.:]?[ \t]*",
        re.I)


def _stem(word: str) -> str:
    """A word matched by its opening, so a heading tolerates inflection drift."""
    keep = max(3, round(len(word) * 0.7))
    return re.escape(word[:keep]) + r"\w*"


def _fuzzy_find(text: str, title: str, start: int) -> tuple[int, int]:
    """
    Last resort: match the heading by word stems, anchored to a line start.

    The section map is typed from the manuscript's own table of contents, which
    does not always agree with the heading printed over the section. ch1's map
    says "Descriptions of the Flight Force"; page 12 reads "Description of the
    Flight Forces". Matching whole words fails on that in both directions, so
    each word matches by its opening instead.

    Still anchored to a line start (or a page mark), because an unanchored match
    would happily find the heading's words inside a sentence discussing them.
    """
    words = [_stem(w) for w in title.split()]
    if len(words) < 2:
        return -1, -1
    body = r"[\s_*\W]{0,6}".join(words)
    pattern = re.compile(
        rf"(?:^|\n|{re.escape(MARK_CLOSE)})[ \t]*(?:\d+(?:\.\d+)*[.:]?\s*)?"
        rf"[_*]{{0,2}}{body}[_*]{{0,2}}[.:]?[ \t]*",
        re.I)
    match = pattern.search(text, start)
    return (match.start(), match.end()) if match else (-1, -1)


def cut(chapter: str, stream: Stream) -> tuple[list[Cut], list[str]]:
    """Slice the stream at each heading. Every character lands in one section."""
    warnings: list[str] = []
    secs = S.sections(chapter)

    # Locate every heading first, left to right, so a slice can run to the next
    # one. Searching forward from the previous match keeps a title that also
    # occurs in prose from matching before its own section.
    starts: list[int | None] = []
    ends: list[int] = []
    cursor = 0
    for sec in secs:
        pattern = heading_pattern(sec.title, sec.id)
        at, after = None, cursor
        if pattern is not None:
            match = pattern.search(stream.text, cursor)
            if match:
                at, after = match.start(), match.end()
        if at is None:
            loose_at, loose_after = _fuzzy_find(stream.text, sec.title, cursor)
            if loose_at >= 0:
                at, after = loose_at, loose_after
                warnings.append(
                    f"{sec.id} {sec.title!r}: heading matched only loosely — "
                    f"the scan reads {strip_marks(stream.text[loose_at:loose_after]).strip()!r}")
            else:
                warnings.append(
                    f"{sec.id} {sec.title!r}: heading NOT FOUND — its text will "
                    f"stay with the previous section")
        starts.append(at)
        ends.append(after)
        cursor = after

    cuts: list[Cut] = []
    for i, sec in enumerate(secs):
        if starts[i] is None:
            cuts.append(Cut(sec, "", 0, False))
            continue
        body_from = ends[i]
        body_to = len(stream.text)
        for j in range(i + 1, len(secs)):
            if starts[j] is not None:
                body_to = starts[j]
                break
        cuts.append(Cut(sec, stream.text[body_from:body_to],
                        stream.page_of(starts[i]), True))

    # Anything before the first located heading is front matter the section map
    # does not describe; report it rather than losing it silently.
    first = next((s for s in starts if s is not None), None)
    if first:
        stray = strip_marks(stream.text[:first]).strip()
        if len(stray.split()) > 20:
            warnings.append(f"{len(stray.split())} words precede the first heading; "
                            f"they are not in any section")
    return cuts, warnings


# ---------------------------------------------------------------------------
# Coverage
# ---------------------------------------------------------------------------

_WORD_RE = re.compile(r"[A-Za-z']+")

# Words the emitter legitimately consumes or produces, which would otherwise
# show up as differences on every run:
#   linkify turns "Figure 3" into "@fig:1-3" and "equation (2)" into #eqref(...)
#   units.convert turns "3 pounds" into #qty(3, "lb")
# Neither loses meaning, so neither is a coverage failure.
def _expected_loss() -> set[str]:
    import units
    # Unit spellings go too: "8 sec" becomes #qty(8, "s"), so the word "sec" is
    # legitimately absent from the output and its canonical form legitimately
    # present. Both sides of every alias are excluded.
    return ({"figure", "figures", "fig", "equation", "equations", "eq", "eqs",
             "section", "sections", "sec"}
            | set(units.ALIASES) | set(units.ALIASES.values()))


_EXPECTED_LOSS = _expected_loss()

# The minimum run worth reporting. Scattered single words are the ordinary
# residue of markup; a doubled or dropped half-paragraph is dozens in a row,
# and that is the failure this exists to catch.
_RUN = 8


def words_of(text: str) -> list[str]:
    return [w.lower() for w in _WORD_RE.findall(text)]


def _source_words(chapter: str) -> list[str]:
    """Body prose from the scan, in reading order, captions excluded."""
    out: list[str] = []
    for page in S.body_pages(chapter):
        text = read_page(chapter, page)
        if not text:
            continue
        for para in _paragraphs(promote_bare_equations(strip_furniture(text))):
            # Captions are deliberately moved to the paragraph that first
            # mentions them, so they land somewhere else in the output and would
            # read as one deletion plus one insertion. They are checked on their
            # own by `caption_drift()`, where position does not matter.
            if _CAPTION_RE.match(para):
                continue
            para = re.sub(r"\$\$.*?\$\$", " ", para, flags=re.S)
            para = re.sub(r"\$[^$]*\$", " ", para)
            out += words_of(para)
    return out


def _strip_captions(text: str) -> str:
    """Remove `caption: [...]` bodies, brackets balanced."""
    out: list[str] = []
    i = 0
    while True:
        at = text.find("caption: [", i)
        if at < 0:
            out.append(text[i:])
            return "".join(out)
        out.append(text[i:at])
        j, depth = at + len("caption: ["), 1
        while j < len(text) and depth:
            if text[j] == "[":
                depth += 1
            elif text[j] == "]":
                depth -= 1
            j += 1
        i = j


def _emitted_words(emitted: str) -> list[str]:
    text = emitted
    # The symbol table is hand-written front matter, not emitted prose, and its
    # meaning column would otherwise read as hundreds of unmatched words.
    if "table.hline()" in text:
        text = text.split("table.hline()")[-1]
    text = re.sub(r"//[^\n]*", " ", text)             # comments
    text = _strip_captions(text)                      # checked separately
    text = re.sub(r"\$[^$]*\$", " ", text)            # math
    text = re.sub(r"<[a-z]+:[^>]*>", " ", text)       # labels
    # String literals in argument position only — image paths, unit names,
    # equation numbers. A bare `"..."` strip would also swallow the book's own
    # quoted prose, and this manuscript quotes constantly: "weathercock",
    # "closed form", "drag due to lift".
    text = re.sub(r'([(,]\s*)"[^"]*"', r"\1 ", text)
    text = re.sub(r"#[a-z][a-z-]*", " ", text)        # call heads
    # Argument names (`caption:`, `dir:`) and nested calls (`image(`, `stack(`).
    # No whitespace is allowed between the name and its bracket: with `\s*` the
    # pattern reached across a blank line and swallowed the last prose word
    # before a `#eq(` on the next line, so promoting an equation looked like
    # deleting a word.
    text = re.sub(r"\b[a-z][a-z-]*(?=[(:])", " ", text)
    return words_of(text)


_FIG_LABEL_RE = re.compile(r"\s*\)\s*<fig:\d+-(\d+)>")


def _emitted_captions(text: str) -> dict[str, str]:
    """
    Figure number -> caption body, found by balancing brackets rather than regex.

    A caption can contain square brackets of its own — Figure 4's discusses
    integration and quotes `[A t]_(t=t_b)` — so `caption: \\[(.*?)\\]` finds the
    wrong end and the match runs on into the next figure. Only counting depth
    gets this right.
    """
    out: dict[str, str] = {}
    i = 0
    while True:
        at = text.find("caption: [", i)
        if at < 0:
            return out
        j, depth = at + len("caption: ["), 1
        while j < len(text) and depth:
            if text[j] == "[":
                depth += 1
            elif text[j] == "]":
                depth -= 1
            j += 1
        label = _FIG_LABEL_RE.match(text, j)
        if label:
            out[label.group(1)] = text[at + len("caption: ["):j - 1]
        i = j


def caption_drift(stream: Stream, emitted: str) -> list[str]:
    """
    Each emitted caption must still say what the scan said.

    Captions are excluded from the sequence diff because they are moved on
    purpose, so this is what keeps them honest — and captions are the one place
    where rewording would be hardest to notice and worst to allow, since a
    caption is the book explaining its own figure.
    """
    report: list[str] = []
    # Captions carry inline math ("In a time interval $\\Delta t$ the rocket…"),
    # which the emitter converts to Typst. Comparing it as prose would report
    # every such caption as changed, so both sides are compared prose-only.
    source = {fig.number: words_of(re.sub(r"\$[^$]*\$", " ", fig.caption))
              for fig in stream.figures}
    seen: set[str] = set()
    for number, body in _emitted_captions(emitted).items():
        seen.add(number)
        want = [w for w in source.get(number, []) if w not in _EXPECTED_LOSS]
        got = [w for w in words_of(re.sub(r'\$[^$]*\$|#[a-z][a-z-]*', " ", body))
               if w not in _EXPECTED_LOSS]
        if number not in source:
            report.append(f"Figure {number} has a caption in the output but none "
                          f"in the scan")
        elif want != got:
            missing = [w for w in want if w not in got][:6]
            report.append(f"Figure {number}'s caption differs from the scan"
                          + (f" — missing {', '.join(missing)}" if missing else ""))
    for number in source:
        if number not in seen:
            report.append(f"Figure {number}'s caption was transcribed but is not "
                          f"in the output")
    return report


_LABEL = r"(?:fig|eq|sec):[\d.a-z-]*[\da-z]"
# A label never *ends* with a dot — a trailing one belongs to the sentence —
# though a section label carries them inside (sec:2-3.2.1).
_DEF_RE = re.compile(rf"(?<!ref\()<({_LABEL})>")
_REF_RE = re.compile(rf"@({_LABEL})|ref\(<({_LABEL})>")


def defined_labels(typst: str) -> set[str]:
    """Labels the text defines. `<eq:2-1>` after an #eq() call is a definition."""
    return set(_DEF_RE.findall(typst))


def referenced_labels(typst: str) -> set[str]:
    """Labels the text points at, via @label or #ref(<label>)."""
    return {a or b for a, b in _REF_RE.findall(typst)}


def prose_words(typst: str) -> list[str]:
    """
    The words a reader would actually read, with all markup removed.

    `edit.py` compares this before and after applying the editor's changes. If
    it differs, the editor rewrote the book rather than marking it up, and the
    change is rejected — which is what makes it safe to let a local model edit
    the file at all.
    """
    return [w for w in _emitted_words(typst) if w not in _EXPECTED_LOSS]


def coverage(chapter: str, emitted: str) -> list[str]:
    """
    Every run of transcribed prose should appear in the output exactly once.

    This is the check the old pipeline lacked, and the reason the previous design
    could double a half-paragraph at a section boundary without anyone noticing
    until they read it. Rather than compare word counts — which drown in the
    ordinary residue of markup — it aligns the two word sequences and reports
    only contiguous runs, which is the shape the failure actually takes.
    """
    import difflib

    source = [w for w in _source_words(chapter) if w not in _EXPECTED_LOSS]
    out = [w for w in _emitted_words(emitted) if w not in _EXPECTED_LOSS]

    report: list[str] = []
    matcher = difflib.SequenceMatcher(None, source, out, autojunk=False)
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        gone, added = i2 - i1, j2 - j1
        # A `replace` covering two long, similar runs is the ordinary residue of
        # markup substitution — linkify and #qty change a word here and there
        # inside a paragraph, and the matcher reports the whole paragraph. Only
        # a lopsided replace, where one side all but vanished, is a real loss.
        if tag == "replace" and min(gone, added) * 3 > max(gone, added):
            continue
        if tag in ("delete", "replace") and gone >= _RUN:
            report.append(f"{gone} words of the scan are missing from the "
                          f"output: “{' '.join(source[i1:i1 + 12])}…”")
        if tag in ("insert", "replace") and added >= _RUN:
            report.append(f"{added} words in the output are not in the scan: "
                          f"“{' '.join(out[j1:j1 + 12])}…”")
    return report


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("chapter")
    ap.add_argument("--section", help="print one section's assembled text")
    ap.add_argument("--figures", action="store_true", help="list the caption plates")
    args = ap.parse_args()

    stream, warnings = assemble(args.chapter)
    cuts, cut_warnings = cut(args.chapter, stream)

    if args.section:
        for c in cuts:
            if c.section.id == args.section:
                print(strip_marks(c.text))
                return
        raise SystemExit(f"no section {args.section}")

    if args.figures:
        for fig in stream.figures:
            print(f"  Figure {fig.number:<4} p{fig.page:<4} {fig.caption[:80]}")
        return

    words = len(words_of(strip_marks(stream.text)))
    console.print(f"[bold]{args.chapter}[/]  {len(stream.pages)} pages, "
                  f"{words} words, {len(stream.figures)} figure captions")
    for c in cuts:
        indent = "  " * c.section.level
        where = f"p{c.page:<4}" if c.located else "[red]not found[/]"
        n = len(words_of(strip_marks(c.text)))
        console.print(f"{indent}{c.section.id:<8} {where} {n:>6}w  {c.section.title}")
    for w in warnings + cut_warnings:
        console.print(f"  [yellow]![/] {w}")


if __name__ == "__main__":
    main()
