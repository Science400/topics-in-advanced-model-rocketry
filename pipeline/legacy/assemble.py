"""Assemble resolved OCR spans into a Typst source file.

Always writes ALL pages for the chapter that are in the DB — not just a batch.

Usage:
    uv run --project pipeline python pipeline/assemble.py \
        --chapter ch3 --output src/chapters/ch3-aerodynamic-drag.typ
"""
import argparse
import re
import sqlite3
from pathlib import Path

from config import DB_PATH, DEFAULT_COMPARISON_MODEL
from term import console

# ---------------------------------------------------------------------------
# Math + markup conversion
# ---------------------------------------------------------------------------

_DISPLAY_RE = re.compile(r'\$\$(.*?)\$\$', re.DOTALL)
_INLINE_RE  = re.compile(r'\$([^\$\n]+?)\$')


def _esc(s: str) -> str:
    """Escape a string for use inside a Typst double-quoted string literal."""
    return s.replace('\\', '\\\\').replace('"', '\\"')


def convert(text: str) -> str:
    """Convert OCR text (LaTeX math, markdown) to Typst source."""
    # Use a single placeholder list for both display and inline math so neither
    # is touched by later text-cleanup passes (especially underscore escaping).
    blocks: list[str] = []

    def _save(converted: str) -> str:
        blocks.append(converted)
        return f'\x00B{len(blocks) - 1}\x00'

    # Step 1: Protect display math ($$...$$)
    text = _DISPLAY_RE.sub(
        lambda m: _save(f'#mitex("{_esc(m.group(1).strip())}")'), text
    )

    # Step 2: Protect inline math ($...$)
    text = _INLINE_RE.sub(
        lambda m: _save(f'#mi("{_esc(m.group(1))}")'), text
    )

    # Step 3: Clean up non-math content
    # Complete markdown images: ![alt](path)  — may span lines
    text = re.sub(r'!\[.*?\]\([^)]*\)', '', text, flags=re.DOTALL)
    # Orphaned image tails: ](path)  — when ![alt is in a previous span
    text = re.sub(r'\]\([^)]*\)', '', text)
    # Orphaned image heads: ![alt text with no closing bracket in this span
    text = re.sub(r'!\[[^\]]*$', '', text, flags=re.MULTILINE)
    # HTML tags
    text = re.sub(r'<[^>]+>', '', text)
    # Bare underscores in plain text → Typst escape (safe: math is in placeholders)
    text = text.replace('_', r'\_')

    # Step 4: Markdown markup → Typst
    def _heading(m):
        return "=" * len(m.group(1)) + " " + m.group(2)
    text = re.sub(r'^(#{1,6})\s+(.+)$', _heading, text, flags=re.MULTILINE)
    text = re.sub(r'\*\*(.+?)\*\*', r'*\1*', text, flags=re.DOTALL)

    # Step 5: Restore math blocks
    for i, block in enumerate(blocks):
        text = text.replace(f'\x00B{i}\x00', block)

    return text


# ---------------------------------------------------------------------------
# Assembly
# ---------------------------------------------------------------------------

_CLEAN = {'auto', 'resolved', 'ai_resolved'}


def assemble_chapter(chapter, output_path,
                     comparison_model=DEFAULT_COMPARISON_MODEL):
    conn = sqlite3.connect(DB_PATH)

    pages = [r[0] for r in conn.execute(
        "SELECT DISTINCT page FROM review_spans "
        "WHERE chapter=? AND comparison_model=? ORDER BY page",
        (chapter, comparison_model),
    ).fetchall()]

    lines = []
    for page in pages:
        spans = conn.execute("""
            SELECT agreement, resolved_text, olmocr_text, status
            FROM review_spans
            WHERE chapter=? AND page=? AND comparison_model=?
            ORDER BY span_index
        """, (chapter, page, comparison_model)).fetchall()

        if not spans:
            continue

        # Comment on its own line — no surrounding blank lines so Typst doesn't
        # treat it as a paragraph break
        lines.append(f"// === page {page} ===")

        for agreement, resolved, olmocr, status in spans:
            text = (resolved or olmocr or "").strip()
            if not text:
                continue

            if status in _CLEAN:
                lines.append(convert(text))
            elif agreement == 'MINOR':
                lines.append(f"#minor[{convert(text)}]")
            else:  # pending CONFLICT or escalate
                lines.append(f"#conflict[{convert(text)}]")

    conn.close()

    header = (
        '#import "@preview/mitex:0.2.4": mitex, mi\n'
        '#import "../preamble.typ": conflict, minor\n\n'
    )

    out = Path(output_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(header + "\n".join(lines), encoding="utf-8")
    console.print(f"  [green]✓[/] Written {len(pages)} page(s), {len(lines)} lines to [cyan]{output_path}[/]")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Assemble all processed OCR spans for a chapter into a Typst source file."
    )
    parser.add_argument("--chapter",          required=True)
    parser.add_argument("--output",           required=True, help="Path to write .typ file")
    parser.add_argument("--comparison-model", default=DEFAULT_COMPARISON_MODEL,
                        help=f"Comparison model tag (default: {DEFAULT_COMPARISON_MODEL})")
    args = parser.parse_args()

    assemble_chapter(args.chapter, args.output, args.comparison_model)
