#!/usr/bin/env python3
"""
Verification pass: recover the equation numbers the transcriber drops.

This manuscript prints equation numbers in the LEFT margin, where olmocr reads
them as list markers and discards them. Adding an instruction to the OCR prompt
was measured and did not work. chandra-ocr-2, however, does read them — so the
verifier uses chandra for the one narrow job it is better at, rather than
running a second full transcription.

The model is asked only for numbered equations, with a snippet of each so the
emitter can match them to what it produced by content rather than by position.
Position alone is unreliable because most display equations are unnumbered.

Results are written beside the OCR cache as sidecars, which `emit.py` reads:

    cache/ch1/p012.eqnums.json   [{"number": "13", "equation": "m_b = m_0 - m_f"}]

Usage
-----
    python pipeline/verify.py --chapter ch1 --section 2.1
    python pipeline/verify.py --chapter ch1 --all
"""

from __future__ import annotations

import argparse
import json
import re
import time
from pathlib import Path

try:
    from openai import OpenAI
except ModuleNotFoundError as exc:
    raise SystemExit(
        f"{exc}\n\nRun through uv:\n"
        "    uv run --project pipeline python pipeline/verify.py --chapter ch1 --all"
    ) from None

import lms
import sections as S
from config import LM_STUDIO_BASE_URL, PDF_DIR, CHAPTER_PDFS
from lms import ensure_loaded
from ocrlib import message_text, render_page
from term import console

_HERE = Path(__file__).parent
CACHE_ROOT = _HERE / "cache"

MODEL_KEY = "chandra-ocr-2"
LONGEST_SIDE = 1288
RETRY_ATTEMPTS = 3
RETRY_BACKOFF = 20
SETTLE_SECONDS = 30

PROMPT = """\
This is one page from a technical textbook. Equation numbers are printed in \
parentheses in the LEFT margin, beside the equation they belong to.

List every NUMBERED equation on this page, in order from top to bottom.
Ignore equations that have no number printed beside them.
Ignore any reference to an equation number that appears inside a sentence.

Return ONLY a JSON array, with no other text:
[{"number": "13", "equation": "m_b = m_0 - m_f"}]

Use the number exactly as printed, without the parentheses. Write the equation \
in LaTeX. If the page has no numbered equations, return [].
"""

_NUM_RE = re.compile(r"^\d{1,3}[a-z]?$")


def parse_response(raw: str) -> list[dict]:
    text = raw.strip()
    if text.startswith("```"):
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```$", "", text)
    start, end = text.find("["), text.rfind("]")
    if start == -1 or end <= start:
        return []
    try:
        data = json.loads(text[start:end + 1])
    except json.JSONDecodeError:
        return []
    if not isinstance(data, list):
        return []

    out = []
    for item in data:
        if not isinstance(item, dict):
            continue
        number = str(item.get("number", "")).strip().strip("()")
        if not _NUM_RE.match(number):
            continue
        out.append({"number": number,
                    "equation": str(item.get("equation", "")).strip()})
    return out


def verify_pages(chapter: str, pages: list[int], force: bool = False) -> None:
    pdf_path = Path(PDF_DIR) / CHAPTER_PDFS[chapter]
    out_dir = CACHE_ROOT / chapter
    out_dir.mkdir(parents=True, exist_ok=True)

    todo = [p for p in pages
            if force or not (out_dir / f"p{p:03d}.eqnums.json").exists()]
    if len(pages) - len(todo):
        console.print(f"  [dim]{len(pages) - len(todo)} page(s) already verified[/]")
    if not todo:
        return

    ensure_loaded(MODEL_KEY)
    client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio", timeout=3600.0)

    for page in todo:
        image_b64 = render_page(pdf_path, page, LONGEST_SIDE)
        found, failure = None, None

        for attempt in range(1, RETRY_ATTEMPTS + 1):
            try:
                with console.status(f"[cyan]verify p{page}[/]..."):
                    response = client.chat.completions.create(
                        model=MODEL_KEY,
                        messages=[{"role": "user", "content": [
                            {"type": "text", "text": PROMPT},
                            {"type": "image_url",
                             "image_url": {"url": f"data:image/png;base64,{image_b64}"}},
                        ]}],
                        max_tokens=2048, temperature=0.0, top_p=1.0,
                    )
                raw = message_text(response.choices[0].message)
                # An empty array is a valid answer, so distinguish "[]" from
                # "the model said nothing at all".
                if raw:
                    found = parse_response(raw)
                    failure = None
                    break
                failure = "empty response"
            except Exception as exc:
                failure = str(exc)

            if attempt < RETRY_ATTEMPTS:
                console.print(f"  [yellow]⟳[/] p{page} ({str(failure)[:50]}); reloading")
                time.sleep(RETRY_BACKOFF * attempt)
                try:
                    lms.unload_all()
                    time.sleep(SETTLE_SECONDS)
                    ensure_loaded(MODEL_KEY)
                except Exception as exc:
                    console.print(f"  [yellow]reload failed: {exc}[/]")

        if failure is not None or found is None:
            console.print(f"  [red]✗[/] p{page}: {failure}")
            continue

        (out_dir / f"p{page:03d}.eqnums.json").write_text(json.dumps(found, indent=2))
        listing = ", ".join(e["number"] for e in found) or "none"
        console.print(f"  [green]✓[/] p{page}  equations: {listing}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--chapter", default="ch1", choices=list(CHAPTER_PDFS))
    group = ap.add_mutually_exclusive_group(required=True)
    group.add_argument("--section")
    group.add_argument("--pages")
    group.add_argument("--all", action="store_true")
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args()

    if args.pages:
        units = [("pages " + args.pages, S.parse_pages(args.pages))]
    elif args.section:
        sec = S.find(args.chapter, args.section)
        units = [(f"{sec.id} {sec.title}", list(sec.pages))]
    else:
        seen: set[int] = set()
        pages = []
        for tile in S.tiles(args.chapter):
            for page in tile.pages:
                if page not in seen:
                    seen.add(page)
                    pages.append(page)
        units = [("whole chapter", pages)]

    for name, pages in units:
        console.print(f"\n[bold]{args.chapter} · {name}[/] ({len(pages)} pages)")
        verify_pages(args.chapter, pages, force=args.force)


if __name__ == "__main__":
    main()
