import argparse
import base64
import io
import sqlite3
import threading
import time
from pathlib import Path

from openai import OpenAI

from config import LM_STUDIO_BASE_URL, MODELS, DB_PATH, PDF_DIR, CHAPTER_PDFS
from lms import ensure_loaded
from term import console

MAX_LONGEST_SIDE = 1288  # olmOCR's native resolution; good for all VLMs


# ---------------------------------------------------------------------------
# Image helpers
# ---------------------------------------------------------------------------

def encode_image_pil(pil_image):
    """Resize to MAX_LONGEST_SIDE and return base64 PNG."""
    w, h = pil_image.size
    longest = max(w, h)
    if longest > MAX_LONGEST_SIDE:
        scale = MAX_LONGEST_SIDE / longest
        pil_image = pil_image.resize((int(w * scale), int(h * scale)))
    buf = io.BytesIO()
    pil_image.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


def render_page_olmocr(pdf_path, page_num):
    """Use olmOCR's own renderer — produces exactly 1288px longest side."""
    from olmocr.data.renderpdf import render_pdf_to_base64png
    return render_pdf_to_base64png(str(pdf_path), page_num,
                                   target_longest_image_dim=MAX_LONGEST_SIDE)


def render_page_lighton(pdf_path, page_num):
    """Render with pypdfium2 at 1540px longest side (LightOnOCR's target)."""
    import pypdfium2 as pdfium
    pdf = pdfium.PdfDocument(str(pdf_path))
    page = pdf[page_num - 1]  # pypdfium2 is 0-indexed
    longest_pts = max(page.get_width(), page.get_height())
    scale = 1540 / longest_pts
    pil_image = page.render(scale=scale).to_pil()
    buf = io.BytesIO()
    pil_image.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


def render_page_chandra(pdf_path, page_num):
    """Render with pypdfium2 at MAX_LONGEST_SIDE for chandra-ocr."""
    import pypdfium2 as pdfium
    pdf = pdfium.PdfDocument(str(pdf_path))
    page = pdf[page_num - 1]
    longest_pts = max(page.get_width(), page.get_height())
    scale = MAX_LONGEST_SIDE / longest_pts
    pil_image = page.render(scale=scale).to_pil()
    buf = io.BytesIO()
    pil_image.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


def render_page(model_name, pdf_path, page_num):
    """Dispatch to the appropriate renderer for the given model."""
    if model_name == "olmocr":
        return render_page_olmocr(pdf_path, page_num)
    if model_name == "lighton":
        return render_page_lighton(pdf_path, page_num)
    if model_name == "chandra":
        return render_page_chandra(pdf_path, page_num)
    raise ValueError(f"Unknown model: {model_name}")


# ---------------------------------------------------------------------------
# Prompt helpers
# ---------------------------------------------------------------------------

GENERIC_PROMPT = """\
You are transcribing a page from a technical rocketry textbook.
Ignore any page number at the top or bottom of the page.
Reassemble any words hyphenated across a line break (e.g. "sub-\nsequently" → "subsequently").
Output one complete sentence per line — not one printed line per line.
Use LaTeX for all math (inline: $...$, block: $$...$$).
If a word appears underlined, wrap it in _underscores_ for italics.
When a handwritten or ambiguous character matches a known symbol below, prefer the known symbol.

{chapter_ctx}{symbol_ctx}
Output ONLY the transcription inside <transcription> tags, like this:
<transcription>
First sentence here.
Second sentence here.
</transcription>"""


def build_prompt(model_name, symbol_context="", chapter_title=""):
    if model_name == "olmocr":
        from olmocr.prompts import build_no_anchoring_v4_yaml_prompt
        return build_no_anchoring_v4_yaml_prompt()
    if model_name == "lighton":
        return None  # image-only, no text prompt
    if model_name == "chandra":
        # chandra.prompts.PROMPT_MAPPING contains the official prompt templates.
        # "ocr_layout" produces HTML output with <math>...</math> for equations
        # (KaTeX-compatible LaTeX), which compare.py will need to normalize.
        from chandra.prompts import PROMPT_MAPPING
        return PROMPT_MAPPING["ocr_layout"]
    chapter_ctx = f"Chapter context: {chapter_title}\n\n" if chapter_title else ""
    symbol_ctx = f"Known symbols:\n{symbol_context}\n\n" if symbol_context else ""
    return GENERIC_PROMPT.format(chapter_ctx=chapter_ctx, symbol_ctx=symbol_ctx)


# ---------------------------------------------------------------------------
# Core OCR
# ---------------------------------------------------------------------------

MODEL_PARAMS = {
    "olmocr":  {"temperature": 0.1, "top_p": 1.0},
    "lighton": {"temperature": 0.2, "top_p": 0.9},
    "chandra": {"temperature": 0.1, "top_p": 1.0},
}


def ocr_page(image_b64, client, model_id, prompt_text,
             temperature=0.0, top_p=1.0, max_tokens: int = 4096):
    content = []
    if prompt_text:
        content.append({"type": "text", "text": prompt_text})
    content.append({"type": "image_url",
                    "image_url": {"url": f"data:image/png;base64,{image_b64}"}})
    raw = client.chat.completions.create(
        model=model_id,
        messages=[{"role": "user", "content": content}],
        max_tokens=max_tokens,
        temperature=temperature,
        top_p=top_p,
    ).choices[0].message.content
    # Strip thinking block first — the thinking may mention <transcription> tags by name,
    # which would fool a naive split on the first occurrence of <transcription>.
    text = raw.split("</think>", 1)[-1] if "</think>" in raw else raw
    if "<transcription>" in text and "</transcription>" in text:
        return text.split("<transcription>", 1)[1].split("</transcription>", 1)[0].strip()
    return text.strip()


def process_pages(chapter, model_name, start_page, end_page,
                  symbol_context="", chapter_title=""):
    pdf_path = Path(PDF_DIR) / CHAPTER_PDFS[chapter]
    model_id = MODELS[model_name]
    client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio",
                    timeout=7200.0)  # 2 hours for slow VLMs on shared GPU
    prompt_text = build_prompt(model_name, symbol_context, chapter_title)

    params = MODEL_PARAMS.get(model_name, {"temperature": 0.0, "top_p": 1.0})

    total_pages = end_page - start_page + 1
    console.print(f"Processing pages {start_page}–{end_page} of [cyan]{pdf_path.name}[/] with [cyan]{model_name}[/]")
    conn = sqlite3.connect(DB_PATH)
    run_start = time.monotonic()

    for page_num in range(start_page, end_page + 1):
        image_b64 = render_page(model_name, pdf_path, page_num)

        label = f"[{model_name}] {chapter} p{page_num}"
        page_start = time.monotonic()
        stop = threading.Event()
        def _tick(lbl=label, t0=page_start):
            while not stop.wait(15):
                t = int(time.monotonic() - t0)
                status.update(f"[cyan]{lbl}[/] — {t}s...")
        with console.status(f"[cyan]{label}[/]...") as status:
            tick = threading.Thread(target=_tick, daemon=True)
            tick.start()
            try:
                result = ocr_page(image_b64, client, model_id, prompt_text, **params)
            finally:
                stop.set()
                tick.join()
        page_elapsed = time.monotonic() - page_start

        conn.execute("""
            INSERT OR REPLACE INTO ocr_results
            (chapter, page, model, raw_text) VALUES (?, ?, ?, ?)
        """, (chapter, page_num, model_name, result))
        conn.commit()
        console.print(f"  [green]✓[/] [{model_name}] {chapter} p{page_num} ({page_elapsed:.0f}s)")

    conn.close()
    total_elapsed = time.monotonic() - run_start
    mins = total_elapsed / 60
    rate = total_pages / mins if mins > 0 else float("inf")
    console.print(f"Done. {total_pages} page(s) in {total_elapsed:.0f}s ({rate:.2f} pages/min)")


# ---------------------------------------------------------------------------
# Multi-model sequential path
# ---------------------------------------------------------------------------

def process_all_models(chapter, start_page, end_page,
                       symbol_context="", chapter_title=""):
    """Process each OCR model one at a time, loading/unloading between models."""
    pdf_path = Path(PDF_DIR) / CHAPTER_PDFS[chapter]
    total_pages = end_page - start_page + 1
    run_start = time.monotonic()

    for model_name in MODELS:
        ensure_loaded(MODELS[model_name])
        client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio", timeout=7200.0)
        prompt_text = build_prompt(model_name, symbol_context, chapter_title)
        params = MODEL_PARAMS.get(model_name, {})

        # Skip pages already in the DB for this model
        conn = sqlite3.connect(DB_PATH)
        done = {r[0] for r in conn.execute(
            "SELECT page FROM ocr_results WHERE chapter=? AND model=? AND page BETWEEN ? AND ?",
            (chapter, model_name, start_page, end_page),
        ).fetchall()}
        remaining = [p for p in range(start_page, end_page + 1) if p not in done]
        if not remaining:
            console.print(f"  [dim][{model_name}] all pages already done, skipping[/]")
            conn.close()
            continue

        suffix = f" ({len(done)} already done)" if done else ""
        console.print(f"Processing pages {start_page}–{end_page} of [cyan]{pdf_path.name}[/] with [cyan]{model_name}[/]{suffix}")
        failed = []
        for page_num in remaining:
            label = f"[{model_name}] {chapter} p{page_num}"
            page_start = time.monotonic()
            stop = threading.Event()
            def _tick(lbl=label, t0=page_start):
                while not stop.wait(15):
                    t = int(time.monotonic() - t0)
                    status.update(f"[cyan]{lbl}[/] — {t}s...")
            try:
                with console.status(f"[cyan]{label}[/]...") as status:
                    tick = threading.Thread(target=_tick, daemon=True)
                    tick.start()
                    try:
                        image_b64 = render_page(model_name, pdf_path, page_num)
                        text = ocr_page(image_b64, client, MODELS[model_name], prompt_text, **params)
                    finally:
                        stop.set()
                        tick.join()
            except Exception as exc:
                console.print(f"  [red]✗[/] [{model_name}] {chapter} p{page_num} FAILED: {exc}")
                failed.append(page_num)
                continue
            conn.execute(
                "INSERT OR REPLACE INTO ocr_results "
                "(chapter, page, model, raw_text) VALUES (?, ?, ?, ?)",
                (chapter, page_num, model_name, text),
            )
            conn.commit()
            elapsed = time.monotonic() - page_start
            console.print(f"  [green]✓[/] [{model_name}] {chapter} p{page_num} ({elapsed:.0f}s)")
        conn.close()
        if failed:
            console.print(f"  [red][{model_name}] failed pages: {failed}[/]")

    total_elapsed = time.monotonic() - run_start
    mins = total_elapsed / 60
    rate = total_pages / mins if mins > 0 else float("inf")
    console.print(f"Done. {total_pages} page(s) in {total_elapsed:.0f}s ({rate:.2f} pages/min)")


# ---------------------------------------------------------------------------
# DB setup
# ---------------------------------------------------------------------------

def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS ocr_results (
            chapter TEXT,
            page    INTEGER,
            model   TEXT,
            raw_text TEXT,
            PRIMARY KEY (chapter, page, model)
        );
        CREATE TABLE IF NOT EXISTS review_spans (
            id               INTEGER PRIMARY KEY AUTOINCREMENT,
            chapter          TEXT,
            page             INTEGER,
            span_index       INTEGER,
            comparison_model TEXT NOT NULL DEFAULT '',
            agreement        TEXT,
            olmocr_text      TEXT,
            lighton_text     TEXT,
            chandra_text     TEXT,
            resolved_text    TEXT,
            status           TEXT DEFAULT 'pending'
        );
    """)
    # Migrations: add columns that may not exist in older databases
    for sql in [
        "ALTER TABLE review_spans ADD COLUMN comparison_model TEXT NOT NULL DEFAULT ''",
        "ALTER TABLE review_spans ADD COLUMN ai_confidence REAL",
        "ALTER TABLE review_spans ADD COLUMN ai_notes TEXT",
    ]:
        try:
            conn.execute(sql)
        except Exception:
            pass  # column already exists
    conn.commit()
    conn.close()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_pages(pages_arg):
    if "-" in pages_arg:
        start, end = pages_arg.split("-")
        return int(start), int(end)
    n = int(pages_arg)
    return n, n


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model",   default="all",
                        choices=list(MODELS.keys()) + ["all"],
                        help="OCR model to run, or 'all' to run all in parallel (default)")
    parser.add_argument("--chapter", required=True, choices=list(CHAPTER_PDFS.keys()))
    parser.add_argument("--pages",   required=True, help="e.g. 1-3 or 5")
    parser.add_argument("--symbol-context", default="")
    parser.add_argument("--chapter-title",  default="")
    args = parser.parse_args()

    init_db()
    start, end = parse_pages(args.pages)

    if args.model == "all":
        process_all_models(args.chapter, start, end,
                           args.symbol_context, args.chapter_title)
    else:
        ensure_loaded(MODELS[args.model])
        process_pages(args.chapter, args.model, start, end,
                      args.symbol_context, args.chapter_title)
