# Topics in Advanced Model Rocketry — Digitization Project

## Project Overview

This project digitizes the book "Topics in Advanced Model Rocketry" (now public domain)
from a scanned typewritten manuscript into a clean Typst typesetting project.
The pipeline uses three OCR models to transcribe pages, a comparison model to flag
conflicts, and a web-based review UI for human editorial decisions.

## Repository Structure to Create

```
topics-in-advanced-model-rocketry/
├── CLAUDE.md                  # this file
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CHANGES.md
├── .gitignore
├── src/
│   ├── main.typ
│   ├── preamble.typ
│   ├── chapters/
│   │   ├── ch1-flight-dynamics.typ
│   │   ├── ch2-aerodynamic-stability.typ
│   │   ├── ch3-aerodynamic-drag.typ
│   │   └── ch4-trajectory-analysis.typ
│   └── appendices/
│       ├── app-a-units.typ
│       ├── app-b-constants.typ
│       ├── app-c-notation.typ
│       └── app-d-nar.typ
├── pipeline/
│   ├── requirements.txt
│   ├── config.py
│   ├── ocr_pages.py
│   ├── compare.py
│   ├── assemble.py
│   └── review_app/
│       ├── app.py
│       ├── templates/
│       │   └── review.html
│       └── static/
├── errata/
│   └── README.md
├── assets/
│   ├── figures-original/      # gitignored — 300dpi scans
│   ├── figures-recreated/     # tracked — SVG, CeTZ .typ, matplotlib .py sources
│   └── figures-export/        # gitignored — rendered outputs for Typst to include
├── docs/
│   └── editorial-decisions.md
└── raw/                       # gitignored
    ├── original-scan.pdf
    └── sections/
```

## Task 1: Create Project Scaffold

Create all directories and placeholder files listed above.

Create `.gitignore`:
```
raw/
*.pdf
__pycache__/
*.pyc
.venv/
*.db
review/
assets/figures-original/
assets/figures-export/
```

Create `src/preamble.typ`:
```typst
// Review mode: set to false for final clean build
#let review-mode = true

#let conflict(content) = if review-mode {
  text(fill: red)[#content]
} else {
  content
}

#let minor(content) = if review-mode {
  text(fill: orange)[#content]
} else {
  content
}

// Symbol table helper
#let sym-table(..rows) = table(
  columns: (auto, 1fr),
  stroke: none,
  ..rows
)
```

Create `src/main.typ`:
```typst
#import "preamble.typ": *

#set document(title: "Topics in Advanced Model Rocketry")
#set page(numbering: "1")
#set text(font: "Linux Libertine", size: 11pt)

// Convert underline emphasis to italics throughout
#show underline: it => emph(it.body)

#include "chapters/ch1-flight-dynamics.typ"
#include "chapters/ch2-aerodynamic-stability.typ"
#include "chapters/ch3-aerodynamic-drag.typ"
#include "chapters/ch4-trajectory-analysis.typ"
#include "appendices/app-a-units.typ"
#include "appendices/app-b-constants.typ"
#include "appendices/app-c-notation.typ"
#include "appendices/app-d-nar.typ"
```

---

## Task 2: Build the Pipeline

### Pipeline setup with uv

```bash
cd pipeline
uv init .
uv add flask openai pdf2image pillow vllm
uv add --dev pytest
```

Commit `pyproject.toml` and `uv.lock`. Keep `.venv/` gitignored.
Run scripts with `uv run python ocr_pages.py`.

### `pipeline/config.py`

```python
# vLLM model IDs — run one at a time on a single GPU
MODELS = {
    "olmocr": "allenai/olmOCR-2-7B-1025-FP8",
    "lighton": "lightonai/LightOnOCR-2-1B",
    "qwen":   "Qwen/Qwen2.5-VL-7B-Instruct",  # verify exact HF model ID
}

# When serving via vLLM, each runs on its own port sequentially
PORTS = {
    "olmocr": 8001,
    "lighton": 8002,
    "qwen":   8003,
}

COMPARISON_MODEL = "Qwen/Qwen2.5-3B-Instruct"

DB_PATH = "pipeline/review.db"

# Chapter page ranges — fill in after splitting PDF
CHAPTERS = {
    "ch1": (1, 52),
    "ch2": (53, 260),
    "ch3": (261, 496),
    "ch4": (497, 616),
}
```

### `pipeline/ocr_pages.py`

```python
import base64, json, sqlite3
from pathlib import Path
from pdf2image import convert_from_path
from openai import OpenAI
from config import MODELS, PORTS, DB_PATH

def encode_image(pil_image):
    import io
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
                {"type": "text", "text": prompt}
            ]
        }],
        max_tokens=4096,
    ).choices[0].message.content

def process_section(pdf_path, start_page, end_page, model_name,
                    symbol_context="", chapter_title=""):
    client = OpenAI(base_url=f"http://localhost:{PORTS[model_name]}/v1",
                    api_key="placeholder")
    model_id = MODELS[model_name]

    images = convert_from_path(pdf_path, first_page=start_page,
                               last_page=end_page, dpi=300)

    conn = sqlite3.connect(DB_PATH)
    for page_num, image in enumerate(images, start=start_page):
        image_b64 = encode_image(image)
        result = ocr_page(image_b64, client, model_id,
                          symbol_context, chapter_title)
        conn.execute("""
            INSERT OR REPLACE INTO ocr_results
            (page, model, raw_text) VALUES (?, ?, ?)
        """, (page_num, model_name, result))
        conn.commit()
        print(f"  Page {page_num} done ({model_name})")
    conn.close()

def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS ocr_results (
            page INTEGER,
            model TEXT,
            raw_text TEXT,
            PRIMARY KEY (page, model)
        );
        CREATE TABLE IF NOT EXISTS review_spans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            page INTEGER,
            span_index INTEGER,
            agreement TEXT,
            olmocr_text TEXT,
            lighton_text TEXT,
            qwen_text TEXT,
            resolved_text TEXT,
            status TEXT DEFAULT 'pending'
        );
    """)
    conn.close()

if __name__ == "__main__":
    init_db()
    # Example: process ch3 symbol table pages first
    # python ocr_pages.py
    # Then run for each model sequentially (restart vllm between models)
```

### `pipeline/compare.py`

```python
import json, sqlite3
from openai import OpenAI
from config import COMPARISON_MODEL, DB_PATH

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
        "olmocr": "text from olmocr,",
        "lighton": "text from lighton",
        "qwen": "text from qwen"
      }}
    }}
  ]
}}

AGREE = all three match exactly (or trivially)
MINOR = punctuation/whitespace/capitalization differences only
CONFLICT = substantive differences, especially in math symbols or equations

If a CONFLICT involves a symbol that appears in the known symbol list, note which symbol is correct.

Known symbols:
{symbol_context}

Output A (olmocr):
{a}

Output B (lighton):
{b}

Output C (qwen):
{c}
"""

def compare_page(page_num, symbol_context=""):
    conn = sqlite3.connect(DB_PATH)
    rows = conn.execute(
        "SELECT model, raw_text FROM ocr_results WHERE page=?", (page_num,)
    ).fetchall()
    conn.close()

    results = {model: text for model, text in rows}
    if len(results) < 3:
        print(f"Page {page_num}: only {len(results)} models done, skipping")
        return

    client = OpenAI(base_url="http://localhost:8003/v1", api_key="placeholder")

    prompt = COMPARE_PROMPT.format(
        page=page_num,
        symbol_context=symbol_context,
        a=results.get("olmocr", ""),
        b=results.get("lighton", ""),
        c=results.get("qwen", ""),
    )

    response = client.chat.completions.create(
        model=COMPARISON_MODEL,
        messages=[{"role": "user", "content": prompt}],
        max_tokens=8192,
    ).choices[0].message.content

    try:
        data = json.loads(response)
    except json.JSONDecodeError:
        # Strip markdown fences if model added them
        cleaned = response.strip().removeprefix("```json").removesuffix("```").strip()
        data = json.loads(cleaned)

    save_spans(page_num, data["spans"])

def save_spans(page_num, spans):
    conn = sqlite3.connect(DB_PATH)
    for span in spans:
        outputs = span.get("outputs", {})
        text = span.get("text", "")
        conn.execute("""
            INSERT INTO review_spans
            (page, span_index, agreement, olmocr_text, lighton_text, qwen_text,
             resolved_text, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
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
```

### `pipeline/assemble.py`

```python
import sqlite3
from config import DB_PATH

def assemble_chapter(start_page, end_page, output_path):
    conn = sqlite3.connect(DB_PATH)
    lines = []

    for page in range(start_page, end_page + 1):
        spans = conn.execute("""
            SELECT agreement, resolved_text, olmocr_text
            FROM review_spans
            WHERE page=? ORDER BY span_index
        """, (page,)).fetchall()

        for agreement, resolved, olmocr in spans:
            text = resolved if resolved else olmocr
            if agreement == "CONFLICT":
                lines.append(f"#conflict[{text}]")
            elif agreement == "MINOR":
                lines.append(f"#minor[{text}]")
            else:
                lines.append(text)

    conn.close()

    with open(output_path, "w") as f:
        f.write("\n".join(lines))
    print(f"Written to {output_path}")
```

### `pipeline/review_app/app.py`

```python
from flask import Flask, render_template, request, jsonify
import sqlite3, base64
from pathlib import Path
from pdf2image import convert_from_path
from config import DB_PATH

app = Flask(__name__)

def get_page_image_b64(page_num):
    # Adjust path to your split PDF sections
    images = convert_from_path(f"raw/sections/full.pdf",
                               first_page=page_num, last_page=page_num, dpi=150)
    import io
    buf = io.BytesIO()
    images[0].save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()

@app.route("/")
def index():
    conn = sqlite3.connect(DB_PATH)
    pending = conn.execute("""
        SELECT DISTINCT page FROM review_spans WHERE status='pending'
        ORDER BY page
    """).fetchall()
    conn.close()
    return render_template("review.html", pages=[p[0] for p in pending])

@app.route("/page/<int:page_num>")
def review_page(page_num):
    conn = sqlite3.connect(DB_PATH)
    spans = conn.execute("""
        SELECT id, span_index, agreement, olmocr_text, lighton_text,
               qwen_text, resolved_text, status
        FROM review_spans WHERE page=? AND status='pending'
        ORDER BY span_index
    """, (page_num,)).fetchall()
    conn.close()

    image_b64 = get_page_image_b64(page_num)
    return render_template("review.html",
                           page_num=page_num,
                           spans=spans,
                           image_b64=image_b64)

@app.route("/resolve", methods=["POST"])
def resolve():
    data = request.json
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""
        UPDATE review_spans SET resolved_text=?, status='resolved'
        WHERE id=?
    """, (data["text"], data["span_id"]))
    conn.commit()
    conn.close()
    return jsonify({"ok": True})

if __name__ == "__main__":
    app.run(debug=True, port=5000)
```

---

## Task 3: GitHub Setup

Create these files:

### `README.md`
Describe: what the book is, its public domain status, how to build with Typst (`typst compile src/main.typ`), pipeline overview, how to contribute.

### `CONTRIBUTING.md`
Document: one sentence per line convention, LaTeX math in Typst (`$ ... $`), how to flag errors via issues, the three issue templates.

### `.github/workflows/build.yml`
```yaml
name: Build PDF
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: typst-community/setup-typst@v3
      - run: typst compile src/main.typ output.pdf
      - uses: actions/upload-artifact@v3
        with:
          name: book-pdf
          path: output.pdf
```

### `.github/ISSUE_TEMPLATE/ocr-error.md`
```markdown
---
name: OCR Error
about: Transcription mistake in the text
---
**Page:** 
**Section:**
**Current text:**
**Correct text:**
**Source:** (errata document / original scan)
```

### `.github/ISSUE_TEMPLATE/math-error.md`
```markdown
---
name: Math Error  
about: Incorrect equation or symbol
---
**Page:**
**Current equation:**
**Correct equation:**
```

---

## Git Workflow

Single editor project — use trunk-based development on `main` with tags for milestones.
No feature branches needed except `pipeline-dev` for experimenting with prompts/models.

Tag pattern per chapter:
```
ch3-symbols-complete
ch3-draft
ch3-reviewed
v0.1-chapters-3-4      ← GitHub release with compiled PDF attached
```

The one-sentence-per-line Typst convention makes `git diff` meaningful within chapter files.

---

## Figures

**During OCR phase** — use placeholder referencing the original scan:
```typst
#figure(
  image("../assets/figures-export/ch3fig7.png"),
  caption: [Drag coefficient as a function of Reynolds number]
)
```

Scan figures at 300 DPI minimum (600 for fine detail). Store in `assets/figures-original/` (gitignored).

**Recreating figures** — pick the right tool per figure type:
- Plots/graphs → Python (matplotlib), save as PDF, include in Typst. Track the `.py` source.
- Geometric diagrams, force diagrams → CeTZ (Typst's native drawing library). Track as `.typ` files.
- Complex technical illustrations → SVG in Inkscape. Track the `.svg` files.

Do not track rendered outputs (`figures-export/`) — these are regenerated from source.
Recreate figures after the text is complete, not during.

---

## Processing Order

**Start with Chapter 3** — it is the most complex (drag theory, lots of math) and a good
stress test before committing to the full book.

Per chapter:
1. OCR symbol table pages first — review carefully, this feeds all subsequent pages
2. Build `symbol_context` string from reviewed symbol table
3. Process one page through all 3 models → run comparison → review before proceeding
4. Once single-page output looks good, process full section
5. Run comparison model on all pages, resolve CONFLICT spans in review UI
6. Run `assemble.py` to generate `.typ` file
7. Check compiled Typst PDF for remaining `#conflict` / `#minor` markers
8. Run LaTeX→Typst math cleanup (Pandoc first, then a model for cleanup)
9. Tag milestone, flip `review-mode = false` for clean release build

