#import "preamble.typ": *
#import "@preview/ilm:2.0.0": *
#import "@preview/zero:0.6.1"
#import "@preview/unify:0.7.1": qty

#set text(lang: "en", font: "EB Garamond")
#show math.equation: set text(font: "Garamond-Math")

#let book-title = [Topics in Advanced Model Rocketry]
#let book-authors = ("Gordon K. Mandell", "George J. Caporaso", "William P. Bengen")

#show: ilm.with(
  title: book-title,
  authors: book-authors,
  paper-size: "us-letter",
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
  cover-page: [
    #align(horizon)[
      #text(4em, weight: "bold")[#book-title]
      #v(0.5em)
      #text(2em)[T+52 Years]
      #v(1.5em)
      #text(1.5em)[#book-authors.join([\ ])]
    ]
  ],
)

// #set par(first-line-indent: (amount: 1em, all: true))

#show heading.where(level: 1): set heading(supplement: [Chapter])

#set heading(numbering: (..nums) => {
  let n = nums.pos()
  if n.len() == 1 { numbering("1", ..n) }
  else { n.slice(1).map(str).join(".") }
})

#include "chapters/ch0-intro.typ"
#include "chapters/ch1-flight-dynamics.typ"
#include "chapters/ch2-aerodynamic-stability.typ"
#include "chapters/ch3-aerodynamic-drag.typ"
#include "chapters/ch4-trajectory-analysis.typ"

// #bibliography("refs-ch3.yml", style: "ieee")