#!/usr/bin/env python3
"""
Shared OCR primitives: rendering, response extraction, and output normalizers.

Used by both `ocr.py` (the pipeline) and `bakeoff.py` (the model comparison
harness) so there is exactly one implementation of each normalizer. Two copies
that drift apart is the class of inconsistency this rebuild exists to remove.
"""

from __future__ import annotations

import base64
import io
import json
import re
from html.parser import HTMLParser
from pathlib import Path

# olmOCR's native resolution; also a sane default for the other VLMs.
MAX_LONGEST_SIDE = 1288


# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------

def render_page(pdf_path: Path, page_num: int, longest_side: int = MAX_LONGEST_SIDE) -> str:
    """Render one 1-based PDF page to a base64 PNG with the given longest edge."""
    import pypdfium2 as pdfium

    pdf = pdfium.PdfDocument(str(pdf_path))
    try:
        page = pdf[page_num - 1]  # pypdfium2 is 0-indexed
        longest_pts = max(page.get_width(), page.get_height())
        image = page.render(scale=longest_side / longest_pts).to_pil()
    finally:
        pdf.close()
    buf = io.BytesIO()
    image.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


# ---------------------------------------------------------------------------
# Response extraction
# ---------------------------------------------------------------------------

def message_text(message) -> str:
    """
    Pull the assistant text out of a response message.

    LM Studio applies thinking-channel parsing based on base architecture, so a
    Qwen-derived OCR model can return its entire output in `reasoning_content`
    with `content` empty. Falling back is also correct for genuine thinking
    models, where `content` is populated and takes precedence.

    Any code path talking to LM Studio must use this rather than reading
    `.content` directly, or it will silently produce empty pages.
    """
    text = (getattr(message, "content", None) or "").strip()
    if text:
        return text
    extra = getattr(message, "model_extra", None) or {}
    return (extra.get("reasoning_content") or "").strip()


# ---------------------------------------------------------------------------
# Normalizers — collapse each model's native format to text + LaTeX
# ---------------------------------------------------------------------------

def unify_math_delims(text: str) -> str:
    r"""
    Rewrite LaTeX \(..\) and \[..\] delimiters to $..$ and $$..$$.

    olmocr emits math in \(..\) / \[..\] form while chandra uses <math> tags.
    Putting both into $-delimited form is what makes side-by-side comparison
    readable and any math-span metric meaningful.
    """
    text = re.sub(r"\\\[\s*(.+?)\s*\\\]", lambda m: f"$$ {m.group(1)} $$", text, flags=re.S)
    text = re.sub(r"\\\(\s*(.+?)\s*\\\)", lambda m: f"${m.group(1)}$", text, flags=re.S)
    return text


def normalize_olmocr(raw: str) -> str:
    """Strip olmocr's YAML front matter, keeping the natural text body."""
    text = raw.strip()
    if "<transcription>" in text and "</transcription>" in text:
        text = text.split("<transcription>", 1)[1].split("</transcription>", 1)[0]
    elif text.startswith("---"):
        # The v4 yaml prompt returns front matter then page text after a --- fence.
        parts = text.split("---")
        if len(parts) >= 3:
            text = "---".join(parts[2:])
    else:
        match = re.search(r"^natural_text:\s*\|?\s*\n(.*)", text, re.S | re.M)
        if match:
            text = match.group(1)
    return unify_math_delims(text.strip())


class _ChandraHTML(HTMLParser):
    """Flatten chandra's layout HTML to text, turning <math> into $...$."""

    _BLOCK = {"div", "p", "h1", "h2", "h3", "h4", "h5", "li", "tr", "br"}

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []
        self._math_depth = 0
        self._math_block = False

    def handle_starttag(self, tag, attrs):
        if tag == "math":
            self._math_depth += 1
            self._math_block = dict(attrs).get("display") == "block"
            self.parts.append("$$" if self._math_block else "$")
        elif tag in self._BLOCK:
            self.parts.append("\n")

    def handle_endtag(self, tag):
        if tag == "math" and self._math_depth:
            self._math_depth -= 1
            self.parts.append("$$" if self._math_block else "$")
            self._math_block = False
        elif tag in self._BLOCK:
            self.parts.append("\n")

    def handle_data(self, data):
        self.parts.append(data)

    def text(self) -> str:
        return re.sub(r"\n{3,}", "\n\n", "".join(self.parts)).strip()


def normalize_chandra(raw: str) -> str:
    parser = _ChandraHTML()
    try:
        parser.feed(raw)
        out = parser.text()
    except Exception:
        return raw
    return out or raw


# A backslash that does not begin a valid JSON escape. Models emitting LaTeX
# inside JSON routinely produce \int, \frac, \, — all invalid JSON.
_BAD_ESCAPE_RE = re.compile(r'\\(["\\/bfnrt]|u[0-9a-fA-F]{4})|\\')


def loads_lenient(payload: str):
    """json.loads, retrying once with unescaped backslashes repaired."""
    try:
        return json.loads(payload)
    except json.JSONDecodeError:
        pass
    repaired = _BAD_ESCAPE_RE.sub(lambda m: m.group(0) if m.group(1) else r"\\", payload)
    return json.loads(repaired)  # may raise; caller handles


def normalize_infinity(raw: str) -> str:
    """Parse Infinity-Parser's layout JSON and emit text in reading order."""
    text = raw.strip()
    if text.startswith("```"):
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```$", "", text)
    start, end = text.find("{"), text.rfind("}")
    if start == -1 or end <= start:
        return raw
    try:
        data = loads_lenient(text[start:end + 1])
    except json.JSONDecodeError:
        return raw

    elements = None
    if isinstance(data, dict):
        for candidate in ("layout", "elements", "layout_elements", "results", "data"):
            if isinstance(data.get(candidate), list):
                elements = data[candidate]
                break
        if elements is None:
            for value in data.values():
                if isinstance(value, list) and value and isinstance(value[0], dict):
                    elements = value
                    break
    elif isinstance(data, list):
        elements = data
    if elements is None:
        return raw

    out: list[str] = []
    for el in elements:
        if not isinstance(el, dict):
            continue
        category = str(el.get("category") or el.get("label") or "").lower()
        content = el.get("text")
        if content is None:
            content = el.get("content", "")
        content = str(content).strip()
        if category == "figure" and not content:
            out.append("[figure]")
            continue
        if not content:
            continue
        out.append(f"$$ {content} $$" if category == "formula" else content)
    return "\n\n".join(out).strip() or raw


def normalize(family: str, raw: str) -> str:
    """Dispatch to the normalizer for a prompt family: olmocr | chandra | infinity."""
    raw = raw.split("</think>", 1)[-1] if "</think>" in raw else raw
    if family == "chandra":
        return normalize_chandra(raw)
    if family == "infinity":
        return normalize_infinity(raw)
    return normalize_olmocr(raw)


# ---------------------------------------------------------------------------
# Degraded-output detection
# ---------------------------------------------------------------------------

# After a Vulkan device loss, LM Studio keeps answering with HTTP 200 but the
# engine produces corrupted text — observed: "0.0 & 21.0" (LaTeX separators
# inside an HTML table), "</ </tr", digits fused as "115.1"/"0.40.4", and CJK
# characters on an English page. A retry that only catches exceptions will
# cache this as if it were a good transcription, so it has to be caught here.

_CJK_RE = re.compile(r"[぀-ヿ一-鿿가-힯]")
_BROKEN_TAG_RE = re.compile(r"</\s+|<\s+/|</[a-z]*\s*$", re.M)
MIN_PLAUSIBLE_CHARS = 80


def looks_degraded(text: str) -> str | None:
    """Return a reason string if the output looks corrupted, else None."""
    stripped = text.strip()
    if len(stripped) < MIN_PLAUSIBLE_CHARS:
        return f"only {len(stripped)} chars"
    if _CJK_RE.search(stripped):
        return "CJK characters in an English document"
    if _BROKEN_TAG_RE.search(stripped):
        return "malformed HTML tag"
    if stripped.count("<table") != stripped.count("</table"):
        return "unbalanced <table> tags"
    # LaTeX tabular separators leaking into an HTML table is a corruption tell,
    # never something the model produces when healthy.
    if "<table" in stripped and re.search(r"<t[dr][^>]*>[^<]*&[^<]*$", stripped, re.M):
        return "LaTeX '&' separators inside an HTML table"
    return None


# ---------------------------------------------------------------------------
# Mechanical metrics — never a quality proxy, only a smoke signal
# ---------------------------------------------------------------------------

MATH_RE = re.compile(r"\$\$.+?\$\$|\$[^$\n]+\$", re.S)
LATEX_CMD_RE = re.compile(r"\\[A-Za-z]+")
# Manuscript equation numbers: a parenthesised number, optionally lettered.
EQ_NUM_RE = re.compile(r"\((\d{1,3}[a-z]?)\)")


def metrics(text: str) -> dict:
    return {
        "chars": len(text),
        "lines": text.count("\n") + 1 if text else 0,
        "math_spans": len(MATH_RE.findall(text)),
        "latex_cmds": len(LATEX_CMD_RE.findall(text)),
        "eq_numbers": sorted(set(EQ_NUM_RE.findall(text))),
    }
