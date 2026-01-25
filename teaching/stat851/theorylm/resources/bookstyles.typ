
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

// 1. Define the Color Palette
// We use a dictionary to map environment names to their color schemes.
#let themes = (
  theorem:    (bg: rgb("#f0f7ff"), border: rgb("#cfe2ff"), header-bg: rgb("#cfe2ff"), text: rgb("#084298")),
  definition: (bg: rgb("#f0fff4"), border: rgb("#badbcc"), header-bg: rgb("#badbcc"), text: rgb("#0f5132")),
  example:    (bg: rgb("#fffbf0"), border: rgb("#ffeebb"), header-bg: rgb("#ffeebb"), text: rgb("#664d03")),
  proof:      (bg: rgb("#e2e3e5"), border: rgb("#e2e3e5"), header-bg: rgb("#a6a4a4"), text: rgb("#41464b")),
  sol:        (bg: rgb("#f9f2f4"), border: rgb("#d9534f"), header-bg: rgb("#d9534f"), text: rgb("#ffffff")),
  solution:   (bg: rgb("#f9f2f4"), border: rgb("#d9534f"), header-bg: rgb("#d9534f"), text: rgb("#ffffff")),
  algorithm:  (bg: rgb("#f3f0ff"), border: rgb("#e0cffc"), header-bg: rgb("#e0cffc"), text: rgb("#440099")),
  remark:     (bg: rgb("#f3fcfc"), border: rgb("#cff4fc"), header-bg: rgb("#cff4fc"), text: rgb("#055160")),
)

// 2. The Master Environment Function
// This mimics the SCSS mixin and container styling.
#let colored-env(type, title: none, body) = {
  // Fallback to theorem colors if type is unknown
  let theme = if type in themes { themes.at(type) } else { themes.theorem }
  
  // Logic for the Header Title
  // SCSS Case B: If it's a solution, force the title "Solution" if none is provided.
  let display-title = if title != none {
    title
  } else if type == "sol" or type == "solution" {
    "Solution"
  } else {
    none
  }

  // 3. Base Container Styling
  block(
    fill: theme.bg,
    stroke: 2pt + theme.border,
    radius: 5pt,
    width: 100%,
    inset: 0pt, // Internal padding is handled by children to allow header to touch edges
    clip: true, // Ensures the header background doesn't bleed outside the rounded corners
    breakable: true, // Allow breaking across pages (optional, remove if unwanted)
    {
      // 4. Header Logic (The "Mixin")
      if display-title != none {
        block(
          fill: theme.header-bg,
          width: 100%,
          inset: (x: 1em, y: 0.6em),
          stroke: (bottom: 1pt + black.transparentize(95%)), // mimicking rgba(0,0,0,0.05)
          sticky: true,
          [
            #set text(fill: theme.text, weight: "bold")
            #display-title
          ]
        )
      }
      
      // The Body Content
      block(
        width: 100%,
        inset: 1em, // Padding: 1em
        body
      )
    }
  )
}

// 5. User-Facing Wrappers
// These allow you to use #theorem[Content] syntax
#let theorem(title: none, body)    = colored-env("theorem", title: title, body)
#let definition(title: none, body) = colored-env("definition", title: title, body)
#let example(title: none, body)    = colored-env("example", title: title, body)
#let proof(title: none, body)      = colored-env("proof", title: title, body)
#let algorithm(title: none, body)  = colored-env("algorithm", title: title, body)
#let remark(title: none, body)     = colored-env("remark", title: title, body)

// Solutions usually don't need a manual title, but we allow it just in case
#let sol(body)      = colored-env("sol", title: none, body)
#let solution(body) = colored-env("solution", title: none, body)
