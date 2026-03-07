import argparse
import sqlite3
from pathlib import Path

from config import DB_PATH


def assemble_chapter(chapter, start_page, end_page, output_path):
    conn = sqlite3.connect(DB_PATH)
    lines = []

    for page in range(start_page, end_page + 1):
        spans = conn.execute("""
            SELECT agreement, resolved_text, olmocr_text
            FROM review_spans
            WHERE chapter=? AND page=? ORDER BY span_index
        """, (chapter, page)).fetchall()

        for agreement, resolved, olmocr in spans:
            text = resolved if resolved else olmocr
            if agreement == "CONFLICT":
                lines.append(f"#conflict[{text}]")
            elif agreement == "MINOR":
                lines.append(f"#minor[{text}]")
            else:
                lines.append(text)

    conn.close()

    Path(output_path).write_text("\n".join(lines))
    print(f"Written to {output_path}")


def parse_pages(pages_arg):
    if "-" in pages_arg:
        start, end = pages_arg.split("-")
        return int(start), int(end)
    n = int(pages_arg)
    return n, n


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--chapter", required=True)
    parser.add_argument("--pages",   required=True, help="e.g. 1-236")
    parser.add_argument("--output",  required=True, help="Path to write .typ file")
    args = parser.parse_args()

    start, end = parse_pages(args.pages)
    assemble_chapter(args.chapter, start, end, args.output)
