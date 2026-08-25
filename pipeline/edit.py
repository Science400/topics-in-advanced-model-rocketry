#!/usr/bin/env python3
"""
Editorial pass over an emitted chapter, one section at a time.

The section is the unit, not the page. A page seam is invisible from inside one
page — you cannot tell that half a paragraph is missing, or printed twice, until
you can see both sides of the join — and a figure is often first mentioned two
pages before the plate it belongs to. So the model reads a whole section.

Four passes, each carrying one rulebook. A 26B model holds one set of
instructions well and four badly, and mixing them means a wrong answer about
units can drag an equation down with it:

    equations    the number printed in the left margin, and the symbols
    continuity   is a paragraph doubled, dropped, or wrongly joined at a seam
    references   Figure 14 -> @fig:2-14, Eq. (44a) -> #eqref(<eq:2-44a>)
    units        numerals the deterministic pass could not place

The model never rewrites prose. It returns edit operations, and every one is
checked before it is applied:

    unique       the text to replace must occur exactly once in the section
    invariant    the words a reader reads must be identical afterwards, except
                 those a #qty or #num legitimately absorbs
    compiles     the chapter still typesets, or the section is rolled back

The invariance gate is the important one. Asked to reproduce a page of prose, a
local model will quietly reword it, and no amount of prompting reliably stops
that. Comparing the prose before and after does.

Usage
-----
    python pipeline/edit.py --chapter ch2 --section 2.1
    python pipeline/edit.py --chapter ch2 --all
    python pipeline/edit.py --chapter ch2 --section 2.1 --dry-run
    python pipeline/edit.py --chapter ch2 --section 2.1 --replay ops.json
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass, field
from pathlib import Path

import emit
import mathconv
import sections as S
import stream as ST
import symtab
from config import CHAPTER_PDFS, LM_STUDIO_BASE_URL, PDF_DIR
from term import console

_HERE = Path(__file__).parent
REPORTS = _HERE / "reports"
_CACHE = _HERE / "cache"

# Two models, chosen by what each was measured to do, not by size.
#
# Every candidate was tried on ch2 page 18, which carries exactly one margin
# number, (1), and page 19, which carries none:
#
#   chandra-ocr-2     reads the margin correctly — it is the only model here
#                     that does. It will not answer a question, though: it
#                     ignores output schemas, and asked to judge one equation it
#                     said "no number" for the equation carrying (1). So it is
#                     asked to transcribe, and the reasoning happens in Python.
#   qwen/qwen3.5-9b   answers questions in schema, including the seam judgement
#                     chandra cannot do, and is stable with ~17 GB to spare. It
#                     is a poor margin reader: asked to list page 18's numbers it
#                     answered "1, 2, 3, 1".
#   qwen3.8-27b       reads correctly in a cold standalone probe, but lost the
#                     Vulkan device on every pipeline run, at 4k context and 768px
#                     alike, and costs ~120s a call.
#   bonsai-27b        a Q1_0 quant: fits in 4.4 GB and still takes ~90s a call,
#                     leaks its reasoning instead of answering, and read page 19's
#                     header "-71-" as a margin number.
#   gemma-4 (all)     no vision at all on this machine — every `gemma4` build
#                     dies on image input while no other architecture does. Not
#                     VRAM (e4b is small and fails too) and not the BF16 vision
#                     projector, which was the obvious theory and is wrong, since
#                     qwen3.5-9b ships BF16 and sees fine.
#
# So: chandra reads the pages, qwen answers the questions. Swapping the 9B for a
# stronger instruct model is one line; swapping chandra out needs a model that
# can actually read a left margin, and none of the others could.
VISION_MODEL_KEY = "chandra-ocr-2"
TEXT_MODEL_KEY = "qwen/qwen3.5-9b"

PASS_MODEL = {
    "equations": "vision",     # transcribe the page, reason in Python
    "continuity": "text",      # a judgement: is this first line indented
    "references": "text",
    "units": "text",
}
MODEL_KEYS = {"vision": VISION_MODEL_KEY, "text": TEXT_MODEL_KEY}

# Sampling per model. Chandra is transcribing, where greedy is right and any
# creativity is a misreading. The qwen models are explicitly not recommended for
# greedy decoding, so they get their card's non-thinking preset — thinking is on
# by default and otherwise lands in the parsed output ("...5. **Format the
# answer:** the user requested...") as well as eating the token budget.
SAMPLING_BY_MODEL = {
    VISION_MODEL_KEY: {"temperature": 0.0},
    TEXT_MODEL_KEY: {"temperature": 0.7, "top_p": 0.80, "presence_penalty": 1.5},
}
DEFAULT_SAMPLING = {"temperature": 0.0}
NO_THINKING = {"chat_template_kwargs": {"enable_thinking": False}}

MAX_TOKENS = 4096
# Chandra answers this by transcribing the whole page, which is long.
PAGE_MAX_TOKENS = 8192
PAGE_LONGEST_SIDE = 1288

# The Vulkan backend intermittently drops the device mid-run
# ("vk::Queue::submit: ErrorDeviceLost"), which kills the engine and fails every
# following request until it is reloaded. A chapter is hundreds of model calls,
# so a transient fault must not cost a section. Measured: unloading and pausing
# is what actually recovers it — reloading immediately does not, because LM
# Studio still lists the model as loaded while its engine is dead.
RETRY_ATTEMPTS = 3
RETRY_BACKOFF = 20   # seconds, multiplied by attempt number
SETTLE_SECONDS = 45

PASS_NAMES = ("equations", "continuity", "references", "units")


@dataclass
class Op:
    rule: str
    why: str
    find: str = ""
    replace: str = ""
    page: int = 0

    @property
    def is_flag(self) -> bool:
        return not self.find

    def __str__(self) -> str:
        where = f"p{self.page} " if self.page else ""
        if self.is_flag:
            return f"{where}[{self.rule}] {self.why}"
        return f"{where}[{self.rule}] {self.find[:50]!r} -> {self.replace[:50]!r}  ({self.why})"


@dataclass
class Outcome:
    applied: list[Op] = field(default_factory=list)
    flags: list[Op] = field(default_factory=list)
    rejected: list[tuple[Op, str]] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Locating sections in the emitted chapter
# ---------------------------------------------------------------------------

_HEADING_RE = re.compile(r"^(=+)\s+(.*?)\s*<sec:\d+-([\d.]+)>\s*$", re.M)


def section_spans(text: str) -> list[tuple[str, int, int]]:
    """(section id, start offset, end offset) for each section of the chapter."""
    heads = list(_HEADING_RE.finditer(text))
    stop = text.find("#bibliography(")
    if stop < 0:
        stop = len(text)
    out = []
    for i, head in enumerate(heads):
        end = heads[i + 1].start() if i + 1 < len(heads) else stop
        out.append((head.group(3), head.start(), min(end, stop)))
    return out


# ---------------------------------------------------------------------------
# Page context
# ---------------------------------------------------------------------------

_PAGE_COMMENT_RE = re.compile(r"^// === page (\d+) ===$", re.M)


def page_at(section_text: str, offset: int, fallback: int = 0) -> int:
    """The manuscript page the text at `offset` came from."""
    page = fallback
    for match in _PAGE_COMMENT_RE.finditer(section_text):
        if match.start() > offset:
            break
        page = int(match.group(1))
    return page


def render(chapter: str, page: int) -> str:
    from ocrlib import render_page
    return render_page(Path(PDF_DIR) / CHAPTER_PDFS[chapter], page,
                       PAGE_LONGEST_SIDE)


# ---------------------------------------------------------------------------
# The model
# ---------------------------------------------------------------------------

class Model:
    """LM Studio chat wrapper. Replaced by `Replay` when testing the gates."""

    def __init__(self, key: str):
        from openai import OpenAI
        from lms import ensure_loaded
        self.key = key
        ensure_loaded(key)
        self.client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio",
                             timeout=1800.0)

    def ask(self, prompt: str, image_b64: str | None = None,
            max_tokens: int = MAX_TOKENS) -> str:
        import time

        import lms
        from lms import ensure_loaded
        from ocrlib import message_text

        content: list[dict] = [{"type": "text", "text": prompt}]
        if image_b64:
            content.append({"type": "image_url",
                            "image_url": {"url": f"data:image/png;base64,{image_b64}"}})

        failure = ""
        for attempt in range(1, RETRY_ATTEMPTS + 1):
            try:
                response = self.client.chat.completions.create(
                    model=self.key,
                    messages=[{"role": "user", "content": content}],
                    max_tokens=max_tokens, extra_body=NO_THINKING,
                    **SAMPLING_BY_MODEL.get(self.key, DEFAULT_SAMPLING),
                )
                return message_text(response.choices[0].message)
            except TypeError:
                # An older LM Studio rejects chat_template_kwargs outright.
                # Thinking then stays on, which costs tokens but still answers.
                response = self.client.chat.completions.create(
                    model=self.key,
                    messages=[{"role": "user", "content": content}],
                    max_tokens=max_tokens,
                    **SAMPLING_BY_MODEL.get(self.key, DEFAULT_SAMPLING),
                )
                return message_text(response.choices[0].message)
            except Exception as exc:
                failure = str(exc)
            if attempt < RETRY_ATTEMPTS:
                console.print(f"  [yellow]⟳[/] model call failed "
                              f"({failure[-70:]}); reloading")
                time.sleep(RETRY_BACKOFF * attempt)
                try:
                    lms.unload_all()
                    time.sleep(SETTLE_SECONDS)   # the pause is what recovers it
                    ensure_loaded(self.key)
                except Exception as exc:
                    console.print(f"  [yellow]reload failed: {exc}[/]")
        # Returning empty rather than raising: the caller turns an unusable
        # answer into a flag, so one dead call costs one flag, not the section.
        console.print(f"  [red]giving up on this call:[/] {failure[-90:]}")
        return ""


class Replay:
    """
    Serves canned answers from a JSON file instead of a model.

    The gates are the part of this worth being sure about, and they are pure
    text handling — so they can be exercised, and regression-tested, without a
    GPU or a running LM Studio. The file maps a pass name to a list of answers,
    consumed in order.
    """

    def __init__(self, path: Path):
        self.answers = json.loads(path.read_text())
        self.used: dict[str, int] = {}
        self.current = "unknown"

    def ask(self, prompt: str, image_b64: str | None = None,
            max_tokens: int = MAX_TOKENS) -> str:
        queue = self.answers.get(self.current, [])
        i = self.used.get(self.current, 0)
        self.used[self.current] = i + 1
        if i >= len(queue):
            return "[]"
        answer = queue[i]
        return answer if isinstance(answer, str) else json.dumps(answer)


def parse_json(raw: str):
    """
    Pull the first JSON value out of a reply, tolerating fences and chatter.

    Parsed leniently, via ocrlib, because these answers carry LaTeX inside JSON
    strings and a single backslash is not a valid JSON escape: `"d\\alpha_D"`
    makes `json.loads` reject an otherwise perfect reply. Using the strict parser
    here silently discarded every equation answer the vision model gave.
    """
    from ocrlib import loads_lenient

    text = raw.strip()
    if text.startswith("```"):
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```$", "", text)
    try:
        return loads_lenient(text)
    except (json.JSONDecodeError, ValueError):
        pass
    # Fall back to carving out the first JSON value, if the model wrapped it in
    # chatter. Which bracket to look for is decided by whichever comes FIRST:
    # trying "[" first extracts the empty `"wrong_symbols": []` out of a perfectly
    # good object and returns a list, so every equation answer reads as garbage.
    candidates = [(text.find(o), o, c) for o, c in (("[", "]"), ("{", "}"))
                  if text.find(o) >= 0]
    for _, opener, closer in sorted(candidates):
        start, end = text.find(opener), text.rfind(closer)
        if end > start:
            try:
                return loads_lenient(text[start:end + 1])
            except (json.JSONDecodeError, ValueError):
                continue
    return None


# ---------------------------------------------------------------------------
# Pass A — equations
# ---------------------------------------------------------------------------

_DISPLAY_RE = re.compile(r'^#eqn\("([^"]+)"\)\[\$ (.*) \$\]\s*<eq:\d+-[^>]+>$|^\$! (.*) \$$',
                         re.M)

EQUATION_PROMPT = """\
You are checking one equation from a typewritten rocketry textbook against the \
scanned page it appears on.

The page image is attached. This manuscript prints equation numbers in \
parentheses in the LEFT MARGIN, beside the equation they belong to. Many \
equations have no number at all.

The equation, as currently transcribed:
    {equation}

{numbering}

Symbols used in it, and what the chapter's symbol table says they mean:
{symbols}

Answer with ONLY this JSON object and nothing else:
{{"number": null, "wrong_symbols": [], "note": ""}}

  number         the number printed in the left margin beside THIS equation,
                 without parentheses. null if no number is printed beside it.
                 Do not use a number that appears inside a sentence.
                 Read it off the image. Do NOT copy the shape of this example —
                 it is a template, not an answer.
  wrong_symbols  symbols in the transcription that do not match the page image.
                 Empty list if they all match.
  note           one short sentence, only if something else is wrong.
"""


PAGE_NUMBERS_PROMPT = """\
Transcribe this page of a typewritten rocketry textbook.

Equation numbers are printed in parentheses in the LEFT MARGIN, beside the \
equation they belong to. Record the margin number with the line it belongs to, \
and leave it empty for lines that have none.

Work only from the image.
"""

# Asked to transcribe, chandra replies in its own layout HTML and puts the
# margin number *inside* the equation it belongs to:
#
#   <div data-bbox="160 554 428 675" data-label="Equation-Block">
#   <math display="block">(1) \quad \begin{aligned} \omega_D &amp;= ... </math>
#
# which is the same "(1) \quad" form mathconv already strips off equations
# olmocr transcribed. So chandra has already done the number-to-equation
# matching, and nothing here has to guess at it.
#
# Asking instead for a list of numbers — which reads like the more direct
# question — was tried and is worse for every model: chandra stops transcribing,
# and the instruct models enumerate. qwen3.5-9b answered "1, 2, 3, 1" for a page
# with one number, and bonsai returned the page header "-71-" for a page with
# none. The transcription framing is what makes this reliable.
_NUMBER_LIST_RE = re.compile(r"\(?\b(\d{1,3}[a-z]?)\)?")

# Chandra's older layout-HTML reply is still accepted, since it carries the
# number inside the equation's LaTeX and costs nothing to keep supporting.
_MATH_BLOCK_RE = re.compile(r"<math[^>]*>(.*?)</math>", re.S)

_MARGIN_ENTRY_KEYS = ("equation", "text", "line", "content")

_page_numbers: dict[tuple[str, int], list[tuple[str, str]]] = {}


def numbers_on_page(chapter: str, page: int, model) -> list[tuple[str, str]]:
    """
    (number, line text) for every numbered line in a page's left margin.

    One call per page, not one per equation, and the matching of numbers to
    equations is then done here rather than asked of the model. That is a
    deliberate reversal: asked about a single equation, chandra answered "no
    number" for an equation that plainly carries (1), and given a worked example
    it copied the example's number instead of reading the page. Asked simply to
    transcribe, it reported (1) against all three rows of that equation,
    correctly. So it is used for what it is — a transcriber — and the reasoning
    is done in Python where it can be checked.
    """
    key = (chapter, page)
    if key in _page_numbers:
        return _page_numbers[key]

    # On disk as well as in memory: a vision call costs a minute or two, a
    # chapter has ~200 pages, and re-running the pass after a prompt change
    # should not pay for the same page twice. Delete the file to re-read a page.
    cached = _CACHE / chapter / f"p{page:03d}.margins.json"
    if cached.exists():
        found = [(n, t) for n, t in json.loads(cached.read_text())]
        _page_numbers[key] = found
        return found

    raw = model.ask(PAGE_NUMBERS_PROMPT, render(chapter, page),
                    max_tokens=PAGE_MAX_TOKENS)
    found = _from_html(raw) or _from_json(raw) or _from_list(raw)

    # Only a real answer is cached. `ask` returns "" when every retry failed,
    # and an empty list is also what a page with no margin numbers looks like —
    # writing that to disk would record a dead GPU as a fact about the page and
    # every later run would trust it without ever asking again.
    if raw.strip():
        cached.parent.mkdir(parents=True, exist_ok=True)
        cached.write_text(json.dumps(found, indent=2))
        _page_numbers[key] = found
    return found


def _from_html(raw: str) -> list[tuple[str, str]]:
    """Chandra's native layout HTML: the number leads the equation's LaTeX."""
    import html as html_mod

    found: list[tuple[str, str]] = []
    for block in _MATH_BLOCK_RE.finditer(raw):
        body = html_mod.unescape(block.group(1)).strip()
        number = mathconv._EQNUM_RE.match(body)
        if not number:
            continue          # an unnumbered display equation, which is normal
        found.append(((number.group(1) or number.group(2)), body[number.end():]))
    return found


def _from_list(raw: str) -> list[tuple[str, str]]:
    """
    A plain comma-separated answer: "1, 2, 3" or "NONE".

    The equation text comes back empty, so `best_match` cannot score these by
    content. That is handled where it matters: with one number on a page there
    is nothing to disambiguate, and with several the caller falls back to
    document order.
    """
    text = raw.strip()
    if not text or re.search(r"\bnone\b", text, re.I):
        return []
    # Only take the answer line: a chatty model may explain itself first, and
    # prose sentences are full of digits that are not margin numbers.
    line = next((l for l in reversed(text.splitlines()) if l.strip()), "")
    return [(n, "") for n in _NUMBER_LIST_RE.findall(line)][:12]


def _from_json(raw: str) -> list[tuple[str, str]]:
    """The other shape it sometimes returns: [{"number", "text", ...}]."""
    answer = parse_json(raw)
    found: list[tuple[str, str]] = []
    for item in answer if isinstance(answer, list) else []:
        if not isinstance(item, dict):
            continue
        number = str(item.get("number") or "").strip().strip("()")
        if not re.fullmatch(r"\d{1,3}[a-z]?", number):
            continue
        text = next((str(item[k]) for k in _MARGIN_ENTRY_KEYS if item.get(k)), "")
        found.append((number, text))
    return found


# The two sides spell the same equation completely differently: chandra returns
# "ω_D = ∝α_D / dt" in Unicode, the emitter holds "omega_D &= (dif alpha_D)/(dif
# t)" in Typst. Reducing both to a bag of names is what makes them comparable.
_GREEK_CHARS = {
    "α": "alpha", "β": "beta", "γ": "gamma", "δ": "delta", "ε": "epsilon",
    "ζ": "zeta", "η": "eta", "θ": "theta", "ι": "iota", "κ": "kappa",
    "λ": "lambda", "μ": "mu", "ν": "nu", "ξ": "xi", "ρ": "rho", "σ": "sigma",
    "τ": "tau", "υ": "upsilon", "φ": "phi", "χ": "chi", "ψ": "psi",
    "ω": "omega", "Γ": "gamma", "Δ": "delta", "Θ": "theta", "Λ": "lambda",
    "Ξ": "xi", "Π": "pi", "Σ": "sigma", "Φ": "phi", "Ψ": "psi", "Ω": "omega",
    "π": "pi", "∫": "integral", "∂": "partial", "√": "sqrt", "∞": "infinity",
}
# Syntax that carries no identity: it appears on one side or the other purely
# as a spelling choice, so counting it would make unrelated equations look alike.
_MATH_NOISE = {"dif", "d", "frac", "left", "right", "quad", "qquad", "text",
               "mathrm", "cdot", "times", "equiv", "approx"}


def math_tokens(expression: str) -> set[str]:
    """A bag of identifier names, for comparing two spellings of one equation."""
    text = expression
    for char, name in _GREEK_CHARS.items():
        text = text.replace(char, f" {name} ")
    text = re.sub(r"\\([A-Za-z]+)", r" \1 ", text)      # LaTeX commands
    # A differential written solid — "dt", "dx" — is the same thing the Typst
    # side spells "dif t". Splitting it makes the two comparable; leaving it
    # whole cost the real match on ch2 p18 most of its overlap.
    text = re.sub(r"\bd([a-zA-Z])\b", r" \1 ", text)
    names = re.findall(r"[A-Za-z]+|\d+", text)
    return {n.lower() for n in names if n.lower() not in _MATH_NOISE}


def best_match(expression: str, entries: list[tuple[str, str]]) -> str | None:
    """
    The margin number of the transcribed line that best matches this equation.

    Overlap has to be decisive, not merely best: most display equations on a
    page are unnumbered, so the closest numbered line is frequently not this
    equation at all. A weak or ambiguous match yields None, which leaves the
    equation visibly unnumbered rather than confidently wrong.
    """
    mine = math_tokens(expression)
    if not mine:
        return None
    scored: list[tuple[float, str]] = []
    for number, text in entries:
        theirs = math_tokens(text)
        if not theirs:
            continue
        overlap = len(mine & theirs) / len(mine | theirs)
        scored.append((overlap, number))
    if not scored:
        return None
    scored.sort(reverse=True)
    best, number = scored[0]
    if best < 0.34:
        return None
    # A tie between two different numbers means the match is not identifying.
    rivals = {n for score, n in scored if score > best - 0.05 and n != number}
    return None if rivals else number


def by_position(entries: list[tuple[str, str]], on_page: list,
                match) -> str | None:
    """
    Line a bare list of margin numbers up against the equations on that page.

    Used when the model answered with numbers alone and gave nothing to match on
    content. Only when the counts agree: three numbers against three equations
    means the nth number belongs to the nth equation, but three numbers against
    five equations says nothing about which two are unnumbered, and guessing
    there would put a wrong number in the book. Mismatches fall through to a
    flag instead.
    """
    if not entries or len(entries) != len(on_page):
        return None
    for i, m in enumerate(on_page):
        if m.start() == match.start():
            return entries[i][0]
    return None


def plausible_next(number: str, seen: list[str], window: int = 20) -> bool:
    """
    Whether a proposed equation number fits the sequence so far.

    The manuscript numbers its equations in ascending order across the chapter,
    so a number far from where the sequence has reached is a misreading however
    confidently it is offered. This costs nothing and catches the case both
    model prompts get wrong together.
    """
    value = int(re.match(r"\d+", number).group())
    if not seen:
        return True
    last = max(int(re.match(r"\d+", n).group()) for n in seen)
    return last <= value <= last + window


def equation_symbols(expression: str, index: dict, table: dict[str, str]) -> str:
    """The symbol-table rows relevant to one equation, rather than all 183."""
    _, unknown = mathconv.canonicalise(expression, index)
    names = sorted(set(re.findall(r"[A-Za-z][A-Za-z0-9]*(?:_(?:\([^()]*\)|[A-Za-z0-9]+))?",
                                  expression)))
    lines = []
    for name in names[:24]:
        meaning = table.get(name)
        if meaning:
            lines.append(f"    {name} — {meaning}")
    for name in sorted(set(unknown))[:8]:
        lines.append(f"    {name} — NOT IN THE SYMBOL TABLE, check it carefully")
    return "\n".join(lines) or "    (none recognised)"


def pass_equations(chapter: str, sid: str, text: str, model, index: dict,
                   table: dict[str, str], chapter_num: int) -> list[Op]:
    """
    Give each display equation the number printed beside it, or leave it bare.

    One model call per page — a plain transcription — and all the reasoning
    here. The model is never asked which number belongs to which equation,
    because when it was asked it got it wrong; it is asked only what the page
    says, which it gets right.
    """
    ops: list[Op] = []
    equations = list(_DISPLAY_RE.finditer(text))
    if not equations:
        return ops

    # Display equations grouped by the page they sit on, in document order, so a
    # bare list of margin numbers can be lined up against them.
    by_page: dict[int, list] = {}
    for m in equations:
        by_page.setdefault(page_at(text, m.start()), []).append(m)

    # Numbers already established, in order, so a proposal can be checked
    # against the sequence. Seeded with the ones the transcriber captured.
    accepted: list[str] = sorted(
        (m.group(1) for m in equations if m.group(1)),
        key=lambda n: int(re.match(r"\d+", n).group()))

    for match in equations:
        numbered = match.group(1)
        expression = match.group(2) if numbered else match.group(3)
        page = page_at(text, match.start())
        whole = match.group(0)

        entries = numbers_on_page(chapter, page, model)
        if any(t.strip() for _, t in entries):
            # The reply carried equation text, so match on content.
            found = best_match(expression, entries)
        else:
            found = by_position(entries, by_page.get(page, []), match)

        # The sequence is the one check that needs no model at all: the
        # manuscript numbers ascend, so a number far from where the sequence has
        # reached is a misreading however plainly it appears in the transcript.
        if found and not plausible_next(found, accepted):
            ops.append(Op("eqnum", f"page {page}'s margin reads ({found}) beside "
                                   f"this equation, but that is out of sequence "
                                   f"after ({accepted[-1]}) — left unnumbered",
                          page=page))
            found = None

        if found and not numbered:
            accepted.append(found)
            ops.append(Op("eqnum", f"margin shows ({found}); equation was unnumbered",
                          find=whole,
                          replace=f'#eqn("{found}")[$ {expression} $] '
                                  f"<eq:{chapter_num}-{found}>",
                          page=page))
        elif found and numbered and found != numbered:
            # Not applied automatically: renumbering also invalidates every
            # reference to the old number, and getting that wrong is worse than
            # leaving it.
            ops.append(Op("eqnum", f"transcribed as ({numbered}) but the margin "
                                   f"appears to read ({found}) — check the scan",
                          page=page))
        elif numbered and not found:
            ops.append(Op("eqnum", f"({numbered}) was transcribed but no margin "
                                   f"number on page {page} matches this equation",
                          page=page))
        elif not found and entries:
            ops.append(Op("eqnum", f"page {page} has margin number(s) "
                                   f"{', '.join(sorted({n for n, _ in entries}))} "
                                   f"but none matched this equation: "
                                   f"{expression[:60]}", page=page))
        elif not found and not numbered:
            # Said explicitly rather than passed over. Most display equations
            # really are unnumbered, but "the model reported no margin numbers
            # anywhere on this page" and "this equation has none" are different
            # facts, and only one of them means the pass worked.
            ops.append(Op("eqnum", f"no margin numbers were read anywhere on "
                                   f"page {page}; this equation is left "
                                   f"unnumbered: {expression[:60]}", page=page))

        # Symbols are checked locally against the chapter's own table; the model
        # is not consulted, since it cannot see which spelling was intended.
        _, unknown = mathconv.canonicalise(expression, index)
        for symbol in sorted(set(unknown))[:4]:
            ops.append(Op("symbol", f"{symbol!r} is not in the chapter symbol "
                                    f"table: {expression[:50]}", page=page))

        if len(expression) > 200 or "\\" in expression:
            ops.append(Op("equation", f"long or multi-line equation, check it "
                                      f"against the scan: {expression[:70]}",
                          page=page))
    return ops


# ---------------------------------------------------------------------------
# Pass B — continuity
# ---------------------------------------------------------------------------

SEAM_PROMPT = """\
The attached image is the top of one page of a typewritten book.

In this manuscript a new paragraph is marked by INDENTING its first line — the \
first line starts further right than the lines below it. A page that continues a \
paragraph from the previous page starts flush with the left margin.

Look only at the first line of body text, ignoring any page number centred above it.

Answer with ONLY this JSON object:
{"indented": true or false}
"""


def pass_continuity(chapter: str, sid: str, text: str, model) -> list[Op]:
    """
    Decide the paragraph breaks the transcription cannot express.

    `stream.py` joins across every page seam by default, because a wrongly split
    paragraph is invisible while a wrongly joined one shows a page comment
    sitting at the join. That default is right but it is still a guess, and the
    page image settles it: the manuscript indents the first line of a paragraph,
    so a seam whose incoming page is indented really was a paragraph break.
    """
    ops: list[Op] = []
    lines = text.split("\n")
    for i, line in enumerate(lines):
        match = _PAGE_COMMENT_RE.match(line)
        # Only seams *inside* a paragraph are in question. One already sitting
        # at a blank line is a paragraph break either way.
        if not match or i == 0 or not lines[i - 1].strip():
            continue
        page = int(match.group(1))
        answer = parse_json(model.ask(SEAM_PROMPT, render(chapter, page)))
        if isinstance(answer, dict) and answer.get("indented") is True:
            ops.append(Op("seam", f"page {page} starts a new paragraph (its first "
                                  f"line is indented)",
                          find=line + "\n", replace=line + "\n\n", page=page))
    return ops


# ---------------------------------------------------------------------------
# Pass C — references
# ---------------------------------------------------------------------------

REFERENCE_PROMPT = """\
Below is one section of a rocketry textbook, already typeset in Typst.

Find places where the prose names a figure, equation or section by number but \
does NOT use a Typst reference. Correct forms look like:

    @fig:{ch}-14                     for "Figure 14"
    Eq. #eqref(<eq:{ch}-44a>)        for "Eq. (44a)"
    @sec:{ch}-3.2                    for "Section 3.2"

These labels exist in this chapter and are the ONLY ones you may reference:
{labels}

Rules:
- Never change any other word. You are adding references, not editing prose.
- Never reference a label that is not in the list above.
- Text already inside $...$ is mathematics; leave it alone.
- Ignore text inside // comments.

Answer with ONLY a JSON array, and [] if there is nothing to change:
[{{"find": "exact text from the section", "replace": "the same text with the reference", "why": "short reason"}}]

The section:
---
{section}
---
"""


def pass_references(sid: str, text: str, model, labels: set[str],
                    chapter_num: int) -> list[Op]:
    listing = "\n".join(f"    {l}" for l in sorted(labels)[:120])
    answer = parse_json(model.ask(REFERENCE_PROMPT.format(
        ch=chapter_num, labels=listing, section=ST.strip_marks(text))))
    return _ops_from_array(answer, "reference")


# ---------------------------------------------------------------------------
# Pass D — units
# ---------------------------------------------------------------------------

UNITS_PROMPT = """\
Below is one section of a rocketry textbook, already typeset in Typst.

Measurements should be written `#qty(3.5, "lb")` and awkward numerals \
`#num("1.4e-6")`. A converter has already done the ones it recognised.

Find numerals it missed — a value with a unit still written as plain prose. Do \
NOT convert plain counts ("3 fins", "the value is 10"): only measurements.

Report them; do not rewrite them. Answer with ONLY a JSON array, [] if none:
[{{"quote": "the exact phrase", "why": "what unit it is"}}]

The section:
---
{section}
---
"""


def pass_units(sid: str, text: str, model) -> list[Op]:
    answer = parse_json(model.ask(UNITS_PROMPT.format(section=ST.strip_marks(text))))
    ops: list[Op] = []
    if isinstance(answer, list):
        for item in answer[:40]:
            if isinstance(item, dict) and item.get("quote"):
                ops.append(Op("units", f"{str(item['quote'])[:80]!r} — "
                                       f"{str(item.get('why', ''))[:80]}"))
    return ops


def _ops_from_array(answer, rule: str) -> list[Op]:
    ops: list[Op] = []
    if not isinstance(answer, list):
        return ops
    for item in answer[:60]:
        if not isinstance(item, dict):
            continue
        find, replace = str(item.get("find", "")), str(item.get("replace", ""))
        why = str(item.get("why", ""))[:160]
        if find and replace and find != replace:
            ops.append(Op(rule, why, find=find, replace=replace))
        elif item.get("why"):
            ops.append(Op(rule, why))
    return ops


# ---------------------------------------------------------------------------
# Gates
# ---------------------------------------------------------------------------

_LABEL = r"(?:fig|eq|sec):[\d.a-z-]*[\da-z]"
# A section label carries dots inside it (sec:2-3.2.1) but a label never *ends*
# with one — a trailing dot is the sentence's, and swallowing it would make a
# perfectly good @fig:2-1. look like a reference to the undefined "fig:2-1.".
#
# Only *references* are gated. `<eq:2-44a>` written after an #eq() call is a
# definition, and the equations pass exists precisely to create those — gating
# them would refuse every equation number the model recovers.
_REF_RE = re.compile(rf"@({_LABEL})|ref\(<({_LABEL})>")
_DEF_RE = re.compile(rf"(?<!ref\()<({_LABEL})>")


def _referenced(text: str) -> set[str]:
    return {a or b for a, b in _REF_RE.findall(text)}


def defined_labels(text: str) -> set[str]:
    return set(_DEF_RE.findall(text))


def invented_labels(op: Op, known: set[str]) -> list[str]:
    """
    Labels an edit *refers to* that the chapter does not define.

    The prose-invariance gate cannot see these on its own: turning "in Figure 1"
    into "in @fig:2-1 and @fig:2-7" adds the word "and" and is caught, but
    "in @fig:2-1, @fig:2-7" adds no prose word at all and would pass. A
    reference to a label that exists but is the wrong one compiles perfectly and
    reads as fact, which makes it the worst kind of error to let through.
    """
    new = _referenced(op.replace) - _referenced(op.find)
    return sorted(l for l in new if l not in known | defined_labels(op.replace))


def apply_ops(text: str, ops: list[Op],
              known_labels: set[str] | None = None) -> tuple[str, Outcome]:
    """
    Apply what is safe, reject what is not, and say why for each.

    Ops are applied one at a time and each is re-checked against the current
    text, so two ops that would both have matched the original but overlap each
    other cannot silently corrupt it.
    """
    known = known_labels or set()
    outcome = Outcome()
    for op in ops:
        if op.is_flag:
            outcome.flags.append(op)
            continue

        invented = invented_labels(op, known)
        if invented:
            outcome.rejected.append(
                (op, f"it references {', '.join(invented)}, which this chapter "
                     f"does not define"))
            outcome.flags.append(Op(op.rule, f"(edit refused) {op.why}", page=op.page))
            continue

        count = text.count(op.find)
        if count == 0:
            outcome.rejected.append((op, "the text to replace is not in the section"))
            continue
        if count > 1:
            outcome.rejected.append(
                (op, f"the text to replace occurs {count} times, so which one "
                     f"was meant is unknown"))
            continue

        candidate = text.replace(op.find, op.replace, 1)
        before, after = ST.prose_words(text), ST.prose_words(candidate)
        if before != after:
            outcome.rejected.append(
                (op, f"it would change the prose a reader reads "
                     f"({_first_difference(before, after)}), not just the markup"))
            # A rejected edit is still a place the model saw something. Keeping
            # it as a flag means the observation is not thrown away.
            outcome.flags.append(Op(op.rule, f"(edit refused) {op.why}", page=op.page))
            continue

        text = candidate
        outcome.applied.append(op)
    return text, outcome


def _first_difference(before: list[str], after: list[str]) -> str:
    for i, (a, b) in enumerate(zip(before, after)):
        if a != b:
            return f"{a!r} became {b!r}"
    if len(before) != len(after):
        longer, shorter = (before, after) if len(before) > len(after) else (after, before)
        return f"{len(longer) - len(shorter)} word(s) added or removed"
    return "changed"


# ---------------------------------------------------------------------------
# Reports
# ---------------------------------------------------------------------------

def write_report(chapter: str, sid: str, title: str, outcome: Outcome) -> Path:
    out = REPORTS / chapter
    out.mkdir(parents=True, exist_ok=True)
    offset = S.page_offset(chapter)

    def where(op: Op) -> str:
        if not op.page:
            return ""
        printed = op.page + offset
        return f"p{op.page}" + (f" (printed −{printed}−)" if offset else "") + " — "

    lines = [f"# {chapter} §{sid} — {title}", ""]
    lines += [f"{len(outcome.applied)} change(s) applied, "
              f"{len(outcome.flags)} flag(s), "
              f"{len(outcome.rejected)} edit(s) refused.", ""]
    if outcome.applied:
        lines += ["## Applied", ""]
        lines += [f"- `{op.rule}` {where(op)}{op.find[:70]!r} → "
                  f"{op.replace[:70]!r}  \n  {op.why}" for op in outcome.applied]
        lines.append("")
    if outcome.flags:
        lines += ["## Needs a closer look", ""]
        lines += [f"- `{op.rule}` {where(op)}{op.why}" for op in outcome.flags]
        lines.append("")
    if outcome.rejected:
        lines += ["## Refused", "",
                  "The model proposed these and the gates turned them down.", ""]
        lines += [f"- `{op.rule}` {op.find[:60]!r} → {op.replace[:60]!r}  \n  "
                  f"refused: {reason}" for op, reason in outcome.rejected]
        lines.append("")
    path = out / f"{sid}.md"
    path.write_text("\n".join(lines))
    return path


def write_summary(chapter: str, all_outcomes: dict[str, Outcome]) -> Path:
    out = REPORTS / chapter
    out.mkdir(parents=True, exist_ok=True)
    by_rule: dict[str, list[tuple[str, Op]]] = {}
    applied = flags = refused = 0
    for sid, outcome in all_outcomes.items():
        applied += len(outcome.applied)
        refused += len(outcome.rejected)
        for op in outcome.flags:
            flags += 1
            by_rule.setdefault(op.rule, []).append((sid, op))

    offset = S.page_offset(chapter)
    lines = [f"# {chapter} — editorial pass", "",
             f"{applied} change(s) applied across {len(all_outcomes)} section(s). "
             f"{flags} flag(s) below. {refused} edit(s) refused by the gates.", "",
             "Work through the flags; each names the section and the manuscript "
             "page it came from.", ""]
    for rule in sorted(by_rule):
        lines += [f"## {rule} ({len(by_rule[rule])})", ""]
        for sid, op in by_rule[rule]:
            page = f"p{op.page + offset}" if op.page else "—"
            lines.append(f"- §{sid} {page}: {op.why}")
        lines.append("")
    path = out / "SUMMARY.md"
    path.write_text("\n".join(lines))
    return path


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def edit_chapter(chapter: str, only: str | None, passes: tuple[str, ...],
                 make_model, dry_run: bool,
                 path: Path | None = None) -> dict[str, Outcome]:
    chapter_num = int(re.search(r"\d+", chapter).group())
    path = path or emit.chapter_file(chapter)
    source = path.read_text()

    symbols = symtab.parse(path)
    index = mathconv.build_symbol_index(symbols)
    table = {s.typst: s.meaning for s in symbols}

    stream, _ = ST.assemble(chapter)
    labels = emit.collect_labels(chapter, chapter_num, stream)
    titles = {s.id: s.title for s in S.sections(chapter)}

    outcomes: dict[str, Outcome] = {}

    def record(sid: str, step: Outcome) -> Outcome:
        got = outcomes.setdefault(sid, Outcome())
        got.applied += step.applied
        got.flags += step.flags
        got.rejected += step.rejected
        return got

    # Grouped by model, vision first. Swapping models is a 30-second load, so
    # doing it per section would cost more than the editing does — and the
    # equations pass has to run before the references pass in any case, since it
    # defines the labels the references pass is allowed to point at.
    # Grouped by the model each pass needs, in the order the passes were given.
    # Derived rather than hard-coded: with one editor model there is a single
    # group, and hard-coding ("vision", "text") silently matched nothing and ran
    # no passes at all when the two models were collapsed into one.
    groups: list[str] = []
    for name in passes:
        if PASS_MODEL[name] not in groups:
            groups.append(PASS_MODEL[name])

    for group in groups:
        group_passes = [p for p in passes if PASS_MODEL[p] == group]
        if not group_passes:
            continue
        model = make_model(group)
        console.print(f"\n[dim]{group} passes: {', '.join(group_passes)}[/]")

        # Recomputed per group: an earlier group's edits moved these offsets.
        # Right to left, so applying a section's edits cannot move the offsets
        # of a section not yet processed.
        for sid, start, end in reversed(section_spans(source)):
            if only and sid != only:
                continue
            text = source[start:end]
            console.print(f"\n[bold]§{sid}[/] {titles.get(sid, '')} "
                          f"({len(text.split())} words)")

            edited = text
            outcome = Outcome()
            for name in group_passes:
                if hasattr(model, "current"):
                    model.current = name
                known = labels | defined_labels(source) | defined_labels(edited)
                try:
                    if name == "equations":
                        ops = pass_equations(chapter, sid, edited, model, index,
                                             table, chapter_num)
                    elif name == "continuity":
                        ops = pass_continuity(chapter, sid, edited, model)
                    elif name == "references":
                        ops = pass_references(sid, edited, model, known, chapter_num)
                    else:
                        ops = pass_units(sid, edited, model)
                except Exception as exc:
                    console.print(f"  [red]{name} pass failed:[/] {exc}")
                    continue
                edited, step = apply_ops(edited, ops, known)
                outcome.applied += step.applied
                outcome.flags += step.flags
                outcome.rejected += step.rejected

            console.print(f"  {len(outcome.applied)} applied, {len(outcome.flags)} "
                          f"flagged, {len(outcome.rejected)} refused")
            for op, reason in outcome.rejected:
                console.print(f"    [yellow]refused[/] {op.rule}: {reason}")

            if not dry_run and edited != text:
                candidate = source[:start] + edited + source[end:]
                path.write_text(candidate)
                ok, err = emit.chapter_compiles(path)
                if ok:
                    source = candidate
                else:
                    path.write_text(source)
                    first = next((l for l in err.splitlines() if l.strip()), "")
                    console.print(f"  [red]rolled back — does not compile:[/] {first}")
                    outcome = Outcome(flags=outcome.flags + [
                        Op("compile", f"the {group} edits for this section were "
                                      f"rolled back because the chapter stopped "
                                      f"compiling")])
            record(sid, outcome)

    if not dry_run:
        for sid, outcome in outcomes.items():
            write_report(chapter, sid, titles.get(sid, ""), outcome)
    return outcomes


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--chapter", default="ch2", choices=list(CHAPTER_PDFS))
    group = ap.add_mutually_exclusive_group(required=True)
    group.add_argument("--section")
    group.add_argument("--all", action="store_true")
    ap.add_argument("--passes", default=",".join(PASS_NAMES),
                    help=f"comma-separated subset of: {', '.join(PASS_NAMES)}")
    ap.add_argument("--dry-run", action="store_true",
                    help="report what would change without touching the file")
    ap.add_argument("--replay", type=Path,
                    help="canned model answers, for exercising the gates with no GPU")
    ap.add_argument("--file", metavar="NAME",
                    help="edit src/chapters/NAME.typ instead of the chapter itself, "
                         "to match a pilot run written by `emit.py --out NAME`")
    args = ap.parse_args()

    passes = tuple(p.strip() for p in args.passes.split(",") if p.strip())
    unknown = [p for p in passes if p not in PASS_NAMES]
    if unknown:
        raise SystemExit(f"unknown pass(es): {', '.join(unknown)}")

    target = emit.CHAPTERS_DIR / f"{args.file}.typ" if args.file else None
    if target and not target.exists():
        raise SystemExit(f"no such chapter file: {target}")

    if args.replay:
        shared = Replay(args.replay)
        make_model = lambda _group: shared
    else:
        make_model = lambda group: Model(MODEL_KEYS[group])
    outcomes = edit_chapter(args.chapter, args.section, passes, make_model,
                            args.dry_run, target)

    if not args.dry_run and outcomes:
        summary = write_summary(args.chapter, outcomes)
        console.print(f"\n[green]{summary}[/]")


if __name__ == "__main__":
    main()
