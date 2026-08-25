#!/usr/bin/env python3
"""
Compare several transcriptions of the same pages, side by side, in a browser.

Where independent models agree, the text is almost certainly what the page says.
Where they disagree, one of them misread it. So this does not show a diff of
everything — it shows the disagreements, which is the only part worth a human
look, and separates two kinds:

    content      the words differ. One model misread the manuscript.
    formatting   the words match; only the Typst around them differs. A
                 judgement call about markup, not a transcription error.

Alignment is per page, using the `// === page N ===` markers every output
carries, and then sentence by sentence within the page — which works because
one-sentence-per-line is a convention the whole project already keeps.

    python pipeline/diff3.py pipeline/bakeoff/hosted/*.typ
    python pipeline/diff3.py a.typ b.typ --out /tmp/diff.html
"""

from __future__ import annotations

import argparse
import difflib
import html
import re
from dataclasses import dataclass
from pathlib import Path

PAGE_RE = re.compile(r"^// === page (\d+) ===\s*$", re.M)


def coalesce(lines: list[str]) -> list[str]:
    """
    Join continuation lines so a multi-line construct compares as one unit.

    Models lay equations out differently — one writes `#eq("1")[$ a \\ b $]` on a
    single line, another spreads the same equation over seven. Compared line by
    line those never pair, and every line of the longer form is reported as text
    the others are missing. That accounted for 50 of the 63 "absent" cells in the
    first run of this and was entirely an artefact.

    Grouping is by delimiter balance: a unit stays open while brackets are
    unclosed or a `$` is unmatched.
    """
    out: list[str] = []
    buf: list[str] = []
    depth = 0
    dollars = 0
    for line in lines:
        buf.append(line.strip())
        stripped = re.sub(r"//[^\n]*", "", line)
        depth += stripped.count("[") - stripped.count("]")
        depth += stripped.count("(") - stripped.count(")")
        dollars += stripped.count("$")
        if depth <= 0 and dollars % 2 == 0:
            out.append(" ".join(b for b in buf if b))
            buf, depth, dollars = [], 0, 0
    if buf:
        out.append(" ".join(b for b in buf if b))
    return [l for l in out if l]


def load(path: Path) -> dict[int, list[str]]:
    """Page number -> its lines, with the generated import header dropped."""
    text = path.read_text()
    text = re.sub(r"^#import[^\n]*\n|^#show[^\n]*\n|^#set page[^\n]*\n", "",
                  text, flags=re.M)
    out: dict[int, list[str]] = {}
    marks = list(PAGE_RE.finditer(text))
    if not marks:
        return {0: coalesce([l for l in text.splitlines() if l.strip()])}
    for i, m in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(text)
        page = int(m.group(1))
        body = text[m.end():end]
        out.setdefault(page, []).extend(
            coalesce([l.rstrip() for l in body.splitlines() if l.strip()]))
    # Anything before the first page marker belongs with the first page.
    head = coalesce([l.rstrip() for l in text[:marks[0].start()].splitlines() if l.strip()])
    if head:
        out.setdefault(int(marks[0].group(1)), [])[:0] = head
    return out


def prose_of(line: str) -> str:
    """
    The words a reader reads, with markup removed but maths kept as its symbols.

    Maths is unwrapped rather than deleted. Deleting it made `$D$` and `D`
    compare unequal, so one model choosing to set axis letters in maths looked
    like it had misread every one of them — 59 false "misreadings" in the first
    run of this, all of them a markup preference.
    """
    s = re.sub(r"//[^\n]*", " ", line)
    s = re.sub(r"\$([^$]*)\$", r" \1 ", s)
    s = re.sub(r"<[a-z]+:[^>]*>", " ", s)
    s = re.sub(r'([(,]\s*)"[^"]*"', r"\1 ", s)
    s = re.sub(r"#[a-z][a-z-]*", " ", s)
    return " ".join(re.findall(r"[a-z']+", s.lower()))


def key_of(line: str) -> str:
    """Loose key for alignment — close enough to pair, not to judge."""
    return " ".join(re.findall(r"[a-z0-9']+", line.lower()))


@dataclass
class Row:
    cells: list[str]
    kind: str          # same | formatting | content


def align(columns: list[list[str]]) -> list[Row]:
    """
    Line up N versions of the same page.

    The first column is the spine and the others are matched against it, which
    is enough here: these are transcriptions of one page, so they agree far more
    than they differ, and anything unmatched is surfaced as its own row rather
    than being quietly dropped.
    """
    spine = columns[0]
    keys = [[key_of(l) for l in col] for col in columns]

    matched: list[dict[int, int]] = []
    for j in range(1, len(columns)):
        pairs: dict[int, int] = {}
        sm = difflib.SequenceMatcher(None, keys[0], keys[j], autojunk=False)
        for a, b, size in sm.get_matching_blocks():
            for k in range(size):
                pairs[a + k] = b + k
        matched.append(pairs)

    used: list[set[int]] = [set() for _ in columns[1:]]
    rows: list[Row] = []
    for i in range(len(spine)):
        cells = [spine[i]]
        for j, pairs in enumerate(matched):
            at = pairs.get(i)
            if at is None:
                cells.append("")
            else:
                cells.append(columns[j + 1][at])
                used[j].add(at)
        rows.append(Row(cells, classify(cells)))

    # Lines no spine row claimed. Before reporting one as unique, try to pair it
    # with a leftover from another column that says the same thing — the models
    # split sentences differently, and an unpaired line is far more often a
    # splitting difference than a transcription difference.
    leftovers: list[tuple[int, str]] = [
        (j + 1, col[at]) for j, col in enumerate(columns[1:])
        for at in range(len(col)) if at not in used[j]]

    claimed: set[int] = set()
    for idx, (col_i, line) in enumerate(leftovers):
        if idx in claimed:
            continue
        cells = [""] * len(columns)
        cells[col_i] = line
        mine = prose_of(line)
        for other, (col_j, cand) in enumerate(leftovers):
            if other <= idx or other in claimed or col_j == col_i or cells[col_j]:
                continue
            if mine and difflib.SequenceMatcher(None, mine, prose_of(cand)).ratio() > 0.75:
                cells[col_j] = cand
                claimed.add(other)
        claimed.add(idx)
        rows.append(Row(cells, classify(cells)))
    return rows


def classify(cells: list[str]) -> str:
    present = [c for c in cells if c.strip()]
    if len(present) != len(cells):
        return "content"                      # one of them is missing it entirely
    if len({c.strip() for c in present}) == 1:
        return "same"
    if len({prose_of(c) for c in present}) == 1:
        return "formatting"                   # same words, different markup
    return "content"


def inline_marks(cells: list[str]) -> list[str]:
    """Highlight the words that actually differ, against the first non-empty cell."""
    base = next((c for c in cells if c.strip()), "")
    base_words = base.split()
    out = []
    for c in cells:
        if not c.strip():
            out.append('<span class="none">— absent —</span>')
            continue
        if c.strip() == base.strip():
            out.append(html.escape(c))
            continue
        sm = difflib.SequenceMatcher(None, base_words, c.split(), autojunk=False)
        parts = []
        for tag, _i1, _i2, j1, j2 in sm.get_opcodes():
            chunk = html.escape(" ".join(c.split()[j1:j2]))
            parts.append(chunk if tag == "equal" else f'<mark>{chunk}</mark>')
        out.append(" ".join(p for p in parts if p))
    return out


CSS = """
:root{--bg:#fbfbfa;--fg:#1c1b19;--line:#e0ded9;--same:#f4f7f2;--fmt:#fff8e6;
--cont:#fdeeee;--mark:#ffd9a0;--muted:#8a857c}
@media(prefers-color-scheme:dark){:root{--bg:#171614;--fg:#e9e6e0;--line:#33302b;
--same:#1b1f1a;--fmt:#2a2416;--cont:#2e1c1c;--mark:#7a5518;--muted:#8f8a80}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);
font:14px/1.55 ui-sans-serif,-apple-system,Segoe UI,Roboto,sans-serif}
header{position:sticky;top:0;background:var(--bg);border-bottom:1px solid var(--line);
padding:14px 20px;z-index:5}
h1{margin:0 0 4px;font-size:17px}
.sub{color:var(--muted);font-size:13px}
.controls{margin-top:10px;display:flex;gap:16px;align-items:center;flex-wrap:wrap;font-size:13px}
.stats{margin:16px 20px;border-collapse:collapse;font-size:13px}
.stats th,.stats td{border:1px solid var(--line);padding:5px 10px;text-align:left}
.stats td.n{text-align:right;font-variant-numeric:tabular-nums}
main{padding:0 20px 60px}
h2{font-size:14px;margin:26px 0 8px;color:var(--muted);font-weight:600}
table.cmp{width:100%;border-collapse:collapse;table-layout:fixed}
table.cmp th{font-size:12px;text-align:left;padding:6px 8px;border-bottom:1px solid var(--line);
position:sticky;top:96px;background:var(--bg)}
table.cmp td{vertical-align:top;padding:6px 8px;border-bottom:1px solid var(--line);
font:12px/1.5 ui-monospace,SFMono-Regular,Menlo,monospace;white-space:pre-wrap;
overflow-wrap:anywhere}
tr.same td{background:var(--same)}
tr.formatting td{background:var(--fmt)}
tr.content td{background:var(--cont)}
mark{background:var(--mark);color:inherit;border-radius:2px;padding:0 1px}
.none{color:var(--muted);font-style:italic}
.legend span{display:inline-block;padding:2px 8px;border-radius:3px;margin-right:6px;font-size:12px}
"""

JS = """
function apply(){
  var hide=document.getElementById('hide').checked;
  document.querySelectorAll('tr.same').forEach(function(r){r.style.display=hide?'none':'';});
  document.querySelectorAll('section').forEach(function(s){
    var vis=s.querySelectorAll('tbody tr:not([style*="none"])').length;
    s.style.display=(hide&&vis===0)?'none':'';
  });
}
document.addEventListener('DOMContentLoaded',function(){
  document.getElementById('hide').addEventListener('change',apply); apply();
});
"""


def build(paths: list[Path], out: Path) -> tuple[Path, dict]:
    names = [p.stem.replace("_", "/") for p in paths]
    docs = [load(p) for p in paths]
    pages = sorted({p for d in docs for p in d})

    sections, tally = [], {"same": 0, "formatting": 0, "content": 0}
    odd = {n: 0 for n in names}

    for page in pages:
        rows = align([d.get(page, []) for d in docs])
        body = []
        for r in rows:
            tally[r.kind] += 1
            # Which model stands alone on this line, if any — the useful signal.
            # Only judged when every version has the line. A blank cell means
            # the alignment could not pair it, usually because the models split
            # sentences differently — that is not evidence about accuracy.
            if r.kind == "content" and all(c.strip() for c in r.cells):
                proses = [prose_of(c) for c in r.cells]
                for i, pr in enumerate(proses):
                    others = [q for j, q in enumerate(proses) if j != i]
                    if others and len(set(others)) == 1 and pr != others[0]:
                        odd[names[i]] += 1
            cells = inline_marks(r.cells) if r.kind != "same" else \
                [html.escape(c) if c.strip() else '<span class="none">— absent —</span>'
                 for c in r.cells]
            body.append(f'<tr class="{r.kind}">'
                        + "".join(f"<td>{c}</td>" for c in cells) + "</tr>")
        heads = "".join(f"<th>{html.escape(n)}</th>" for n in names)
        sections.append(
            f'<section><h2>page {page}</h2><table class="cmp">'
            f"<thead><tr>{heads}</tr></thead><tbody>{''.join(body)}</tbody></table></section>")

    total = sum(tally.values()) or 1
    stats = (
        '<table class="stats"><tr><th>Lines compared</th>'
        f'<td class="n">{total}</td><td></td></tr>'
        f'<tr><th>Identical</th><td class="n">{tally["same"]}</td>'
        f'<td class="n">{tally["same"]/total*100:.0f}%</td></tr>'
        f'<tr><th>Markup differs, words agree</th><td class="n">{tally["formatting"]}</td>'
        f'<td class="n">{tally["formatting"]/total*100:.0f}%</td></tr>'
        f'<tr><th>Words differ</th><td class="n">{tally["content"]}</td>'
        f'<td class="n">{tally["content"]/total*100:.0f}%</td></tr>'
        + "".join(f'<tr><th>Odd one out — {html.escape(n)}</th>'
                  f'<td class="n">{c}</td><td></td></tr>' for n, c in odd.items())
        + "</table>")

    page = f"""<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Transcription comparison</title><style>{CSS}</style></head><body>
<header><h1>Transcription comparison</h1>
<div class="sub">{len(names)} outputs · pages {pages[0]}&ndash;{pages[-1]} ·
where they agree the text is almost certainly right; the coloured rows are what to read</div>
<div class="controls">
<label><input type="checkbox" id="hide" checked> show only disagreements</label>
<span class="legend"><span style="background:var(--fmt)">markup differs</span>
<span style="background:var(--cont)">words differ</span></span>
</div></header>
{stats}
<main>{''.join(sections)}</main>
<script>{JS}</script></body></html>"""
    out.write_text(page)
    return out, {"tally": tally, "odd": odd, "total": total}


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+", type=Path)
    ap.add_argument("--out", type=Path,
                    default=Path("pipeline/bakeoff/hosted/diff.html"))
    args = ap.parse_args()

    args.out.parent.mkdir(parents=True, exist_ok=True)
    out, info = build(args.files, args.out)
    t, total = info["tally"], info["total"]
    print(f"{out}")
    print(f"  {total} lines: {t['same']} identical, "
          f"{t['formatting']} markup-only, {t['content']} word differences")
    for name, count in info["odd"].items():
        print(f"  odd one out {count:4}x  {name}")


if __name__ == "__main__":
    main()
