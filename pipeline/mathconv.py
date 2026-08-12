#!/usr/bin/env python3
"""
LaTeX -> Typst math conversion for the emitter.

Wraps the deterministic converter harvested from `convert_mi.py` (which was
built and proven over ch3) and fixes the failure modes that showed up on ch1's
corpus. The wrapper approach keeps `convert_mi.py` untouched, since it is still
the tool of record for ch3.

Fixes applied here, each measured against real OCR output:

  \\text{(21)} \\quad N ...   equation number extracted, not left inside the math
  C_{N\\alpha}                was C_("Nalpha") — a literal text run, not N·α
  \\{ ... \\}                  was \\( ... \\) — invalid Typst
  a \\\\ b                     line break was dropped, merging stacked equations
  \\frac{d m_e}{dt}           numerator 'd' was left as an identifier, not `dif`
  \\dots                      absent from the converter tables entirely
  C_{D0}                     canonicalised to the symbol table's C_D_0
"""

from __future__ import annotations

import re
from dataclasses import dataclass

import convert_mi as CM
import symtab

# Private-use codepoint: passes through the converter untouched and cannot
# collide with anything in the source text.
_LINEBREAK = "\ue000"
_TEXT_OPEN, _TEXT_CLOSE = "\ue001", "\ue002"
_TEXT_RUNS: list[str] = []

# Commands missing from convert_mi's tables that appear in this book.
_EXTRA_CMDS = {
    r"\dots": "dots.h",
    r"\vdots": "dots.v",
    r"\ddots": "dots.down",
    r"\cong": "tilde.equiv",
    r"\propto": "prop",
}

# A leading equation number the transcriber folded into the math, e.g.
# "\text{(21)} \quad N \sin \alpha" or "(21) \quad ...".
_EQNUM_RE = re.compile(
    r"^\s*(?:\\text\s*\{\s*\((\d{1,3}[a-z]?)\)\s*\}|\((\d{1,3}[a-z]?)\))"
    r"\s*(?:\\quad|\\qquad|\\,|\\;|~)?\s*"
)


@dataclass
class Converted:
    typst: str | None       # None if conversion failed
    eq_number: str | None   # manuscript number recovered from the expression
    unknown: list[str]      # identifiers absent from the symbol table


# ---------------------------------------------------------------------------
# Pre / post processing
# ---------------------------------------------------------------------------

def _preprocess(latex: str) -> str:
    s = latex.strip()

    # Protect LaTeX line breaks: convert_mi maps "\\" -> "\ " -> " ", silently
    # merging stacked equations into one line.
    s = re.sub(r"\\\\(?!\w)", _LINEBREAK, s)

    # \{ ... \} is a literal brace group; the escapes survive conversion and
    # produce invalid Typst. Bare braces convert to parentheses correctly.
    s = s.replace(r"\{", "(").replace(r"\}", ")")

    # A command butted against a preceding letter inside a subscript gets
    # swallowed into a quoted text run: C_{N\alpha} -> C_("Nalpha").
    s = re.sub(r"([A-Za-z0-9])(\\[A-Za-z]+)", r"\1 \2", s)

    # \text{and} must survive as a quoted Typst run. convert_mi strips the
    # wrapper, leaving a bare word that _split_implicit_products then shreds
    # into "a n d". Protect the content and restore it quoted afterwards.
    def _stash(m):
        _TEXT_RUNS.append(m.group(1))
        return f"{_TEXT_OPEN}{len(_TEXT_RUNS) - 1}{_TEXT_CLOSE}"
    s = re.sub(r"\\(?:text|mathrm|textrm)\s*\{([^{}]*)\}", _stash, s)

    # Lambda replacements: these strings contain single backslashes, which
    # re.sub would otherwise interpret as escape sequences.
    for cmd in _EXTRA_CMDS:
        s = re.sub(rf"{re.escape(cmd)}(?![A-Za-z])",
                   lambda _m, c=cmd: f" {c} ", s)

    return s


def _postprocess(typst: str) -> str:
    s = typst

    for cmd, rep in _EXTRA_CMDS.items():
        s = s.replace(cmd, rep)

    # Differentials in a fraction numerator: (d m_e)/(dif t) -> (dif m_e)/(dif t).
    # convert_mi special-cases "dt" but not a spaced or leading "d".
    s = re.sub(r"\(d\s+(?=[A-Za-z])", "(dif ", s)
    # A bare differential: dm_e, dt, dx. Requires the letter after `d` to be
    # the last one, so multi-letter names (dots.h, deg, dif, dot) are untouched.
    s = re.sub(r"(?<![A-Za-z])d([A-Za-z])(?![A-Za-z])", r"dif \1", s)

    # Slash-form differentials: "dif m_e/dif t" parses as dif (m_e/dif) t
    # because / binds tighter than the implicit product. The \frac form is
    # already parenthesised; this fixes the ones the transcriber wrote inline.
    s = _DIFF_SLASH_RE.sub(lambda m: f"({m.group('num')})/(dif {m.group('den')})", s)

    s = _split_implicit_products(s)
    for i, run in enumerate(_TEXT_RUNS):
        s = s.replace(f"{_TEXT_OPEN}{i}{_TEXT_CLOSE}", f'"{run}"')
    _TEXT_RUNS.clear()
    s = s.replace(_LINEBREAK, " \\ ")
    s = re.sub(r"\s+([,;)\]])", r"\1", s)   # " ," -> "," from command spacing
    return re.sub(r"[ \t]{2,}", " ", s).strip()


_ATOM = r"(?:dot\([A-Za-z]\)|[A-Za-z])(?:_(?:\([^()]*\)|\"[^\"]*\"|[A-Za-z0-9]+))?"
_DIFF_SLASH_RE = re.compile(
    rf"(?P<num>(?:dif\s+)?{_ATOM})\s*/\s*dif\s+(?P<den>{_ATOM})")


def _known_names() -> set[str]:
    """Every bare word Typst math accepts as a name rather than a product."""
    names = set(CM.GREEK.values()) | set(CM.SIMPLE_CMDS.values())
    names |= {v for v in CM.BRACE_CMDS.values() if v}
    names |= {"dif", "dot", "op", "upright", "text", "bold", "italic", "cal",
              "frak", "mono", "bb", "arrow", "hat", "tilde", "overline",
              "underline", "sqrt", "root", "abs", "norm", "floor", "ceil",
              "space", "quad", "thin", "med", "thick", "wide"}
    # Multi-part names like "dots.h" are matched on their first component.
    return {n.split(".")[0] for n in names if n and n[0].isalpha()}


_KNOWN_NAMES = None
_LETTER_RUN_RE = re.compile(r'"[^"]*"|[A-Za-z]{2,}')


def _split_implicit_products(typst: str, extra_known: set[str] | None = None) -> str:
    """
    Space out multi-letter runs that Typst would read as one identifier.

    LaTeX renders `At` as the product A·t; Typst treats it as a variable named
    "At" and fails with "unknown variable". Anything that is not a known
    function, Greek letter, or declared symbol has to be split — which is
    exactly what Typst's own error hint recommends.
    """
    global _KNOWN_NAMES
    if _KNOWN_NAMES is None:
        _KNOWN_NAMES = _known_names()
    known = _KNOWN_NAMES | (extra_known or set())

    def replace(match: re.Match) -> str:
        run = match.group(0)
        if run.startswith('"') or run in known:
            return run          # quoted text and real names pass through
        return " ".join(run)

    return _LETTER_RUN_RE.sub(replace, typst)


# ---------------------------------------------------------------------------
# Symbol canonicalisation
# ---------------------------------------------------------------------------

# Typst operators and functions that legitimately take a subscript as a limit
# or index, and are therefore never symbol-table entries.
_OPERATORS = {
    "sum", "product", "integral", "lim", "max", "min", "sup", "inf", "log",
    "ln", "exp", "det", "deg", "sin", "cos", "tan", "cot", "sec", "csc",
    "arg", "dim", "gcd", "mod", "Pr",
}

_TOKEN_RE = re.compile(
    r'[A-Za-z][A-Za-z0-9]*(?:_(?:\([^()]*\)|"[^"]*"|[A-Za-z0-9]+))+'
)


def _normkey(s: str) -> str:
    """Collapse a Typst identifier to a spelling-independent key."""
    return re.sub(r'[_(){}"\s]', "", s).lower()


def build_symbol_index(symbols: list[symtab.Symbol]) -> dict[str, str]:
    """normalised key -> canonical Typst spelling, from the chapter's table."""
    index: dict[str, str] = {}
    for sym in symbols:
        key = _normkey(sym.typst)
        if key and key not in index:
            index[key] = sym.typst.strip()
    return index


def canonicalise(typst: str, index: dict[str, str]) -> tuple[str, list[str]]:
    """
    Rewrite subscripted identifiers to the symbol table's spelling.

    The transcriber produces variant LaTeX for the same symbol — C_{D0},
    C_{D_0}, C_{D 0} all mean the same thing — which the converter turns into
    three different Typst spellings. Normalising to the table's declared form
    is what makes the output consistent across a whole chapter.

    Returns the rewritten expression and any subscripted identifiers that are
    not in the table at all, which are either OCR errors or table gaps.
    """
    unknown: list[str] = []

    def replace(match: re.Match) -> str:
        token = match.group(0)
        key = _normkey(token)
        if key in index:
            return index[key]
        # Not every subscripted token is a symbol. Operators carry limits
        # (sum_(i=1), integral_0, lim_(n -> infinity)), and an indexed variant
        # of a known symbol is legitimate (F_1, F_i, t_i all derive from
        # symbols the table does declare). Flagging those would bury the
        # genuine finds — a symbol the model invented — in noise.
        base = re.match(r"[A-Za-z][A-Za-z0-9]*", token)
        base_name = base.group(0) if base else ""
        if base_name in _OPERATORS or _normkey(base_name) in index:
            return token
        unknown.append(token)
        return token

    return _TOKEN_RE.sub(replace, typst), unknown


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

_corrections = None


def convert(latex: str, index: dict[str, str] | None = None) -> Converted:
    global _corrections
    if _corrections is None:
        _corrections = CM.load_corrections()

    body = latex.strip()
    eq_number = None
    match = _EQNUM_RE.match(body)
    if match:
        eq_number = match.group(1) or match.group(2)
        body = body[match.end():]

    try:
        raw = CM.latex_to_typst(_preprocess(body), _corrections)
    except Exception:
        raw = None
    if not raw:
        return Converted(None, eq_number, [])

    out = _postprocess(raw)
    unknown: list[str] = []
    if index:
        out, unknown = canonicalise(out, index)
    return Converted(out, eq_number, unknown)


if __name__ == "__main__":
    import sys
    from pathlib import Path

    chapter_typ = sys.argv[1] if len(sys.argv) > 1 else \
        "../src/chapters/ch1-flight-dynamics.typ"
    idx = build_symbol_index(symtab.parse(Path(chapter_typ)))
    for line in sys.stdin:
        line = line.strip()
        if line:
            r = convert(line, idx)
            print(f"{line}\n  -> {r.typst}"
                  f"{f'   [eq {r.eq_number}]' if r.eq_number else ''}"
                  f"{f'   unknown: {r.unknown}' if r.unknown else ''}")
