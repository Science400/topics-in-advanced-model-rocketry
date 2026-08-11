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

#set document(title: "Topics in Advanced Model Rocketry")
#set page(numbering: "1", margin: (x: 1.25in, y: 1in))
#set text(font: "New Computer Modern", size: 12pt)
#set par(justify: true, leading: 0.65em, first-line-indent: (amount: 1em, all: true))

// Typewriter manuscript convention: underline → italics
#show underline: it => emph(it.body)
