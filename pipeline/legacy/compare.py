import argparse
import json
import re
import sqlite3
import threading
import time

from openai import OpenAI

from config import LM_STUDIO_BASE_URL, COMPARISON_MODELS, DB_PATH
from lms import ensure_loaded
from term import console

# Per-model API parameters for the comparison call.
# Qwen3.5 requires chat_template_kwargs to disable thinking (soft switch unsupported).
_COMPARE_PARAMS = {
    "google/gemma-3-4b": {
        "temperature": 0.1,
        "max_tokens":  4096,
    },
    "qwen/qwen3.5-9b": {
        "temperature": 0.7,
        "top_p":       0.8,
        "max_tokens":  4096,
        "extra_body":  {"top_k": 20, "presence_penalty": 1.5},
    },
    "qwen3-4b-instruct-2507": {
        "temperature": 0.7,
        "top_p":       0.8,
        "max_tokens":  4096,
        "extra_body":  {"top_k": 20, "presence_penalty": 1.5},
    },
}

_TAG_RE = re.compile(r"<[^>]+>")

# Chandra: <math display="block">(N) \quad content</math>
_CHANDRA_MATH_BLOCK_RE = re.compile(r'<math\s+display="block">(.*?)</math>', re.DOTALL)
# Lighton: blank-line-isolated "(N) $content$" — a display equation with equation number
_LIGHTON_DISPLAY_RE = re.compile(r'(?<!\S)\(\d+\)\s+\$([^$\n]+)\$(?=\s*\n|\s*$)', re.MULTILINE)


def strip_olmocr_yaml(text):
    """Remove the YAML front matter olmocr prepends to every page."""
    return re.sub(r"^---\n.*?\n---\n?", "", text, flags=re.DOTALL).strip()


def normalize_math(text):
    """Convert olmocr's \\(...\\) and \\[...\\] delimiters to $...$ / $$...$$."""
    text = re.sub(r"\\\((.+?)\\\)", r"$\1$", text, flags=re.DOTALL)
    text = re.sub(r"\\\[(.+?)\\\]", r"$$\1$$", text, flags=re.DOTALL)
    return text


def _prepare_chandra(text: str) -> str:
    """Convert chandra's display math blocks to $$...$$ then strip remaining HTML.

    Chandra wraps display equations in <math display="block">(N) \\quad content</math>.
    We strip the equation-number prefix so the content can align with olmocr's equations.
    """
    def _block(m):
        content = m.group(1).strip()
        # Strip leading "(N) \quad " equation-number prefix
        content = re.sub(r'^\(\d+\)\s*\\quad\s*', '', content)
        return f'\n\n$${content}$$\n\n'

    text = _CHANDRA_MATH_BLOCK_RE.sub(_block, text)
    return re.sub(r'\s+', ' ', _TAG_RE.sub(' ', text)).strip()


def _prepare_lighton(text: str) -> str:
    """Convert lighton's display equations to $$...$$.

    Lighton writes display equations in two ways:
      1. "(N) $content$" on a standalone paragraph line → convert to $$...$$.
      2. "(N)" on its own line immediately before a $$ block → strip the number.
    """
    text = _LIGHTON_DISPLAY_RE.sub(lambda m: f'$$\n{m.group(1)}\n$$', text)
    # Strip lone equation-number lines that precede $$ blocks.
    text = re.sub(r'^\(\d+\)\s*$', '', text, flags=re.MULTILINE)
    return text


def _strip_html(text: str) -> str:
    """Strip HTML tags from chandra output, replacing with spaces to preserve word boundaries."""
    return re.sub(r'\s+', ' ', _TAG_RE.sub(" ", text)).strip()


# Common abbreviations in technical/rocketry text that should not trigger sentence splits.
_ABBREVS = re.compile(
    r'\b(?:Fig|Eq|Eqs|Ref|Sec|Vol|No|vs|approx|cf|et al|e\.g|i\.e|Dr|Mr|Mrs|Ms|Prof|Jr|Sr)\.'
)


def _split_sentences(text: str) -> list:
    """Split text into sentence/equation-level spans.

    Display math ($$...$$) is always its own span.
    Sentence splitting uses (?<=[.!?])\\s+ but guards against common abbreviations.
    """
    # 1. Tokenize into alternating [text, $$equation$$, text, ...] segments
    raw_parts = re.split(r'(\$\$.*?\$\$)', text, flags=re.DOTALL)
    spans = []
    for part in raw_parts:
        if part.startswith('$$') and part.endswith('$$'):
            if part.strip():
                spans.append(part.strip())
        else:
            # 2. Protect abbreviation periods by replacing ". " with ".\x00" temporarily
            protected = _ABBREVS.sub(lambda m: m.group().replace('. ', '.\x00'), part)
            # 3. Split on sentence-ending punctuation followed by whitespace
            sents = re.split(r'(?<=[.!?])\s+', protected)
            # 4. Restore protected periods
            for s in sents:
                cleaned = s.replace('\x00', ' ').strip()
                if cleaned:
                    spans.append(cleaned)
    return spans


def _norm_ws(s: str) -> str:
    """Collapse all whitespace."""
    return " ".join(s.split())


def _norm_punct(s: str) -> str:
    """Collapse whitespace, strip punctuation, lowercase."""
    return " ".join(re.sub(r'[^\w\s]', '', _norm_ws(s)).lower().split())


def _classify(a: str, b: str, c: str) -> str:
    """Programmatically classify agreement between three span texts."""
    if _norm_ws(a) == _norm_ws(b) == _norm_ws(c):
        return "AGREE"
    if _norm_punct(a) == _norm_punct(b) == _norm_punct(c):
        return "MINOR"
    return "CONFLICT"


# LLM fallback prompt — used when sentence counts diverge.
# Chandra HTML is always stripped before this prompt is built.
_FALLBACK_PROMPT = """You are comparing three OCR transcriptions of the same page from a technical rocketry textbook.

Split the content into spans — ONE span per sentence, or ONE span per standalone equation.
Do NOT merge multiple sentences into a single span.
For each span, compare the three outputs word by word and character by character.

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
        "chandra": "text from chandra"
      }}
    }},
    {{
      "id": 2,
      "agreement": "MINOR",
      "text": "best guess text",
      "outputs": {{
        "olmocr": "text from olmocr",
        "lighton": "text from lighton",
        "chandra": "text from chandra"
      }}
    }}
  ]
}}

AGREE = the three outputs are word-for-word identical (ignoring only sentence-boundary newlines)
MINOR = differences in punctuation, whitespace, or capitalization only — no word differences
CONFLICT = any difference in words, numbers, names, or math content

Known symbols:
{symbol_context}

Output A (olmocr):
{a}

Output B (lighton):
{b}

Output C (chandra):
{c}
"""


def _llm_call(client, model_id, prompt, label="LLM fallback"):
    """Make a single LLM call with status spinner; return (response_text, elapsed_s, usage)."""
    params = _COMPARE_PARAMS.get(model_id, {"temperature": 0.1, "max_tokens": 4096})
    messages = [{"role": "user", "content": prompt}]
    if model_id in ("qwen/qwen3.5-9b", "qwen3-4b-instruct-2507"):
        messages.append({"role": "assistant", "content": "<think>\n\n</think>\n"})

    t0 = time.monotonic()
    stop = threading.Event()
    def _tick(t_start=t0):
        while not stop.wait(15):
            t = int(time.monotonic() - t_start)
            status.update(f"[cyan]{label}[/] — {t}s...")
    with console.status(f"[cyan]{label}[/]...") as status:
        tick = threading.Thread(target=_tick, daemon=True)
        tick.start()
        try:
            completion = client.chat.completions.create(model=model_id, messages=messages, **params)
        finally:
            stop.set()
            tick.join()
    elapsed = time.monotonic() - t0

    return completion.choices[0].message.content or "", elapsed, completion.usage


def _parse_json(response: str) -> dict:
    """Parse JSON from LLM response, handling common formatting issues."""
    def _fix_escapes(s):
        return re.sub(r'\\(?!["\\/bfnrtu])', r'\\\\', s)

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
                raise ValueError("No JSON object found in LLM response")
            return _try(match.group())


def compare_page(chapter, page_num, model_id, symbol_context=""):
    conn = sqlite3.connect(DB_PATH)
    rows = conn.execute(
        "SELECT model, raw_text FROM ocr_results WHERE chapter=? AND page=?",
        (chapter, page_num),
    ).fetchall()
    conn.close()

    results = {model: text for model, text in rows}
    required = ("olmocr", "chandra")
    missing_required = [m for m in required if m not in results]
    if missing_required:
        console.print(f"[yellow]Page {page_num}: missing required models {missing_required}, skipping[/]")
        return
    missing_optional = [m for m in ("lighton",) if m not in results]
    if missing_optional:
        console.print(f"[dim]Page {page_num}: missing {missing_optional}, comparing with available models only[/]")

    # Normalize each model's output into a common format before splitting.
    # chandra: convert <math display="block"> → $$...$$ then strip HTML
    # lighton: convert "(N) $...$" standalone lines → $$...$$
    # olmocr:  convert \[...\] / \(...\) → $$...$$ / $...$, then strip
    #          inline equation-number labels like "(1) $$...$$" → "$$...$$"
    #          so they don't bleed into the preceding sentence as "(1)" suffix.
    olmocr_clean  = re.sub(
        r'\(\d+\)\s*(?=\$\$)', '',
        normalize_math(strip_olmocr_yaml(results["olmocr"])),
    )
    chandra_clean = normalize_math(_prepare_chandra(results["chandra"]))
    has_lighton   = "lighton" in results and results["lighton"].strip()
    lighton_clean = normalize_math(_prepare_lighton(results["lighton"])) if has_lighton else ""

    # --- Programmatic sentence splitting ---
    olmocr_sents  = _split_sentences(olmocr_clean)
    chandra_sents = _split_sentences(chandra_clean)
    lighton_sents = _split_sentences(lighton_clean) if has_lighton else []

    n_o = len(olmocr_sents)
    n_c = len(chandra_sents)
    n_l = len(lighton_sents) if has_lighton else n_o

    counts = [n_o, n_c] + ([n_l] if has_lighton else [])
    max_count = max(counts) if counts else 0
    min_count = min(counts) if counts else 0

    if max_count == 0:
        console.print(f"  [dim]{chapter} p{page_num}: no sentences extracted, using LLM fallback[/]")
        _compare_page_llm(
            chapter, page_num, model_id, symbol_context, results,
            olmocr_clean, lighton_clean, chandra_clean, has_lighton,
        )
        return

    # --- Align other models to olmocr using SequenceMatcher ---
    # This handles insertions/deletions (one model missing a sentence) without desyncing.
    def _align(ref, other):
        """Return a list the same length as ref. Each position holds the best-matching
        sentence from other, or '' if other has no corresponding sentence there.

        For 'replace' blocks we require a minimum similarity ratio (0.3) before accepting
        a pairing. Dissimilar pairs are left as '' → CONFLICT, preventing mismatched
        sentences from being shown as if they correspond to each other.
        """
        if not other:
            return [''] * len(ref)
        import difflib
        norm_r = [_norm_ws(s).lower() for s in ref]
        norm_o = [_norm_ws(s).lower() for s in other]
        matcher = difflib.SequenceMatcher(None, norm_r, norm_o, autojunk=False)
        aligned = [''] * len(ref)
        for tag, i1, i2, j1, j2 in matcher.get_opcodes():
            if tag == 'equal':
                for di in range(i2 - i1):
                    aligned[i1 + di] = other[j1 + di]
            elif tag == 'replace':
                for di in range(min(i2 - i1, j2 - j1)):
                    ri, oi = i1 + di, j1 + di
                    ratio = difflib.SequenceMatcher(None, norm_r[ri], norm_o[oi]).ratio()
                    if ratio >= 0.3:
                        aligned[ri] = other[oi]
                    # else: leave as '' — the two sentences are too different to be a pair
        return aligned

    aligned_lighton = _align(olmocr_sents, lighton_sents) if has_lighton else olmocr_sents[:]
    aligned_chandra = _align(olmocr_sents, chandra_sents)

    if min_count / max_count < 0.9:
        console.print(f"  [dim]{chapter} p{page_num}: sentence counts {counts}, aligning with SequenceMatcher[/]")

    # --- Programmatic classification ---
    t0 = time.monotonic()
    spans = []
    for i, a in enumerate(olmocr_sents):
        b = aligned_lighton[i] if aligned_lighton[i] else a
        c = aligned_chandra[i] if aligned_chandra[i] else a

        # If a model had no matching sentence at this position, force CONFLICT —
        # UNLESS the exact text appears elsewhere in that model's sentence list
        # (i.e. SequenceMatcher just placed it at a different index). In that
        # case the model does have the sentence; let save_spans override catch
        # any real disagreement via the full-text substring check.
        b_missing = has_lighton and not aligned_lighton[i]
        c_missing = not aligned_chandra[i]

        norm_a_p = _norm_punct(a)
        if c_missing and any(norm_a_p in _norm_punct(s) for s in chandra_sents):
            c_missing = False
        if b_missing and any(norm_a_p in _norm_punct(s) for s in lighton_sents):
            b_missing = False

        if b_missing or c_missing:
            agreement = "CONFLICT"
        else:
            agreement = _classify(a, b, c)

        span = {"id": i, "agreement": agreement}
        if agreement == "AGREE":
            span["text"] = _norm_ws(a)
        else:
            span["text"] = _norm_ws(a)
            span["outputs"] = {"olmocr": a, "lighton": b, "chandra": c}
        spans.append(span)

    elapsed = time.monotonic() - t0
    n_agree    = sum(1 for s in spans if s["agreement"] == "AGREE")
    n_minor    = sum(1 for s in spans if s["agreement"] == "MINOR")
    n_conflict = sum(1 for s in spans if s["agreement"] == "CONFLICT")
    console.print(f"  [green]✓[/] {chapter} p{page_num}: {len(spans)} spans — "
                  f"{n_agree}A {n_minor}M [yellow]{n_conflict}C[/] (programmatic, {elapsed:.1f}s)")

    save_spans(chapter, page_num, model_id, spans, results)


def _compare_page_llm(chapter, page_num, model_id, symbol_context,
                      results, olmocr_clean, lighton_clean, chandra_clean, has_lighton):
    """LLM fallback used when sentence counts diverge too much to align programmatically.
    Chandra HTML is always pre-stripped before building the prompt."""
    client = OpenAI(base_url=LM_STUDIO_BASE_URL, api_key="lm-studio", timeout=7200.0)

    prompt = _FALLBACK_PROMPT.format(
        page=page_num,
        symbol_context=symbol_context,
        a=olmocr_clean,
        b=lighton_clean if has_lighton else "[not available — image processing failed]",
        c=chandra_clean,
    )

    response, elapsed, usage = _llm_call(client, model_id, prompt,
                                         label=f"{chapter} p{page_num}: LLM fallback")

    if usage:
        console.print(f"  [dim]tokens: prompt={usage.prompt_tokens} completion={usage.completion_tokens}[/]")

    data = _parse_json(response.strip())
    save_spans(chapter, page_num, model_id, data["spans"], results)
    console.print(f"  [green]✓[/] {chapter} p{page_num}: {len(data['spans'])} spans (LLM fallback, {elapsed:.0f}s)")


def _norm(s):
    """Normalize whitespace for comparison — ignore sentence-boundary newlines."""
    return " ".join(s.split())


def save_spans(chapter, page_num, comparison_model, spans, raw_results):
    # Pre-normalize raw model outputs for AGREE verification.
    # Only include models that actually returned results.
    norm_full = {}
    if "olmocr" in raw_results:
        norm_full["olmocr"]  = _norm(normalize_math(strip_olmocr_yaml(raw_results["olmocr"])))
    if "lighton" in raw_results:
        norm_full["lighton"] = _norm(normalize_math(raw_results["lighton"]))
    if "chandra" in raw_results:
        norm_full["chandra"] = _norm(normalize_math(_strip_html(raw_results["chandra"])))

    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        "DELETE FROM review_spans WHERE chapter=? AND page=? AND comparison_model=?",
        (chapter, page_num, comparison_model),
    )
    for span in spans:
        outputs = span.get("outputs", {})
        text = span.get("text", "")
        agreement = span["agreement"]

        olmocr_text   = outputs.get("olmocr",   text)
        lighton_text  = outputs.get("lighton",  text)
        chandra_text  = outputs.get("chandra",  text)

        # Programmatic override: search for the agreed text as a substring in
        # each model's full normalized output. If any model doesn't contain it,
        # there's a real conflict.
        # Two passes: first exact (whitespace-normalized), then punct-stripped.
        # The punct-stripped pass handles cases where one model uses inline math
        # delimiters ($c$) while another uses plain text (c) for the same symbol.
        if agreement == "AGREE":
            norm_text = _norm(text)
            norm_text_p = " ".join(re.sub(r'[^\w\s]', '', norm_text).lower().split())
            missing = [
                m for m in norm_full
                if norm_text not in norm_full[m]
                and norm_text_p not in " ".join(
                    re.sub(r'[^\w\s]', '', norm_full[m]).lower().split()
                )
            ]
            if missing:
                agreement = "CONFLICT"
                console.print(f"    [dim]span {span['id']}: AGREE→CONFLICT (text absent from {missing})[/]")

        conn.execute("""
            INSERT INTO review_spans
            (chapter, page, span_index, comparison_model, agreement,
             olmocr_text, lighton_text, chandra_text, resolved_text, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            chapter,
            page_num,
            span["id"],
            comparison_model,
            agreement,
            olmocr_text,
            lighton_text,
            chandra_text,
            text if agreement == "AGREE" else "",
            "auto" if agreement == "AGREE" else "pending",
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
    parser.add_argument("--model",   default="gemma", choices=list(COMPARISON_MODELS),
                        help="Comparison model to use (default: gemma)")
    parser.add_argument("--symbol-context", default="")
    args = parser.parse_args()

    model_id = COMPARISON_MODELS[args.model]
    ensure_loaded(model_id)

    start, end = parse_pages(args.pages)
    total_pages = end - start + 1
    run_start = time.monotonic()
    for page in range(start, end + 1):
        compare_page(args.chapter, page, model_id, args.symbol_context)
    total_elapsed = time.monotonic() - run_start
    mins = total_elapsed / 60
    rate = total_pages / mins if mins > 0 else float("inf")
    console.print(f"Done. {total_pages} page(s) in {total_elapsed:.0f}s ({rate:.2f} pages/min)")
