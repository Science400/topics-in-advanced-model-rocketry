# OCR cache

Raw transcription output, one file per scanned page: `p012.raw.txt` is exactly
what the OCR model returned for page 12 of that chapter's PDF.

**This is committed on purpose.** The page scans in `pdf/` are gitignored, so a
clone has no images, no model, and no way to re-run OCR. These files are the
only reproducible input to `emit.py` — without them the Typst chapters cannot
be rebuilt, and there is no record of what the model actually said.

They also serve as provenance: if a transcription looks wrong, you can check
the model's raw output here before going back to the scan.

## What is here, and what is not

| | committed | why |
|---|---|---|
| `p*.raw.txt` | yes | expensive to produce — a GPU and ~1 hour per chapter |
| `manifest.json` | yes | per-page timings, metrics, and which prompt variant was used |
| `p*.md` | no | pure derivation of the raw via `ocrlib.normalize()`; `emit.py` regenerates it |
| `p*.eqnums.json` | no | sidecars from the shelved equation-number verifier |

## Regenerating

The normalized `.md` files reappear automatically the next time `emit.py` runs.
To redo the OCR itself you need the scans and a local model:

    uv run --project pipeline python pipeline/ocr.py --chapter ch1 --all
