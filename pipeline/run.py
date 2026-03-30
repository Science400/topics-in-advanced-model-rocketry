"""End-to-end pipeline runner: OCR → compare → resolve → assemble → typst compile.

Usage (from project root):
    uv run --project pipeline python pipeline/run.py --chapter ch3 --pages 23-25

Skip stages already completed:
    uv run --project pipeline python pipeline/run.py --chapter ch3 --pages 23-25 --skip-ocr
"""
import argparse
import sqlite3
import subprocess
import sys
import time
from pathlib import Path

# Ensure pipeline/ is on sys.path regardless of working directory
_PIPELINE = Path(__file__).parent
if str(_PIPELINE) not in sys.path:
    sys.path.insert(0, str(_PIPELINE))

ROOT = _PIPELINE.parent

from assemble     import assemble_chapter
from compare      import compare_page
from config       import (AI_CONFIDENCE_THRESHOLD, CHAPTER_PDFS,
                          COMPARISON_MODELS, DEFAULT_COMPARISON_MODEL,
                          RESOLUTION_MODELS)
from lms          import ensure_loaded
from ocr_pages    import process_all_models
from resolve      import _load_symbol_context, resolve_page
from term         import console


def parse_pages(pages_arg):
    if "-" in pages_arg:
        start, end = pages_arg.split("-")
        return int(start), int(end)
    n = int(pages_arg)
    return n, n


def _banner(stage, msg=""):
    console.print()
    console.rule(f"[bold]{stage}[/]  {msg}")


def main():
    parser = argparse.ArgumentParser(
        description="Run the full OCR → compare → resolve → assemble → compile pipeline."
    )
    parser.add_argument("--chapter",        required=True, choices=list(CHAPTER_PDFS))
    parser.add_argument("--pages",          default=None, help="e.g. 23-25 or 24 (not needed with --refresh)")
    parser.add_argument("--refresh",        action="store_true",
                        help="Re-assemble and recompile from DB; skips OCR/compare/resolve")
    parser.add_argument("--accept-all",     action="store_true",
                        help="Accept all escalated/pending spans as-is, then refresh")
    parser.add_argument("--compare-model",  default="gemma",    choices=list(COMPARISON_MODELS))
    parser.add_argument("--resolve-model",  default="qwen3-4b", choices=list(RESOLUTION_MODELS))
    parser.add_argument("--threshold",      type=float, default=0.85,
                        help=f"Resolve confidence threshold (default: 0.85)")
    parser.add_argument("--also-minor",     action="store_true",
                        help="Also resolve MINOR spans (default: CONFLICT only)")
    parser.add_argument("--pdf",            default="output.pdf",
                        help="Output PDF filename (default: output.pdf)")
    parser.add_argument("--skip-ocr",       action="store_true")
    parser.add_argument("--skip-compare",   action="store_true")
    parser.add_argument("--skip-resolve",   action="store_true")
    parser.add_argument("--skip-assemble",  action="store_true")
    parser.add_argument("--skip-compile",   action="store_true")
    args = parser.parse_args()

    if args.accept_all:
        args.refresh = True

    if args.refresh:
        args.skip_ocr = args.skip_compare = args.skip_resolve = True

    if args.pages is None and not args.refresh:
        parser.error("--pages is required unless --refresh is set")

    if args.pages:
        start, end = parse_pages(args.pages)
        total_pages = end - start + 1
    else:
        start = end = None
        total_pages = 0

    run_start = time.monotonic()

    # Derive output .typ path from chapter PDF name
    pdf_name  = CHAPTER_PDFS[args.chapter]           # e.g. "ch3-aerodynamic-drag.pdf"
    typ_name  = pdf_name.replace(".pdf", ".typ")      # e.g. "ch3-aerodynamic-drag.typ"
    typ_path  = ROOT / "src" / "chapters" / typ_name

    # Load symbol context once — reused by OCR, compare, and resolve
    symbol_context = _load_symbol_context(args.chapter, symbol_file=None)
    if symbol_context:
        console.print(f"  [dim]Symbol context loaded ({len(symbol_context)} chars)[/]")

    # ------------------------------------------------------------------
    # Stage 1: OCR
    # ------------------------------------------------------------------
    if args.skip_ocr:
        console.print("[dim][OCR] skipped[/]")
    else:
        _banner("OCR", f"{args.chapter} pages {start}–{end}")
        process_all_models(args.chapter, start, end, symbol_context=symbol_context)

    # ------------------------------------------------------------------
    # Stage 2: Compare
    # ------------------------------------------------------------------
    if args.skip_compare:
        console.print("[dim][compare] skipped[/]")
    else:
        _banner("compare", f"{args.chapter} pages {start}–{end} ({args.compare_model})")
        model_id = COMPARISON_MODELS[args.compare_model]
        ensure_loaded(model_id)
        for page in range(start, end + 1):
            compare_page(args.chapter, page, model_id, symbol_context)

    # ------------------------------------------------------------------
    # Stage 3: Resolve
    # ------------------------------------------------------------------
    if args.skip_resolve:
        console.print("[dim][resolve] skipped[/]")
    else:
        _banner("resolve", f"{args.chapter} pages {start}–{end} ({args.resolve_model})")
        model_id = RESOLUTION_MODELS[args.resolve_model]
        ensure_loaded(model_id)
        total_resolved = total_escalated = 0
        for page in range(start, end + 1):
            r, e = resolve_page(args.chapter, page, model_id, symbol_context,
                                args.threshold, args.also_minor)
            total_resolved  += r
            total_escalated += e
        console.print(f"  resolve total: {total_resolved} ai_resolved, "
                      f"[yellow]{total_escalated} escalated[/]")

    # ------------------------------------------------------------------
    # Stage 3b: Accept-all (optional bulk acceptance)
    # ------------------------------------------------------------------
    if args.accept_all:
        from config import DB_PATH
        conn = sqlite3.connect(DB_PATH)
        c1 = conn.execute(
            "UPDATE review_spans SET status='ai_resolved' "
            "WHERE chapter=? AND status='escalate'",
            (args.chapter,),
        ).rowcount
        c2 = conn.execute(
            "UPDATE review_spans "
            "SET status='ai_resolved', "
            "    resolved_text=COALESCE(NULLIF(resolved_text,''), olmocr_text) "
            "WHERE chapter=? AND status='pending'",
            (args.chapter,),
        ).rowcount
        conn.commit()
        conn.close()
        console.print(f"  [green]✓[/] accepted {c1} escalated + {c2} pending = [bold]{c1+c2}[/] spans")

    # ------------------------------------------------------------------
    # Stage 4: Assemble
    # ------------------------------------------------------------------
    if args.skip_assemble:
        console.print("[dim][assemble] skipped[/]")
    else:
        _banner("assemble", str(typ_path.relative_to(ROOT)))
        assemble_chapter(args.chapter, str(typ_path),
                         comparison_model=DEFAULT_COMPARISON_MODEL)

    # ------------------------------------------------------------------
    # Stage 5: Compile
    # ------------------------------------------------------------------
    if args.skip_compile:
        console.print("[dim][compile] skipped[/]")
    else:
        _banner("compile", f"src/main.typ → {args.pdf}")
        result = subprocess.run(
            ["typst", "compile", "src/main.typ", args.pdf],
            cwd=ROOT,
        )
        if result.returncode == 0:
            console.print(f"  [green]✓[/] {args.pdf}")
        else:
            console.print(f"  [red]✗[/] typst compile failed (exit {result.returncode})")
            sys.exit(result.returncode)

    # ------------------------------------------------------------------
    # Summary
    # ------------------------------------------------------------------
    elapsed = time.monotonic() - run_start
    if total_pages:
        mins = elapsed / 60
        rate = total_pages / mins if mins > 0 else float("inf")
        console.print(f"\n[bold]Done.[/] {total_pages} page(s) in {elapsed:.0f}s ({rate:.2f} pages/min)")
    else:
        console.print(f"\n[bold]Done[/] in {elapsed:.0f}s")


if __name__ == "__main__":
    main()
