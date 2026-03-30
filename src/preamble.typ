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
