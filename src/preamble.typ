#import "@preview/unify:0.7.1": qty as _qty, unit, num, qtyrange

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

// Equation numbering. A display equation is numbered by default; a leading `!`
// inside the dollars marks one the manuscript left unnumbered.
//
//   $ F = m a $                                     numbered, counter steps
//   $! arrow(c) equiv -c $                          display, no number
//   #eq("44a")[$ u = (partial psi)/(partial y) $]   literal manuscript number
//
// The `!` replaces the `#set math.equation(numbering: none)` / `#set ... "(1)"`
// sandwiches ch3 is full of, which leak forward until the next #set and so make
// every unnumbered equation a two-line edit in three places.
//
// #eq() stays for the manuscript's out-of-order numbers (12a, 44b, 102a): the
// number is written literally beside the label, so the two cannot disagree.
// Note it still steps the counter, so a chapter mixing both needs the usual
// #counter(math.equation).update(n) resync after a lettered run.

// `$!` has no space after the opening dollar, so Typst parses it as *inline*
// math whose body begins with a `!` text child. The rule therefore has to strip
// the `!` (and the space behind it) and rebuild the equation as a block — a
// show rule cannot flip `block` in place.
#let _bang = $!$.body

#let _unnumbered-bang(it) = {
  let kids = if it.body.has("children") { it.body.children } else { (it.body,) }
  if kids.len() == 0 or kids.first() != _bang { return it }
  // Introspection still sees the original numbered element, so a label here
  // would resolve to whatever the counter happens to hold — a silently wrong
  // cross-reference. Fail loudly instead.
  if it.at("label", default: none) != none {
    panic("`$! ... $` is unnumbered and cannot be referenced — use `$ ... $` or #eq()")
  }
  let rest = kids.slice(1)
  if rest.len() > 0 and rest.first() == [ ] { rest = rest.slice(1) }
  math.equation(block: true, numbering: none, rest.join())
}

#let eq(n, body) = math.equation(
  block: true,
  numbering: _ => "(" + n + ")",
  body,
)

// Bare "(44a)" instead of "Equation (44a)", for prose that already says the word.
#let eqref(label) = ref(label, supplement: none)

// Aspect ratio, written in the manuscript as a hand-drawn A-R ligature. There is
// no Unicode codepoint for it and no Typst package supplying one — LaTeX's
// `aspectratio` ships a purpose-drawn font — so it is assembled from Garamond-Math's
// own A and R.
//
// Simply overlapping the two letters does not work: the A's right leg is a diagonal
// and the R's stem is vertical, so no kern makes them coincide and the result always
// shows a doubled stroke. A real ligature deletes the A's right leg outright and lets
// the crossbar die into the R's stem, which is what the truncation below does — the A
// is clipped mid-crossbar and the R is kerned back so its stem covers the cut edge.
// The A's apex still protrudes a little to the left of the stem, as it does in the
// manuscript's hand-drawn glyph.
//
// Both constants are measured, not eyeballed, against Garamond-Math at 1em = 1000
// units: the R's stem spans x = 130..210 of its own advance, so the R sits back far
// enough to put that stem where the A's leg was, and the A is cut at 0.44em — inside
// the stem, so the flat cut edge is hidden under it. Re-measure if the *math* font
// changes; the body font does not matter, since math.upright resolves in the math font.
#let _ar-cut = 0.44em
#let _ar-kern = -0.195em

#let AR = math.class("normal",
  box(clip: true, width: _ar-cut, math.upright($A$)) + h(_ar-kern) + math.upright($R$))

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
//
// Equation numbering lives here for the same reason — a bare `#set` at the top
// of this file is dead code, since #import carries values but not rules. The
// counter restarts per chapter, as the manuscript numbers do.
#let chapter-setup(body) = {
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() == 1 { numbering("1", ..n) } else { n.slice(1).map(str).join(".") }
  })
  show heading.where(level: 1): set heading(supplement: [Chapter])
  // A function, not the "(1)" pattern string: Typst strips a pattern's literal
  // affixes inside a @ref, so the string form numbers "(7)" on the page but
  // references it as "7" — while #eq() below, being a function, keeps "(44a)".
  set math.equation(numbering: n => "(" + str(n) + ")")
  show math.equation: _unnumbered-bang
  counter(math.equation).update(0)
  body
}

#set document(title: "Topics in Advanced Model Rocketry")
#set page(numbering: "1", margin: (x: 1.25in, y: 1in))
#set text(font: "EB Garamond", size: 12pt)
#show math.equation: set text(font: "Garamond-Math")
#set par(justify: true, leading: 0.65em, first-line-indent: (amount: 1em, all: true))

// Typewriter manuscript convention: underline → italics
#show underline: it => emph(it.body)
