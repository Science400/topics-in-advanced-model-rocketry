#!/usr/bin/env python3
"""
Repair the LaTeX reflexes a model leaves in otherwise-good Typst.

A frontier model asked for Typst produces Typst, but a handful of LaTeX habits
survive — and because most are runtime errors rather than parse errors, Typst
reports them one at a time, so a chapter with five of them takes five compile
rounds to diagnose. This applies every fix at once, inside maths only, and
reports what it changed.

Measured on ch2 (196 pages, 3,691 lines, one model): 9 fixes in total. That is
the entire distance between "does not compile" and a finished chapter.

    python pipeline/typstfix.py src/chapters/ch2-hosted.typ
    python pipeline/typstfix.py src/chapters/ch2-hosted.typ --dry-run
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

# Units that read as bare identifiers in maths and must be quoted text runs.
_UNITS = ("cm", "mm", "km", "kg", "sec", "gm", "ft", "lb", "oz", "in", "dyn")

# (name, pattern, replacement) — all applied inside $...$ only, never inside a
# quoted run within it.
FIXES: list[tuple[str, str, str]] = [
    ("bare superscript: `$^2$` has no base", r"^(\^|_)", r'""\1'),
    ("LaTeX \\left / \\right: Typst sizes delimiters itself",
     r"\bleft\s*(?=[\[\(\|\{])", ""),
    ("", r"\bright\s*(?=[\]\)\|\}])", ""),
    ("letter-digit run: `s1` reads as a variable", r"([A-Za-z])(\d)", r"\1 \2"),
    ("unit as a bare identifier in maths",
     rf"(?<![A-Za-z\"])({'|'.join(_UNITS)})(?![A-Za-z\"])", r'"\1"'),
]


def fix_math(text: str) -> tuple[str, dict[str, int]]:
    counts: dict[str, int] = {}

    def one_span(match: re.Match) -> str:
        body = match.group(1)
        parts = re.split(r'("[^"]*")', body)
        for i, part in enumerate(parts):
            if part.startswith('"'):
                continue
            for name, pattern, repl in FIXES:
                part, n = re.subn(pattern, repl, part)
                if n and name:
                    counts[name] = counts.get(name, 0) + n
            parts[i] = part
        return "$" + "".join(parts) + "$"

    # `$^2$` has to be handled before the span split, since the `^` sits right
    # after the opening dollar and would otherwise be the span's first char.
    text, n = re.subn(r"\$(\^|_)", r'$""\1', text)
    if n:
        counts["bare superscript: `$^2$` has no base"] = n
    return re.sub(r"\$([^$]*)\$", one_span, text), counts


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+", type=Path)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    for path in args.files:
        fixed, counts = fix_math(path.read_text())
        total = sum(counts.values())
        print(f"{path}: {total} fix(es)")
        for name, n in sorted(counts.items(), key=lambda kv: -kv[1]):
            print(f"   {n:4}  {name}")
        if not args.dry_run and total:
            path.write_text(fixed)


if __name__ == "__main__":
    main()
