# Pipeline — Quick Reference

All commands are run from the **project root** with `uv run --project pipeline python pipeline/<script>`.

LM Studio must be running before any OCR, compare, or resolve commands.

---

## Most Common Workflows

### Process a new batch of pages (full pipeline)

```bash
uv run --project pipeline python pipeline/run.py --chapter ch3 --pages 121-220
```

Runs all five stages in sequence: OCR → compare → resolve → assemble → typst compile.

### After reviewing in the web UI — rebuild the PDF

```bash
uv run --project pipeline python pipeline/run.py --chapter ch3 --refresh
```

Skips OCR/compare/resolve. Re-assembles all DB pages for the chapter and recompiles.

### Accept all remaining conflicts and rebuild

```bash
uv run --project pipeline python pipeline/run.py --chapter ch3 --accept-all
```

Marks every `escalate` and `pending` span as accepted (using the AI's best guess, or
olmocr as fallback), then re-assembles and recompiles. Use this when you'd rather
fix remaining issues directly in the `.typ` file than review them span-by-span in the
web UI.

### Start the review web app

```bash
uv run --project pipeline python pipeline/review_app/app.py
```

Open [http://localhost:5000](http://localhost:5000). Shows all pages with pending conflict spans.

---

## Individual Scripts

### `run.py` — End-to-end pipeline orchestrator

```bash
uv run --project pipeline python pipeline/run.py \
    --chapter ch3 \
    --pages 121-220          # page range (not needed with --refresh)
    --refresh                # re-assemble + recompile only; skip OCR/compare/resolve
    --accept-all             # accept all escalated/pending spans, then refresh
    --resolve-model qwen3-4b # default: gemma
    --threshold 0.85         # confidence threshold for auto-resolving (default: 0.85)
    --also-minor             # also AI-resolve MINOR spans (default: CONFLICT only)
    --skip-ocr               # skip individual stages as needed
    --skip-compare
    --skip-resolve
    --skip-assemble
    --skip-compile
    --pdf output.pdf         # output filename (default: output.pdf)
```

### `resolve.py` — AI conflict resolution (standalone)

Re-run resolve on specific pages, e.g. after updating the symbol table:

```bash
uv run --project pipeline python pipeline/resolve.py \
    --chapter ch3 \
    --pages 11-120 \
    --model qwen3-4b \
    --threshold 0.85 \
    --also-minor \           # include MINOR spans
    --reset                  # reset ai_resolved/escalate back to pending first
```

`--reset` is needed if the pages were already resolved and you want to re-run from scratch.
Without `--reset`, only spans still in `pending` status are processed.

### `compare.py` — Compare OCR outputs (standalone)

```bash
uv run --project pipeline python pipeline/compare.py \
    --chapter ch3 \
    --pages 11-30 \
    --model gemma
```

### `assemble.py` — Build the Typst source file (standalone)

Assembles ALL pages for the chapter currently in the DB (not just a batch):

```bash
uv run --project pipeline python pipeline/assemble.py \
    --chapter ch3 \
    --output src/chapters/ch3-aerodynamic-drag.typ
```

### `show_results.py` — Inspect the database

```bash
# List all pages with OCR results for a chapter
uv run --project pipeline python pipeline/show_results.py --list --chapter ch3

# Show span-level comparison results for a specific page
uv run --project pipeline python pipeline/show_results.py --spans --chapter ch3 --page 42
```

---

## Span Statuses

| Status | Meaning |
|--------|---------|
| `auto` | All three models agreed — no review needed |
| `pending` | Conflict flagged, awaiting resolution |
| `ai_resolved` | AI resolved with sufficient confidence |
| `escalate` | AI couldn't resolve confidently — needs human review in web UI |
| `resolved` | Manually resolved in the web UI |

In the assembled `.typ` file:
- `auto`, `ai_resolved`, `resolved` → plain text
- `MINOR` pending → `#minor[...]` (yellow highlight in review mode)
- `CONFLICT` pending or `escalate` → `#conflict[...]` (red highlight in review mode)

---

## Symbol Tables

Per-chapter symbol files live in `pipeline/symbols/{chapter}.md`.
They are loaded automatically by `run.py` and passed to OCR, compare, and resolve.

Edit `pipeline/symbols/ch3.md` to add or correct symbol definitions before processing a chapter.

---

## Typst Compilation (standalone)

```bash
typst compile src/main.typ output.pdf
```

Run from the project root. Requires [Typst](https://typst.app) installed.
