import argparse
import json
import sqlite3

from openai import OpenAI

from config import LM_STUDIO_BASE_URL, MODELS, DB_PATH


COMPARE_PROMPT = """You are comparing three OCR transcriptions of the same page from a technical rocketry textbook.

Split the content into spans at sentence boundaries and equation boundaries.
For each span, determine if the three outputs agree.

Return ONLY valid JSON in this exact format:
{{
  "page": {page},
  "spans": [
    {{
      "id": 0,
      "agreement": "AGREE",
      "text": "The agreed text here."
    }},
    {{
      "id": 1,
      "agreement": "CONFLICT",
      "outputs": {{
        "olmocr": "text from olmocr",
        "lighton": "text from lighton",
        "qwen": "text from qwen"
      }}
    }},
    {{
      "id": 2,
      "agreement": "MINOR",
      "text": "best guess text",
      "outputs": {{
        "olmocr": "text from olmocr",
        "lighton": "text from lighton",
        "qwen": "text from qwen"
      }}
    }}
  ]
}}

AGREE = all three match exactly (or trivially)
MINOR = punctuation/whitespace/capitalization differences only
CONFLICT = substantive differences, especially in math symbols or equations

Known symbols:
{symbol_context}

Output A (olmocr):
{a}

Output B (lighton):
{b}

Output C (qwen):
{c}
"""


def compare_page(chapter, page_num, symbol_context=""):
    conn = sqlite3.connect(DB_PATH)
    rows = conn.execute(
        "SELECT model, raw_text FROM ocr_results WHERE chapter=? AND page=?",
        (chapter, page_num),
    ).fetchall()
    conn.close()

    results = {model: text for model, text in rows}
    missing = [m for m in ("olmocr", "lighton", "qwen") if m not in results]
    if missing:
        print(f"Page {page_num}: missing models {missing}, skipping")
        return

    client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio")

    prompt = COMPARE_PROMPT.format(
        page=page_num,
        symbol_context=symbol_context,
        a=results["olmocr"],
        b=results["lighton"],
        c=results["qwen"],
    )

    response = client.chat.completions.create(
        model=MODELS["comparison"],
        messages=[{"role": "user", "content": prompt}],
        max_tokens=8192,
    ).choices[0].message.content

    try:
        data = json.loads(response)
    except json.JSONDecodeError:
        cleaned = response.strip().removeprefix("```json").removesuffix("```").strip()
        data = json.loads(cleaned)

    save_spans(chapter, page_num, data["spans"])
    print(f"  {chapter} p{page_num} compared — {len(data['spans'])} spans")


def save_spans(chapter, page_num, spans):
    conn = sqlite3.connect(DB_PATH)
    for span in spans:
        outputs = span.get("outputs", {})
        text = span.get("text", "")
        conn.execute("""
            INSERT INTO review_spans
            (chapter, page, span_index, agreement,
             olmocr_text, lighton_text, qwen_text, resolved_text, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            chapter,
            page_num,
            span["id"],
            span["agreement"],
            outputs.get("olmocr", text),
            outputs.get("lighton", text),
            outputs.get("qwen", text),
            text if span["agreement"] == "AGREE" else "",
            "auto" if span["agreement"] == "AGREE" else "pending",
        ))
    conn.commit()
    conn.close()


def parse_pages(pages_arg):
    if "-" in pages_arg:
        start, end = pages_arg.split("-")
        return int(start), int(end)
    n = int(pages_arg)
    return n, n


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--chapter", required=True)
    parser.add_argument("--pages",   required=True, help="e.g. 1-3 or 5")
    parser.add_argument("--symbol-context", default="")
    args = parser.parse_args()

    print(f"Make sure '{MODELS['comparison']}' is loaded in LM Studio, then press Enter...")
    input()

    start, end = parse_pages(args.pages)
    for page in range(start, end + 1):
        compare_page(args.chapter, page, args.symbol_context)
