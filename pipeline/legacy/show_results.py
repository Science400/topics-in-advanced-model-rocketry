"""
Quick inspection of OCR results in the database.

Usage:
  uv run python inspect.py --chapter ch3 --page 11
  uv run python inspect.py --chapter ch3 --page 11 --model lighton
  uv run python inspect.py --list
"""

import argparse
import sqlite3
import textwrap

from config import DB_PATH

DIVIDER = "─" * 72


def list_pages():
    conn = sqlite3.connect(DB_PATH)
    rows = conn.execute("""
        SELECT chapter, page, GROUP_CONCAT(model, ', ') as models, COUNT(*) as n
        FROM ocr_results
        GROUP BY chapter, page
        ORDER BY chapter, page
    """).fetchall()
    conn.close()

    if not rows:
        print("No OCR results in database yet.")
        return

    print(f"{'Chapter':<10} {'Page':<6} {'Models'}")
    print(DIVIDER)
    for chapter, page, models, _ in rows:
        print(f"{chapter:<10} {page:<6} {models}")


def show_page(chapter, page, model=None):
    conn = sqlite3.connect(DB_PATH)
    if model:
        rows = conn.execute(
            "SELECT model, raw_text FROM ocr_results WHERE chapter=? AND page=? AND model=?",
            (chapter, page, model),
        ).fetchall()
    else:
        rows = conn.execute(
            "SELECT model, raw_text FROM ocr_results WHERE chapter=? AND page=? ORDER BY model",
            (chapter, page),
        ).fetchall()
    conn.close()

    if not rows:
        print(f"No results for {chapter} page {page}" + (f" model={model}" if model else ""))
        return

    for model_name, raw_text in rows:
        print(DIVIDER)
        print(f"  {chapter}  page {page}  [{model_name}]")
        print(DIVIDER)
        # Wrap long lines for readability but preserve intentional newlines
        for line in raw_text.splitlines():
            if len(line) > 100:
                print(textwrap.fill(line, width=100, subsequent_indent="  "))
            else:
                print(line)
        print()


def show_spans(chapter, page, comparison_model=None):
    conn = sqlite3.connect(DB_PATH)
    if comparison_model:
        rows = conn.execute("""
            SELECT comparison_model, span_index, agreement,
                   olmocr_text, lighton_text, chandra_text
            FROM review_spans
            WHERE chapter=? AND page=? AND comparison_model=?
            ORDER BY span_index
        """, (chapter, page, comparison_model)).fetchall()
    else:
        rows = conn.execute("""
            SELECT comparison_model, span_index, agreement,
                   olmocr_text, lighton_text, chandra_text
            FROM review_spans
            WHERE chapter=? AND page=?
            ORDER BY comparison_model, span_index
        """, (chapter, page)).fetchall()
    conn.close()

    if not rows:
        print(f"No spans for {chapter} page {page}" + (f" [{comparison_model}]" if comparison_model else ""))
        return

    cur_cmodel = None
    for cmodel, span_idx, agreement, olmocr, lighton, chandra in rows:
        if cmodel != cur_cmodel:
            print(f"\n{'═' * 72}")
            print(f"  comparison_model: {cmodel}")
            print(f"{'═' * 72}")
            cur_cmodel = cmodel
        print(f"\n  span {span_idx}  [{agreement}]")
        if agreement == "AGREE":
            print(f"    {olmocr[:120]}")
        else:
            print(f"    olmocr:  {olmocr[:100]}")
            print(f"    lighton: {lighton[:100]}")
            print(f"    chandra: {chandra[:100]}")


def list_spans_summary():
    conn = sqlite3.connect(DB_PATH)
    rows = conn.execute("""
        SELECT chapter, page, comparison_model,
               COUNT(*) as total,
               SUM(agreement='AGREE') as agree,
               SUM(agreement='MINOR') as minor,
               SUM(agreement='CONFLICT') as conflict
        FROM review_spans
        GROUP BY chapter, page, comparison_model
        ORDER BY chapter, page, comparison_model
    """).fetchall()
    conn.close()

    if not rows:
        print("No spans in database yet.")
        return

    print(f"{'Chapter':<8} {'Page':<6} {'Model':<32} {'Total':>6} {'AGREE':>6} {'MINOR':>6} {'CONFLICT':>8}")
    print(DIVIDER)
    for chapter, page, cmodel, total, agree, minor, conflict in rows:
        print(f"{chapter:<8} {page:<6} {cmodel:<32} {total:>6} {agree:>6} {minor:>6} {conflict:>8}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--list",    action="store_true", help="List all pages with OCR results")
    parser.add_argument("--spans",   action="store_true", help="Show span comparison results")
    parser.add_argument("--chapter", help="Chapter key, e.g. ch3")
    parser.add_argument("--page",    type=int, help="Page number")
    parser.add_argument("--model",   help="Filter to one OCR/comparison model (optional)")
    args = parser.parse_args()

    if args.list:
        list_pages()
    elif args.spans and args.chapter and args.page:
        show_spans(args.chapter, args.page, args.model)
    elif args.spans:
        list_spans_summary()
    elif args.chapter and args.page:
        show_page(args.chapter, args.page, args.model)
    else:
        parser.print_help()
