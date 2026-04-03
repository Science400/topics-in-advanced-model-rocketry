#!/usr/bin/env python3
"""Interactive converter: #mi() / #mitex() → native Typst math.

Usage:
    python convert_mi.py <file.typ>                   # all mi/mitex calls
    python convert_mi.py <file.typ> --lines 220-280   # restrict to line range
    python convert_mi.py <file.typ> --batch           # non-interactive batch mode
    python convert_mi.py <file.typ> --batch --dry-run # batch preview only

Interactive controls:
    y  accept proposed conversion
    n  skip (leave as-is)
    e  edit — type your own replacement, end with a blank line
    q  quit (writes all accepted changes so far)

The file is updated after each accepted change, so it stays compilable.
"""

import json
import re
import sys
import argparse
from pathlib import Path

# ── Corrections cache ────────────────────────────────────────────────────────

CORRECTIONS_PATH = Path(__file__).parent / "mi_corrections.json"


def load_corrections() -> dict[str, str]:
    """Load saved latex→typst_inner mappings from disk."""
    if CORRECTIONS_PATH.exists():
        return json.loads(CORRECTIONS_PATH.read_text())
    return {}


def save_correction(corrections: dict, latex_raw: str, typst_inner: str) -> None:
    """Persist a new latex→typst_inner mapping."""
    key = _normalize(latex_raw).strip()
    corrections[key] = typst_inner
    CORRECTIONS_PATH.write_text(json.dumps(corrections, indent=2, ensure_ascii=False))


def lookup_correction(corrections: dict, latex_raw: str) -> str | None:
    """Return saved typst_inner for this latex, or None."""
    key = _normalize(latex_raw).strip()
    return corrections.get(key)


def extract_inner(replacement: str) -> str | None:
    """Strip $...$ or $\\n  ...\\n$ wrappers to get just the math content.
    Returns None if the replacement doesn't look like a Typst math block."""
    s = replacement.strip()
    if s.startswith("$") and s.endswith("$") and len(s) >= 2:
        return s[1:-1].strip()
    return None

# ── Symbol tables ────────────────────────────────────────────────────────────

GREEK = {
    "alpha": "alpha", "beta": "beta", "gamma": "gamma", "delta": "delta",
    "epsilon": "epsilon", "zeta": "zeta", "eta": "eta", "theta": "theta",
    "iota": "iota", "kappa": "kappa", "lambda": "lambda", "mu": "mu",
    "nu": "nu", "xi": "xi", "pi": "pi", "rho": "rho", "sigma": "sigma",
    "tau": "tau", "upsilon": "upsilon", "phi": "phi", "chi": "chi",
    "psi": "psi", "omega": "omega",
    "Alpha": "Alpha", "Beta": "Beta", "Gamma": "Gamma", "Delta": "Delta",
    "Epsilon": "Epsilon", "Zeta": "Zeta", "Eta": "Eta", "Theta": "Theta",
    "Lambda": "Lambda", "Xi": "Xi", "Pi": "Pi", "Sigma": "Sigma",
    "Upsilon": "Upsilon", "Phi": "Phi", "Psi": "Psi", "Omega": "Omega",
    "varepsilon": "epsilon.alt", "varphi": "phi.alt",
    "vartheta": "theta.alt", "varrho": "rho.alt",
}

SIMPLE_CMDS = {
    r"\times": "times",   r"\cdot": "dot.op",    r"\propto": "prop",
    r"\infty": "infinity", r"\partial": "partial", r"\nabla": "nabla",
    r"\approx": "approx", r"\neq": "!=",          r"\leq": "<=",
    r"\geq": ">=",        r"\ll": "<<",            r"\gg": ">>",
    r"\pm": "plus.minus", r"\mp": "minus.plus",
    r"\ldots": "dots.h",  r"\cdots": "dots.c",
    r"\sum": "sum",       r"\prod": "product",
    r"\int": "integral",  r"\oint": "integral.cont",
    r"\to": "->",         r"\rightarrow": "->",   r"\leftarrow": "<-",
    r"\Rightarrow": "=>", r"\Leftrightarrow": "<=>",
    r"\equiv": "equiv",   r"\sim": "tilde",        r"\simeq": "approx.eq",
    r"\in": "in",         r"\notin": "in.not",
    r"\subset": "subset", r"\supset": "supset",
    r"\cup": "union",     r"\cap": "sect",
    r"\forall": "forall", r"\exists": "exists",
    r"\cos": "cos",  r"\sin": "sin",  r"\tan": "tan",  r"\cot": "cot",
    r"\sec": "sec",  r"\csc": "csc",  r"\ln": "ln",    r"\log": "log",
    r"\exp": "exp",  r"\max": "max",  r"\min": "min",  r"\lim": "lim",
    r"\sup": "sup",  r"\inf": "inf",  r"\det": "det",  r"\deg": "deg",
    r"\mod": "mod",  r"\Re": "Re",    r"\Im": "Im",
    r"\,": " ",      r"\ ": " ",      r"\!": "",        r"\quad": "  ",
}

# \cmd{arg} → typst_fn(arg)
BRACE_CMDS = {
    r"\sqrt": "sqrt",
    r"\vec": "arrow",   r"\hat": "hat",        r"\bar": "overline",
    r"\tilde": "tilde", r"\dot": "dot",        r"\ddot": "dot.double",
    r"\overline": "overline",   r"\underline": "underline",
    r"\overbrace": "overbrace", r"\underbrace": "underbrace",
    r"\text": None,   r"\mathrm": None,
    r"\mathbf": "bold", r"\mathit": None, r"\mathcal": "cal",
}

# Commands we can't auto-convert — leave flagged
STILL_COMPLEX = {
    r"\iint", r"\iiint", r"\oiint",
    r"\begin", r"\end",
    r"\underset", r"\overset", r"\stackrel",
}


# ── LaTeX → Typst conversion ─────────────────────────────────────────────────

def _normalize(s: str) -> str:
    """The file stores \\\\cmd (two backslashes); normalise to \\cmd (one)."""
    return s.replace("\\\\", "\\")


def find_brace_group(s: str, pos: int) -> tuple[str, int]:
    """Content of {balanced braces} at pos. Returns (content, end_pos)."""
    assert s[pos] == "{", f"Expected '{{' at {pos}"
    depth = 0
    for i in range(pos, len(s)):
        if s[i] == "{":
            depth += 1
        elif s[i] == "}":
            depth -= 1
            if depth == 0:
                return s[pos + 1 : i], i + 1
    raise ValueError(f"Unbalanced braces at {pos}: {s[pos:]!r}")


def _is_atom(s: str) -> bool:
    s = s.strip()
    if len(s) <= 2:
        return True
    if s.startswith("(") and s.endswith(")"):
        depth = 0
        for i, c in enumerate(s):
            depth += (c == "(") - (c == ")")
            if depth == 0 and i < len(s) - 1:
                return False
        return True
    if re.fullmatch(r'[a-zA-Z_][a-zA-Z0-9_.]*\([^()]*\)', s):
        return True
    return False


def _transform(s: str) -> str:
    """Core recursive LaTeX→Typst converter (after normalisation)."""
    result = []
    i = 0
    while i < len(s):
        matched = False

        # \frac / \dfrac / \tfrac
        for cmd in (r"\frac", r"\dfrac", r"\tfrac"):
            if s[i:].startswith(cmd) and not s[i + len(cmd) : i + len(cmd) + 1].isalpha():
                j = i + len(cmd)
                while j < len(s) and s[j] == " ":
                    j += 1
                if j < len(s) and s[j] == "{":
                    num_raw, j = find_brace_group(s, j)
                    while j < len(s) and s[j] == " ":
                        j += 1
                    if j < len(s) and s[j] == "{":
                        den_raw, j = find_brace_group(s, j)
                        num = _transform(num_raw.strip())
                        den = _transform(den_raw.strip())
                        num_s = num if _is_atom(num) else f"({num})"
                        den_s = den if _is_atom(den) else f"({den})"
                        result.append(f"{num_s}/{den_s}")
                        i = j
                        matched = True
                        break
        if matched:
            continue

        # Single-arg brace commands
        for cmd, typst_fn in BRACE_CMDS.items():
            if s[i:].startswith(cmd) and not s[i + len(cmd) : i + len(cmd) + 1].isalpha():
                j = i + len(cmd)
                while j < len(s) and s[j] == " ":
                    j += 1
                if j < len(s) and s[j] == "{":
                    arg_raw, j = find_brace_group(s, j)
                    arg = _transform(arg_raw.strip())
                    result.append(arg if typst_fn is None else f"{typst_fn}({arg})")
                    i = j
                    matched = True
                    break
        if matched:
            continue

        # \left / \right — drop the sizing, keep delimiter
        for sizing in (r"\left", r"\right"):
            if s[i:].startswith(sizing) and not s[i + len(sizing) : i + len(sizing) + 1].isalpha():
                j = i + len(sizing)
                if j < len(s) and s[j] in r"([]).|/\{}":
                    delim = "" if s[j] == "." else s[j]
                    result.append(delim)
                    i = j + 1
                else:
                    result.append(s[i])
                    i += 1
                matched = True
                break
        if matched:
            continue

        result.append(s[i])
        i += 1

    s = "".join(result)

    # Greek letters
    for name, typst_name in GREEK.items():
        s = re.sub(r"\\" + name + r"(?![a-zA-Z])", typst_name, s)

    # Simple commands
    for latex_cmd, typst_cmd in SIMPLE_CMDS.items():
        s = s.replace(latex_cmd, typst_cmd)

    # ^{...} / _{...} → ^(...) / _(...)
    def convert_script(m):
        op, content = m.group(1), m.group(2)
        return f"{op}{content}" if len(content) == 1 else f"{op}({content})"
    for _ in range(5):
        new = re.sub(r'([_^])\{([^{}]*)\}', convert_script, s)
        if new == s:
            break
        s = new

    # Remaining {...} → (...)
    for _ in range(5):
        new = re.sub(r'\{([^{}]*)\}', r'(\1)', s)
        if new == s:
            break
        s = new

    return re.sub(r'  +', ' ', s).strip()


def is_still_complex(latex: str) -> bool:
    return any(cmd in latex for cmd in STILL_COMPLEX)


def latex_to_typst(raw: str, corrections: dict | None = None) -> str | None:
    """Convert raw LaTeX (as stored in file, double-backslash) to Typst inner
    content (no $ wrappers). Returns None if conversion is not possible.
    Checks corrections cache first if provided."""
    if corrections:
        cached = lookup_correction(corrections, raw)
        if cached is not None:
            return cached
    s = _normalize(raw).strip()
    if is_still_complex(s):
        return None
    return _transform(s)


# ── File editing ─────────────────────────────────────────────────────────────

# Matches #mi("...") or #mitex("..."), capturing (kind, content)
_MI_RE = re.compile(r'#(mi(?:tex)?)\("([^"]*)"\)')


def find_calls(text: str, start_line: int = 1, end_line: int = 10**9
               ) -> list[tuple[int, int, int, str, str]]:
    """Return list of (line_no, char_start, char_end, kind, latex) for all
    #mi / #mitex calls within [start_line, end_line]."""
    results = []
    pos = 0
    line_no = 1
    for m in _MI_RE.finditer(text):
        # Count newlines up to this match
        while pos < m.start():
            if text[pos] == "\n":
                line_no += 1
            pos += 1
        if start_line <= line_no <= end_line:
            results.append((line_no, m.start(), m.end(), m.group(1), m.group(2)))
    return results


def apply_replacement(text: str, char_start: int, char_end: int,
                      replacement: str) -> str:
    return text[:char_start] + replacement + text[char_end:]


# ── Interactive mode ─────────────────────────────────────────────────────────

RESET  = "\033[0m"
BOLD   = "\033[1m"
DIM    = "\033[2m"
RED    = "\033[31m"
GREEN  = "\033[32m"
YELLOW = "\033[33m"
CYAN   = "\033[36m"


def fmt_proposed(kind: str, typst: str) -> str:
    if kind == "mitex":
        return f"$\n  {typst}\n$"
    else:
        return f"${typst}$"


def interactive(path: Path, start_line: int, end_line: int) -> None:
    corrections = load_corrections()
    text = path.read_text()
    calls = find_calls(text, start_line, end_line)

    if not calls:
        print(f"No #mi / #mitex calls found in lines {start_line}–{end_line}.")
        return

    cached_count = sum(1 for *_, latex_raw in calls
                       if lookup_correction(corrections, latex_raw) is not None)
    print(f"\n{BOLD}{len(calls)} call(s) in lines {start_line}–{end_line} of {path.name}{RESET}")
    if cached_count:
        print(f"{DIM}{cached_count} have saved corrections{RESET}")
    print(f"{DIM}Controls: [y] accept  [n] skip  [e] edit  [q] quit{RESET}\n")

    # Work through calls in reverse order so char offsets stay valid after edits
    pending = list(reversed(calls))
    accepted = 0
    skipped  = 0

    for line_no, char_start, char_end, kind, latex_raw in pending:
        original = text[char_start:char_end]
        typst    = latex_to_typst(latex_raw, corrections)
        from_cache = lookup_correction(corrections, latex_raw) is not None

        print(f"{CYAN}━━━ Line {line_no} {'━' * max(0, 50 - len(str(line_no)))}{RESET}")
        print(f"{DIM}ORIGINAL:{RESET} {original}")

        if typst is None:
            proposed = None
            print(f"{YELLOW}AUTO-CONVERT: not possible (contains \\iint / \\begin etc.){RESET}")
        else:
            proposed = fmt_proposed(kind, typst)
            source_tag = f" {DIM}(from corrections){RESET}" if from_cache else ""
            print(f"{GREEN}PROPOSED:{RESET}{source_tag}")
            for ln in proposed.splitlines():
                print(f"  {ln}")

        print()
        while True:
            choice = input(f"  {BOLD}[y/n/e/q]>{RESET} ").strip().lower()
            if choice in ("y", "n", "e", "q"):
                break

        if choice == "q":
            print("\nQuitting.")
            break
        elif choice == "n":
            skipped += 1
            print()
            continue
        elif choice == "y":
            if proposed is None:
                print(f"{YELLOW}  Nothing to accept — no valid conversion. Skipping.{RESET}\n")
                skipped += 1
                continue
            replacement = proposed
            # Save confirmed auto-conversions too (speeds up future runs)
            if not from_cache and typst is not None:
                save_correction(corrections, latex_raw, typst)
        else:  # e
            print(f"  Enter replacement (blank line to finish):")
            lines = []
            while True:
                ln = input("  ")
                if ln == "" and lines:
                    break
                lines.append(ln)
            replacement = "\n".join(lines)
            # Save the correction for future runs
            inner = extract_inner(replacement)
            if inner is not None:
                save_correction(corrections, latex_raw, inner)
                print(f"  {DIM}correction saved{RESET}")

        text = apply_replacement(text, char_start, char_end, replacement)
        path.write_text(text)
        accepted += 1

        # Since we process in reverse order and write immediately, earlier
        # (lower line number) calls have not been touched yet, so their char
        # offsets are still valid — no re-scan needed.
        pending = pending[pending.index((line_no, char_start, char_end, kind, latex_raw)) + 1:]

        print(f"  {GREEN}✓ written{RESET}\n")

    print(f"\nDone. {accepted} accepted, {skipped} skipped.")


# ── Batch mode (original behaviour) ─────────────────────────────────────────

def batch(path: Path, dry_run: bool) -> None:
    text = path.read_text()
    mi_ok = mi_flagged = mitex_ok = mitex_flagged = 0

    def replace_mi(m):
        nonlocal mi_ok, mi_flagged
        t = latex_to_typst(m.group(2))
        if t is not None:
            mi_ok += 1
            return f"${t}$"
        mi_flagged += 1
        return m.group(0) + "/* TODO: mi */"

    def replace_mitex(m):
        nonlocal mitex_ok, mitex_flagged
        t = latex_to_typst(m.group(2))
        if t is not None:
            mitex_ok += 1
            return f"$\n  {t}\n$"
        mitex_flagged += 1
        return m.group(0) + "/* TODO: mitex */"

    new = re.sub(r'#(mi)\("([^"]*)"\)',    replace_mi,    text)
    new = re.sub(r'#(mitex)\("([^"]*)"\)', replace_mitex, new)

    if not dry_run:
        path.write_text(new)

    tag = "[DRY RUN] " if dry_run else ""
    print(f"{tag}#mi:    {mi_ok} converted, {mi_flagged} flagged")
    print(f"{tag}#mitex: {mitex_ok} converted, {mitex_flagged} flagged")
    if (mi_flagged + mitex_flagged) and not dry_run:
        print("Search for '/* TODO:' to find flagged items.")


# ── CLI ──────────────────────────────────────────────────────────────────────

def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("file", type=Path)
    p.add_argument("--lines", metavar="START-END",
                   help="Line range to process, e.g. 220-280")
    p.add_argument("--batch", action="store_true",
                   help="Non-interactive batch conversion")
    p.add_argument("--dry-run", action="store_true",
                   help="Batch preview without writing (implies --batch)")
    args = p.parse_args()

    if not args.file.exists():
        print(f"File not found: {args.file}")
        sys.exit(1)

    if args.dry_run:
        args.batch = True

    if args.batch:
        batch(args.file, dry_run=args.dry_run)
        return

    start, end = 1, 10**9
    if args.lines:
        parts = args.lines.split("-")
        start = int(parts[0])
        end   = int(parts[1]) if len(parts) > 1 else start

    interactive(args.file, start, end)


if __name__ == "__main__":
    main()
