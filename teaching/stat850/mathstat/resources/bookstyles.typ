/* =========================================
   1. GLOBAL TEXT & PARAGRAPH SETTINGS
   ========================================= */
#set text(
  font: "Times New Roman",
  size: 12pt
)

#set par(
  leading: 0.65em, /* Line spacing */
  justify: true
)

/* =========================================
   2. HEADING FORMATTING & NUMBERING
   ========================================= */
/* Force section numbering (e.g., 1.1, 1.1.1) */
#set heading(numbering: "1.1")

/* Level 1: 12pt size + space below */
#show heading.where(level: 1): set text(size: 12pt)
#show heading.where(level: 1): set block(below: 1em)

/* Level 2: 11pt size + space below */
#show heading.where(level: 2): set text(size: 11pt)
#show heading.where(level: 2): set block(below: 1em)

/* =========================================
   3. COUNTER RESET LOGIC (CRITICAL)
   ========================================= */
/* This ensures that Equations AND Environments (Theorems, etc.) 
   restart numbering at every new Chapter (Level 1).
   e.g. Chapter 2 starts with Eq 2.1 and Theorem 2.1 
*/
#show heading.where(level: 1): it => {
  // A. Reset Equation Counter
  counter(math.equation).update(0)
  
  // B. Reset Environment Counters
  counter(figure.where(kind: "theorem")).update(0)
  counter(figure.where(kind: "definition")).update(0)
  counter(figure.where(kind: "example")).update(0)
  counter(figure.where(kind: "proof")).update(0)
  counter(figure.where(kind: "algorithm")).update(0)
  counter(figure.where(kind: "remark")).update(0)
  counter(figure.where(kind: "sol")).update(0)
  counter(figure.where(kind: "solution")).update(0)
  
  it
}

/* =========================================
   4. EQUATION NUMBERING STYLE
   ========================================= */
/* Format math equations as (Chapter.Equation) */
#set math.equation(numbering: n => {
  let chapter = counter(heading).get().first()
  numbering("(1.1)", chapter, n)
})

/* =========================================
   5. CUSTOM COLORED ENVIRONMENTS
   ========================================= */

// A. Define the Color Palette
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

// B. The Master Environment Function
#let colored-env(type, title: none, body) = {
  // 1. Determine Theme & Supplement
  let theme = if type in themes { themes.at(type) } else { themes.theorem }
  let supplement = if type == "sol" or type == "solution" { "Solution" } else { type.at(0).upper() + type.slice(1) }

  // 2. Create the Figure
  figure(
    kind: type,
    supplement: supplement,
    numbering: "1.1",
    outlined: false,
    caption: none,
    
    // 3. Contextual Content (Numbering + Box)
    context {
      // Get the chapter number and item number for "Chapter.Item" format
      let chapter = counter(heading).get().first()
      let item-num = counter(figure.where(kind: type)).get().first()
      let num-str = [#chapter.#item-num]

      // Build Header Title
      let full-title = if title != none {
        [#supplement #num-str: #title]
      } else {
        [#supplement #num-str]
      }

      // Draw the Colored Box
      block(
        fill: theme.bg,
        stroke: 2pt + theme.border,
        radius: 5pt,
        width: 100%,
        inset: 0pt,
        clip: true,
        breakable: true,
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
          block(width: 100%, inset: 1em, body)
        }
      )
    }
  )
}

// C. User-Facing Wrappers
// Handles arguments from both Lua filters and Quarto extension styles
#let env-wrapper(type, ..args) = {
  let pos = args.pos()
  let named = args.named()
  let title = named.at("title", default: none)
  let body = none

  if pos.len() == 2 {
    title = pos.at(0)
    body = pos.at(1)
  } else if pos.len() == 1 {
    body = pos.at(0)
  } else {
    panic("Invalid arguments passed to environment wrapper")
  }

  colored-env(type, title: title, body)
}

// D. Shortcuts
#let theorem(..args)    = env-wrapper("theorem", ..args)
#let definition(..args) = env-wrapper("definition", ..args)
#let example(..args)    = env-wrapper("example", ..args)
#let proof(..args)      = env-wrapper("proof", ..args)
#let algorithm(..args)  = env-wrapper("algorithm", ..args)
#let remark(..args)     = env-wrapper("remark", ..args)
#let sol(..args)        = env-wrapper("sol", ..args)
#let solution(..args)   = env-wrapper("solution", ..args)