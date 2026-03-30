#import "preamble.typ": *
#import "@preview/ilm:2.0.0": *
#import "@preview/zero:0.6.1"

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

#include "chapters/ch3-aerodynamic-drag.typ"
