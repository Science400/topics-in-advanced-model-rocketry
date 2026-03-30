import difflib
import html
import io
import re
import sqlite3
import sys
from pathlib import Path

import pypdfium2 as pdfium
from flask import Flask, abort, jsonify, render_template, request, Response

sys.path.insert(0, str(Path(__file__).parent.parent))
from config import CHAPTER_PDFS, DB_PATH, PDF_DIR

app = Flask(__name__)
DEFAULT_COMPARISON_MODEL = "google/gemma-3-4b"


def db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def _diff_html(reference: str, other: str) -> str:
    """Return `other` as HTML with character-level differences highlighted."""
    matcher = difflib.SequenceMatcher(None, reference, other, autojunk=False)
    parts = []
    for tag, _i1, _i2, j1, j2 in matcher.get_opcodes():
        chunk = html.escape(other[j1:j2])
        if tag == "equal":
            parts.append(chunk)
        elif chunk:
            parts.append(f'<mark class="diff">{chunk}</mark>')
    return "".join(parts)


_TAG_RE   = re.compile(r"<[^>]+>")
_BBOX_RE  = re.compile(r'data-bbox="\[([^\]]+)\]"')

# Chandra renders at this longest-side resolution; display image at DISPLAY_LS
CHANDRA_LS = 1288
DISPLAY_LS = 1800


def _strip_tags(text: str) -> str:
    """Strip HTML tags from chandra's bounding-box output."""
    return _TAG_RE.sub("", text).strip()


def _extract_bboxes(chandra_html: str) -> list:
    """Return all [[x1,y1,x2,y2], ...] bounding boxes from chandra HTML."""
    bboxes = []
    for m in _BBOX_RE.finditer(chandra_html):
        try:
            bboxes.append([int(v.strip()) for v in m.group(1).split(",")])
        except ValueError:
            pass
    return bboxes


def _span_diffs(span, raw: dict) -> dict:
    """Compute character-level diff HTML for each model's span text."""
    olmocr  = (span["olmocr_text"]  or "").strip()
    lighton = (span["lighton_text"] or "").strip()
    chandra_raw = (span["chandra_text"] or "").strip()
    chandra = _strip_tags(chandra_raw)

    all_same = (olmocr == lighton == chandra)

    return {
        "olmocr_html":   html.escape(olmocr),
        "lighton_html":  _diff_html(olmocr, lighton),
        "chandra_html":  _diff_html(olmocr, chandra),
        "chandra_plain": chandra,
        "bboxes":        _extract_bboxes(chandra_raw),
        "all_same":      all_same,
    }


# ---------------------------------------------------------------------------
# Page image
# ---------------------------------------------------------------------------

@app.route("/api/page-image/<chapter>/<int:page_num>")
def page_image(chapter, page_num):
    pdf_name = CHAPTER_PDFS.get(chapter)
    if not pdf_name:
        abort(404)
    pdf_path = Path(PDF_DIR) / pdf_name
    if not pdf_path.exists():
        abort(404)

    doc = pdfium.PdfDocument(str(pdf_path))
    if page_num < 1 or page_num > len(doc):
        abort(404)
    page = doc[page_num - 1]
    longest_pts = max(page.get_width(), page.get_height())
    scale = 1800 / longest_pts  # ~150 dpi for letter
    bitmap = page.render(scale=scale)
    pil_image = bitmap.to_pil()
    buf = io.BytesIO()
    pil_image.save(buf, format="PNG")
    buf.seek(0)
    return Response(buf.read(), mimetype="image/png")


# ---------------------------------------------------------------------------
# Overview
# ---------------------------------------------------------------------------

@app.route("/")
def index():
    conn = db()
    rows = conn.execute("""
        SELECT chapter,
               SUM(status='pending')     as pending,
               SUM(status='escalate')    as escalate,
               SUM(status='ai_resolved') as ai_resolved,
               COUNT(*) as total
        FROM review_spans
        WHERE comparison_model = ?
        GROUP BY chapter
        ORDER BY chapter
    """, (DEFAULT_COMPARISON_MODEL,)).fetchall()
    conn.close()
    return render_template("review.html", view="index", chapters=rows)


# ---------------------------------------------------------------------------
# Chapter page list
# ---------------------------------------------------------------------------

@app.route("/chapter/<chapter>")
def chapter_view(chapter):
    conn = db()
    rows = conn.execute("""
        SELECT page,
               SUM(agreement='AGREE')    as agree,
               SUM(agreement='MINOR')    as minor,
               SUM(agreement='CONFLICT') as conflict,
               SUM(status='pending')     as pending,
               SUM(status='escalate')    as escalate,
               SUM(status='ai_resolved') as ai_resolved,
               COUNT(*)                  as total
        FROM review_spans
        WHERE chapter = ? AND comparison_model = ?
        GROUP BY page
        ORDER BY page
    """, (chapter, DEFAULT_COMPARISON_MODEL)).fetchall()
    conn.close()
    return render_template("review.html", view="chapter", chapter=chapter, pages=rows)


# ---------------------------------------------------------------------------
# Per-page review
# ---------------------------------------------------------------------------

@app.route("/review/<chapter>/<int:page_num>")
def review_page(chapter, page_num):
    conn = db()
    spans = conn.execute("""
        SELECT id, span_index, agreement,
               olmocr_text, lighton_text, chandra_text,
               resolved_text, status, ai_confidence, ai_notes
        FROM review_spans
        WHERE chapter = ? AND page = ? AND comparison_model = ?
        ORDER BY span_index
    """, (chapter, page_num, DEFAULT_COMPARISON_MODEL)).fetchall()

    adjacent = conn.execute("""
        SELECT DISTINCT page FROM review_spans
        WHERE chapter = ? AND comparison_model = ?
        ORDER BY page
    """, (chapter, DEFAULT_COMPARISON_MODEL)).fetchall()
    conn.close()

    pages = [r["page"] for r in adjacent]
    idx = pages.index(page_num) if page_num in pages else -1
    prev_page = pages[idx - 1] if idx > 0 else None
    next_page = pages[idx + 1] if idx >= 0 and idx < len(pages) - 1 else None

    # Fetch raw OCR texts for this page so diffs use the original model outputs
    conn2 = db()
    raw = {r["model"]: r["raw_text"] for r in conn2.execute(
        "SELECT model, raw_text FROM ocr_results WHERE chapter=? AND page=?",
        (chapter, page_num),
    ).fetchall()}
    conn2.close()

    diffs = {span["id"]: _span_diffs(span, raw) for span in spans
             if span["agreement"] != "AGREE"}

    return render_template(
        "review.html",
        view="page",
        chapter=chapter,
        page_num=page_num,
        spans=spans,
        diffs=diffs,
        prev_page=prev_page,
        next_page=next_page,
        chandra_ls=CHANDRA_LS,
        display_ls=DISPLAY_LS,
    )


# ---------------------------------------------------------------------------
# Resolve API
# ---------------------------------------------------------------------------

@app.route("/api/resolve", methods=["POST"])
def resolve():
    data = request.get_json()
    span_id = data.get("span_id")
    resolved_text = data.get("resolved_text", "")
    if not span_id:
        return jsonify({"ok": False, "error": "missing span_id"}), 400
    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        "UPDATE review_spans SET resolved_text=?, status='resolved' WHERE id=?",
        (resolved_text, span_id),
    )
    conn.commit()
    conn.close()
    return jsonify({"ok": True})


@app.route("/api/resolve-all", methods=["POST"])
def resolve_all():
    """Auto-resolve all AGREE spans on a page that are not yet resolved."""
    data = request.get_json()
    chapter = data.get("chapter")
    page_num = data.get("page")
    if not chapter or not page_num:
        return jsonify({"ok": False, "error": "missing chapter/page"}), 400
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""
        UPDATE review_spans
        SET resolved_text = olmocr_text, status = 'resolved'
        WHERE chapter=? AND page=? AND comparison_model=?
          AND agreement='AGREE' AND status != 'resolved'
    """, (chapter, page_num, DEFAULT_COMPARISON_MODEL))
    count = conn.total_changes
    conn.commit()
    conn.close()
    return jsonify({"ok": True, "resolved": count})


@app.route("/api/accept-ai-resolve", methods=["POST"])
def accept_ai_resolve():
    """Accept a single ai_resolved span (promote to resolved) or bulk-accept a page."""
    data = request.get_json()
    span_id  = data.get("span_id")
    chapter  = data.get("chapter")
    page_num = data.get("page")

    conn = sqlite3.connect(DB_PATH)
    if span_id:
        # Single span
        conn.execute(
            "UPDATE review_spans SET status='resolved' WHERE id=? AND status='ai_resolved'",
            (span_id,),
        )
    elif chapter and page_num:
        # Bulk: all ai_resolved spans on the page
        conn.execute("""
            UPDATE review_spans SET status='resolved'
            WHERE chapter=? AND page=? AND comparison_model=? AND status='ai_resolved'
        """, (chapter, page_num, DEFAULT_COMPARISON_MODEL))
    else:
        conn.close()
        return jsonify({"ok": False, "error": "provide span_id or chapter+page"}), 400

    count = conn.total_changes
    conn.commit()
    conn.close()
    return jsonify({"ok": True, "resolved": count})


if __name__ == "__main__":
    app.run(debug=True, port=5000)
