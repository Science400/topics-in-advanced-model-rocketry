#!/usr/bin/env python3
"""
Transcribe a whole chapter from page images to Typst, via OpenRouter's batch API.

The chapter is cut into windows of consecutive pages, one request each, and all
of them go up as a single batch. Batch pricing is half of live and the observed
turnaround has been minutes rather than the 24h the window allows, so there is
little reason to pay double.

Windowing is for resumability, not for any hard limit: the whole chapter's
images fit the context, but its Typst does not fit one response, and a failure
90% of the way through a single enormous call would cost the lot.

    python pipeline/hosted_chapter.py --chapter ch2 --submit
    python pipeline/hosted_chapter.py --chapter ch2 --collect
    python pipeline/hosted_chapter.py --chapter ch2 --submit --wait
"""

from __future__ import annotations

import argparse
import json
import os
import re
import time
from pathlib import Path

import httpx

import emit
import sections as S
from config import CHAPTER_PDFS, PDF_DIR
from hosted_bakeoff import (LONGEST_SIDE, build_prompt, clean, compiles,
                             cost_of, money)
from ocrlib import render_page
from term import console

_HERE = Path(__file__).parent
STATE_DIR = _HERE / "bakeoff" / "chapters"
BATCH_URL = "https://openrouter.ai/api/beta/batches"
DEFAULT_MODEL = "openai/gpt-5.6-sol:batch"
WINDOW = 14
MAX_TOKENS = 32000

CONTINUATION = """
These pages are part of a longer chapter and do not begin it. Do not write a \\
chapter title, and do not add an introduction or a summary of your own. If the \\
first page starts in the middle of a sentence or paragraph, start your output in \\
the middle of it too — the pages before this one have already been transcribed.
"""


def windows(pages: list[int], size: int) -> list[list[int]]:
    return [pages[i:i + size] for i in range(0, len(pages), size)]


def submit(chapter: str, model: str, size: int, key: str) -> dict:
    pages = S.body_pages(chapter)
    chunks = windows(pages, size)
    pdf = Path(PDF_DIR) / CHAPTER_PDFS[chapter]

    console.print(f"[dim]{len(pages)} pages in {len(chunks)} windows of {size}[/]")
    requests = []
    for i, chunk in enumerate(chunks):
        console.print(f"  rendering window {i + 1}/{len(chunks)}: "
                      f"pages {chunk[0]}–{chunk[-1]}", end="\r")
        prompt = build_prompt(chapter, chunk) + CONTINUATION
        content: list[dict] = [{"type": "text", "text": prompt}]
        for page in chunk:
            b64 = render_page(pdf, page, LONGEST_SIDE)
            content.append({"type": "image_url",
                            "image_url": {"url": f"data:image/png;base64,{b64}"}})
        requests.append({"custom_id": f"w{i:03d}",
                         "body": {"max_tokens": MAX_TOKENS, "temperature": 0.0,
                                  "messages": [{"role": "user", "content": content}]}})
    console.print()

    payload = {"endpoint": "/v1/chat/completions", "model": model,
               "requests": requests}
    console.print(f"[dim]submitting {len(requests)} requests…[/]")
    r = httpx.post(BATCH_URL, headers={"Authorization": f"Bearer {key}"},
                   json=payload, timeout=1800.0)
    if r.is_error:
        raise SystemExit(f"batch rejected: {r.status_code} {r.text[:400]}")
    body = r.json()

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    state = {"chapter": chapter, "model": model, "batch_id": body["id"],
             "windows": [[c[0], c[-1]] for c in chunks],
             "submitted_at": time.time()}
    (STATE_DIR / f"{chapter}.json").write_text(json.dumps(state, indent=2))
    console.print(f"[green]batch {body['id']}[/] — {body['request_counts']['total']} requests")
    return state


def run_live(chapter: str, model: str, size: int, key: str,
             out_name: str | None) -> None:
    """
    Window by window through the ordinary endpoint, no batch queue.

    Batch is half the price but its pre-flight balance check estimates image
    cost from the base64 payload length rather than the model's own image
    tokenisation — 2.8M "tokens" for a window the API actually bills at 24k. The
    estimate for this chapter came to $37.57 against a true cost near $0.65, and
    the check refuses the submission on the phantom figure. Live has no such
    pre-flight, so it simply works, at double a very small number.
    """
    pages = S.body_pages(chapter)
    chunks = windows(pages, size)
    pdf = Path(PDF_DIR) / CHAPTER_PDFS[chapter]
    live_model = model.replace(":batch", "")

    ordered: list[str] = []
    notes: list[str] = []
    spent = 0.0
    for i, chunk in enumerate(chunks):
        prompt = build_prompt(chapter, chunk) + CONTINUATION
        content: list[dict] = [{"type": "text", "text": prompt}]
        for page in chunk:
            content.append({"type": "image_url", "image_url": {
                "url": f"data:image/png;base64,{render_page(pdf, page, LONGEST_SIDE)}"}})
        started = time.monotonic()
        try:
            r = httpx.post("https://openrouter.ai/api/v1/chat/completions",
                           headers={"Authorization": f"Bearer {key}"},
                           json={"model": live_model, "max_tokens": MAX_TOKENS,
                                 "temperature": 0.0,
                                 "messages": [{"role": "user", "content": content}]},
                           timeout=1800.0)
            if r.is_error:
                raise RuntimeError(f"{r.status_code} {r.text[:200]}")
            body = r.json()
            text = (body["choices"][0]["message"].get("content") or "").strip()
            usage = body.get("usage") or {}
            cost = cost_of(body.get("id"), key) or 0.0
            spent += cost
            text, why = clean(text)
            notes += [f"w{i:03d}: {w}" for w in why]
            ordered.append(text)
            console.print(f"  window {i + 1}/{len(chunks)} pages {chunk[0]}–{chunk[-1]}: "
                          f"{time.monotonic() - started:.0f}s · "
                          f"{usage.get('completion_tokens', 0)} out · {money(cost)}")
        except Exception as exc:
            console.print(f"  [red]window {i + 1} failed:[/] {str(exc)[:140]}")
            ordered.append(f'#conflict[Window {i:03d} (pages {chunk[0]}–{chunk[-1]}) '
                           f'failed and is missing.]')

    path = (emit.CHAPTERS_DIR / f"{out_name}.typ") if out_name \
        else emit.chapter_file(chapter)
    if out_name and not path.exists():
        path.write_text(emit.chapter_file(chapter).read_text())
    emit.ensure_imports(path)
    emit.write_body(path, "\n\n".join(ordered))
    ok, err = compiles(path)

    console.print(f"\n[bold]total billed:[/] {money(spent)}")
    for n in notes:
        console.print(f"  [yellow]![/] {n}")
    if ok:
        console.print(f"[green]written to {path.name}, compiles[/]")
    else:
        console.print(f"[red]{path.name} does not compile[/]; first error:")
        for line in err.splitlines()[:8]:
            console.print(f"    {line}")


def fetch(batch_id: str, key: str) -> dict:
    r = httpx.get(f"{BATCH_URL}/{batch_id}",
                  headers={"Authorization": f"Bearer {key}"}, timeout=120.0)
    if r.is_error:
        raise SystemExit(f"could not read batch: {r.status_code} {r.text[:300]}")
    return r.json()


def wait(batch_id: str, key: str, every: int = 20) -> dict:
    seen = ""
    while True:
        body = fetch(batch_id, key)
        status = body.get("status")
        counts = body.get("request_counts") or {}
        line = (f"  {status}  {counts.get('completed', 0)}/{counts.get('total', 0)} done"
                f"{', ' + str(counts['failed']) + ' failed' if counts.get('failed') else ''}")
        if line != seen:
            console.print(line)
            seen = line
        if status in ("completed", "failed", "expired", "cancelled"):
            return body
        time.sleep(every)


def collect(chapter: str, key: str, out_name: str | None) -> None:
    state_path = STATE_DIR / f"{chapter}.json"
    if not state_path.exists():
        raise SystemExit(f"no submitted batch for {chapter} — run --submit first")
    state = json.loads(state_path.read_text())

    body = fetch(state["batch_id"], key)
    if body.get("status") != "completed":
        console.print(f"[yellow]batch is {body.get('status')}[/] — "
                      f"{(body.get('request_counts') or {}).get('completed', 0)} done. "
                      f"Run --collect again later, or --wait.")
        return

    pieces: dict[str, str] = {}
    failures: list[str] = []
    for item in body.get("results") or []:
        cid = item.get("custom_id", "?")
        resp = item.get("response") or {}
        if resp.get("status_code") != 200:
            failures.append(f"{cid}: HTTP {resp.get('status_code')}")
            continue
        choices = (resp.get("body") or {}).get("choices") or []
        text = (choices[0]["message"].get("content") or "") if choices else ""
        if not text.strip():
            failures.append(f"{cid}: empty response")
            continue
        pieces[cid] = text

    notes: list[str] = []
    ordered: list[str] = []
    for i in range(len(state["windows"])):
        cid = f"w{i:03d}"
        lo, hi = state["windows"][i]
        if cid not in pieces:
            # A hole is left visible rather than silently closed: the pages it
            # covers are named, so the gap cannot be mistaken for the book.
            ordered.append(f'#conflict[Window {cid} (pages {lo}–{hi}) did not come '
                           f'back from the batch and is missing.]')
            continue
        text, why = clean(pieces[cid])
        notes += [f"{cid}: {w}" for w in why]
        ordered.append(text)

    path = (emit.CHAPTERS_DIR / f"{out_name}.typ") if out_name \
        else emit.chapter_file(chapter)
    if out_name and not path.exists():
        path.write_text(emit.chapter_file(chapter).read_text())
    emit.ensure_imports(path)

    before = path.read_text()
    emit.write_body(path, "\n\n".join(ordered))
    ok, err = compiles(path)

    usage = body.get("usage") or {}
    cost = usage.get("cost")
    console.print(f"\n[bold]{len(pieces)}/{len(state['windows'])} windows returned[/] · "
                  f"{usage.get('prompt_tokens', 0)} in / "
                  f"{usage.get('completion_tokens', 0)} out · {money(cost)}")
    for f in failures:
        console.print(f"  [red]![/] {f}")
    for n in notes:
        console.print(f"  [yellow]![/] {n}")

    if ok:
        console.print(f"[green]written to {path.name}, compiles[/]")
    else:
        console.print(f"[red]{path.name} does not compile[/] — left in place so it "
                      f"can be fixed; the first error is:")
        for line in err.splitlines()[:8]:
            console.print(f"    {line}")
        (STATE_DIR / f"{chapter}.compile-error.txt").write_text(err)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--chapter", default="ch2", choices=list(CHAPTER_PDFS))
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--window", type=int, default=WINDOW)
    ap.add_argument("--submit", action="store_true")
    ap.add_argument("--live", action="store_true",
                    help="use the ordinary endpoint instead of the batch queue")
    ap.add_argument("--collect", action="store_true")
    ap.add_argument("--wait", action="store_true", help="poll until the batch finishes")
    ap.add_argument("--status", action="store_true")
    ap.add_argument("--out", metavar="NAME",
                    help="write to src/chapters/NAME.typ instead of the chapter")
    args = ap.parse_args()

    key = os.environ.get("OPENROUTER_API_KEY")
    if not key:
        raise SystemExit("OPENROUTER_API_KEY is not set")

    if args.live:
        run_live(args.chapter, args.model, args.window, key, args.out)
        return

    if args.submit:
        state = submit(args.chapter, args.model, args.window, key)
        if args.wait:
            wait(state["batch_id"], key)
            collect(args.chapter, key, args.out)
        return

    state_path = STATE_DIR / f"{args.chapter}.json"
    if args.status:
        state = json.loads(state_path.read_text())
        body = fetch(state["batch_id"], key)
        console.print(f"{state['batch_id']}: {body.get('status')} "
                      f"{body.get('request_counts')}")
        return

    if args.collect:
        state = json.loads(state_path.read_text())
        if args.wait:
            wait(state["batch_id"], key)
        collect(args.chapter, key, args.out)
        return

    ap.error("give --submit, --collect or --status")


if __name__ == "__main__":
    main()
