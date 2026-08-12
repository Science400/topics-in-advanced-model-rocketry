#!/usr/bin/env python3
"""
OCR model bake-off harness.

Runs several OCR models over the same pages and writes their output side by
side so they can be scored by eye. Each model is driven with its own official
prompt — handicapping a model by forcing it into someone else's output format
would measure the prompt, not the model — and the results are then normalized
to plain text + LaTeX so they can be compared.

Usage
-----
    # default: 8 pages sampled across section 2.1, three models
    python pipeline/bakeoff.py --chapter ch1 --section 2.1

    # explicit pages, all four models, same resolution for every model
    python pipeline/bakeoff.py --chapter ch1 --pages 12-19 \
        --models olmocr chandra2 chandra1 infinity --longest-side 1288

    # rebuild the HTML report from cached output without re-running the models
    python pipeline/bakeoff.py --chapter ch1 --section 2.1 --report-only

Output lands in pipeline/bakeoff/<chapter>/:
    p012/olmocr.raw.txt     what the model actually returned
    p012/olmocr.md          normalized to text + LaTeX
    report.html             page image beside every model's output
    results.json            timings and metrics
"""

from __future__ import annotations

import argparse
import html
import json
import re
import time
from dataclasses import dataclass, asdict
from pathlib import Path
from statistics import median

from openai import OpenAI

from config import LM_STUDIO_BASE_URL, PDF_DIR, CHAPTER_PDFS
from lms import ensure_loaded
from term import console
from ocrlib import message_text, metrics, normalize, render_page
import sections as S

_HERE = Path(__file__).parent
OUT_ROOT = _HERE / "bakeoff"


# ---------------------------------------------------------------------------
# Model registry
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class ModelSpec:
    key: str            # model id as LM Studio reports it
    prompt: str         # which prompt family: olmocr | chandra | infinity
    longest_side: int   # render target, longest image edge in px
    temperature: float = 0.1
    top_p: float = 1.0
    max_tokens: int = 8192


# Render targets default to each model's native resolution. Pass --longest-side
# to force them all equal when you want to rule out resolution as the variable.
BAKEOFF_MODELS: dict[str, ModelSpec] = {
    "olmocr":   ModelSpec("allenai/olmocr-2-7b",     "olmocr",   1288),
    "chandra2": ModelSpec("chandra-ocr-2",           "chandra",  1288),
    "chandra1": ModelSpec("chandra-ocr",             "chandra",  1288),
    "infinity": ModelSpec("infinity-parser2-flash",  "infinity", 1600),
}

DEFAULT_MODELS = ["olmocr", "chandra2", "infinity"]


# ---------------------------------------------------------------------------
# Prompts — each model's own, quoted from its model card or package
# ---------------------------------------------------------------------------

# Verbatim from the Infinity-Parser2-Flash model card "Minimal Hello World".
INFINITY_PROMPT = """
- Extract layout information from the provided PDF image.
- For each layout element, output its bbox, category, and the text content within the bbox.
- Bbox format: [x1, y1, x2, y2].
- Allowed layout categories: ['header', 'title', 'text', 'figure', 'table', 'formula', 'figure_caption', 'table_caption', 'formula_caption', 'figure_footnote', 'table_footnote', 'page_footnote', 'footer'].
- Text extraction and formatting:
  1) For 'figure', the text field must be an empty string.
  2) For 'formula', format text as LaTeX.
  3) For 'table', format text as HTML.
  4) For all other categories (e.g., text, title), format text as Markdown.
- The output text must be exactly the original text from the image, with no translation or rewriting.
- Sort all layout elements in human reading order.
- Final output must be a single JSON object.
"""

# Fallback if the chandra package is not importable.
_CHANDRA_FALLBACK = (
    "OCR this image to HTML, arranged as layout blocks. Each layout block should "
    "be a div with the data-bbox attribute representing the bounding box of the "
    "block in [x0, y0, x1, y1] format. Bboxes are normalized 0-1024. The "
    "data-label attribute is the label for the block.\n\n"
    "Inline math: Surround math with <math>...</math> tags. Math expressions "
    "should be rendered in KaTeX-compatible LaTeX. Use display for block math."
)


def build_prompt(family: str) -> str | None:
    if family == "olmocr":
        try:
            from olmocr.prompts import build_no_anchoring_v4_yaml_prompt
            return build_no_anchoring_v4_yaml_prompt()
        except Exception as exc:
            console.print(f"  [yellow]olmocr prompt import failed ({exc}); using generic[/]")
            return "Transcribe this page exactly. Use LaTeX for all math."
    if family == "chandra":
        try:
            from chandra.prompts import PROMPT_MAPPING
            return PROMPT_MAPPING["ocr_layout"]
        except Exception as exc:
            console.print(f"  [yellow]chandra prompt import failed ({exc}); using fallback[/]")
            return _CHANDRA_FALLBACK
    if family == "infinity":
        return INFINITY_PROMPT.strip()
    raise ValueError(f"unknown prompt family: {family}")


# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

def run_model(name: str, spec: ModelSpec, pdf_path: Path, pages: list[int],
              out_dir: Path, longest_side: int | None, force: bool) -> dict[int, dict]:
    ensure_loaded(spec.key)
    client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio", timeout=3600.0)
    prompt_text = build_prompt(spec.prompt)
    side = longest_side or spec.longest_side
    results: dict[int, dict] = {}

    console.print(f"\n[bold cyan]{name}[/] ({spec.key}) @ {side}px")
    for page in pages:
        page_dir = out_dir / f"p{page:03d}"
        page_dir.mkdir(parents=True, exist_ok=True)
        raw_path = page_dir / f"{name}.raw.txt"
        md_path = page_dir / f"{name}.md"

        if raw_path.exists() and not force:
            raw = raw_path.read_text()
            norm = normalize(spec.prompt, raw)
            md_path.write_text(norm)
            results[page] = {"seconds": None, **metrics(norm)}
            console.print(f"  [dim]p{page} cached[/]")
            continue

        image_b64 = render_page(pdf_path, page, side)
        started = time.monotonic()
        try:
            with console.status(f"[cyan]{name} p{page}[/]..."):
                response = client.chat.completions.create(
                    model=spec.key,
                    messages=[{"role": "user", "content": [
                        {"type": "text", "text": prompt_text},
                        {"type": "image_url",
                         "image_url": {"url": f"data:image/png;base64,{image_b64}"}},
                    ]}],
                    max_tokens=spec.max_tokens,
                    temperature=spec.temperature,
                    top_p=spec.top_p,
                )
            raw = message_text(response.choices[0].message)
        except Exception as exc:
            console.print(f"  [red]✗[/] p{page} failed: {exc}")
            results[page] = {"seconds": None, "error": str(exc),
                             "chars": 0, "lines": 0, "math_spans": 0, "latex_cmds": 0}
            continue
        elapsed = time.monotonic() - started

        raw_path.write_text(raw)
        norm = normalize(spec.prompt, raw)
        md_path.write_text(norm)
        m = metrics(norm)
        results[page] = {"seconds": round(elapsed, 1), **m}
        console.print(
            f"  [green]✓[/] p{page} {elapsed:5.1f}s  "
            f"{m['chars']:5d} chars  {m['math_spans']:3d} math"
        )
    return results


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

_REPORT_CSS = """
:root { color-scheme: light dark; --bg:#fff; --fg:#111; --line:#d4d4d4; --muted:#666; --flag:#b45309; }
@media (prefers-color-scheme: dark) {
  :root { --bg:#16181c; --fg:#e6e6e6; --line:#33373d; --muted:#9aa0a6; --flag:#fbbf24; }
}
* { box-sizing: border-box; }
body { margin:0; background:var(--bg); color:var(--fg);
       font: 14px/1.5 ui-sans-serif, system-ui, sans-serif; }
header { position:sticky; top:0; z-index:5; background:var(--bg);
         border-bottom:1px solid var(--line); padding:12px 16px; }
h1 { margin:0 0 4px; font-size:16px; }
.meta { color:var(--muted); font-size:12px; }
table.summary { border-collapse:collapse; margin:12px 16px; font-size:13px; }
table.summary th, table.summary td { border:1px solid var(--line); padding:4px 10px; text-align:right; }
table.summary th:first-child, table.summary td:first-child { text-align:left; }
section.page { border-top:1px solid var(--line); padding:16px; }
h2 { font-size:15px; margin:0 0 10px; }
.cols { display:flex; gap:12px; align-items:flex-start; overflow-x:auto; }
.col { flex:0 0 clamp(360px, 30vw, 560px); }
.col.scan { flex:0 0 clamp(300px, 24vw, 460px); }
.col h3 { font-size:13px; margin:0 0 6px; display:flex; justify-content:space-between; }
.col h3 .stat { color:var(--muted); font-weight:400; }
.col img { width:100%; border:1px solid var(--line); }
pre { margin:0; padding:10px; border:1px solid var(--line); border-radius:4px;
      max-height:70vh; overflow:auto; white-space:pre-wrap; word-break:break-word;
      font: 12px/1.45 ui-monospace, SFMono-Regular, Menlo, monospace; }
.flag { color:var(--flag); font-weight:600; }
"""


def build_report(chapter: str, pdf_path: Path, pages: list[int], model_names: list[str],
                 results: dict[str, dict[int, dict]], out_dir: Path, side: int) -> Path:
    rows = []
    for page in pages:
        chars = [results[m].get(page, {}).get("chars", 0) for m in model_names]
        nonzero = [c for c in chars if c]
        mid = median(nonzero) if nonzero else 0

        cols = [
            '<div class="col scan"><h3>scan</h3>'
            f'<img src="data:image/png;base64,{render_page(pdf_path, page, 1000)}" alt="page {page}"></div>'
        ]
        for name in model_names:
            r = results[name].get(page, {})
            text = (out_dir / f"p{page:03d}" / f"{name}.md")
            body = text.read_text() if text.exists() else r.get("error", "(no output)")
            secs = r.get("seconds")
            stat = f"{r.get('chars', 0)} chars · {r.get('math_spans', 0)} math"
            if secs is not None:
                stat += f" · {secs}s"
            deviant = mid and r.get("chars", 0) and abs(r["chars"] - mid) / mid > 0.30
            cls = ' class="flag"' if deviant else ""
            cols.append(
                f'<div class="col"><h3><span{cls}>{html.escape(name)}</span>'
                f'<span class="stat">{stat}</span></h3>'
                f"<pre>{html.escape(body)}</pre></div>"
            )
        rows.append(
            f'<section class="page"><h2>page {page}</h2>'
            f'<div class="cols">{"".join(cols)}</div></section>'
        )

    def _med(values: list[float], fmt: str) -> str:
        return format(median(values), fmt) if values else "—"

    head = ["<tr><th>model</th><th>pages</th><th>median s</th>"
            "<th>median chars</th><th>median math</th><th>errors</th></tr>"]
    for name in model_names:
        vals = [results[name].get(p, {}) for p in pages]
        secs = [v["seconds"] for v in vals if v.get("seconds") is not None]
        chars = [v.get("chars", 0) for v in vals]
        maths = [v.get("math_spans", 0) for v in vals]
        errors = sum(1 for v in vals if v.get("error"))
        head.append(
            f"<tr><td>{html.escape(name)}</td><td>{len(pages)}</td>"
            f"<td>{_med(secs, '.1f')}</td>"
            f"<td>{_med(chars, '.0f')}</td>"
            f"<td>{_med(maths, '.0f')}</td>"
            f"<td>{errors or ''}</td></tr>"
        )

    doc = (
        "<!doctype html><meta charset='utf-8'>"
        f"<title>OCR bake-off — {chapter}</title><style>{_REPORT_CSS}</style>"
        f"<header><h1>OCR bake-off — {chapter}</h1>"
        f"<div class='meta'>{len(pages)} pages · {', '.join(model_names)} · "
        f"render {side}px · amber = output length &gt;30% off the median</div></header>"
        f"<table class='summary'>{''.join(head)}</table>"
        f"{''.join(rows)}"
    )
    path = out_dir / "report.html"
    path.write_text(doc)
    return path


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--chapter", default="ch1", choices=list(CHAPTER_PDFS))
    ap.add_argument("--section", help="section id from the chapter's TOML map, e.g. 2.1")
    ap.add_argument("--pages", help="explicit pages, e.g. 12-19 or 12,15,18")
    ap.add_argument("--sample", type=int, default=8,
                    help="pages to sample from --section (default 8)")
    ap.add_argument("--models", nargs="+", default=DEFAULT_MODELS,
                    choices=list(BAKEOFF_MODELS), metavar="NAME",
                    help=f"default: {' '.join(DEFAULT_MODELS)}")
    ap.add_argument("--longest-side", type=int,
                    help="force one render size for every model (default: each model's native)")
    ap.add_argument("--force", action="store_true", help="re-run pages that are already cached")
    ap.add_argument("--report-only", action="store_true",
                    help="rebuild report.html from cached output, run nothing")
    args = ap.parse_args()

    if not args.section and not args.pages:
        ap.error("give --section or --pages")

    if args.pages:
        pages = S.parse_pages(args.pages)
    else:
        sec = S.find(args.chapter, args.section)
        start, end = sec.start, sec.end
        pages = S.sample(start, end, args.sample)
        console.print(f"Section {args.section} spans pages {start}–{end}; "
                      f"sampling {len(pages)}: {pages}")

    pdf_path = Path(PDF_DIR) / CHAPTER_PDFS[args.chapter]
    if not pdf_path.exists():
        raise SystemExit(f"Missing PDF: {pdf_path}")
    out_dir = OUT_ROOT / args.chapter
    out_dir.mkdir(parents=True, exist_ok=True)

    results: dict[str, dict[int, dict]] = {}
    started = time.monotonic()
    for name in args.models:
        spec = BAKEOFF_MODELS[name]
        if args.report_only:
            # Re-normalize from the raw capture rather than reusing the old .md,
            # so normalizer changes take effect without re-running any model.
            cached = {}
            for page in pages:
                page_dir = out_dir / f"p{page:03d}"
                raw_path, md_path = page_dir / f"{name}.raw.txt", page_dir / f"{name}.md"
                if raw_path.exists():
                    norm = normalize(spec.prompt, raw_path.read_text())
                    md_path.write_text(norm)
                elif md_path.exists():
                    norm = md_path.read_text()
                else:
                    continue
                cached[page] = {"seconds": None, **metrics(norm)}
            results[name] = cached
        else:
            results[name] = run_model(name, spec, pdf_path, pages, out_dir,
                                      args.longest_side, args.force)

    side = args.longest_side or 0
    report = build_report(args.chapter, pdf_path, pages, args.models, results, out_dir,
                          side or -1)
    (out_dir / "results.json").write_text(json.dumps(
        {"chapter": args.chapter, "pages": pages,
         "models": {n: asdict(BAKEOFF_MODELS[n]) for n in args.models},
         "longest_side_override": args.longest_side,
         "results": {n: {str(p): v for p, v in r.items()} for n, r in results.items()}},
        indent=2))

    if not args.report_only:
        console.print(f"\nTotal {time.monotonic() - started:.0f}s")
    console.print(f"[green]Report:[/] {report}")


if __name__ == "__main__":
    main()
