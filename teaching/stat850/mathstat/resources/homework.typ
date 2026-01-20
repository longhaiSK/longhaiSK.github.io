#let sol(content) = {
  block(
    fill: rgb("#f9f2f4"),      // Background color
    stroke: 2pt + rgb("#d9534f"), // Border color and width
    radius: 5pt,               // Rounded corners
    width: 100%,
    inset: 0pt,                // Reset inset so header touches edges
    clip: true,                // Clip header to rounded corners
    stack(
      dir: ttb,                // Stack items top-to-bottom
      
      // The Header Bar
      block(
        width: 100%,
        fill: rgb("#d9534f"),
        inset: (x: 1em, y: 0.6em),
        text(fill: white, weight: "bold")[Solution]
      ),
      
      // The Content Body
      block(
        width: 100%,
        inset: 1em,
        content
      )
    )
  )
}

/* In resources/homework.typ */

/* --- Heading Formatting --- */
/* Level 1: 12pt size + 1 line (1em) space below */
#show heading.where(level: 1): set text(size: 12pt)
#show heading.where(level: 1): set block(below: 1em)

/* Level 2: 11pt size + 1 line (1em) space below */
#show heading.where(level: 2): set text(size: 11pt)
#show heading.where(level: 2): set block(below: 1em)


/* --- Global Text Settings --- */
#set text(
  font: "Times New Roman",
  size: 12pt
)

/* --- Paragraph Settings --- */
#set par(
  leading: 0.65em, /* Line spacing */
  justify: true
)