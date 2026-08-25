# Legacy — the three-model vote path

Kept for reference, not run. Nothing in the live pipeline imports from here.

The original design OCR'd every page with three models (olmocr, LightOnOCR, chandra),
had a fourth model diff the three transcriptions span by span, and sent the disagreements
to a Flask review UI. `compare.py`, `resolve.py`, `assemble.py`, `ocr_pages.py`,
`show_results.py`, `review_app/` and `review.db` are that path.

It was abandoned because the vote carried no usable signal: 38% of spans came back
CONFLICT, and three models can agree on an omission none of them reports. `bakeoff.py`
settled on a single model instead — see the design notes.

`verify.py` is newer but also retired. It ran chandra over every page for the sole
purpose of recovering the equation numbers this manuscript prints in the left margin,
which olmocr reads as list markers and drops. Nothing ever consumed its `.eqnums.json`
sidecars. That job now belongs to `edit.py`'s equation pass, which reads the page image
with the model already loaded for editing rather than paying for a third model.
