Look at the current IDE selection. In that range of the open file, convert raw numeric values to the appropriate Typst macros:
- Measurements with units → #qty(value, "unit")  e.g. "3.5 lb" → #qty(3.5, "lb"), "300 ft/s" → #qty(300, "ft/s")
- Bare numbers with no unit → #num(value)  e.g. "the value is 42" → "the value is #num(42)"
- Do NOT convert numbers already inside #qty(), #num(), equation blocks ($ ... $), or labels.
- Do NOT change anything else.

Edit the file directly at the selected lines.
