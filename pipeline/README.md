# Pipeline

Run everything from the **project root**, through uv:

```bash
uv run --project pipeline python pipeline/<script>.py …
```

LM Studio must be running for `ocr` and `edit`. Nothing else needs a GPU.

---

## The whole chapter

```bash
uv run --project pipeline python pipeline/run.py --chapter ch2 --all
```

| stage | what it does | model |
|---|---|---|
| `ocr` | transcribe every body page | olmocr, one page at a time |
| `emit` | assemble, cut into sections, convert to Typst, place figures | none |
| `edit` | editorial passes over each section | gemma, one section at a time |
| `build` | compile `src/main.typ` | none |

Stages are batched by model deliberately. LM Studio serves one model at a time,
so transcribing every page before editing any section costs two model loads for
the chapter rather than two per section.

Resume or narrow a run:

```bash
--from emit            # skip OCR, start at emit
--only edit            # just one stage
--skip edit,build      # leave stages out
--section 2.1          # restrict emit and edit to one section
--pages 40-52          # restrict OCR
```

---

## The unit of work

**OCR works by page. Everything after it works by section.**

A page is the wrong unit once the text exists. A sentence runs across the seam;
a paragraph runs across a figure plate bound into the middle of it; a section
boundary falls partway down a page. The previous design gave each section the
page range `[start, next_start]` inclusive at *both* ends and split the shared
boundary page by regex — which emitted a half-paragraph twice when the heading
matched in both halves and dropped one when it matched in neither.

`stream.py` now joins the chapter once and cuts it at the headings, so every
character lands in exactly one section, and `coverage()` proves it rather than
assuming it. Sections are located by matching their heading text in the
transcribed stream, which is why `start` in the section map is only a hint.

---

## Section maps — `pipeline/sections/chN.toml`

Scaffold one from a chapter's own headings:

```bash
uv run --project pipeline python pipeline/sections.py ch2 --scaffold
uv run --project pipeline python pipeline/sections.py ch2          # show it
```

Then fill in `[frontmatter]`:

- `body_starts` — first page of body text (after the title page and symbol table)
- `references` — page the bibliography begins on; everything before it is body
- `page_offset` — printed page minus PDF page. ch1's is 0; **ch2's is 52**,
  because its PDF page 11 is stamped `-63-`. Reports cite both.

`start` on each section is optional. Sections are found by heading text, so a
number there only narrows the search. If a heading is reported as "matched only
loosely", the message prints what the scan actually says — usually the section
map was typed from the table of contents and the printed heading differs
("Descriptions of the Flight Force" vs. "Description of the Flight Forces").

---

## Symbol tables

Each chapter's symbol table is hand-typed into the chapter as `#table(…)` and
read back out by `symtab.py` — one artifact serving as both published content
and pipeline configuration, so nothing has to be kept in sync.

```bash
uv run --project pipeline python pipeline/symtab.py src/chapters/ch2-aerodynamic-stability.typ
```

It feeds the OCR prompt and canonicalises math spellings: `C_{2R}`, `C_{2 R}`
and `C_(2R)` all collapse to whatever the table declares.

A row may hold several symbols sharing one meaning — `[$A$, $B$, $C$], [space
axes]` declares three, and is parsed as three. A comma *inside* one pair of
dollars is part of a single symbol's name (`$F_1, dots.h, F_8$`) and does not
split.

---

## Units — `units.py`

unify does not fail on a unit it does not know. It silently renders the number
and drops the unit:

```
#qty(1, "in")     ->  "1"        the inches vanish, and it compiles
#qty(1, "lb ft")  ->  "1 ft"     the pounds vanish, and it compiles
```

So a compile gate cannot police this. Every unit is verified by *rendering*:
Typst measures `qty(1, u)` against a bare `1` and reports any that added no
width, calibrated against a deliberately nonsense unit rather than a magic
threshold.

```bash
uv run --project pipeline python pipeline/units.py --check --show
```

Run it after editing `_raw-units` in `src/preamble.typ`. A unit that fails is
left as prose and flagged — never guessed at. That is what produced
`#qty("3", "Newton")` in ch1, which compiled clean and rendered as a bare 3.

`#num` is only for scientific notation and grouped numerals (`1.4e-6`,
`12,500`), not plain small numbers.

---

## Equation numbering

**A numbered equation is always written `#eq("21")[$ … $] <eq:2-21>`.** A bare
`$ … $` is never emitted, because Typst would number it from a counter and the
counter agrees with the manuscript only until one equation is missed — after
that every number is wrong and nothing says so.

This manuscript prints its numbers in the left margin, where olmocr reads them
as list markers and drops them. So:

1. `emit.py` uses the number when the transcriber happened to capture it inline,
   and otherwise emits `$! … $` — the preamble's unnumbered form. The output is
   either right or visibly unnumbered, never plausibly misnumbered.
2. `edit.py`'s equation pass reads the page image and supplies the numbers that
   are missing.

A number the model reads *differently* from what was transcribed is reported,
not applied — renumbering also invalidates every reference to the old number.

---

## The editorial pass — `edit.py`

Four passes, each carrying one rulebook. A 26B model holds one set of
instructions well and four badly.

| pass | needs the page image | what it does |
|---|---|---|
| `equations` | yes | the margin number, and the symbols |
| `continuity` | yes | is a paragraph doubled, dropped, or wrongly joined at a seam |
| `references` | no | `Figure 14` → `@fig:2-14`, `Eq. (44a)` → `#eqref(<eq:2-44a>)` |
| `units` | no | numerals the deterministic pass could not place |

The model never rewrites prose. It returns edit operations, and each is checked
before it is applied:

- **unique** — the text to replace must occur exactly once in the section
- **invariant** — the words a reader reads must be identical afterwards, except
  those a `#qty` or `#num` legitimately absorbs
- **no invented references** — a label the edit points at must exist. Invariance
  cannot see this on its own: `"in @fig:2-1, @fig:2-7"` adds no prose word, and
  a wrong-but-valid reference compiles perfectly and reads as fact
- **compiles** — or the section is rolled back

The invariance gate is the important one. Asked to reproduce a page of prose, a
local model will quietly reword it, and no amount of prompting reliably stops
that. Comparing the prose before and after does.

Exercise the gates with no GPU:

```bash
uv run --project pipeline python pipeline/edit.py --chapter ch2 --section 2.1 \
    --replay canned.json --dry-run
```

`canned.json` maps a pass name to a list of answers, served in order.

Reports land in `pipeline/reports/chN/` — one per section, plus `SUMMARY.md`
grouping every flag by rule so the hand pass starts from a worklist.

---

## Coverage

`emit` checks that every run of transcribed prose appears in the output exactly
once, by aligning the two word sequences and reporting only contiguous runs —
which is the shape a doubled or dropped half-paragraph actually takes. Figure
captions are moved on purpose, so they are excluded from that alignment and
checked separately, word for word, against what the scan said.

A clean run says so. Anything else is worth reading before going further.

---

## Corrections — `pipeline/corrections/chN.toml`

When the same edit is needed twice, it belongs here rather than in the `.typ`:
re-emitting regenerates the chapter body and a hand fix inside it is lost.

```toml
[[prose]]
find = "formulæ"
replace = "formulae"
note = "ae ligature misread"
```

`[[math]]` touches converted Typst math only, `[[prose]]` prose only, `[[any]]`
the finished section. Literal find/replace unless `regex = true`.

```bash
uv run --project pipeline python pipeline/corrections.py ch2
```

---

## Comparing a run against hand-edited work

`emit` regenerates the whole chapter body, so it will overwrite hand edits.
To run the pipeline without destroying them:

```bash
uv run --project pipeline python pipeline/run.py --chapter ch1 --from emit --out ch1-pilot
git diff --no-index src/chapters/ch1-flight-dynamics.typ src/chapters/ch1-pilot.typ
```

`--out NAME` writes to `src/chapters/NAME.typ`, a sibling of the real chapter so
relative image paths and the compile gate behave identically. `main.typ` does
not include it.

---

## What is in the chapter file

```
imports, chapter heading, symbol table     hand-written, never touched
  … body …                                 regenerated by emit.py
#bibliography(…)                           hand-written, never touched
```

There are no section-marker comments. The headings delimit the sections, and the
file's own structure marks where the generated body begins and ends.

`// === page 18 ===` marks every page seam and stays. It is emitted between two
sentence lines with no blank line either side, so Typst folds it away and the
paragraph renders unbroken — it is there to let you read the `.typ` against the
scan.

---

## `legacy/`

The abandoned three-model vote, and the chandra equation-number verifier. Kept
for reference; nothing live imports from it. See `legacy/README.md`.
