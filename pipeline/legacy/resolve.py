"""AI-assisted conflict resolution pass.

Reads CONFLICT (and optionally MINOR) spans from the database, sends them to an LLM
one page at a time with surrounding page context and a chapter symbol table, then tags
each span as either 'ai_resolved' (high confidence) or 'escalate' (needs human review).

Usage:
    uv run python resolve.py --chapter ch3 --pages 24-30 [--model gemma] [--threshold 0.75]
                             [--also-minor] [--symbol-file pipeline/symbols/ch3.md]
"""
import argparse
import json
import re
import sqlite3
import threading
import time
from pathlib import Path

from openai import OpenAI

from config import (
    AI_CONFIDENCE_THRESHOLD,
    DB_PATH,
    LM_STUDIO_BASE_URL,
    RESOLUTION_MODELS,
)
from lms import ensure_loaded
from term import console

# ---------------------------------------------------------------------------
# LLM call parameters.  Note: qwen3-4b does NOT use the empty-think prefill
# here — we want brief reasoning, not suppressed thinking.
# ---------------------------------------------------------------------------
_RESOLVE_PARAMS = {
    "google/gemma-3-4b": {
        "temperature": 0.1,
        "max_tokens":  2048,
    },
    "qwen3-4b-instruct-2507": {
        "temperature": 0.6,
        "top_p":       0.9,
        "max_tokens":  3000,
        "extra_body":  {"top_k": 20},
    },
}

# ---------------------------------------------------------------------------
# Prompt template
# ---------------------------------------------------------------------------
_RESOLVE_PROMPT = """\
You are proofreading OCR conflicts in a scanned rocketry textbook.
Your job is to pick the correct text for each conflicting span.

OCR ERROR SUBSTITUTION TABLE:
The WRONG column lists OCR mistakes — invalid tokens that must be replaced.
`f`, `f_0`, `f_o` are NOT valid symbols; they are misread Greek letters.
Apply these substitutions to whichever model made the error before choosing resolved text.
{symbol_context}

PAGE CONTEXT (surrounding agreed text — for understanding variable definitions only; \
do not modify this text):
{page_context}

CONFLICTS TO RESOLVE:
{conflicts_json}

Each conflict has three OCR model outputs: olmocr, lighton, chandra.
Steps to resolve each span:
1. Look at the actual text of each model's output for this span.
   Only apply a substitution rule if the WRONG token literally appears in that output.
   Do NOT apply a rule if you cannot find the exact WRONG token in the text.
2. If no substitution rule applies, choose the best text by majority vote or page context.
   Prefer olmocr when models disagree and no rule applies.
3. If the conflict is about formatting (degree symbols, page numbers, emphasis markup,
   equation delimiters) rather than symbol identity, set confidence <= 0.5 and escalate.
4. In your reasoning, quote the exact WRONG token you found (or state "no substitution
   rule applies" if none of the WRONG tokens appear in any model's output).

Confidence — be conservative:
  1.0 = exactly one model has a known WRONG token; other two agree on the correct form
  0.8 = substitution applied AND the corrected text matches at least one other model
  0.5 = substitution applied but corrected text still differs from all other models,
        OR conflict is about formatting/delimiters/page numbers rather than symbols
  0.3 = all three models differ with no applicable rule, or the correct form is unclear
  If your resolved_text still contains any WRONG token from the table, set confidence 0.3.

Return ONLY valid JSON — no markdown fences, no explanation outside the JSON:
{{
  "resolutions": [
    {{
      "span_index": <integer>,
      "resolved_text": "<best text>",
      "confidence": <float 0.0-1.0>,
      "reasoning": "<one sentence — cite the specific substitution or agreement>"
    }}
  ]
}}

Spans with confidence >= {threshold} will be auto-accepted without human review.
"""


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _load_symbol_context(chapter: str, symbol_file: str | None) -> str:
    """Load symbol table from file, or return empty string."""
    if symbol_file:
        path = Path(symbol_file)
    else:
        path = Path(__file__).parent / "symbols" / f"{chapter}.md"
    if path.exists():
        return path.read_text(encoding="utf-8").strip()
    return ""


def _llm_call(client, model_id, prompt, label=""):
    """Make a single LLM call with status spinner; return (response_text, elapsed_s)."""
    params = _RESOLVE_PARAMS.get(model_id, {"temperature": 0.1, "max_tokens": 2048})
    # qwen3-4b: do NOT inject empty-think prefill — allow brief reasoning
    messages = [{"role": "user", "content": prompt}]

    display = label or "LLM"
    t0 = time.monotonic()
    stop = threading.Event()
    def _tick(t_start=t0):
        while not stop.wait(15):
            t = int(time.monotonic() - t_start)
            status.update(f"[cyan]{display}[/] — {t}s...")
    with console.status(f"[cyan]{display}[/]...") as status:
        tick = threading.Thread(target=_tick, daemon=True)
        tick.start()
        try:
            completion = client.chat.completions.create(model=model_id, messages=messages, **params)
        finally:
            stop.set()
            tick.join()
    elapsed = time.monotonic() - t0

    return completion.choices[0].message.content or "", elapsed


def _fix_escapes(s: str) -> str:
    """Fix invalid JSON escape sequences, including LaTeX commands like \\rho, \\Delta.

    The regex approach fails because JSON valid single-char escapes (\\r, \\n, \\t, \\f, \\b)
    overlap with LaTeX command prefixes (\\rho, \\nu, \\tau, \\frac, \\beta).  A char-by-char
    scanner handles each case explicitly:
      - \\uXXXX with valid hex  → keep
      - \\u + non-hex           → double (invalid unicode escape)
      - \\", \\\\, \\/          → keep (always valid)
      - \\b/f/n/r/t + alnum    → double (LaTeX command, e.g. \\rho, \\frac, \\nu)
      - \\b/f/n/r/t + non-alnum→ keep (real JSON control escape)
      - anything else           → double (unknown escape like \\D, \\p)
    """
    out = []
    i = 0
    n = len(s)
    while i < n:
        if s[i] != '\\' or i + 1 >= n:
            out.append(s[i])
            i += 1
            continue
        nxt = s[i + 1]
        after = s[i + 2] if i + 2 < n else ''
        if nxt == 'u':
            hex4 = s[i + 2: i + 6]
            if len(hex4) == 4 and all(c in '0123456789abcdefABCDEF' for c in hex4):
                out.append(s[i: i + 6])
                i += 6
            else:
                out.append('\\\\')
                i += 1
        elif nxt in '"\\/':
            out.append(s[i: i + 2])
            i += 2
        elif nxt in 'bfnrt':
            if after and after.isalnum():
                # Looks like a LaTeX command (\\rho, \\beta, \\frac, \\nu, \\tau …)
                out.append('\\\\')
                i += 1
            else:
                out.append(s[i: i + 2])
                i += 2
        else:
            out.append('\\\\')
            i += 1
    return ''.join(out)


def _parse_json(response: str) -> dict:
    """Parse JSON from LLM response, tolerating markdown fences and bad escapes."""
    def _try(s):
        try:
            return json.loads(s)
        except json.JSONDecodeError:
            return json.loads(_fix_escapes(s))

    try:
        return _try(response)
    except json.JSONDecodeError:
        cleaned = response.removeprefix("```json").removesuffix("```").strip()
        try:
            return _try(cleaned)
        except json.JSONDecodeError:
            match = re.search(r'\{.*\}', cleaned, re.DOTALL)
            if not match:
                raise ValueError(f"No JSON found in response:\n{response[:500]}")
            try:
                return _try(match.group())
            except (json.JSONDecodeError, ValueError) as exc:
                raise ValueError(
                    f"JSON parse failed after all fallbacks: {exc}\n"
                    f"Response (first 800 chars):\n{response[:800]}"
                ) from exc


def _norm_ws(s: str) -> str:
    return " ".join(s.split())


# Patterns that must NOT appear in resolved text (ch3 known OCR errors).
# If any match, the resolution is incomplete and must be escalated.
_WRONG_TOKEN_PATTERNS = [
    # f used as a variable symbol (not inside words like "of", "for", "from", "if")
    re.compile(r'(?<![A-Za-z])f(?![A-Za-z])'),
    # f_0, f_o, f0 (lighton's misread of rho_0)
    re.compile(r'f[_]?[0o]'),
]


def _still_has_errors(text: str) -> bool:
    """Return True if resolved text still contains known WRONG tokens."""
    return any(p.search(text) for p in _WRONG_TOKEN_PATTERNS)


# ---------------------------------------------------------------------------
# Core resolution logic
# ---------------------------------------------------------------------------

def resolve_page(chapter, page_num, model_id, symbol_context, threshold, also_minor):
    agreements = ["CONFLICT", "MINOR"] if also_minor else ["CONFLICT"]
    placeholders = ",".join("?" * len(agreements))

    conn = sqlite3.connect(DB_PATH)

    # Fetch conflict spans
    conflict_rows = conn.execute(f"""
        SELECT id, span_index, agreement, olmocr_text, lighton_text, chandra_text
        FROM review_spans
        WHERE chapter=? AND page=? AND status='pending'
          AND agreement IN ({placeholders})
        ORDER BY span_index
    """, (chapter, page_num, *agreements)).fetchall()

    if not conflict_rows:
        conn.close()
        return 0, 0

    # Fetch surrounding context (AGREE/auto spans)
    context_rows = conn.execute("""
        SELECT span_index, resolved_text, olmocr_text
        FROM review_spans
        WHERE chapter=? AND page=? AND status IN ('auto', 'resolved')
        ORDER BY span_index
    """, (chapter, page_num)).fetchall()

    conn.close()

    # Build page context string (interleave context with [CONFLICT] markers)
    conflict_indices = {r[1] for r in conflict_rows}
    page_lines = []
    for idx, resolved, olmocr in context_rows:
        if idx not in conflict_indices:
            text = resolved or olmocr or ""
            if text.strip():
                page_lines.append(_norm_ws(text))
    page_context = "\n".join(page_lines) if page_lines else "(no surrounding context available)"

    # Build conflicts JSON for the prompt
    conflicts = []
    for row_id, span_idx, agreement, olmocr, lighton, chandra in conflict_rows:
        conflicts.append({
            "span_index": span_idx,
            "agreement":  agreement,
            "olmocr":     _norm_ws(olmocr  or ""),
            "lighton":    _norm_ws(lighton  or ""),
            "chandra":    _norm_ws(chandra  or ""),
        })

    prompt = _RESOLVE_PROMPT.format(
        symbol_context=symbol_context or "(none provided — use majority vote and context)",
        page_context=page_context,
        conflicts_json=json.dumps(conflicts, indent=2, ensure_ascii=False),
        threshold=threshold,
    )

    client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio", timeout=7200.0)

    try:
        response, elapsed = _llm_call(client, model_id, prompt, label=f"{chapter} p{page_num}")
        data = _parse_json(response.strip())
    except Exception as e:
        console.print(f"  [red]✗[/] {chapter} p{page_num}: LLM error — {e}")
        return 0, 0

    resolutions = data.get("resolutions", [])

    # Index conflict rows by span_index for fast lookup
    span_map = {r[1]: r[0] for r in conflict_rows}  # span_index → row id

    n_resolved = 0
    n_escalated = 0

    conn = sqlite3.connect(DB_PATH)
    for res in resolutions:
        span_idx  = res.get("span_index")
        resolved  = res.get("resolved_text", "")
        conf      = float(res.get("confidence", 0.0))
        reasoning = res.get("reasoning", "")

        row_id = span_map.get(span_idx)
        if row_id is None:
            console.print(f"  [yellow]warning: span_index {span_idx} not found on page {page_num}[/]")
            continue

        if _still_has_errors(resolved):
            conf = min(conf, 0.3)
            reasoning = f"[auto-downgraded: resolved text still contains WRONG token] {reasoning}"

        new_status = "ai_resolved" if conf >= threshold else "escalate"
        conn.execute("""
            UPDATE review_spans
            SET resolved_text=?, status=?, ai_confidence=?, ai_notes=?
            WHERE id=?
        """, (_norm_ws(resolved), new_status, conf, reasoning, row_id))

        if new_status == "ai_resolved":
            n_resolved += 1
        else:
            n_escalated += 1

    conn.commit()
    conn.close()

    console.print(f"  [green]✓[/] {chapter} p{page_num}: {n_resolved} ai_resolved, "
                  f"[yellow]{n_escalated} escalated[/] ({elapsed:.1f}s)")
    return n_resolved, n_escalated


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
    parser = argparse.ArgumentParser(
        description="AI first-pass conflict resolution for OCR spans."
    )
    parser.add_argument("--chapter",     required=True)
    parser.add_argument("--pages",       required=True, help="e.g. 14-30 or 24")
    parser.add_argument("--model",       default="gemma", choices=list(RESOLUTION_MODELS),
                        help="Resolution model (default: gemma)")
    parser.add_argument("--threshold",   type=float, default=AI_CONFIDENCE_THRESHOLD,
                        help=f"Confidence threshold for ai_resolved (default: {AI_CONFIDENCE_THRESHOLD})")
    parser.add_argument("--also-minor",  action="store_true",
                        help="Also resolve MINOR spans (default: CONFLICT only)")
    parser.add_argument("--symbol-file", default=None,
                        help="Path to symbol table markdown (default: symbols/{chapter}.md)")
    parser.add_argument("--reset",       action="store_true",
                        help="Reset ai_resolved/escalate spans back to pending before running")
    args = parser.parse_args()

    start, end = parse_pages(args.pages)

    if args.reset:
        conn = sqlite3.connect(DB_PATH)
        conn.execute("""
            UPDATE review_spans
            SET status='pending', resolved_text=NULL, ai_confidence=NULL, ai_notes=NULL
            WHERE chapter=? AND page BETWEEN ? AND ?
              AND status IN ('ai_resolved', 'escalate')
        """, (args.chapter, start, end))
        n = conn.total_changes
        conn.commit()
        conn.close()
        console.print(f"  Reset {n} span(s) to pending.")

    model_id = RESOLUTION_MODELS[args.model]
    ensure_loaded(model_id)

    symbol_context = _load_symbol_context(args.chapter, args.symbol_file)
    if symbol_context:
        console.print(f"  [dim]Symbol context loaded ({len(symbol_context)} chars)[/]")
    else:
        console.print(f"  [yellow]No symbol file found — resolution will use majority vote only[/]")
    total_pages = end - start + 1
    total_resolved = total_escalated = 0
    run_start = time.monotonic()

    for page in range(start, end + 1):
        r, e = resolve_page(
            args.chapter, page, model_id, symbol_context,
            args.threshold, args.also_minor,
        )
        total_resolved  += r
        total_escalated += e

    total_elapsed = time.monotonic() - run_start
    mins = total_elapsed / 60
    rate = total_pages / mins if mins > 0 else float("inf")
    console.print(f"Done. {total_pages} page(s) in {total_elapsed:.0f}s ({rate:.2f} pages/min) — "
                  f"{total_resolved} ai_resolved, {total_escalated} escalated total")
