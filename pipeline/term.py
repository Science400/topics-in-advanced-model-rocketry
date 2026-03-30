from rich.console import Console

# Shared console instance for the whole pipeline.
# highlight=False prevents Rich from auto-coloring numbers/strings in
# diagnostic messages (page numbers, elapsed times, model names, etc.).
console = Console(highlight=False)
