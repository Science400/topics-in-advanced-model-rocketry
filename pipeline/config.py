# LM Studio serves all models on a single port — load/unload via the GUI between runs
LM_STUDIO_BASE_URL = "http://localhost:1234/v1"

# Model identifiers exactly as shown in LM Studio after loading
MODELS = {
    "olmocr":  "allenai/olmocr-2-7b",
    "lighton": "lightonocr-2-1b",
    "chandra": "chandra-ocr",
}

# Comparison models available via --model flag in compare.py
COMPARISON_MODELS = {
    "gemma":   "google/gemma-3-4b",
    "qwen":    "qwen/qwen3.5-9b",
    "qwen3-4b": "qwen3-4b-instruct-2507",
}

# Resolution models available via --model flag in resolve.py
RESOLUTION_MODELS = {
    "gemma":    "google/gemma-3-4b",
    "qwen3-4b": "qwen3-4b-instruct-2507",
}

# Confidence threshold: spans at or above this are tagged ai_resolved, below → escalate
AI_CONFIDENCE_THRESHOLD = 0.75

# Default comparison model used by the review app and assembler
DEFAULT_COMPARISON_MODEL = "google/gemma-3-4b"

# Parameters passed to LM Studio's /api/v1/models/load for each model
LOAD_CONFIGS = {
    "allenai/olmocr-2-7b": {"context_length": 8192,  "flash_attention": True},
    "lightonocr-2-1b":     {"context_length": 4096,  "flash_attention": True},
    "chandra-ocr":         {"context_length": 8192,  "flash_attention": True},
    "qwen/qwen3.5-9b":              {"context_length": 16384, "flash_attention": True},
    "qwen3-4b-instruct-2507":       {"context_length": 16384, "flash_attention": True},
    "google/gemma-3-4b":            {"context_length": 8192,  "flash_attention": True},
}

from pathlib import Path

_HERE = Path(__file__).parent
DB_PATH = str(_HERE / "review.db")

# Per-chapter split PDFs live in pdf/ — page numbers are relative to each file
PDF_DIR = str(_HERE.parent / "pdf")
CHAPTER_PDFS = {
    "ch0": "ch0-intro.pdf",
    "ch1": "ch1-flight-dynamics.pdf",
    "ch2": "ch2-aerodynamic-stability.pdf",
    "ch3": "ch3-aerodynamic-drag.pdf",
    "ch4": "ch4-trajectory-analysis.pdf",
    "ch5": "ch5-appendices.pdf",
    "ch6": "ch6-errata.pdf",
}
