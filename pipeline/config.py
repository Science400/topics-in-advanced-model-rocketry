# LM Studio serves all models on a single port — load/unload via the GUI between runs
LM_STUDIO_BASE_URL = "http://localhost:1234/v1"

# Model identifiers exactly as shown in LM Studio after loading
MODELS = {
    "olmocr":     "allenai/olmocr-2-7b",
    "lighton":    "lightonocr-2-1b",
    "qwen":       "qwen/qwen3.5-9b",
    "comparison": "qwen/qwen3.5-9b",
}

DB_PATH = "pipeline/review.db"

# Per-chapter split PDFs live in pdf/ — page numbers are relative to each file
PDF_DIR = "pdf"
CHAPTER_PDFS = {
    "ch0": "ch0-intro.pdf",
    "ch1": "ch1-flight-dynamics.pdf",
    "ch2": "ch2-aerodynamic-stability.pdf",
    "ch3": "ch3-aerodynamic-drag.pdf",
    "ch4": "ch4-trajectory-analysis.pdf",
    "ch5": "ch5-appendices.pdf",
    "ch6": "ch6-errata.pdf",
}
