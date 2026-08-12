#import "@preview/unify:0.7.1": qty as _qty, unit, num

// Units not in unify's SI registry — extend as needed for this book.
// Values are Typst math expression strings passed to eval inside unify's rawunit mode.
#let _raw-units = (
  "psi":  "upright(\"psi\")",
  "fps":  "upright(\"fps\")",
  "rpm":  "upright(\"rpm\")",
  "slug": "upright(\"slug\")",
  "lb":   "upright(\"lb\")",
  "lbf":  "upright(\"lbf\")",
  "ft":   "upright(\"ft\")",
  "degC": "upright(\"°C\")",
  "degF": "upright(\"°F\")",
  "degR": "upright(\"°R\")",
  "K":    "upright(\"K\")",
)

// Drop-in replacement for unify's qty that handles custom units automatically
#let qty(value, unit-str, per: "/", ..args) = {
  if unit-str in _raw-units.keys() {
    _qty(value, _raw-units.at(unit-str), rawunit: true, per: per, ..args)
  } else {
    _qty(value, unit-str, per: per, ..args)
  }
}

// Review mode: conflict/minor spans are highlighted; set false for clean build
#let review-mode = true

#let conflict(content) = if review-mode {
  highlight(fill: red.lighten(60%))[#content]
} else {
  content
}

#let minor(content) = if review-mode {
  highlight(fill: yellow.lighten(60%))[#content]
} else {
  content
}

// Equation numbering: unnumbered is the default, numbered is explicit.
//
// Ch3 did this the other way round and it cost 24 #set rules, 9 counter
// resyncs, and 38 wrapper blocks — a #set leaks forward until the next one, so
// inserting an equation shifts every number after it. Here the manuscript's own
// number is written literally beside the label, so the two cannot disagree and
// out-of-order numbers need no special handling.
//
//   $ (partial u)/(partial x) = 0 $                 unnumbered, zero markup
//   #eq("44a")[$ u = (partial psi)/(partial y) $] <eq:1-44a>
//
#set math.equation(numbering: none)

#let eq(n, body) = math.equation(
  block: true,
  numbering: _ => "(" + n + ")",
  body,
)

// Bare "(44a)" instead of "Equation (44a)", for prose that already says the word.
#let eqref(label) = ref(label, supplement: none)

// The chapter symbol table: content in the book, and parsed back out by
// pipeline/symtab.py as the pipeline's symbol configuration.
#let symbol-table(..rows) = table(columns: (auto, 1fr), stroke: none, ..rows)

// Applied by each chapter as `#show: chapter-setup`.
//
// Typst does not carry #set rules across an #import, so a chapter compiled on
// its own would have unnumbered headings — and an unnumbered heading cannot be
// referenced, which breaks every @sec: link. Wrapping it in a show rule scopes
// the numbering to the chapter instead of leaking into the rest of the book.
//
// Level 1 is the chapter; deeper levels drop the chapter number so a level-3
// heading in chapter 1 reads "2.1", matching the manuscript.
#let chapter-setup(body) = {
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() == 1 { numbering("1", ..n) } else { n.slice(1).map(str).join(".") }
  })
  show heading.where(level: 1): set heading(supplement: [Chapter])
  body
}

#set document(title: "Topics in Advanced Model Rocketry")
#set page(numbering: "1", margin: (x: 1.25in, y: 1in))
#set text(font: "New Computer Modern", size: 12pt)
#set par(justify: true, leading: 0.65em, first-line-indent: (amount: 1em, all: true))

// Typewriter manuscript convention: underline → italics
#show underline: it => emph(it.body)
