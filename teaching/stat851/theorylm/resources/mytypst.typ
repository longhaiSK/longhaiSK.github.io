// exam-theme.typ

// 1. The Logic for Shaded Headings with Hanging Indent
#let shaded-heading(it) = {
  block(
    fill: rgb("e6e6e6"),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    below: 1em,
    stroke: none,
    
    // This GRID is what creates the hanging effect.
    // Column 1: The Number (auto width)
    // Column 2: The Text (takes remaining space)
    grid(
      columns: (auto, 1fr),
      gutter: 0.5em, // Space between number and text
      
      // Logic: Only show number if numbering is turned on
      if it.numbering != none {
        counter(heading).display(it.numbering)
      },
      
      // The Title Text
      it.body
    )
  )
}

// 2. Apply the rules
// We export a "conf" function that Quarto will call
#let conf(doc) = {
  
  // Apply styling to Level 1 Headings
  show heading.where(level: 1): it => shaded-heading(it)
  
  // Apply styling to Code Blocks
  show raw.where(block: true): block.with(
    fill: rgb("f9f9f9"),
    inset: 8pt,
    radius: 2pt,
    width: 100%
  )

  doc
}