#!/usr/bin/env python3
"""
Per-chapter correction rules, applied on every emit.

The point is that a fix is made once and never again. When the transcriber
gets the same symbol wrong on thirty pages, or a variable needs renaming
throughout, the edit belongs here rather than in thirty places in the Typst —
because re-emitting a section overwrites hand edits inside its markers, and
because the same misreading recurs on every chapter the model touches.

This is the generalisation of ch3's `mi_corrections.json`, which accumulated
357 verified fixes over that chapter.

Rules live in pipeline/corrections/<chapter>.toml and are applied in order:

    [[math]]     to converted Typst math only — never touches prose
    [[prose]]    to prose text only — never touches math
    [[any]]      to the finished section, math and prose alike

Each rule is a literal find/replace unless it sets `regex = true`.

    python pipeline/corrections.py ch1        # show the rules and a self-test
"""

from __future__ import annotations

import re
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path

CORRECTIONS_DIR = Path(__file__).parent / "corrections"


@dataclass(frozen=True)
class Rule:
    find: str
    replace: str
    regex: bool = False
    note: str = ""

    def apply(self, text: str) -> tuple[str, int]:
        if self.regex:
            out, n = re.subn(self.find, lambda _m, r=self.replace: r, text)
        else:
            n = text.count(self.find)
            out = text.replace(self.find, self.replace) if n else text
        return out, n


@dataclass
class Corrections:
    math: list[Rule]
    prose: list[Rule]
    any: list[Rule]
    hits: dict[str, int]

    def _run(self, rules: list[Rule], text: str) -> str:
        for rule in rules:
            text, n = rule.apply(text)
            if n:
                self.hits[rule.find] = self.hits.get(rule.find, 0) + n
        return text

    def fix_math(self, text: str) -> str:
        return self._run(self.math, text)

    def fix_prose(self, text: str) -> str:
        return self._run(self.prose, text)

    def fix_any(self, text: str) -> str:
        return self._run(self.any, text)

    @property
    def total(self) -> int:
        return sum(self.hits.values())


def _rules(entries: list) -> list[Rule]:
    out = []
    for entry in entries:
        if "find" not in entry:
            continue
        out.append(Rule(
            find=str(entry["find"]),
            replace=str(entry.get("replace", "")),
            regex=bool(entry.get("regex", False)),
            note=str(entry.get("note", "")),
        ))
    return out


def load(chapter: str) -> Corrections:
    path = CORRECTIONS_DIR / f"{chapter}.toml"
    if not path.exists():
        return Corrections([], [], [], {})
    with path.open("rb") as fh:
        data = tomllib.load(fh)
    return Corrections(_rules(data.get("math", [])),
                       _rules(data.get("prose", [])),
                       _rules(data.get("any", [])),
                       {})


if __name__ == "__main__":
    chapter = sys.argv[1] if len(sys.argv) > 1 else "ch1"
    c = load(chapter)
    for kind, rules in (("math", c.math), ("prose", c.prose), ("any", c.any)):
        for rule in rules:
            flag = " (regex)" if rule.regex else ""
            note = f"   # {rule.note}" if rule.note else ""
            print(f"  [{kind}]{flag} {rule.find!r} -> {rule.replace!r}{note}")
    if not (c.math or c.prose or c.any):
        print(f"  no rules yet — create {CORRECTIONS_DIR / f'{chapter}.toml'}")
