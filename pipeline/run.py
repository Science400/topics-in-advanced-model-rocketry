#!/usr/bin/env python3
"""
Run a chapter through the whole pipeline.

    ocr    transcribe every body page          olmocr, one page at a time
    emit   assemble, cut, convert, place       no model
    edit   editorial passes                    gemma, one section at a time
    build  compile the book

Stages are batched by model on purpose. LM Studio serves one model at a time, so
transcribing every page before editing any section costs two model loads for the
chapter rather than two per section.

    python pipeline/run.py --chapter ch2 --all
    python pipeline/run.py --chapter ch2 --from emit
    python pipeline/run.py --chapter ch2 --section 2.1
    python pipeline/run.py --chapter ch1 --from emit --out ch1-pilot --skip edit
"""

from __future__ import annotations

import argparse
import subprocess
import time
from pathlib import Path

import sections as S
from config import CHAPTER_PDFS
from term import console

_HERE = Path(__file__).parent
REPO_ROOT = _HERE.parent

STAGES = ("ocr", "emit", "edit", "build")


def stage_ocr(args) -> None:
    import ocr
    pages = (S.parse_pages(args.pages) if args.pages
             else S.body_pages(args.chapter))
    console.print(f"[bold]ocr[/] {args.chapter}: {len(pages)} page(s)")
    ocr.ocr_pages(args.chapter, pages, force=args.force)


def stage_emit(args) -> None:
    import emit
    console.print(f"\n[bold]emit[/] {args.chapter}")
    path = emit.chapter_file(args.chapter)
    emit.ensure_imports(path)
    body, report = emit.build(args.chapter, args.section)

    if args.out:
        path = emit.CHAPTERS_DIR / f"{args.out}.typ"
        if not path.exists():
            path.write_text(emit.chapter_file(args.chapter).read_text())

    before = path.read_text()
    emit.write_body(path, body)
    ok, err = emit.chapter_compiles(path)
    if not ok:
        path.write_text(before)
        console.print("[red]emit rolled back — the chapter does not compile[/]")
        for line in err.splitlines()[:12]:
            console.print(f"  {line}")
        raise SystemExit(1)

    console.print(f"  written to {path.name}, compiles")
    if report.eq_numbers:
        problems = emit.check_numbering(report.eq_numbers)
        console.print(f"  {len(report.eq_numbers)} numbered equations"
                      + (f", {len(problems)} numbering problem(s)" if problems else ""))
        for problem in problems:
            console.print(f"    [yellow]![/] {problem}")

    if not args.section:
        import stream as ST
        stream, _ = ST.assemble(args.chapter)
        gaps = ST.coverage(args.chapter, body) + ST.caption_drift(stream, body)
        if gaps:
            for gap in gaps:
                console.print(f"  [yellow]![/] {gap}")
        else:
            console.print("  [green]coverage clean[/]")
    for warning in report.warnings:
        console.print(f"  [yellow]![/] {warning}")


def stage_edit(args) -> None:
    import edit
    console.print(f"\n[bold]edit[/] {args.chapter}")
    target = (edit.emit.CHAPTERS_DIR / f"{args.out}.typ") if args.out else None
    if args.replay:
        shared = edit.Replay(args.replay)
        make_model = lambda _group: shared
    else:
        make_model = lambda group: edit.Model(edit.MODEL_KEYS[group])
    passes = tuple(p.strip() for p in args.passes.split(",") if p.strip())
    outcomes = edit.edit_chapter(args.chapter, args.section, passes, make_model,
                                 dry_run=False, path=target)
    if outcomes:
        console.print(f"\n  report: {edit.write_summary(args.chapter, outcomes)}")


def stage_build(args) -> None:
    console.print("\n[bold]build[/]")
    out = REPO_ROOT / "output.pdf"
    done = subprocess.run(
        ["typst", "compile", "--root", str(REPO_ROOT),
         str(REPO_ROOT / "src" / "main.typ"), str(out)],
        capture_output=True, text=True, timeout=600)
    if done.returncode:
        console.print("[red]the book does not compile[/]")
        for line in done.stderr.splitlines()[:15]:
            console.print(f"  {line}")
        raise SystemExit(1)
    console.print(f"  [green]{out.name}[/]")


RUNNERS = {"ocr": stage_ocr, "emit": stage_emit,
           "edit": stage_edit, "build": stage_build}


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--chapter", default="ch2", choices=list(CHAPTER_PDFS))
    ap.add_argument("--all", action="store_true", help="every stage")
    ap.add_argument("--from", dest="start", choices=STAGES,
                    help="begin at this stage and run the rest")
    ap.add_argument("--only", choices=STAGES, help="run just this stage")
    ap.add_argument("--skip", default="", help="comma-separated stages to skip")
    ap.add_argument("--section", help="restrict emit and edit to one section")
    ap.add_argument("--pages", help="restrict ocr to these pages")
    ap.add_argument("--out", metavar="NAME",
                    help="work on src/chapters/NAME.typ instead of the chapter, "
                         "so a run can be compared against hand-edited work")
    ap.add_argument("--passes", default="equations,continuity,references,units",
                    help="comma-separated editor passes to run")
    ap.add_argument("--replay", type=Path, help="canned editor answers, no GPU")
    ap.add_argument("--force", action="store_true", help="re-OCR cached pages")
    args = ap.parse_args()

    if args.only:
        todo = [args.only]
    elif args.start:
        todo = list(STAGES[STAGES.index(args.start):])
    elif args.all:
        todo = list(STAGES)
    else:
        ap.error("give --all, --from STAGE, or --only STAGE")

    skip = {s.strip() for s in args.skip.split(",") if s.strip()}
    todo = [s for s in todo if s not in skip]
    # Building the whole book pulls in every other chapter, so a run scoped to
    # one section of one chapter has no business doing it.
    if args.section and "build" in todo:
        todo.remove("build")

    console.print(f"[dim]stages: {' → '.join(todo)}[/]")
    started = time.monotonic()
    for stage in todo:
        RUNNERS[stage](args)
    console.print(f"\n[dim]done in {(time.monotonic() - started) / 60:.1f} min[/]")


if __name__ == "__main__":
    main()
