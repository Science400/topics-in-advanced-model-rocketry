#!/usr/bin/env python3
"""Convert #mi() / #mitex() LaTeX calls to native Typst math.

Three modes:

  Auto pass (default):
    Silently converts trivial and simple #mi() calls — single Greek letters,
    single variables, subscripted/superscripted expressions with no structural
    LaTeX (no \\frac, \\partial, \\vec, etc.). Safe to run without review.

      python convert_mi.py src/chapters/ch3-aerodynamic-drag.typ

  LLM-assist mode (--llm-assist):
    Sends each pending complex #mi() and #mitex() to a local LLM for
    validation. High-confidence approvals are written automatically.
    Uncertain / rejected items are left for --review.

      python convert_mi.py src/chapters/ch3-aerodynamic-drag.typ --llm-assist
      python convert_mi.py src/chapters/ch3-aerodynamic-drag.typ --llm-assist --lines 220-350 --llm-model gemma3:27b

    Default LLM endpoint: http://localhost:11434/v1 (Ollama).
    Override with --llm-url and --llm-model.

  Review mode (--review):
    Interactive queue for complex #mi() and all #mitex() calls. Shows each
    one with a proposed conversion, lets you accept / edit / skip.

      python convert_mi.py src/chapters/ch3-aerodynamic-drag.typ --review
      python convert_mi.py src/chapters/ch3-aerodynamic-drag.typ --review --lines 220-350

Interactive controls:
    y  accept proposed conversion
    e  edit — type your own Typst, end with a blank line
    n  skip (leave as-is for now)
    q  quit (already-accepted changes are written)

Corrections are saved to pipeline/mi_corrections.json. On re-runs, cached
corrections are applied automatically (shown as "from cache").
"""

import json
import re
import sys
import argparse
import readline
from pathlib import Path
from term import console

try:
    from lms import ensure_loaded as _lms_ensure_loaded
except ImportError:
    _lms_ensure_loaded = None

# ── Corrections cache ────────────────────────────────────────────────────────

CORRECTIONS_PATH = Path(__file__).parent / "mi_corrections.json"
SYMBOLS_PATH = Path(__file__).parent / "symbols" / "ch3.md"


def load_corrections() -> dict:
    if CORRECTIONS_PATH.exists():
        return json.loads(CORRECTIONS_PATH.read_text())
    return {}


def save_correction(corrections: dict, latex_raw: str, typst_inner: str) -> None:
    key = _normalize(latex_raw).strip()
    corrections[key] = typst_inner
    CORRECTIONS_PATH.write_text(json.dumps(corrections, indent=2, ensure_ascii=False))


def lookup_correction(corrections: dict, latex_raw: str) -> str | None:
    key = _normalize(latex_raw).strip()
    return corrections.get(key)


# ── Symbol table ─────────────────────────────────────────────────────────────

def load_symbols() -> list[tuple[str, str]]:
    """Return list of (latex_key, meaning) from ch3.md symbol table."""
    if not SYMBOLS_PATH.exists():
        return []
    symbols = []
    in_table = False
    for line in SYMBOLS_PATH.read_text().splitlines():
        if "| LaTeX | Meaning |" in line:
            in_table = True
            continue
        if in_table:
            if line.startswith("|---") or line.startswith("| ---"):
                continue
            if not line.startswith("|"):
                in_table = False
                continue
            parts = [p.strip() for p in line.strip("|").split("|")]
            if len(parts) >= 2:
                key = parts[0].strip("`")
                meaning = parts[1]
                symbols.append((key, meaning))
    return symbols


def relevant_symbols(latex_raw: str, symbols: list[tuple[str, str]]) -> list[tuple[str, str]]:
    """Return symbol table rows whose key appears in the expression."""
    s = _normalize(latex_raw)
    matches = []
    for key, meaning in symbols:
        # Check if the key (stripped of LaTeX formatting) appears in the expression
        bare = key.replace("\\", "\\").strip()
        if bare and bare in s:
            matches.append((key, meaning))
    return matches[:6]  # cap at 6 to avoid flooding the terminal


# ── LaTeX normalisation and conversion ───────────────────────────────────────

GREEK = {
    "alpha": "alpha",   "beta": "beta",     "gamma": "gamma",   "delta": "delta",
    "epsilon": "epsilon", "zeta": "zeta",   "eta": "eta",       "theta": "theta",
    "iota": "iota",     "kappa": "kappa",   "lambda": "lambda", "mu": "mu",
    "nu": "nu",         "xi": "xi",         "pi": "pi",         "rho": "rho",
    "sigma": "sigma",   "tau": "tau",       "upsilon": "upsilon", "phi": "phi",
    "chi": "chi",       "psi": "psi",       "omega": "omega",
    "Alpha": "Alpha",   "Beta": "Beta",     "Gamma": "Gamma",   "Delta": "Delta",
    "Epsilon": "Epsilon", "Zeta": "Zeta",   "Eta": "Eta",       "Theta": "Theta",
    "Lambda": "Lambda", "Xi": "Xi",         "Pi": "Pi",         "Sigma": "Sigma",
    "Upsilon": "Upsilon", "Phi": "Phi",     "Psi": "Psi",       "Omega": "Omega",
    "varepsilon": "epsilon.alt", "varphi": "phi.alt",
    "vartheta": "theta.alt",     "varrho": "rho.alt",
}

SIMPLE_CMDS = {
    r"\times": "times",     r"\cdot": "dot.op",     r"\propto": "prop",
    r"\infty": "infinity",  r"\partial": "partial",  r"\nabla": "nabla",
    r"\approx": "approx",  r"\neq": "!=",           r"\leq": "<=",
    r"\geq": ">=",          r"\ll": "<<",            r"\gg": ">>",
    r"\pm": "plus.minus",  r"\mp": "minus.plus",
    r"\ldots": "dots.h",   r"\cdots": "dots.c",
    r"\sum": "sum",         r"\prod": "product",
    r"\int": "integral",   r"\oint": "integral.cont",
    r"\iint": "integral.double", r"\iiint": "integral.triple",
    r"\oiint": "integral.surf",
    r"\to": "->",           r"\rightarrow": "->",    r"\leftarrow": "<-",
    r"\Rightarrow": "=>",  r"\Leftrightarrow": "<=>",
    r"\equiv": "equiv",    r"\sim": "tilde",         r"\simeq": "approx.eq",
    r"\in": "in",           r"\notin": "in.not",
    r"\subset": "subset",  r"\supset": "supset",
    r"\cup": "union",       r"\cap": "sect",
    r"\forall": "forall",  r"\exists": "exists",
    r"\cos": "cos",  r"\sin": "sin",  r"\tan": "tan",  r"\cot": "cot",
    r"\sec": "sec",  r"\csc": "csc",  r"\ln": "ln",    r"\log": "log",
    r"\exp": "exp",  r"\max": "max",  r"\min": "min",  r"\lim": "lim",
    r"\sup": "sup",  r"\inf": "inf",  r"\det": "det",  r"\deg": "deg",
    r"\mod": "mod",  r"\Re": "Re",    r"\Im": "Im",
    r"\ell": "ell",
    r"\,": " ",      r"\ ": " ",      r"\!": "",        r"\quad": "  ",
    r"\qquad": "    ",
}

# \cmd{arg} → typst_fn(arg)  (None = strip wrapper, keep arg as-is)
BRACE_CMDS = {
    r"\sqrt":      "sqrt",
    r"\vec":       "arrow",    r"\hat":  "hat",          r"\bar":  "overline",
    r"\tilde":     "tilde",    r"\dot":  "dot",          r"\ddot": "dot.double",
    r"\overline":  "overline", r"\underline": "underline",
    r"\overbrace": "overbrace", r"\underbrace": "underbrace",
    r"\text":      None,       r"\mathrm": None,
    r"\mathbf":    "bold",     r"\mathit": None,         r"\mathcal": "cal",
}

# Structural commands that require manual conversion
COMPLEX_CMDS = {
    r"\frac", r"\dfrac", r"\tfrac",
    r"\partial",
    r"\vec", r"\hat", r"\bar", r"\tilde", r"\dot", r"\ddot",
    r"\overline", r"\underline",
    r"\sqrt",
    r"\left", r"\right",
    r"\text", r"\mathrm", r"\mathbf", r"\mathit", r"\mathcal",
    r"\begin", r"\end",
    r"\underset", r"\overset", r"\stackrel",
}

# Commands that prevent even attempted auto-conversion
UNCONVERTIBLE = {r"\begin", r"\end",
                 r"\underset", r"\overset", r"\stackrel"}


def _normalize(s: str) -> str:
    """Convert double-backslash (as stored in .typ files) to single."""
    return s.replace("\\\\", "\\")


def is_complex(latex_raw: str) -> bool:
    """True if expression contains structural commands needing review."""
    s = _normalize(latex_raw)
    return any(cmd in s for cmd in COMPLEX_CMDS)


def is_unconvertible(latex_raw: str) -> bool:
    """True if auto-conversion is impossible (\\iint, \\begin, etc.)."""
    s = _normalize(latex_raw)
    return any(cmd in s for cmd in UNCONVERTIBLE)


def find_brace_group(s: str, pos: int) -> tuple[str, int]:
    assert s[pos] == "{", f"Expected '{{' at {pos}, got {s[pos]!r}"
    depth = 0
    for i in range(pos, len(s)):
        depth += (s[i] == "{") - (s[i] == "}")
        if depth == 0:
            return s[pos + 1 : i], i + 1
    raise ValueError(f"Unbalanced braces at {pos}")


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
    """Core LaTeX → Typst conversion (operates on single-backslash LaTeX)."""
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

        # \left / \right — drop sizing, keep delimiter
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

    # Simple symbol commands
    for latex_cmd, typst_cmd in SIMPLE_CMDS.items():
        s = s.replace(latex_cmd, typst_cmd)

    # ^{...} / _{...} with multi-char content → ^(...) / _(...)
    # Purely-alphabetic multi-letter content that isn't a known Typst math symbol
    # must be quoted so Typst doesn't try to look it up as an identifier.
    _TYPST_MATH_IDENTS = (
        set(GREEK.values())
        | set(SIMPLE_CMDS.values())
        | {'infinity', 'partial', 'nabla', 'integral', 'product', 'ell',
           'dif', 'sqrt', 'arrow', 'hat', 'overline', 'underline',
           'overbrace', 'underbrace', 'tilde', 'dot', 'bold', 'cal',
           'forall', 'exists', 'union', 'sect', 'subset', 'supset',
           'sin', 'cos', 'tan', 'cot', 'sec', 'csc', 'ln', 'log', 'exp',
           'max', 'min', 'lim', 'sup', 'inf', 'det', 'deg', 'mod',
           'Re', 'Im', 'sum', 'prop', 'approx', 'equiv'}
    )

    def convert_script(m):
        op, content = m.group(1), m.group(2)
        if len(content) == 1:
            return f"{op}{content}"
        # Quote purely-alphabetic text labels that aren't known Typst math symbols
        if re.fullmatch(r'[a-zA-Z]+', content) and content not in _TYPST_MATH_IDENTS:
            return f'{op}("{content}")'
        return f"{op}({content})"
    for _ in range(5):
        new = re.sub(r'([_^])\{([^{}]*)\}', convert_script, s)
        if new == s:
            break
        s = new

    # Remaining bare {...} → (...)
    for _ in range(5):
        new = re.sub(r'\{([^{}]*)\}', r'(\1)', s)
        if new == s:
            break
        s = new

    # Differentials: d immediately followed by a single letter → dif
    # Matches both "dy" and "d y" but not "delta", "dif", "dot", etc.
    s = re.sub(r'\bd([A-Za-z])\b', r'dif \1', s)
    s = re.sub(r'\bd ([A-Za-z])\b', r'dif \1', s)

    return re.sub(r'  +', ' ', s).strip()


def latex_to_typst(latex_raw: str, corrections: dict | None = None) -> str | None:
    """Convert raw LaTeX (double-backslash) to Typst inner content.
    Returns None if unconvertible. Checks corrections cache first."""
    if corrections:
        cached = lookup_correction(corrections, latex_raw)
        if cached is not None:
            return cached
    if is_unconvertible(latex_raw):
        return None
    return _transform(_normalize(latex_raw).strip())


# ── Finding calls in source ───────────────────────────────────────────────────

_MI_RE = re.compile(r'#(mi(?:tex)?)\("([^"]*)"\)')


def find_calls(text: str, start_line: int = 1, end_line: int = 10**9,
               kinds: set | None = None) -> list[tuple[int, int, int, str, str]]:
    """Return (line_no, char_start, char_end, kind, latex_raw) for matching calls."""
    results = []
    line_no = 1
    line_start = 0
    for m in _MI_RE.finditer(text):
        # Advance line counter to this match position
        while line_start < m.start():
            if text[line_start] == "\n":
                line_no += 1
            line_start += 1
        kind = m.group(1)
        if kinds and kind not in kinds:
            continue
        if start_line <= line_no <= end_line:
            results.append((line_no, m.start(), m.end(), kind, m.group(2)))
    return results


# ── Auto pass ────────────────────────────────────────────────────────────────

def auto_pass(path: Path) -> None:
    """Silently convert all simple (non-complex) #mi() calls."""
    text = path.read_text()
    converted = 0
    skipped = 0

    def replace(m):
        nonlocal converted, skipped
        kind = m.group(1)
        latex_raw = m.group(2)
        if kind == "mitex" or is_complex(latex_raw):
            skipped += 1
            return m.group(0)
        typst = latex_to_typst(latex_raw)
        if typst is None:
            skipped += 1
            return m.group(0)
        converted += 1
        return f"${typst}$"

    new_text = _MI_RE.sub(replace, text)

    # Fix prose superscripts: meter$^2$ → meter#super[2]
    n_super = len(re.findall(r'[a-zA-Z.]\$\^\d+\$', new_text))
    new_text = re.sub(r'([a-zA-Z.])\$\^(\d+)\$', r'\1#super[\2]', new_text)

    # Fix split subscripts created by earlier conversion: $sym$\_sub → $sym_sub$
    n_split = len(re.findall(r'\$[a-zA-Z.]+\$\\_[a-zA-Z0-9]+', new_text))
    new_text = re.sub(r'\$([a-zA-Z.]+)\$\\_([a-zA-Z0-9]+)', r'$\1_\2$', new_text)

    # Fix \ell inside existing $...$ spans in prose (OCR artifact not in #mi wrappers)
    def fix_ell_in_math(m):
        inner = m.group(1)
        return f'${inner.replace(chr(92) + "ell", "ell")}$'
    protected_re = re.compile(r'(#mi(?:tex)?\("[^"]*"\))')
    prose_parts = protected_re.split(new_text)
    n_ell = 0
    for k in range(0, len(prose_parts), 2):
        fixed = re.sub(r'\$([^$\n]+)\$', fix_ell_in_math, prose_parts[k])
        n_ell += prose_parts[k].count('\\ell')
        prose_parts[k] = fixed
    new_text = ''.join(prose_parts)

    # Fix bare \cmd in prose (OCR artifacts not wrapped in #mi)
    # Also fix ^\circ → degree and multi-letter identifiers inside $...$
    n_bare = 0
    n_circ = 0
    n_multilet = 0
    protected = re.compile(r'(\$[^$\n]*\$|#mi(?:tex)?\("[^"]*"\))')

    # Multi-letter physics shorthands that Typst can't parse as single identifiers.
    # Maps the run-together form → correct Typst form (applied inside $...$ prose spans).
    # Differentials use `dif` (upright d) per Typst convention.
    MULTILET = {
        # differentials — all single-letter combos
        'dx': 'dif x', 'dy': 'dif y', 'dz': 'dif z', 'dt': 'dif t',
        'du': 'dif u', 'dv': 'dif v', 'dw': 'dif w',
        'dS': 'dif S', 'ds': 'dif s', 'dp': 'dif p', 'dA': 'dif A',
        # subscript abbreviations that land in prose math
        'crit': '"crit"', 'turb': '"turb"', 'lam': '"lam"',
        'adm': '"adm"', 'tot': '"tot"',
        'lug': '"lug"', 'fb': '"fb"', 'stag': '"stag"',
    }

    lines_out = []
    for line in new_text.splitlines(keepends=True):
        if line.strip().startswith('//'):
            lines_out.append(line)
            continue
        parts = protected.split(line)
        new_parts = []
        for j, part in enumerate(parts):
            if j % 2 == 1:  # protected span — leave alone
                new_parts.append(part)
                continue
            # Fix bare Greek \cmd in prose text
            for name, typst_name in GREEK.items():
                subbed = re.sub(r'\\' + name + r'(?![a-zA-Z_])', f'${typst_name}$', part)
                if subbed != part:
                    n_bare += 1
                part = subbed
            # Fix ^\circ inside $...$ spans
            def fix_circ(m):
                nonlocal n_circ
                inner = m.group(1)
                fixed = re.sub(r'\^\\?circ\b', ' degree', inner)
                fixed = re.sub(r'\^\(\\?circ\)', ' degree', fixed)
                if fixed != inner:
                    n_circ += 1
                return f'${fixed}$'
            part = re.sub(r'\$([^$\n]+)\$', fix_circ, part)
            # Fix multi-letter identifiers inside $...$ spans
            def fix_multilet(m):
                nonlocal n_multilet
                inner = m.group(1)
                orig = inner
                for bad, good in MULTILET.items():
                    inner = re.sub(r'\b' + re.escape(bad) + r'\b', good, inner)
                if inner != orig:
                    n_multilet += 1
                return f'${inner}$'
            part = re.sub(r'\$([^$\n]+)\$', fix_multilet, part)
            new_parts.append(part)
        lines_out.append(''.join(new_parts))
    new_text = ''.join(lines_out)

    path.write_text(new_text)
    print(f"Auto pass: {converted} #mi converted, {skipped} left for review.")
    if n_super:
        print(f"  + {n_super} prose superscripts fixed (text$^N$ → #super[N])")
    if n_split:
        print(f"  + {n_split} split subscripts fixed ($sym$\\_sub → $sym_sub$)")
    if n_bare:
        print(f"  + {n_bare} bare \\cmd in prose fixed")
    if n_ell:
        print(f"  + {n_ell} \\ell fixed inside prose $...$ spans")
    if n_circ:
        print(f"  + {n_circ} degree symbols fixed (^\\circ → degree)")
    if n_multilet:
        print(f"  + {n_multilet} multi-letter identifiers spaced in prose math")


# ── Interactive review ────────────────────────────────────────────────────────

RESET  = "\033[0m"
BOLD   = "\033[1m"
DIM    = "\033[2m"
GREEN  = "\033[32m"
YELLOW = "\033[33m"
CYAN   = "\033[36m"


def input_prefilled(prompt: str, prefill: str) -> str:
    """input() with prefilled editable text (uses readline pre-input hook)."""
    def hook():
        readline.insert_text(prefill)
        readline.redisplay()
    readline.set_pre_input_hook(hook)
    try:
        return input(prompt)
    finally:
        readline.set_pre_input_hook(None)


def fmt_replacement(kind: str, typst_inner: str) -> str:
    if kind == "mitex":
        return f"$ {typst_inner} $"
    return f"${typst_inner}$"


def review(path: Path, start_line: int, end_line: int) -> None:
    corrections = load_corrections()
    symbols = load_symbols()
    text = path.read_text()

    # Queue: complex #mi() + all #mitex()
    calls = find_calls(text, start_line, end_line)
    queue = [(ln, s, e, k, lx) for ln, s, e, k, lx in calls
             if k == "mitex" or is_complex(lx)]

    if not queue:
        print(f"Nothing left to review in lines {start_line}–{end_line}.")
        return

    cached_count = sum(1 for *_, lx in queue if lookup_correction(corrections, lx) is not None)
    print(f"\n{BOLD}{len(queue)} item(s) to review in lines {start_line}–{end_line}{RESET}")
    if cached_count:
        print(f"{DIM}{cached_count} have cached corrections (will auto-propose){RESET}")
    print(f"{DIM}y=accept  e=edit  n=skip  q=quit{RESET}\n")

    accepted = skipped = 0

    for idx, (line_no, char_start, char_end, kind, latex_raw) in enumerate(queue):
        # Re-read each time since prior edits shift offsets
        text = path.read_text()
        # Re-locate this call in the (possibly updated) text
        all_calls = find_calls(text, 1, 10**9, kinds={kind})
        match = next(
            ((s, e) for ln, s, e, k, lx in all_calls
             if k == kind and lx == latex_raw and abs(ln - line_no) <= 5),
            None
        )
        if match is None:
            # Already converted in a prior session
            continue
        char_start, char_end = match

        original = text[char_start:char_end]
        from_cache = lookup_correction(corrections, latex_raw) is not None
        typst = latex_to_typst(latex_raw, corrections)

        remaining = len(queue) - idx
        print(f"{CYAN}━━━ Line {line_no}  [{kind}]  ({remaining} remaining) {'━' * max(0, 35 - len(str(line_no)))}{RESET}")
        print(f"{DIM}ORIGINAL:{RESET} {original}")

        # Show relevant symbol definitions
        rel = relevant_symbols(latex_raw, symbols)
        if rel:
            print(f"{DIM}SYMBOLS:{RESET}")
            for key, meaning in rel:
                print(f"  {DIM}{key:<30} {meaning}{RESET}")

        if typst is None:
            print(f"{YELLOW}Cannot auto-convert (contains \\iint / \\begin etc.){RESET}")
            proposed = None
        else:
            proposed = fmt_replacement(kind, typst)
            cache_tag = f"  {DIM}(from cache){RESET}" if from_cache else ""
            print(f"{GREEN}PROPOSED:{RESET}{cache_tag}")
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
                print(f"{YELLOW}  No valid conversion — skipping.{RESET}\n")
                skipped += 1
                continue
            replacement = proposed
            if not from_cache:
                save_correction(corrections, latex_raw, typst)
        else:  # e
            prefill = proposed if proposed is not None else ""
            replacement = input_prefilled(f"  {BOLD}edit>{RESET} ", prefill)
            # Extract inner content (strip outer $ delimiters) for caching
            inner = replacement.strip()
            if inner.startswith("$") and inner.endswith("$"):
                inner = inner[1:-1].strip()
            save_correction(corrections, latex_raw, inner)
            print(f"  {DIM}correction saved{RESET}")

        text = text[:char_start] + replacement + text[char_end:]
        path.write_text(text)
        accepted += 1
        print(f"  {GREEN}✓ written{RESET}\n")

    print(f"\nDone. {accepted} accepted, {skipped} skipped.")


# ── LLM-assist mode ──────────────────────────────────────────────────────────

_LLM_PROMPT = """\
Convert this LaTeX math to correct, compilable Typst (rocketry textbook).

Kind: {kind_label}
LaTeX:    {latex}
Proposed: {proposed}
Symbols:  {symbol_hints}

Typst math rules:
- Greek: no backslash — \\alpha→alpha, \\rho→rho, \\Delta→Delta
- Fractions: \\frac{{a}}{{b}}→(a)/(b)
- Differentials: use upright `dif` — dx→dif x, dy→dif y, d(expr)→dif expr
- Multi-letter identifiers are INVALID unless quoted — _(stag) WRONG, _("stag") CORRECT
- \\sqrt{{x}}→sqrt(x), \\vec{{v}}→arrow(v), \\hat{{v}}→hat(v)
- \\left/\\right → drop entirely, keep delimiter char
- \\iint→integral.double, \\iiint→integral.triple
- Inline: no surrounding spaces; Display: space inside each $
- NEVER use curly braces {{}} — Typst uses () for grouping: ^{{3/2}} WRONG, ^(3/2) CORRECT
- NEVER use backslash \\ in output — \\cdot WRONG use dot; \\text{{x}} WRONG use "x"

Example:
  LaTeX: \\frac{{d(C_{{Db}})_m}}{{dC_{{Df}}}} = -\\left(\\frac{{d_b}}{{d_m}}\\right)^3 \\frac{{0.029}}{{2(C_{{Df}})^{{3/2}}}}
  typst_inner: (dif (C_(D_b))_m)/(dif C_(D_f)) = -((dif b)/(dif m))^3 0.029/(2 (C_(D_f))^(3/2))

Always write the best compilable Typst in typst_inner — correct the proposed if it has errors.
Set approved=false only if you cannot produce a reliable conversion.

Reply ONLY with this JSON (no extra text, no fences):
{{"approved": true, "typst_inner": "the correct inner content (no $ delimiters)", "confidence": "high"}}

confidence: high=certain, medium=likely correct, low=guessing.
"""


_FIX_PROMPT = """\
This Typst math expression failed to compile:

  {wrapper}

Compiler error:
  {error}

Rewrite it so it compiles correctly. Same rules:
- Greek no backslash, dif for differentials, multi-letter subscript labels quoted _("stag")
- \\frac→(a)/(b), \\left/\\right dropped
- NEVER use curly braces {{}} — use () for grouping: ^{{3/2}} WRONG, ^(3/2) CORRECT
- NEVER use backslash \\ in output

Reply ONLY with JSON (no fences):
{{"typst_inner": "fixed inner content (no $ delimiters)", "confidence": "high"}}
"""


def _compile_check(typst_inner: str, kind: str) -> tuple[bool, str]:
    """Compile a standalone Typst snippet. Returns (ok, error_text)."""
    import os, subprocess, tempfile
    wrapper = f"$ {typst_inner} $" if kind == "mitex" else f"${typst_inner}$"
    src = f"#set page(width: 40cm, height: 3cm)\n{wrapper}\n"
    with tempfile.NamedTemporaryFile(suffix=".typ", mode="w", delete=False) as f:
        f.write(src)
        tmp_in = f.name
    tmp_out = tmp_in.replace(".typ", ".pdf")
    try:
        r = subprocess.run(
            ["typst", "compile", tmp_in, tmp_out],
            capture_output=True, text=True, timeout=15,
        )
        # Strip the temp path from error messages to keep them short
        err = r.stderr.replace(tmp_in, "<expr>").strip()
        return r.returncode == 0, err
    finally:
        os.unlink(tmp_in)
        if os.path.exists(tmp_out):
            os.unlink(tmp_out)


def _parse_llm_response(raw: str) -> dict:
    """Parse JSON from LLM response, handling thinking preamble, fences, and
    Typst-specific quoting issues.

    Gemma 4 without json_schema uses a <|channel>thought preamble. LaTeX in the
    thinking (e.g. C_{D_0}) also has { chars, so we anchor to schema keys.

    Typst math uses "..." for text literals ("cm", "span/chord"). Those unescaped
    double-quotes break json.loads.  When standard parsing fails we fall back to
    a greedy regex that extracts typst_inner by anchoring on the surrounding keys
    rather than on the quote delimiters.
    """
    text = raw.strip()
    # Strip ```json ... ``` fences
    text = re.sub(r'^```(?:json)?\s*', '', text)
    text = re.sub(r'\s*```$', '', text)
    text = text.strip()
    # Skip thinking preamble: jump to the { that opens our schema JSON object.
    anchor = re.search(r'\{"(?:approved|typst_inner|confidence)"', text)
    if anchor:
        text = text[anchor.start():]
    # Find the { ... } block
    m = re.search(r'\{.*\}', text, re.DOTALL)
    if m:
        text = m.group(0)

    # Stage 1: standard JSON parse
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass

    # Stage 2: single-quote key/value fix
    try:
        fixed = re.sub(r"'([^']*)'", r'"\1"', text)
        return json.loads(fixed)
    except json.JSONDecodeError:
        pass

    # Stage 3: Typst-quote-aware regex extraction.
    # Typst uses "..." for upright text inside math (e.g. 12.95 "cm"^2).
    # Those unescaped quotes make json.loads fail with "Expecting ',' delimiter".
    # Extract each field individually: typst_inner with a greedy .* anchored on
    # the neighbouring key names so it swallows the internal quotes correctly.
    result: dict = {}
    m = re.search(r'"approved"\s*:\s*(true|false)', text)
    if m:
        result['approved'] = (m.group(1) == 'true')
    m = re.search(r'"confidence"\s*:\s*"(high|medium|low)"', text)
    if m:
        result['confidence'] = m.group(1)
    # Greedy .* runs to the LAST possible ", "confidence" boundary.
    # Also tolerate key-name typos (typst_f_inner, etc.) and backtick delimiters.
    _inner_key = r'"typst[^"]*"'   # tolerates key typos like typst_f_inner, typst_interger_content
    m = re.search(_inner_key + r'\s*:\s*"(.*)",\s*"confidence"', text, re.DOTALL)
    if not m:
        # Backtick-delimited value (model sometimes uses ` instead of ")
        m = re.search(_inner_key + r'\s*:\s*`(.*?)`', text, re.DOTALL)
    if not m:
        # Confidence absent (fix-prompt schema) or at end of object
        m = re.search(_inner_key + r'\s*:\s*"(.*)"(?:\s*[,}])', text, re.DOTALL)
    if m:
        result['typst_inner'] = m.group(1)
    if 'typst_inner' in result:
        return result

    raise json.JSONDecodeError("could not extract typst_inner", text, 0)


def _sanitize_typst(s: str) -> str:
    """Fix predictable LLM mistakes in Typst math output.

    The model reliably uses LaTeX grouping habits ({}) in Typst output despite
    prompt instructions.  Catch those here so they never reach the compile check.
    Order matters: replace \\text{} before the brace-to-paren pass so inner
    braces don't get consumed first.
    """
    # \\text{...} → "..." first, so its inner braces don't confuse the next passes
    s = re.sub(r'\\text\{([^}]*)\}', r'"\1"', s)
    # ^{...} → ^(...)
    s = re.sub(r'\^\{([^}]*)\}', r'^(\1)', s)
    # _{...} — quote multi-letter all-alpha subscripts, otherwise just paren-wrap
    def _fix_sub(m: re.Match) -> str:
        content = m.group(1)
        if re.match(r'^[A-Za-z]{2,}$', content):
            return f'_("{content}")'
        return f'_({content})'
    s = re.sub(r'_\{([^}]*)\}', _fix_sub, s)
    # Stray backslash commands the model still emits
    s = s.replace('\\cdot', ' dot ').replace('\\times', ' times ')
    # Fused differential symbols: dx → dif x, dy → dif y, etc.
    # The model writes dx (one identifier) instead of dif x (two tokens).
    s = re.sub(r'(?<![A-Za-z_])d([xyztr])(?![A-Za-z_0-9])', r'dif \1', s)
    return s


def llm_assist(path: Path, start_line: int, end_line: int,
               llm_url: str, llm_model: str) -> None:
    """Auto-convert equations via a local LLM; escalate uncertain ones to --review."""
    try:
        from openai import OpenAI as _OpenAI
    except ImportError:
        print("openai package not found — run: uv add openai  (then use: uv run python convert_mi.py)")
        sys.exit(1)

    # Load the model via LM Studio API before sending any requests.
    if _lms_ensure_loaded is not None:
        _lms_ensure_loaded(llm_model)
    else:
        console.print(f"[dim](lms.py not importable — assuming {llm_model} is already loaded)[/]")

    corrections = load_corrections()
    symbols = load_symbols()
    text = path.read_text()

    calls = find_calls(text, start_line, end_line)
    queue = [(ln, s, e, k, lx) for ln, s, e, k, lx in calls
             if k == "mitex" or is_complex(lx)]

    if not queue:
        print(f"Nothing left to process in lines {start_line}–{end_line}.")
        return

    # Skip items already in the corrections cache — review() handles those fine.
    uncached = [(ln, s, e, k, lx) for ln, s, e, k, lx in queue
                if lookup_correction(corrections, lx) is None]
    cached_count = len(queue) - len(uncached)

    console.print(f"\n[bold]{len(queue)} items in range[/] "
                  f"([dim]{cached_count} cached, {len(uncached)} sending to LLM[/])")
    console.print(f"[dim]Model: {llm_model}  Endpoint: {llm_url}[/]\n")

    client = _OpenAI(base_url=llm_url, api_key="placeholder")
    auto_accepted = 0
    escalated: list[tuple[int, str]] = []  # (line_no, reason)

    MAX_LATEX_LEN = 300  # expressions longer than this risk GPU OOM — send to --review

    for idx, (line_no, _cs, _ce, kind, latex_raw) in enumerate(uncached):
        label = f"[{idx + 1}/{len(uncached)}] line {line_no}"

        if len(_normalize(latex_raw)) > MAX_LATEX_LEN:
            console.print(f"  [cyan]{label}[/]  [dim]too long ({len(_normalize(latex_raw))} chars) — escalated[/]")
            escalated.append((line_no, f"too long ({len(_normalize(latex_raw))} chars)"))
            continue

        proposed_inner = latex_to_typst(latex_raw, corrections)

        # Fast path: if the deterministic converter produced valid Typst, accept
        # it without touching the LLM.  Handles \vec{F}→arrow(F), \sqrt{x}→sqrt(x),
        # simple subscripts, Greek, etc. — everything BRACE_CMDS/SIMPLE_CMDS cover.
        if proposed_inner:
            p_clean = _sanitize_typst(proposed_inner)
            ok, _ = _compile_check(p_clean, kind)
            if ok:
                current_text = path.read_text()
                all_calls = find_calls(current_text, 1, 10**9, kinds={kind})
                match = next(
                    ((s, e) for ln, s, e, k, lx in all_calls
                     if k == kind and lx == latex_raw and abs(ln - line_no) <= 5),
                    None,
                )
                if match:
                    cs, ce = match
                    path.write_text(current_text[:cs] + fmt_replacement(kind, p_clean) + current_text[ce:])
                    save_correction(corrections, latex_raw, p_clean)
                    auto_accepted += 1
                    console.print(f"  [cyan]{label}[/]  [green]✓ auto-accepted (deterministic)[/]")
                else:
                    console.print(f"  [cyan]{label}[/]  [dim]not found (already converted)[/]")
                continue

        proposed_str = fmt_replacement(kind, proposed_inner) if proposed_inner else "(no auto-conversion)"

        rel = relevant_symbols(latex_raw, symbols)
        symbol_hints = "\n".join(f"  {k}: {v}" for k, v in rel) or "  (none)"

        kind_label = "inline $...$" if kind == "mi" else "display $ ... $"
        prompt = _LLM_PROMPT.format(
            kind_label=kind_label,
            latex=_normalize(latex_raw),
            proposed=proposed_str,
            symbol_hints=symbol_hints,
        )

        resp = None
        result = None
        fail_reason = "unknown"
        for attempt in range(3):
            try:
                with console.status(f"[cyan]{label}[/]..." +
                                    (f" [yellow](retry {attempt})[/]" if attempt else "")):
                    resp = '{"' + client.chat.completions.create(
                        model=llm_model,
                        messages=[
                            {"role": "user",      "content": prompt},
                            {"role": "assistant", "content": '{"'},
                            # Prefill forces JSON-first output, suppressing Gemma 4's
                            # <|channel>thought preamble which otherwise saturates the
                            # token budget before the answer appears.
                        ],
                        max_tokens=512,
                        temperature=0.1,
                    ).choices[0].message.content
                result = _parse_llm_response(resp)
                break  # success
            except json.JSONDecodeError as ex:
                fail_reason = f"bad JSON: {ex}"
                console.print(f"  [cyan]{label}[/]  [yellow]bad JSON ({ex})[/]")
                if resp:
                    console.print(f"  [dim]raw: {resp[:200]!r}[/]")
                break  # malformed output — no point retrying
            except Exception as ex:
                err_str = str(ex)
                if "model has crashed" in err_str or "No models loaded" in err_str:
                    fail_reason = "crashed (GPU OOM)"
                    console.print(f"  [cyan]{label}[/]  [red]model crashed — escalating[/]")
                    if _lms_ensure_loaded is not None:
                        try:
                            _lms_ensure_loaded(llm_model)
                        except Exception as load_err:
                            console.print(f"  [red]reload failed: {load_err}[/]")
                            import time; time.sleep(20)
                    else:
                        import time; time.sleep(20)
                    break  # same input will OOM again — escalate immediately
                else:
                    fail_reason = f"error: {ex}"
                    console.print(f"  [cyan]{label}[/]  [yellow]error ({ex})[/]")
                    break  # non-recoverable

        if result is None:
            escalated.append((line_no, fail_reason))
            continue

        approved = result.get("approved", False)
        confidence = result.get("confidence", "low")
        typst_inner = _sanitize_typst(result.get("typst_inner", proposed_inner or "").strip())

        if not (confidence == "high" and typst_inner and approved is not False):
            conf_str = f" [dim][{confidence}][/]" if confidence != "high" else ""
            console.print(f"  [cyan]{label}[/]  [yellow]escalated[/]{conf_str}")
            escalated.append((line_no, f"low confidence ({confidence})"))
            continue

        # Compile-check the expression; ask LLM to fix on failure (up to 2 tries).
        compile_ok, compile_err = _compile_check(typst_inner, kind)
        fix_attempts = 0
        while not compile_ok and fix_attempts < 2:
            fix_attempts += 1
            wrapper = fmt_replacement(kind, typst_inner)
            fix_prompt = _FIX_PROMPT.format(wrapper=wrapper, error=compile_err[:400])
            try:
                with console.status(f"[cyan]{label}[/] [red]compile error — asking LLM to fix (attempt {fix_attempts})[/]"):
                    fix_resp = '{"' + client.chat.completions.create(
                        model=llm_model,
                        messages=[
                            {"role": "user",      "content": fix_prompt},
                            {"role": "assistant", "content": '{"'},
                        ],
                        max_tokens=512,
                        temperature=0.1,
                    ).choices[0].message.content
                fix_result = _parse_llm_response(fix_resp)
                new_inner = _sanitize_typst(fix_result.get("typst_inner", "").strip())
                if new_inner and fix_result.get("confidence") == "high":
                    typst_inner = new_inner
                    compile_ok, compile_err = _compile_check(typst_inner, kind)
                else:
                    break  # LLM isn't confident — give up
            except Exception:
                break

        if not compile_ok:
            first_err = compile_err.splitlines()[0][:80]
            console.print(f"  [cyan]{label}[/]  [red]compile failed — escalated[/] "
                          f"[dim]{first_err}[/]")
            escalated.append((line_no, f"compile failed: {first_err}"))
            continue

        # All good — write to file.
        current_text = path.read_text()
        all_calls = find_calls(current_text, 1, 10**9, kinds={kind})
        match = next(
            ((s, e) for ln, s, e, k, lx in all_calls
             if k == kind and lx == latex_raw and abs(ln - line_no) <= 5),
            None,
        )
        if match:
            cs, ce = match
            replacement = fmt_replacement(kind, typst_inner)
            path.write_text(current_text[:cs] + replacement + current_text[ce:])
            save_correction(corrections, latex_raw, typst_inner)
            auto_accepted += 1
            fix_tag = f" [dim](fixed in {fix_attempts} attempt{'s' if fix_attempts != 1 else ''})[/]" if fix_attempts else ""
            console.print(f"  [cyan]{label}[/]  [green]✓ auto-accepted[/]{fix_tag}")
        else:
            console.print(f"  [cyan]{label}[/]  [dim]not found (already converted)[/]")

    console.print(f"\n[bold]LLM pass complete.[/] "
                  f"[green]{auto_accepted} auto-accepted[/], "
                  f"[yellow]{len(escalated)} escalated[/]")
    if escalated:
        console.print("\n[yellow]Escalated items[/] [dim](run --review to handle):[/]")
        for esc_line, esc_reason in escalated:
            console.print(f"  [dim]line {esc_line:<6}[/] {esc_reason}")


# ── CLI ───────────────────────────────────────────────────────────────────────

def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("file", type=Path)
    p.add_argument("--review", action="store_true",
                   help="Interactive review of complex #mi() and all #mitex()")
    p.add_argument("--llm-assist", action="store_true",
                   help="Use a local LLM to auto-convert; escalates uncertain items to --review")
    p.add_argument("--llm-url", default="http://127.0.0.1:1234/v1",
                   help="LLM server base URL (default: LM Studio at 127.0.0.1:1234)")
    p.add_argument("--llm-model", default="google/gemma-4-26b-a4b",
                   help="Model name to use (default: google/gemma-4-26b-a4b)")
    p.add_argument("--lines", metavar="START-END",
                   help="Restrict to line range, e.g. 220-350")
    args = p.parse_args()

    if not args.file.exists():
        print(f"File not found: {args.file}")
        sys.exit(1)

    start, end = 1, 10**9
    if args.lines:
        parts = args.lines.split("-")
        start = int(parts[0])
        end = int(parts[1]) if len(parts) > 1 else start

    if args.llm_assist:
        llm_assist(args.file, start, end, args.llm_url, args.llm_model)
    elif args.review:
        review(args.file, start, end)
    else:
        auto_pass(args.file)


if __name__ == "__main__":
    main()
