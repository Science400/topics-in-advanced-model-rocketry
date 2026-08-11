Look at the current IDE selection. In that range of the open file, fix equation numbering:
- Remove any manually typed equation numbers like "(3.1)" or "(a)" appended at the end of display equation lines — Typst numbers them automatically.
- Equations that should NOT be numbered: wrap with #math.equation(numbering: none)[ $ ... $ ]
- Equations with non-standard numbering (letters, roman numerals, nested like "3.1a"): wrap with #math.equation(numbering: "(1a)")[ $ ... $ ]
- Do NOT change equation content, only numbering markup.

Edit the file directly at the selected lines.
