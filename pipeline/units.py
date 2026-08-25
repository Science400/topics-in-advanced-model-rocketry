#!/usr/bin/env python3
"""
Convert measurements in prose to #qty(), and awkward numerals to #num().

The hard part is not the regex, it is knowing which unit strings actually work.
unify does not fail on a unit it does not recognise — it silently renders the
number and drops the unit:

    #qty(1, "in")      ->  "1"          the inches vanish
    #qty(1, "oz")      ->  "1"
    #qty(1, "sec")     ->  "1"
    #qty(1, "lb ft")   ->  "1 ft"       the pounds vanish

All four of those compile clean. So a compile gate cannot police this, and a
model guessing at unit spellings will quietly delete units from the book — which
is how `#qty("3", "Newton")` reached ch1's page 20. Every unit used here is
therefore verified by rendering: `check()` measures `qty(1, u)` against a bare
`1` inside Typst and panics if the unit added no width.

The compound rule follows from the same probe. `preamble.typ` special-cases a
handful of units unify lacks (lb, psi, slug, fps, ...) by passing them through
`rawunit`, and that lookup matches the whole string — so "lb" works and "lb ft"
does not. Compounds are allowed only between units unify itself knows.

    python pipeline/units.py --check      re-verify against the current preamble
    python pipeline/units.py --show       print the accepted spellings
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import tempfile
from pathlib import Path

_HERE = Path(__file__).parent
REPO_ROOT = _HERE.parent
PREAMBLE = REPO_ROOT / "src" / "preamble.typ"
VERIFIED_PATH = _HERE / "cache" / "units-verified.json"

# Manuscript spelling -> the unit string to write. Only entries whose target
# passes check() are ever used; the rest are reported, never guessed at.
#
# Written out longhand rather than derived, because the mapping is a judgement
# about this book's prose ("sec" means seconds, "in." means inches) and not a
# property of unify.
ALIASES: dict[str, str] = {
    # force
    "newton": "N", "newtons": "N", "n": "N",
    "pound": "lb", "pounds": "lb", "lb": "lb", "lbs": "lb",
    "pound-force": "lbf", "lbf": "lbf",
    # length
    "foot": "ft", "feet": "ft", "ft": "ft",
    "inch": "in", "inches": "in", "in": "in",
    "meter": "m", "meters": "m", "metre": "m", "metres": "m", "m": "m",
    "centimeter": "cm", "centimeters": "cm", "cm": "cm",
    "millimeter": "mm", "millimeters": "mm", "mm": "mm",
    "kilometer": "km", "kilometers": "km", "km": "km",
    # mass
    "gram": "g", "grams": "g", "gm": "g", "g": "g",
    "kilogram": "kg", "kilograms": "kg", "kg": "kg",
    "ounce": "oz", "ounces": "oz", "oz": "oz",
    "slug": "slug", "slugs": "slug",
    # time
    "second": "s", "seconds": "s", "sec": "s", "secs": "s", "s": "s",
    # pressure
    "psi": "psi",
    # rotation / angle
    "rpm": "rpm",
    "degree": "deg", "degrees": "deg",
    # speed
    "fps": "fps",
}

# Compounds are written as they appear and split on "/" and " ". Both sides must
# be unify-native, which check() decides.
_COMPOUND_SEP_RE = re.compile(r"[ /]")


def raw_units() -> set[str]:
    """The units preamble.typ patches in because unify lacks them."""
    src = PREAMBLE.read_text()
    block = re.search(r"#let _raw-units\s*=\s*\((.*?)\n\)", src, re.S)
    if not block:
        return set()
    return set(re.findall(r'"([^"]+)"\s*:', block.group(1)))


# ---------------------------------------------------------------------------
# Verification by rendering
# ---------------------------------------------------------------------------

# A unit unify cannot possibly know, used to learn what "rendered nothing" costs.
# `qty` still emits the separating space, so the empty case is not zero width —
# measured at 2.218pt in EB Garamond, exactly what "in" and "oz" also measure.
# Calibrating against this instead of a hard-coded threshold means the check
# survives a change of font or of unify's spacing.
_ABSENT = "zzqqxx"

_PROBE = """#import "/src/preamble.typ": qty
#set page(width: 40cm, height: auto)
#context {{
  let bare = measure[1].width
  let empty = measure(qty(1, "{absent}")).width - bare
  let bad = ()
  for u in ({units}) {{
    if measure(qty(1, u)).width - bare <= empty + 1pt {{ bad.push(u) }}
  }}
  if bad.len() > 0 {{ panic("RENDERS-AS-NOTHING " + bad.join(" ")) }}
}}
"""


def check(units: list[str]) -> tuple[list[str], list[str]]:
    """
    Split `units` into those that render a visible unit and those that do not.

    Typst does the measuring, because only Typst knows what unify emitted. One
    compile covers every unit: the failures are collected and reported together
    through a single panic, rather than aborting on the first.
    """
    if not units:
        return [], []
    listed = ", ".join(f'"{u}"' for u in units) + ("," if len(units) == 1 else "")
    probe = _HERE / "cache" / "_unitprobe.typ"
    probe.parent.mkdir(parents=True, exist_ok=True)
    try:
        probe.write_text(_PROBE.format(absent=_ABSENT, units=listed))
        with tempfile.TemporaryDirectory() as tmp:
            done = subprocess.run(
                ["typst", "compile", "--root", str(REPO_ROOT),
                 str(probe), str(Path(tmp) / "probe.pdf")],
                capture_output=True, text=True, timeout=180)
    finally:
        probe.unlink(missing_ok=True)

    if done.returncode == 0:
        return list(units), []
    found = re.search(r"RENDERS-AS-NOTHING ([^\"\n]*)", done.stdout + done.stderr)
    if not found:
        raise SystemExit("unit probe failed for an unexpected reason:\n"
                         + (done.stderr or done.stdout))
    bad = found.group(1).split()
    return [u for u in units if u not in bad], bad


def verified(refresh: bool = False) -> set[str]:
    """Accepted unit strings, verified against the current preamble."""
    if not refresh and VERIFIED_PATH.exists():
        cached = json.loads(VERIFIED_PATH.read_text())
        if cached.get("preamble_bytes") == PREAMBLE.stat().st_size:
            return set(cached["units"])
    candidates = sorted(set(ALIASES.values()))
    ok, _bad = check(candidates)
    VERIFIED_PATH.parent.mkdir(parents=True, exist_ok=True)
    VERIFIED_PATH.write_text(json.dumps(
        {"preamble_bytes": PREAMBLE.stat().st_size, "units": sorted(ok)}, indent=2))
    return set(ok)


# ---------------------------------------------------------------------------
# Conversion
# ---------------------------------------------------------------------------

# "3.5 lb", "100 N", "12 ft/s". The unit is a word, so this cannot fire on
# "3 rockets" unless "rockets" is in ALIASES, which it is not.
#
# A trailing period is deliberately NOT part of the match. It is ambiguous —
# "a 2 in. body tube" abbreviates inches, "as high as 100 N." ends a sentence —
# and it does not need resolving: leaving the period as ordinary text after the
# call renders both correctly, as "2 in." and "100 N." respectively.
# The value accepts grouped thousands so "12,500 feet" comes out as one
# quantity rather than a #num next to a loose word — this book quotes a lot of
# altitudes that way.
_MEASURE_RE = re.compile(
    r"(?<![\w.])(\d{1,3}(?:,\d{3})+|\d+(?:\.\d+)?)\s+([A-Za-z]+(?:/[A-Za-z]+)?)(?![\w/])")

# Numerals worth wrapping in #num: grouped thousands and scientific notation.
# A plain small number is left alone — "10" reads better as 10.
_SCI_RE = re.compile(
    r"(?<![\w.])(\d+(?:\.\d+)?)\s*(?:[x×]\s*10|E|e)\s*\^?\s*"
    r"\{?([+-]?\d+)\}?(?![\w])")
_GROUPED_RE = re.compile(r"(?<![\w.])(\d{1,3}(?:,\d{3})+)(?![\w])")


def canonical(word: str) -> str | None:
    """
    The unit string for a word as the manuscript spells it, or None.

    Compounds are mapped a side at a time, so "ft/s", "feet/second" and "ft/sec"
    all land on "ft/s" — but only if every side is a unit. "lb/hour" stays prose
    because "hour" is not in the table, which is the intended outcome: a unit
    that is half-guessed is worse than one left alone.
    """
    parts = [p for p in word.split("/") if p]
    if not parts:
        return None
    mapped = [ALIASES.get(p.rstrip(".").lower()) for p in parts]
    if any(m is None for m in mapped):
        return None
    return "/".join(mapped)


def candidates(text: str) -> set[str]:
    """Every unit string this text would use, for verifying before converting."""
    found = set()
    for match in _MEASURE_RE.finditer(text):
        unit = canonical(match.group(2))
        if unit:
            found.add(unit)
    return found


def prepare(text: str) -> set[str]:
    """
    Verify, by rendering, every unit this text will actually use.

    Called once per chapter before converting. Compounds have to be checked as
    written rather than a side at a time: `preamble.typ` patches in the units
    unify lacks by matching the whole string, so "lb" renders and "lb ft" throws
    the pounds away. Only the exact string that will be emitted proves anything.
    """
    wanted = sorted(candidates(text) | set(ALIASES.values()))
    ok, bad = check(wanted)
    if bad:
        from term import console
        console.print(f"  [yellow]{len(bad)} unit(s) render as nothing and will "
                      f"stay prose: {', '.join(bad)}[/]")
    return set(ok)


def convert(text: str, accepted: set[str]) -> tuple[str, list[str]]:
    """
    Rewrite measurements and awkward numerals. Returns (text, flags).

    Anything not confidently recognised is reported rather than converted. A
    wrong #qty deletes a unit from the book silently; a flag costs one look.
    """
    flags: list[str] = []

    def measurement(match: re.Match) -> str:
        value, word = match.group(1), match.group(2)
        unit = canonical(word)
        if unit is None:
            return match.group(0)          # an ordinary noun; not a measurement
        if unit not in accepted:
            flags.append(f"unit {word!r} maps to {unit!r}, which renders as "
                         f"nothing — left as prose: {match.group(0)!r}")
            return match.group(0)
        return f'#qty({value.replace(",", "")}, "{unit}")'

    def scientific(match: re.Match) -> str:
        return f'#num("{match.group(1)}e{match.group(2)}")'

    def grouped(match: re.Match) -> str:
        return f'#num("{match.group(1).replace(",", "")}")'

    # Order matters. Scientific notation first, since "10^-6" contains numerals
    # the others would claim. Measurements next, so a grouped value carrying a
    # unit becomes one #qty. Bare grouped numerals last, as the leftovers.
    text = _SCI_RE.sub(scientific, text)
    text = _MEASURE_RE.sub(measurement, text)
    text = _GROUPED_RE.sub(grouped, text)
    return text, flags


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true",
                    help="re-verify every unit by rendering it")
    ap.add_argument("--show", action="store_true")
    args = ap.parse_args()

    if args.check or not VERIFIED_PATH.exists():
        candidates = sorted(set(ALIASES.values()))
        ok, bad = check(candidates)
        print(f"{len(ok)}/{len(candidates)} units render a visible unit")
        if bad:
            print("\nThese render as a bare number — the unit is silently dropped:")
            for unit in bad:
                spellings = [k for k, v in ALIASES.items() if v == unit]
                print(f"  {unit:<6} (from {', '.join(sorted(spellings))})")
            print("\nAdd them to _raw-units in src/preamble.typ, or they stay prose.")
        verified(refresh=True)

    if args.show:
        accepted = verified()
        print(f"\npreamble raw units: {', '.join(sorted(raw_units()))}")
        print(f"accepted: {', '.join(sorted(accepted))}")


if __name__ == "__main__":
    main()
