#!/usr/bin/env python3
"""
Section-scoped OCR.

Transcribes a section's pages with a single model and caches raw plus
normalized output to disk. One model, not an ensemble: a three-way vote
flagged 38% of spans as conflicting, which carried no usable information, and
three models can agree on an omission that none of them reports. Model choice
(olmocr-2-7b) was settled by `bakeoff.py` — see the design notes.

The section is the unit of work, not the page and not the chapter: equation
numbers run in sequence within a section, symbol context is local, and a
failure is bounded.

Usage
-----
    python pipeline/ocr.py --chapter ch1 --section 2.1
    python pipeline/ocr.py --chapter ch1 --all
    python pipeline/ocr.py --chapter ch1 --pages 12-15 --force
    python pipeline/ocr.py --chapter ch1 --list

Output lands in pipeline/cache/<chapter>/:
    p012.raw.txt      exactly what the model returned
    p012.md           normalized to text + LaTeX
    manifest.json     per-page metrics and the prompt variant used
"""

from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

try:
    from openai import OpenAI
except ModuleNotFoundError as exc:  # almost always the system python, not the venv
    raise SystemExit(
        f"{exc}\n\n"
        "Dependencies live in pipeline/.venv, so run this through uv:\n"
        "    uv run --project pipeline python pipeline/ocr.py --chapter ch1 --all\n"
        "  or from inside pipeline/:\n"
        "    uv run python ocr.py --chapter ch1 --all"
    ) from None

import sections as S
import symtab
from config import LM_STUDIO_BASE_URL, PDF_DIR, CHAPTER_PDFS
import lms
from lms import ensure_loaded
from ocrlib import (MAX_LONGEST_SIDE, looks_degraded, message_text, metrics,
                    normalize, render_page)
from term import console

_HERE = Path(__file__).parent
CACHE_ROOT = _HERE / "cache"
CHAPTERS_DIR = _HERE.parent / "src" / "chapters"

MODEL_KEY = "allenai/olmocr-2-7b"
MODEL_FAMILY = "olmocr"          # selects the normalizer in ocrlib
TEMPERATURE = 0.1
TOP_P = 1.0
MAX_TOKENS = 8192

# Appended to olmocr's own prompt, which is short and plain enough to extend
# safely. Kept to instructions measured to actually change the output (A/B'd
# against the official prompt on pages 17, 22, 26, 30):
#
#   underline marking  — works. Control dropped every underline on p30;
#                        this recovers "_specific impulse_", "_weight_",
#                        "_seconds_". Underline→italics is a core convention
#                        and the information is unrecoverable once lost.
#
# Deliberately NOT asked for, because asking failed and there is a better way:
#   equation numbers   — this manuscript prints them in the LEFT margin and the
#                        model reads them as list markers and drops them. The
#                        verifier pass compares the page image against emitted
#                        Typst anyway, so numbering is its job.
#   one sentence/line  — ignored by the model. Sentence splitting is a
#                        deterministic text operation; the emitter does it.
PROMPT_ADDENDUM = """
Additional requirements for this document:
- Mark underlined words with _underscores_, not bold.
- Ignore the page number centred at the top of the page.
- Reassemble words hyphenated across a line break, so "sub-\nsequently" becomes "subsequently".
"""

# LM Studio's Vulkan backend intermittently drops the device mid-run
# ("vk::Device::waitForFences: ErrorDeviceLost"), which kills the engine and
# fails the next request too. Unattended chapter runs are dozens of pages, so a
# transient fault must not cost a page.
RETRY_ATTEMPTS = 3
RETRY_BACKOFF = 20   # seconds, multiplied by attempt number
SETTLE_SECONDS = 30  # pause after unloading, before reloading the engine


def chapter_typ(chapter: str) -> Path | None:
    """The chapter's Typst source, whose name mirrors its PDF."""
    stem = Path(CHAPTER_PDFS[chapter]).stem
    path = CHAPTERS_DIR / f"{stem}.typ"
    return path if path.exists() else None


def build_prompt(symbol_context: str = "", addendum: bool = True) -> str:
    try:
        from olmocr.prompts import build_no_anchoring_v4_yaml_prompt
        prompt = build_no_anchoring_v4_yaml_prompt()
    except Exception as exc:
        console.print(f"  [yellow]olmocr prompt import failed ({exc}); using fallback[/]")
        prompt = ("Attached is one page of a document. Return the plain text "
                  "representation as if reading it naturally. Convert equations "
                  "to LaTeX and tables to HTML.")
    if addendum:
        prompt += "\n" + PROMPT_ADDENDUM.strip()
    if symbol_context:
        prompt += (
            "\n\nThis chapter uses the following symbols. When a character is "
            "ambiguous, prefer the reading that matches this list:\n"
            + symbol_context
        )
    return prompt


def symbol_context(chapter: str, limit: int | None = None) -> str:
    """LaTeX | meaning list parsed from the chapter's own symbol table."""
    path = chapter_typ(chapter)
    if path is None:
        console.print(f"  [yellow]no Typst source for {chapter}; no symbol context[/]")
        return ""
    syms = symtab.parse(path)
    if not syms:
        console.print(f"  [yellow]no symbol table found in {path.name}[/]")
        return ""
    console.print(f"  [dim]{len(syms)} symbols from {path.name}[/]")
    return symtab.prompt_block(syms, limit=limit)


def ocr_pages(chapter: str, pages: list[int], *, force: bool = False,
              addendum: bool = True, use_symbols: bool = True,
              longest_side: int = MAX_LONGEST_SIDE) -> dict[int, dict]:
    pdf_path = Path(PDF_DIR) / CHAPTER_PDFS[chapter]
    if not pdf_path.exists():
        raise SystemExit(f"Missing PDF: {pdf_path}")
    out_dir = CACHE_ROOT / chapter
    out_dir.mkdir(parents=True, exist_ok=True)

    context = symbol_context(chapter) if use_symbols else ""
    prompt_text = build_prompt(context, addendum=addendum)
    variant = f"official{'+addendum' if addendum else ''}{'+symbols' if context else ''}"

    todo = [p for p in pages
            if force or not (out_dir / f"p{p:03d}.raw.txt").exists()]
    cached = len(pages) - len(todo)
    if cached:
        console.print(f"  [dim]{cached} page(s) already cached[/]")
    if not todo:
        return _load_manifest_slice(out_dir, pages)

    ensure_loaded(MODEL_KEY)
    client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio", timeout=3600.0)
    console.print(f"[bold cyan]olmocr[/] @ {longest_side}px, prompt: {variant}")

    results: dict[int, dict] = {}
    run_start = time.monotonic()
    for page in todo:
        image_b64 = render_page(pdf_path, page, longest_side)
        started = time.monotonic()
        raw, failure = "", None

        for attempt in range(1, RETRY_ATTEMPTS + 1):
            try:
                with console.status(f"[cyan]p{page}[/]"
                                    f"{f' (retry {attempt - 1})' if attempt > 1 else ''}..."):
                    response = client.chat.completions.create(
                        model=MODEL_KEY,
                        messages=[{"role": "user", "content": [
                            {"type": "text", "text": prompt_text},
                            {"type": "image_url",
                             "image_url": {"url": f"data:image/png;base64,{image_b64}"}},
                        ]}],
                        max_tokens=MAX_TOKENS, temperature=TEMPERATURE, top_p=TOP_P,
                    )
                raw = message_text(response.choices[0].message)
                if not raw:
                    failure = "empty response"
                else:
                    # A degraded engine answers 200 with corrupted text; without
                    # this check it would be cached as a good transcription.
                    degraded = looks_degraded(normalize(MODEL_FAMILY, raw))
                    if degraded:
                        failure = f"degraded output ({degraded})"
                        raw = ""
                    else:
                        failure = None
                        break
            except Exception as exc:
                failure = str(exc)

            if attempt < RETRY_ATTEMPTS:
                console.print(f"  [yellow]⟳[/] p{page} attempt {attempt} failed "
                              f"({failure[:60]}); reloading model")
                time.sleep(RETRY_BACKOFF * attempt)
                try:
                    # ensure_loaded alone is a no-op here: after a device loss
                    # LM Studio still lists the model as loaded while its engine
                    # is dead, so the next request fails identically. Force the
                    # unload first to get a genuinely fresh engine.
                    lms.unload_all()
                    time.sleep(SETTLE_SECONDS)  # the pause is what actually recovers it
                    ensure_loaded(MODEL_KEY)
                except Exception as exc:
                    console.print(f"  [yellow]reload failed: {exc}[/]")

        if failure or not raw:
            console.print(f"  [red]✗[/] p{page}: {failure or 'empty response'}")
            results[page] = {"error": failure or "empty response"}
            continue
        elapsed = time.monotonic() - started

        (out_dir / f"p{page:03d}.raw.txt").write_text(raw)
        norm = normalize(MODEL_FAMILY, raw)
        (out_dir / f"p{page:03d}.md").write_text(norm)

        m = metrics(norm)
        results[page] = {"seconds": round(elapsed, 1), "variant": variant, **m}
        eqs = ",".join(m["eq_numbers"]) or "-"
        console.print(f"  [green]✓[/] p{page} {elapsed:5.1f}s  {m['chars']:5d} chars  "
                      f"{m['math_spans']:3d} math  eq:{eqs}")

    total = time.monotonic() - run_start
    if todo:
        console.print(f"  {len(todo)} page(s) in {total:.0f}s "
                      f"({total / len(todo):.0f}s/page)")

    _merge_manifest(out_dir, results)
    return _load_manifest_slice(out_dir, pages)


# ---------------------------------------------------------------------------
# Manifest
# ---------------------------------------------------------------------------

def _manifest_path(out_dir: Path) -> Path:
    return out_dir / "manifest.json"


def _merge_manifest(out_dir: Path, results: dict[int, dict]) -> None:
    path = _manifest_path(out_dir)
    data = json.loads(path.read_text()) if path.exists() else {}
    for page, info in results.items():
        data[str(page)] = info
    path.write_text(json.dumps(dict(sorted(data.items(), key=lambda kv: int(kv[0]))),
                               indent=2))


def _load_manifest_slice(out_dir: Path, pages: list[int]) -> dict[int, dict]:
    path = _manifest_path(out_dir)
    if not path.exists():
        return {}
    data = json.loads(path.read_text())
    return {p: data[str(p)] for p in pages if str(p) in data}


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--chapter", default="ch1", choices=list(CHAPTER_PDFS))
    group = ap.add_mutually_exclusive_group()
    group.add_argument("--section", help="section id from the chapter's TOML map, e.g. 2.1")
    group.add_argument("--pages", help="explicit pages, e.g. 12-19 or 12,15")
    group.add_argument("--all", action="store_true", help="every tile in the chapter")
    group.add_argument("--list", action="store_true", help="show the work units and exit")
    ap.add_argument("--force", action="store_true", help="re-run pages already cached")
    ap.add_argument("--no-addendum", action="store_true",
                    help="use olmocr's official prompt unmodified")
    ap.add_argument("--no-symbols", action="store_true",
                    help="omit the chapter symbol table from the prompt")
    ap.add_argument("--longest-side", type=int, default=MAX_LONGEST_SIDE)
    args = ap.parse_args()

    if args.list:
        start, end = S.body_range(args.chapter)
        console.print(f"  body pages {start}-{end} "
                      f"({end - start + 1}p), {len(S.sections(args.chapter))} headings")
        for sec in S.sections(args.chapter):
            where = f"{sec.start:>3}-{sec.end:<3}" if sec.has_pages else " by heading"
            console.print(f"  {'  ' * sec.level}{sec.id:<8} {where} {sec.title}")
        return

    if args.pages:
        units = [("pages " + args.pages, S.parse_pages(args.pages))]
    elif args.section:
        sec = S.find(args.chapter, args.section)
        if not sec.has_pages:
            ap.error(f"section {sec.id} has no page range in {args.chapter}.toml "
                     f"(start is a hint and may be 0) — use --pages instead")
        units = [(f"{sec.id} {sec.title}", list(sec.pages))]
    elif args.all:
        # Every body page exactly once. Sections no longer tile the chapter —
        # they are located by heading text after transcription — so the page
        # range from [frontmatter] is what OCR works from.
        units = [("whole chapter", S.body_pages(args.chapter))]
    else:
        ap.error("give --section, --pages, --all, or --list")

    grand = time.monotonic()
    for name, pages in units:
        console.print(f"\n[bold]{args.chapter} · {name}[/] "
                      f"(pages {pages[0]}–{pages[-1]}, {len(pages)})")
        ocr_pages(args.chapter, pages, force=args.force,
                  addendum=not args.no_addendum,
                  use_symbols=not args.no_symbols,
                  longest_side=args.longest_side)
    if len(units) > 1:
        console.print(f"\nAll units done in {(time.monotonic() - grand) / 60:.1f} min")


if __name__ == "__main__":
    main()
