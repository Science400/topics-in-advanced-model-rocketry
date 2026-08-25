#!/usr/bin/env python3
"""
Compare hosted vision models on a real span of the manuscript, page images in
and finished Typst out — the "skip OCR entirely" hypothesis, measured.

Each model gets the same pages, the same symbol table and the same conventions,
and answers in one call. The outputs are compiled, costed from OpenRouter's own
accounting rather than estimated, and bound into one PDF so they can be read
side by side.

    python pipeline/hosted_bakeoff.py --chapter ch2 --pages 15-28
    python pipeline/hosted_bakeoff.py --chapter ch2 --pages 15-28 --models a,b
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import time
from dataclasses import dataclass, field
from pathlib import Path

import httpx

import sections as S
import symtab
from config import CHAPTER_PDFS, PDF_DIR
from ocrlib import render_page, message_text
from term import console

_HERE = Path(__file__).parent
REPO_ROOT = _HERE.parent
OUT_DIR = _HERE / "bakeoff" / "hosted"

BASE_URL = "https://openrouter.ai/api/v1"
DEFAULT_MODELS = [
    "anthropic/claude-opus-5",
    "openai/gpt-5.6-sol",
    "google/gemini-3.7-flash",
]
LONGEST_SIDE = 1288
MAX_TOKENS = 32000

PROMPT = """\
You are digitising a scanned, typewritten 1970s textbook into Typst. The images \
are consecutive pages, in order.

TRANSCRIBE, DO NOT IMPROVE. This is a faithful digitisation of a public-domain \
book. Reproduce the author's words exactly as printed, including any wording, \
spelling or grammar you would otherwise correct. Do not modernise, do not fix \
the author's mistakes, do not summarise, do not skip anything.

Output Typst only — no code fences, no commentary, no preamble, no `#import`.

CONVENTIONS

Headings, using the numbers this chapter actually uses:
{headings}

Body text
- One sentence per line. This is a hard rule; it makes diffs readable.
- EMPHASIS IS NOT OPTIONAL. Every word or phrase underlined in the scan becomes
  _emphasis_. The underlining is the author's and carries meaning; dropping it
  loses information from the book. Check each line for it.
- The manuscript's `--` is an em dash: write ---.
- Ignore the running head and the page number centred at the top of each page.
- At each page boundary emit a comment line `// === page N ===` using the page
  numbers given below, with no blank line before or after it, so a paragraph
  that runs across the boundary stays one paragraph.

Mathematics — Typst syntax, never LaTeX
- Equation numbers are printed in the LEFT MARGIN, in parentheses, level with
  their equation. An equation that HAS one:
      #eqn("14")[$ C_1 = ... $] <eq:{ch}-14>
- An equation with NO margin number, which is most of them:
      $! C_1 = ... $
  Never write a bare `$ ... $` on its own line; that would be auto-numbered.
- Several rows sharing one margin number stay one equation, rows split by \\
      #eqn("1")[$ omega_D &= ... \\ omega_E &= ... $] <eq:{ch}-1>
- Inline maths uses single dollars: $alpha_D$.
- A lone variable letter in prose is maths, not a word: write "the _body axes_
  $D$, $E$ and $F$", not "D, E and F". This chapter's own symbol table sets
  them that way, so the body must match it.
- Never write `eq.not`; write `!=` for a not-equals sign.

Definitions and lists
- Where the book defines terms in a run — "and define omega_D = angular velocity
  about D, or D-component of angular velocity" — keep the words as PROSE with
  the symbol in inline maths. Do not put the definition text inside a maths
  block as a quoted string; it does not line-break and cannot be edited.

Symbols — use these exact spellings wherever the symbol appears:
{symbols}

Figures
- Some pages are nothing but a figure caption. Emit that page as:
      #figure(
        image("/assets/figures-original/fig{ch}-N.png"),
        caption: [the caption, transcribed exactly]
      ) <fig:{ch}-N>
- Do not invent a caption, and do not reword one.

Cross-references, only where the target exists in these pages
- "Figure 3" -> @fig:{ch}-3
- "equation (5)" -> Eq. #eqref(<eq:{ch}-5>)
- "Section 2.1" -> @sec:{ch}-2.1

Measurements
- A value with a unit: #qty(3.5, "lb"), #qty(300, "ft/s")
- Scientific or grouped numerals: #num("1.4e-6"), #num("12500")
- Leave plain counts alone: "three fins", "the value is 10".

The pages, in order: {pages}
Begin.
"""


@dataclass
class Result:
    model: str
    typst: str = ""
    seconds: float = 0.0
    prompt_tokens: int = 0
    completion_tokens: int = 0
    cost: float | None = None
    compiles: bool = False
    error: str = ""
    notes: list[str] = field(default_factory=list)


def build_prompt(chapter: str, pages: list[int]) -> str:
    num = int(re.search(r"\d+", chapter).group())
    chapter_typ = REPO_ROOT / "src" / "chapters" / f"{Path(CHAPTER_PDFS[chapter]).stem}.typ"
    syms = symtab.parse(chapter_typ)
    listing = "\n".join(f"    {s.typst}  —  {s.meaning[:70]}" for s in syms)
    heads = "\n".join(
        f"    {'=' * (sec.level + 1)} {sec.title} <sec:{num}-{sec.id}>"
        for sec in S.sections(chapter))
    return PROMPT.format(ch=num, symbols=listing, headings=heads,
                         pages=", ".join(str(p) for p in pages))


def ask(model: str, prompt: str, images: list[str], key: str) -> Result:
    content: list[dict] = [{"type": "text", "text": prompt}]
    for b64 in images:
        content.append({"type": "image_url",
                        "image_url": {"url": f"data:image/png;base64,{b64}"}})

    result = Result(model=model)
    started = time.monotonic()
    try:
        r = httpx.post(f"{BASE_URL}/chat/completions",
                       headers={"Authorization": f"Bearer {key}"},
                       json={"model": model, "max_tokens": MAX_TOKENS,
                             "temperature": 0.0,
                             "messages": [{"role": "user", "content": content}]},
                       timeout=1800.0)
        result.seconds = time.monotonic() - started
        if r.is_error:
            result.error = f"{r.status_code}: {r.text[:300]}"
            return result
        body = r.json()
        result.typst = (body["choices"][0]["message"].get("content") or "").strip()
        usage = body.get("usage") or {}
        result.prompt_tokens = usage.get("prompt_tokens", 0)
        result.completion_tokens = usage.get("completion_tokens", 0)
        result.cost = cost_of(body.get("id"), key)
    except Exception as exc:
        result.seconds = time.monotonic() - started
        result.error = str(exc)[:300]
    return result


def cost_of(gen_id: str | None, key: str) -> float | None:
    """
    What OpenRouter actually charged, not what the price list implies.

    Their accounting settles a moment after the response, so this retries a few
    times before giving up and letting the caller fall back to an estimate.
    """
    if not gen_id:
        return None
    for attempt in range(6):
        time.sleep(1.5 * (attempt + 1))
        try:
            r = httpx.get(f"{BASE_URL}/generation", params={"id": gen_id},
                          headers={"Authorization": f"Bearer {key}"}, timeout=60.0)
            if r.is_error:
                continue
            return float(r.json()["data"]["total_cost"])
        except Exception:
            continue
    return None


_FENCE_RE = re.compile(r"^```[a-z]*\s*|\s*```$", re.M)


def _split_letter_digit(text: str) -> tuple[str, int]:
    """Inside $...$ only, and never inside a quoted run within it."""
    count = 0

    def fix(match: re.Match) -> str:
        nonlocal count
        parts = re.split(r'("[^"]*")', match.group(1))
        for i, part in enumerate(parts):
            if part.startswith('"'):
                continue
            parts[i], n = re.subn(r"([A-Za-z])(\d)", r"\1 \2", part)
            count += n
        return "$" + "".join(parts) + "$"

    return re.sub(r"\$([^$]*)\$", fix, text), count


def clean(typst: str) -> tuple[str, list[str]]:
    """Strip what the model was told not to emit, and say what was stripped."""
    notes: list[str] = []
    out = typst
    if "```" in out:
        out = _FENCE_RE.sub("", out)
        notes.append("wrapped its answer in code fences")
    if re.search(r"^#import\b", out, re.M):
        out = re.sub(r"^#import[^\n]*\n?", "", out, flags=re.M)
        notes.append("emitted an #import line")
    if re.search(r"^#show\b", out, re.M):
        out = re.sub(r"^#show[^\n]*\n?", "", out, flags=re.M)
        notes.append("emitted a #show rule")
    # `$^2$` is a LaTeX reflex: in Typst `^` needs a base, so a superscript with
    # nothing before it is a parse error. Three of these in 3,691 lines was the
    # only thing that stopped a whole chapter compiling.
    hats = len(re.findall(r"\$(\^|_)", out))
    if hats:
        out = re.sub(r"\$(\^|_)", r'$""\1', out)
        notes.append(f"wrote {hats} bare `$^n$` superscript(s), which Typst rejects")
    # `M_(s1)`: Typst reads `s1` as an identifier and fails with "unknown
    # variable". A letter followed by a digit is juxtaposition, so it needs the
    # space — the same split the local converter does for `At` -> `A t`.
    out, runs = _split_letter_digit(out)
    if runs:
        notes.append(f"wrote {runs} `s1`-style subscript(s), which Typst reads "
                     f"as an unknown variable")
    if re.search(r"^= ", out, re.M):
        out = re.sub(r"^= ", "== ", out, flags=re.M)
        notes.append("used a level-1 heading (demoted; it would restart the chapter)")
    return out.strip(), notes


HEAD = """#import "/src/preamble.typ": conflict, minor, unit, qty, qtyrange, num, eqn, eqref, symbol-table, chapter-setup, AR
#show: chapter-setup
#set page(numbering: "1")

"""


def compiles(fragment: Path) -> tuple[bool, str]:
    proc = subprocess.run(
        ["typst", "compile", "--root", str(REPO_ROOT), str(fragment),
         str(fragment.with_suffix(".pdf"))],
        capture_output=True, text=True, timeout=300)
    return proc.returncode == 0, proc.stderr.strip()


def money(value: float | None) -> str:
    return "unknown" if value is None else f"${value:.4f}"


def money_typ(value: float | None) -> str:
    """Same, escaped for Typst — a bare $ opens maths and eats the document."""
    return "unknown" if value is None else f"\\${value:.4f}"


def build_report(chapter: str, pages: list[int], results: list[Result]) -> Path:
    """
    Cover sheet, then each model's output, bound into one PDF.

    Each output is rendered as its own document and the PDFs are concatenated,
    rather than #include-ing them all into one. They have to be: every model
    labels the same figure `<fig:2-1>`, and Typst rejects a document that
    defines a label twice. Rendering separately is also the more honest
    comparison, since it is how each would be built for real.
    """
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    offset = S.page_offset(chapter)

    rows = []
    for r in results:
        if r.error:
            status = "request failed"
        else:
            status = "compiles" if r.compiles else "does NOT compile"
        rows.append(
            f'  [{r.model}], [{money_typ(r.cost)}], [{r.prompt_tokens}], '
            f'[{r.completion_tokens}], [{r.seconds:.0f}s], [{status}],')
    total = sum(r.cost or 0 for r in results)

    cover = OUT_DIR / "cover.typ"
    cover.write_text("\n".join([
        HEAD,
        '#align(center)[#text(17pt, weight: "bold")[Hosted model bake-off]]',
        f'#align(center)[{chapter}, pages {pages[0]}--{pages[-1]} '
        f'(printed \u2212{pages[0] + offset}\u2212 to \u2212{pages[-1] + offset}\u2212), '
        f'{len(pages)} page images sent to each model in a single call]',
        "#v(1.5em)",
        "#table(",
        "  columns: 6, stroke: 0.4pt, align: (left, right, right, right, right, left),",
        '  table.header([*Model*], [*Cost*], [*In*], [*Out*], [*Time*], [*Result*]),',
        *rows,
        ")",
        "#v(1em)",
        f"Total billed for this run: *{money_typ(total)}*.",
        "",
        "Costs are what OpenRouter actually charged, read back per request from "
        "its accounting endpoint, not estimated from the price list.",
        "",
        "Each model received identical input: the same page images at "
        f"{LONGEST_SIDE}px, the chapter's own symbol table, its heading numbers, "
        "and the same Typst conventions. Output follows, one model per section, "
        "each rendered on its own.",
        ""]))

    pdfs: list[Path] = []
    ok, err = compiles(cover)
    if not ok:
        raise SystemExit(f"cover page did not compile: {err[:200]}")
    pdfs.append(cover.with_suffix(".pdf"))

    for r in results:
        stem = r.model.replace("/", "_")
        divider = OUT_DIR / f"divider_{stem}.typ"
        note = ("; ".join(r.notes) if r.notes else "")
        lines = [HEAD,
                 "#v(4em)",
                 f'#align(center)[#text(15pt, weight: "bold")[{r.model}]]',
                 "#v(0.6em)",
                 f'#align(center)[{money_typ(r.cost)} \u00b7 {r.completion_tokens} output '
                 f'tokens \u00b7 {r.seconds:.0f}s \u00b7 '
                 + ("compiles" if r.compiles else "does not compile") + "]"]
        if note:
            lines.append(f'#align(center)[#text(9pt, style: "italic")[Departed from the '
                         f'brief: {note}]]')
        if r.error:
            lines.append(f'#v(1em)#align(center)[#text(red)[The request failed]]')
        divider.write_text("\n".join(lines) + "\n")
        if compiles(divider)[0]:
            pdfs.append(divider.with_suffix(".pdf"))

        fragment = OUT_DIR / f"{stem}.typ"
        if r.error or not fragment.exists():
            continue
        if r.compiles and fragment.with_suffix(".pdf").exists():
            pdfs.append(fragment.with_suffix(".pdf"))
        else:
            # Show the source instead, so a failure is still readable and the
            # reason it failed is visible rather than merely asserted.
            src = OUT_DIR / f"source_{stem}.typ"
            src.write_text(HEAD
                           + '#set text(7pt)\n#set page(columns: 1)\n'
                           + f'#raw(read("{stem}.typ"), lang: "typ", block: true)\n')
            if compiles(src)[0]:
                pdfs.append(src.with_suffix(".pdf"))

    # The prompt itself, so the comparison can be read knowing exactly what each
    # model was asked. Regenerated rather than stored when missing: build_prompt
    # is deterministic in the chapter and page range.
    prompt_path = OUT_DIR / "prompt.txt"
    if not prompt_path.exists():
        prompt_path.write_text(build_prompt(chapter, pages))
    appendix = OUT_DIR / "appendix_prompt.typ"
    appendix.write_text(
        HEAD
        + '#v(3em)\n#align(center)[#text(15pt, weight: "bold")[The prompt]]\n'
        + '#align(center)[Sent verbatim to all three models, with the '
        + f'{len(pages)} page images appended in order]\n'
        + '#v(1em)#line(length: 100%)#v(1em)\n'
        + '#set text(8pt)\n'
        + '#raw(read("prompt.txt"), block: true)\n')
    if compiles(appendix)[0]:
        pdfs.append(appendix.with_suffix(".pdf"))

    out = OUT_DIR / "comparison.pdf"
    subprocess.run(["pdfunite", *[str(p) for p in pdfs], str(out)],
                   check=True, capture_output=True, timeout=300)
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--chapter", default="ch2", choices=list(CHAPTER_PDFS))
    ap.add_argument("--pages", default="15-28")
    ap.add_argument("--models", default=",".join(DEFAULT_MODELS))
    ap.add_argument("--report-only", action="store_true",
                    help="rebuild the PDF from the last run's results.json, "
                         "without calling any model again")
    args = ap.parse_args()

    pages = S.parse_pages(args.pages)
    if args.report_only:
        saved = json.loads((OUT_DIR / "results.json").read_text())
        results = [Result(**r) for r in saved]
        doc = build_report(args.chapter, pages, results)
        console.print(f"[bold]report[/] {doc}")
        return

    key = os.environ.get("OPENROUTER_API_KEY")
    if not key:
        raise SystemExit("OPENROUTER_API_KEY is not set")

    models = [m.strip() for m in args.models.split(",") if m.strip()]
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    pdf = Path(PDF_DIR) / CHAPTER_PDFS[args.chapter]
    console.print(f"[dim]rendering {len(pages)} pages at {LONGEST_SIDE}px[/]")
    images = [render_page(pdf, p, LONGEST_SIDE) for p in pages]
    prompt = build_prompt(args.chapter, pages)
    (OUT_DIR / "prompt.txt").write_text(prompt)

    results: list[Result] = []
    for model in models:
        console.print(f"\n[bold]{model}[/]")
        r = ask(model, prompt, images, key)
        if r.error:
            console.print(f"  [red]failed:[/] {r.error[:160]}")
        else:
            r.typst, r.notes = clean(r.typst)
            fragment = OUT_DIR / f"{model.replace('/', '_')}.typ"
            fragment.write_text(HEAD + r.typst + "\n")
            r.compiles, err = compiles(fragment)
            console.print(f"  {r.seconds:.0f}s · {r.prompt_tokens} in / "
                          f"{r.completion_tokens} out · {money(r.cost)} · "
                          + ("[green]compiles[/]" if r.compiles
                             else f"[red]does not compile[/] {err.splitlines()[0][:90] if err else ''}"))
            for note in r.notes:
                console.print(f"  [yellow]![/] {note}")
        results.append(r)

    (OUT_DIR / "results.json").write_text(json.dumps(
        [{k: v for k, v in vars(r).items() if k != "typst"} for r in results], indent=2))
    doc = build_report(args.chapter, pages, results)
    console.print(f"\n[bold]report[/] {doc}")
    console.print(f"[bold]total billed:[/] {money(sum(r.cost or 0 for r in results))}")


if __name__ == "__main__":
    main()
