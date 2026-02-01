/* In resources/bookstyles.typ */

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

// 2. The Master Environment Function (Upgraded)
// This wraps the colored box in a figure to enable numbering and referencing.
#let colored-env(type, title: none, body) = {
  // A. Determine Theme
  let theme = if type in themes { themes.at(type) } else { themes.theorem }
  
  // B. Determine Supplement (e.g., "Theorem", "Definition")
  let supplement = if type == "sol" or type == "solution" {
    "Solution"
  } else {
    type.at(0).upper() + type.slice(1)
  }

  // C. Create the Figure (This makes it referenceable!)
  figure(
    kind: type,            // Each type (theorem, lemma) gets its own counter
    supplement: supplement,
    numbering: "1.1",      // Auto-numbering style
    outlined: false,       // Don't show in table of figures
    caption: none,         // Hide standard caption (we draw it inside the box)
    
    // D. The Content (Context is needed to get the current number)
    context {
      // 1. Get the current number (e.g., "1.1")
      let num = counter(figure.where(kind: type)).display(figure.numbering)
      
      // 2. Build the Header Title (e.g., "Theorem 1.1: Title")
      let full-title = if title != none {
        [#supplement #num: #title]
      } else {
        [#supplement #num]
      }

      // 3. Draw the Colored Box
      block(
        fill: theme.bg,
        stroke: 2pt + theme.border,
        radius: 5pt,
        width: 100%,
        inset: 0pt,
        clip: true,
        breakable: true, // Note: Figures often resist breaking across pages in Typst
        {
          // Header
          block(
            fill: theme.header-bg,
            width: 100%,
            inset: (x: 1em, y: 0.6em),
            stroke: (bottom: 1pt + black.transparentize(95%)),
            sticky: true,
            [
              #set text(fill: theme.text, weight: "bold")
              #full-title
            ]
          )
          
          // Body
          block(
            width: 100%,
            inset: 1em,
            body
          )
        }
      )
    }
  )
}

/* --- Equation Numbering Settings --- */

// 1. Format the number as (Chapter.Equation)
#set math.equation(numbering: n => {
  let chapter = counter(heading).get().first()
  numbering("(1.1)", chapter, n)
})

// 2. Reset equation counter at every Level 1 heading
#show heading.where(level: 1): it => {
  counter(math.equation).update(0)
  it
}

// 5. User-Facing Wrappers (Robust Version)
// These handle arguments from both your Lua filter AND the Quarto extension styles.
#let env-wrapper(type, ..args) = {
  let pos = args.pos()
  let named = args.named()
  
  // Default title to named arg 'title' or none
  let title = named.at("title", default: none)
  let body = none

  if pos.len() == 2 {
    // Case: #env("Title")[Body] (Extension style)
    title = pos.at(0)
    body = pos.at(1)
  } else if pos.len() == 1 {
    // Case: #env[Body] (Filter style)
    body = pos.at(0)
  } else {
    panic("Invalid arguments passed to environment wrapper")
  }

  colored-env(type, title: title, body)
}

// Define the shortcuts using the wrapper
#let theorem(..args)    = env-wrapper("theorem", ..args)
#let definition(..args) = env-wrapper("definition", ..args)
#let example(..args)    = env-wrapper("example", ..args)
#let proof(..args)      = env-wrapper("proof", ..args)
#let algorithm(..args)  = env-wrapper("algorithm", ..args)
#let remark(..args)     = env-wrapper("remark", ..args)
#let sol(..args)        = env-wrapper("sol", ..args)
#let solution(..args)   = env-wrapper("solution", ..args)