// resources/mystyles.typ

// 1. DEFINE COLORS
#let lightblue = rgb("#ADD8E6")
#let ibm-blue = rgb("#e6f3ff")
// 2. LAYOUT LOGIC
#let hanging-layout(it) = {
  grid(
    columns: (auto, 1fr),
    gutter: 0.75em,
    if it.numbering != none {
       counter(heading).display(it.numbering)
    },
    it.body
  )
}

// 3. MAIN CONFIGURATION
#let conf(doc) = {
  
  // --- NEW: INDENT SETTINGS ---
  // This pushes bullet points (list) right by 2em
  set list(indent: 1em)
  
  // This pushes numbered lists (enum) right by 2em
  set enum(indent: 1em)
  
  
  // --- HEADINGS ---
  show heading: it => {
    if it.level == 1 {
      block(
        fill: ibm-blue, 
        inset: 10pt,
        radius: 5pt,
        width: 100%,
        below: 1.1em,
        stroke: none,
        hanging-layout(it)
      )
    } else {
      block(
        above: 1.5em,
        below: 1.1em,
        hanging-layout(it)
      )
    }
  }

  // --- CODE BLOCKS ---
  show raw.where(block: true): block.with(
    fill: luma(250), 
    inset: 8pt,
    radius: 2pt,
    width: 100%
  )

  doc
}