import argparse
import base64
import io
import sqlite3
from pathlib import Path

from pdf2image import convert_from_path
from openai import OpenAI

from config import LM_STUDIO_BASE_URL, MODELS, DB_PATH, PDF_DIR, CHAPTER_PDFS


def encode_image(pil_image):
    buf = io.BytesIO()
    pil_image.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


def ocr_page(image_b64, client, model_id, symbol_context="", chapter_title=""):
    prompt = f"""You are transcribing a page from a technical rocketry textbook.
Output the page content exactly. Use LaTeX for all math (inline: $...$, block: $$...$$).
Put each sentence on its own line.
If a word appears underlined, wrap it in _underscores_ for italics.
When a handwritten or ambiguous character matches a known symbol below, prefer the known symbol.

{f"Chapter context: {chapter_title}" if chapter_title else ""}

{f"Known symbols:{chr(10)}{symbol_context}" if symbol_context else ""}

Transcribe the page now:"""

    return client.chat.completions.create(
        model=model_id,
        messages=[{
            "role": "user",
            "content": [
                {"type": "image_url",
                 "image_url": {"url": f"data:image/png;base64,{image_b64}"}},
                {"type": "text", "text": prompt},
            ],
        }],
        max_tokens=4096,
    ).choices[0].message.content


def process_pages(chapter, model_name, start_page, end_page,
                  symbol_context="", chapter_title=""):
    pdf_path = Path(PDF_DIR) / CHAPTER_PDFS[chapter]
    model_id = MODELS[model_name]
    client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio")

    print(f"Loading pages {start_page}–{end_page} from {pdf_path}")
    images = convert_from_path(str(pdf_path), first_page=start_page,
                               last_page=end_page, dpi=300)

    conn = sqlite3.connect(DB_PATH)
    for page_num, image in enumerate(images, start=start_page):
        image_b64 = encode_image(image)
        result = ocr_page(image_b64, client, model_id, symbol_context, chapter_title)
        conn.execute("""
            INSERT OR REPLACE INTO ocr_results
            (chapter, page, model, raw_text) VALUES (?, ?, ?, ?)
        """, (chapter, page_num, model_name, result))
        conn.commit()
        print(f"  [{model_name}] {chapter} p{page_num} done")
    conn.close()


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
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            chapter      TEXT,
            page         INTEGER,
            span_index   INTEGER,
            agreement    TEXT,
            olmocr_text  TEXT,
            lighton_text TEXT,
            qwen_text    TEXT,
            resolved_text TEXT,
            status       TEXT DEFAULT 'pending'
        );
    """)
    conn.close()


def parse_pages(pages_arg):
    """Parse '1-3' or '5' into (start, end) tuple."""
    if "-" in pages_arg:
        start, end = pages_arg.split("-")
        return int(start), int(end)
    n = int(pages_arg)
    return n, n


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model",   required=True, choices=list(MODELS.keys()),
                        help="Which OCR model to use (must be loaded in LM Studio)")
    parser.add_argument("--chapter", required=True, choices=list(CHAPTER_PDFS.keys()))
    parser.add_argument("--pages",   required=True,
                        help="Page range, e.g. 1-3 or 5")
    parser.add_argument("--symbol-context", default="",
                        help="Known symbols to feed the model")
    parser.add_argument("--chapter-title",  default="")
    args = parser.parse_args()

    init_db()

    start, end = parse_pages(args.pages)
    print(f"Make sure '{MODELS[args.model]}' is loaded in LM Studio, then press Enter...")
    input()

    process_pages(args.chapter, args.model, start, end,
                  args.symbol_context, args.chapter_title)
