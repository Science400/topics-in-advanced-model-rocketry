#!/usr/bin/env python3
"""
Parse a chapter's symbol table out of its Typst source.

The book opens each chapter with a symbol table, so that table is hand-typed
into the chapter as content and this module reads it back — one artifact
serving as both published content and pipeline configuration. Nothing has to
be kept in sync, and the canonical Typst spelling of every symbol is declared
rather than inferred.

The table is found as the first `#symbol-table(...)` call, falling back to the
first `#table(...)` in the file. Rows are `[$math$], [meaning],` pairs; header
cells and rules are ignored because they are not `$`-delimited.

    python pipeline/symtab.py src/chapters/ch1-flight-dynamics.typ
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

_OPEN = {"(": ")", "[": "]", "{": "}"}
_CLOSE = {v: k for k, v in _OPEN.items()}


@dataclass(frozen=True)
class Symbol:
    typst: str      # canonical Typst math, e.g. 'A_r' or 'arrow(F)'
    meaning: str    # right-hand column, Typst markup as written
    latex: str      # best-effort LaTeX rendering, for OCR prompts


# ---------------------------------------------------------------------------
# Balanced scanning
# ---------------------------------------------------------------------------

def _skip_string(src: str, i: int) -> int:
    """Given src[i] == '"', return the index just past the closing quote."""
    i += 1
    while i < len(src):
        if src[i] == "\\":
            i += 2
            continue
        if src[i] == '"':
            return i + 1
        i += 1
    return i


def _call_body(src: str, name: str) -> tuple[str, int] | None:
    """Return (body, start_index) for the first `#name(...)`, paren-balanced."""
    for match in re.finditer(rf"#{re.escape(name)}\s*\(", src):
        start = match.end()          # just inside the opening paren
        depth, i = 1, start
        while i < len(src) and depth:
            ch = src[i]
            if ch == '"':
                i = _skip_string(src, i)
                continue
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
            i += 1
        if depth == 0:
            return src[start:i - 1], start
    return None


def _bracket_groups(body: str) -> list[str]:
    """Contents of every top-level [...] group, in order."""
    groups: list[str] = []
    i, depth, start = 0, 0, 0
    while i < len(body):
        ch = body[i]
        if ch == '"':
            i = _skip_string(body, i)
            continue
        if ch in _OPEN:
            if ch == "[" and depth == 0:
                start = i + 1
            depth += 1
        elif ch in _CLOSE:
            depth -= 1
            if ch == "]" and depth == 0:
                groups.append(body[start:i])
        i += 1
    return groups


# ---------------------------------------------------------------------------
# Typst math -> LaTeX, for injecting into OCR prompts
# ---------------------------------------------------------------------------

_GREEK = [
    "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
    "iota", "kappa", "lambda", "mu", "nu", "xi", "pi", "rho", "sigma", "tau",
    "upsilon", "phi", "chi", "psi", "omega",
]
_GREEK += [g.capitalize() for g in _GREEK]

_WORD_MAP = {
    "infinity": r"\infty",
    "integral": r"\int",
    "dif": "d",
    "dot": r"\cdot",
    "dots.h": r"\dots",
    "space.en": " ",
    "->": r"\to",
    "lim": r"\lim",
}


def to_latex(typst: str) -> str:
    """Best-effort Typst math -> LaTeX. Only needs to be good enough to prompt with."""
    out = typst
    out = re.sub(r"\barrow\(([^()]*)\)", r"\\vec{\1}", out)
    out = re.sub(r"\bdot\(([^()]*)\)", r"\\dot{\1}", out)
    out = re.sub(r"\bupright\(([^()]*)\)", r"\\mathrm{\1}", out)
    # Replacements are passed as lambdas: these strings contain single
    # backslashes, which re.sub would otherwise read as escape sequences.
    # The lookbehind excludes a backslash so a word is not rewritten inside a
    # command this function already produced: \dot{m} must not become \\cdot{m}.
    for word, rep in _WORD_MAP.items():
        out = re.sub(rf"(?<![A-Za-z.\\]){re.escape(word)}(?![A-Za-z])",
                     lambda _m, r=rep: r, out)
    for greek in _GREEK:
        out = re.sub(rf"(?<![A-Za-z\\]){greek}(?![A-Za-z])",
                     lambda _m, g=greek: "\\" + g, out)
    # _(...) and ^(...) become _{...} / ^{...}
    out = re.sub(r"([_^])\(([^()]*)\)", r"\1{\2}", out)
    return re.sub(r"\s+", " ", out).strip()


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

_MATH_SPAN_RE = re.compile(r"\$([^$]+)\$")


def _split_cell(cell: str) -> list[str]:
    """
    The symbols declared by one left-hand cell.

    Usually one, but the book groups symbols that share a meaning into a single
    row — `[$A$, $B$, $C$], [space axes]` declares three. Matching the cell as
    one `$...$` span reads that as a symbol literally named `A$, $B$, $C`, which
    then poisons both the OCR prompt and the canonicalisation index.

    A comma *inside* a single pair of dollars is different and must not split:
    `$F_1, dots.h, F_8$` is one symbol whose name contains commas. So the cell
    splits only when it is entirely a run of `$...$` spans joined by commas.
    """
    spans = list(_MATH_SPAN_RE.finditer(cell))
    if not spans:
        return []
    # Whatever sits outside the spans decides whether this is a list or a
    # single symbol that merely looks like one.
    between = _MATH_SPAN_RE.sub("", cell)
    if between.strip(", \t\r\n"):
        return []
    return [m.group(1).strip() for m in spans if m.group(1).strip()]


def table_span(src: str) -> tuple[int, int] | None:
    """
    (start, end) of the whole symbol-table call in a chapter source.

    `emit.py` regenerates the chapter body in place and needs to know where the
    hand-written front matter stops. The symbol table is the last of it, so its
    closing paren is the boundary — which means the body can be rewritten with
    no marker comments delimiting it, since the file's own structure says where
    it begins.
    """
    for name in ("symbol-table", "table"):
        found = _call_body(src, name)
        if found is None:
            continue
        body, start = found
        # `start` points just inside the opening paren. Walk back to the "#" of
        # the call rather than assuming its width — `#table (` is legal Typst.
        head = src.rfind(f"#{name}", 0, start)
        if head < 0:
            continue
        return head, start + len(body) + 1
    return None


def parse(path: str | Path) -> list[Symbol]:
    src = Path(path).read_text()
    found = _call_body(src, "symbol-table") or _call_body(src, "table")
    if found is None:
        return []
    groups = _bracket_groups(found[0])

    symbols: list[Symbol] = []
    i = 0
    while i < len(groups):
        cell = groups[i].strip()
        names = _split_cell(cell) if i + 1 < len(groups) else []
        if names:
            meaning = " ".join(groups[i + 1].split())
            for name in names:
                symbols.append(Symbol(name, meaning, to_latex(name)))
            i += 2
            continue
        i += 1
    return symbols


def prompt_block(symbols: list[Symbol], limit: int | None = None) -> str:
    """
    Render the table as a compact LaTeX | meaning list for an OCR prompt.

    Pass the whole table. Trimming it to the "informative" symbols — dropping
    bare single letters like A, C, t, x — was measured to be actively harmful:
    with the full 56-symbol block olmocr transcribes a figure page as caption
    only (470/474 chars over two runs), which is what this book wants, and with
    the 39-symbol block it transcribes the figure's internal data table instead
    (1027/1027). The long list appears to bias the model toward reading the page
    as prose and math rather than exhaustively reading graph annotations.
    """
    rows = symbols[:limit] if limit else symbols
    return "\n".join(f"  {s.latex}  —  {s.meaning}" for s in rows)


def typst_set(symbols: list[Symbol]) -> set[str]:
    """Canonical Typst spellings, for validating emitted math later."""
    return {s.typst for s in symbols}


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    syms = parse(sys.argv[1])
    print(f"{len(syms)} symbols\n")
    for s in syms:
        print(f"  {s.typst:<28} {s.latex:<28} {s.meaning[:44]}")
