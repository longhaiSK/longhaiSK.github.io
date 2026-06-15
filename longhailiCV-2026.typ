// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}


// syntax highlighting functions from skylighting:
/* Function definitions for syntax highlighting generated by skylighting: */
#let EndLine() = raw("\n")
#let Skylighting(fill: none, number: false, start: 1, sourcelines) = {
   let blocks = []
   let lnum = start - 1
   let bgcolor = rgb("#f1f3f5")
   for ln in sourcelines {
     if number {
       lnum = lnum + 1
       blocks = blocks + box(width: if start + sourcelines.len() > 999 { 30pt } else { 24pt }, text(fill: rgb("#aaaaaa"), [ #lnum ]))
     }
     blocks = blocks + ln + EndLine()
   }
   block(fill: bgcolor, width: 100%, inset: 8pt, radius: 2pt, blocks)
}
#let AlertTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let AnnotationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let AttributeTok(s) = text(fill: rgb("#657422"),raw(s))
#let BaseNTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let BuiltInTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let CharTok(s) = text(fill: rgb("#20794d"),raw(s))
#let CommentTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let CommentVarTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ConstantTok(s) = text(fill: rgb("#8f5902"),raw(s))
#let ControlFlowTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let DataTypeTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DecValTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DocumentationTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ErrorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let ExtensionTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let FloatTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let FunctionTok(s) = text(fill: rgb("#4758ab"),raw(s))
#let ImportTok(s) = text(fill: rgb("#00769e"),raw(s))
#let InformationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let KeywordTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let NormalTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let OperatorTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let OtherTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let PreprocessorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let RegionMarkerTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let SpecialCharTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let SpecialStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let StringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let VariableTok(s) = text(fill: rgb("#111111"),raw(s))
#let VerbatimStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let WarningTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))



#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
   }

  let has-title-block = title != none or (authors != none and authors != ()) or date != none or abstract != none
  if has-title-block {
    place(
      top,
      float: true,
      scope: "parent",
      clearance: 4mm,
      block(below: 1em, width: 100%)[

        #if title != none {
          align(center, block(inset: 2em)[
            #set par(leading: heading-line-height) if heading-line-height != none
            #set text(font: heading-family) if heading-family != none
            #set text(weight: heading-weight)
            #set text(style: heading-style) if heading-style != "normal"
            #set text(fill: heading-color) if heading-color != black

            #text(size: title-size)[#title #if thanks != none {
              footnote(thanks, numbering: "*")
              counter(footnote).update(n => n - 1)
            }]
            #(if subtitle != none {
              parbreak()
              text(size: subtitle-size)[#subtitle]
            })
          ])
        }

        #if authors != none and authors != () {
          let count = authors.len()
          let ncols = calc.min(count, 3)
          grid(
            columns: (1fr,) * ncols,
            row-gutter: 1.5em,
            ..authors.map(author =>
                align(center)[
                  #author.name \
                  #author.affiliation \
                  #author.email
                ]
            )
          )
        }

        #if date != none {
          align(center)[#block(inset: 1em)[
            #date
          ]]
        }

        #if abstract != none {
          block(inset: 2em)[
          #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
          ]
        }
      ]
    )
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc
}

#set table(
  inset: 6pt,
  stroke: none
)
#show figure: set block(breakable: true)
#set enum(indent: 1em, body-indent: 0.75em, numbering: "[1]")
#set list(indent: 1em, body-indent: 0.75em)
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (bottom: 25mm,top: 25mm,x: 20mm,),
  numbering: "1",
  columns: 1,
)

#show: doc => article(
  title: [CURRICULUM VITAE of LONGHAI LI (Jun 15, 2026)],
  fontsize: 11pt,
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)

= 1. PERSONAL
<personal>
- Official webpage: #link("https://artsandscience.usask.ca/profile/LLi")
- Professional web site: #link("https://longhaisk.github.io")
- Phone: +1 (306) 966-6095
- Email: #link("mailto:longhai.li@usask.ca")[longhai.li\@usask.ca]
- Address: \
  Department of Mathematics & Statistics \
  University of Saskatchewan \
  106 Wiggins RD \
  Saskatoon, SK, S7W0G8 CANADA

= 2. DEGREES
<degrees>
- Ph.D., University of Toronto, 2007, Statistics \
  Supervisor: #link("https://glizen.com/radfordneal/")[Radford M. Neal] \
  Thesis: Bayesian Classification and Regression with High Dimensional Features
- M.Sc., University of Toronto, 2003, Statistics
- B.Sc., University of Science and Technology of China, 2002, Statistics.

= 4. Employment History
<employment-history>
- Full Professor, July 1st, 2018, Dept. of Math & Stat., Univ. of Saskatchewan, SK, Canada
- Associate Professor, July 1st, 2012, Dept. of Math & Stat., Univ. of Saskatchewan, SK, Canada
- Assistant Professor, July 1st, 2007, Dept. of Math & Stat., Univ. of Saskatchewan, SK, Canada
- Research Intern, Nov.~2006 to Feb.~2007, Microsoft Research, Redmond, WA, USA
- Sessional Instructor, 2006-2007, University of Toronto, Toronto, ON, Canada

= 7. LEAVES
<leaves>
- Sabbatical Leave, Jan.~1st, 2025 to June 30th, 2025.
- Sabbatical Leave, July 1st, 2020 to June 30th, 2021.
- Parental Leave, Jan.~1st, 2019 to June 30th, 2019.
- Sabbatical Leave, July 1st, 2013 to June 30th, 2014.

= 9. TEACHING ACTIVITIES
<teaching-activities>
== 9.1 Scheduled Instructional Activity
<scheduled-instructional-activity>
#block[
#[
#set table(inset: (x: 5pt, y: 2.5pt))
#set par(leading: 0.45em)
#strong[2025-2026]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 851], [T2], [Linear Statistical Models], [LEC], [4], [39], [156],
  [STAT 443], [T2], [Linear Models], [LEC], [3], [39], [117],
  [STAT 442], [T2], [Statistical Inference], [LEC], [3], [39], [117],
  [STAT 850], [T2], [Mathematical Statistics and Inference], [LEC], [1], [39], [39],
  [STAT 845], [T1], [Statistical Methods for Research], [LEC], [10], [39], [390],
  [MATH 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [1], [], [],
)
#strong[2024-2025]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 348], [T1], [Sampling Techniques], [LEC], [15], [39], [585],
  [STAT 812], [T1], [Computational Statistics], [LEC], [5], [39], [195],
  [STAT 420], [T1], [Topics in Computational Statistics], [LEC], [1], [39], [39],
  [BIOS 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
  [BIOS 996], [T1T2], [Research Supervision (M.Sc.)], [RES], [1], [], [],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [1], [], [],
)
#strong[2023-2024]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 245], [T1], [Introduction to Statistical Methods], [LEC], [91], [39], [3549],
  [STAT 812], [T1], [Computational Statistics], [LEC], [5], [39], [195],
  [STAT 420], [T1], [Topics in Computational Statistics], [LEC], [1], [39], [39],
  [STAT 443], [T2], [Linear Statistical Models], [LEC], [4], [39], [156],
  [STAT 851], [T2], [Linear Models], [LEC], [4], [39], [156],
  [BIOS 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
  [BIOS 996], [T1T2], [Research Supervision (M.Sc.)], [RES], [1], [], [],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [1], [], [],
)
#strong[2022-2023]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 348], [T1], [Sampling Techniques], [LEC], [35], [39], [1365],
  [STAT 812], [T1], [Computational Statistics], [LEC], [3], [39], [117],
  [STAT 420], [T1], [Topics in Computational Statistics], [LEC], [1], [39], [39],
  [STAT 443], [T2], [Linear Statistical Models], [LEC], [1], [39], [39],
  [STAT 851], [T2], [Linear Models], [LEC], [1], [39], [39],
  [BIOS 996], [T1T2], [Research Supervision (M.Sc.)], [RES], [1], [], [],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [1], [], [],
  [BIOS 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
)
#strong[2021-2022]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 244], [T2], [Elementary Statistical Concepts], [LEC], [72], [39], [2808],
  [STAT 342], [T1], [Mathematical Statistics], [LEC], [8], [39], [312],
  [STAT 443], [T2], [Linear Statistical Models], [LEC], [3], [39], [117],
  [STAT 851], [T2], [Linear Models], [LEC], [5], [39], [195],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [2], [], [],
  [MATH 994], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
  [BIOS 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
  [ENGR 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
)
#strong[2020-2021]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [3], [], [],
  [BIOS 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
  [ENGR 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
)
#strong[2019-2020]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 245], [T1], [Introduction to Statistical Methods], [LEC], [128], [39], [4992],
  [STAT 345], [T2], [Design and Analysis of Experiments], [LEC], [27], [39], [1053],
  [STAT 834], [T2], [Advanced Experimental Design], [LEC], [1], [39], [39],
  [STAT 812], [T1], [Computational Statistics], [LEC], [5], [39], [195],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [1], [], [],
  [BIOS 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
  [ENGR 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
)
#strong[2018-2019]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 812], [T1], [Computational Statistics], [LEC], [11], [39], [429],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [2], [], [],
  [BIOS 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [2], [], [],
  [BIOS 994], [T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
  [MATH 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
)
#strong[2017-2018]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 241], [T1], [Probability Theory], [LEC], [70], [39], [2730],
  [STAT 345], [T2], [Design and Analysis of Experiments], [LEC], [25], [39], [975],
  [STAT 834], [T2], [Advanced Experimental Design], [LEC], [9], [39], [351],
  [STAT 841], [T2], [Probability Theory], [LEC], [5], [39], [195],
  [MATH 994], [T1T2], [M.Sc. Research Supervision], [RES], [5], [], [],
)
#strong[2016-2017]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 812], [T1], [Computational Statistics], [LEC], [12], [39], [468],
  [STAT 348], [T2], [Sampling Techniques], [LEC], [33], [39], [1287],
  [STAT 442], [T2], [Statistical Inference], [LEC], [1], [39], [39],
  [STAT 846], [T2], [Sp. Topics (Statistical Inference)], [LEC], [8], [39], [312],
  [MATH 994], [T1T2], [M.Sc. Research Supervision], [RES], [6], [], [],
)
#strong[2015-2016]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 245], [T1], [Intro. to Stat. Methods], [LEC], [157], [39], [6123],
  [STAT 342], [T1], [Mathematical Statistics], [LEC], [7], [39], [273],
  [STAT 242], [T2], [Stat. Theory & Methodology], [LEC], [11], [39], [429],
  [STAT 245], [T2 (2014SS)], [Intro to Statistical Methods], [LEC], [30], [39], [1170],
  [MATH 994], [T1T2], [M.Sc. Research Supervision], [RES], [5], [], [],
  [MATH 996], [T1T2], [Ph.D.~Research Supervision], [RES], [1], [], [],
)
#strong[2014-2015]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 342], [T1], [Mathematical Statistics], [LEC], [9], [39], [351],
  [STAT 812], [T1], [Computational Statistics], [LEC], [10], [39], [390],
  [STAT 348], [T2], [Sampling Techniques], [LEC], [21], [39], [819],
  [STAT 442], [T2], [Statistical Inference], [LEC], [5], [39], [195],
  [STAT 846], [T2], [Sp. Topics (Statistical Inference)], [LEC], [8], [39], [312],
  [STAT 244], [T2], [Elementary Statistical Concepts], [LEC], [14], [39], [546],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [4], [], [],
  [MATH 996], [T1], [Research Supervision (Ph.D.)], [RES], [2], [], [],
)
#strong[2012-2013]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 241], [T1], [Probability Theory], [LEC], [51], [39], [1989],
  [STAT 348], [T2], [Sampling Techniques], [LEC], [15], [39], [585],
  [STAT 245], [T2], [Intro to Statistical Methods], [LEC], [135], [39], [5265],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [2], [], [],
  [MATH 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [2], [], [],
)
#strong[2011-2012]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 241], [T1], [Probability Theory], [LEC], [43], [39], [1677],
  [STAT 342], [T1], [Mathematical Statistics], [LEC], [3], [39], [117],
  [STAT 841], [T1], [Probability Theory], [LEC], [10], [39], [390],
  [STAT 245], [T2], [Intro to Statistical Methods], [LEC], [138], [39], [5382],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [2], [], [],
)
#strong[2010-2011]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 241], [T1], [Probability Theory], [LEC], [42], [39], [1638],
  [STAT 846], [T1], [Computational Statistics], [LEC], [8], [39], [195],
  [STAT 242], [T2], [Stat. Theory & Methodology], [LEC], [13], [39], [507],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [2], [], [],
  [MATH 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
)
#strong[2009-2010]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 342], [T1], [Mathematical Statistics], [LEC], [4], [39], [156],
  [STAT 841], [T1], [Probability Theory], [LEC], [6], [39], [234],
  [STAT 241], [T2], [Probability Theory], [LEC], [28], [39], [1092],
  [STAT 244], [T2], [Elem. Stat. Concepts], [LEC], [83], [39], [3237],
  [STAT 848], [T2], [Multivariate Data Analysis], [READ], [2], [39], [78],
  [MATH 994], [T1T2], [Research Supervision (M.Sc.)], [RES], [2], [], [],
  [MATH 996], [T1T2], [Research Supervision (Ph.D.)], [RES], [1], [], [],
)
#strong[2008-2009]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 342], [T1], [Mathematical Statistics], [LEC], [19], [39], [741],
  [STAT 848], [T2], [Multivariate Data Analysis], [LEC], [6], [39], [234],
)
#strong[2007-2008]

#table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%, 7.69%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([COURSE], [TERM], [TITLE], [TYPE], [ENRL], [YIH], [YCSH],),
  table.hline(),
  [STAT 342], [T1], [Mathematical Statistics], [LEC], [7], [39], [273],
  [STAT 846], [T2], [Computational Statistics], [LEC], [5], [39], [195],
)
]
]
== 9.2 Unscheduled Instructional Activity
<unscheduled-instructional-activity>
- Creating and assessing PhD qualifying exam on Mathematical Statistics, July 2021.
- Creating and assessing PhD qualifying exam on Mathematical Statistics, May 2021.

== 9.3 Course and Program Development
<course-and-program-development>
#strong[2022-2023]

3. Renewal of the University of Saskatchewan Courses for SSC Accreditation.

2. Participated in creating new M.Sc. and Ph.D.~programs in Statistics, approved on May 18, 2023.

#strong[2020-2021]

1. Participation in creating Certificate in Statistical Methods, 2021.

== 9.4 Teaching Materials
<teaching-materials>
#strong[2025-2026]

4. STAT 442/850: a textbook entitled "Theory of Statistical Inference" in PDF ($gt.eq$ 200 pages) and HTML.

3. STAT 845: a textbook entitled "Statistical Inference and Learning Methods for Research" in PDF ($gt.eq$ 200 pages) and HTML

2. STAT 443/851: a textbook entitled "Theory of Linear Model" in PDF ($gt.eq$ 200 pages) and HTML.

#strong[2024-2025]

1. STAT 443/851: 273 pages of handwritten lecture notes were developed and posted to students.

== 9.5 Other Teaching-Related Activities
<other-teaching-related-activities>
#strong[2025-2026]

10. Peer evaluation for Matthew Schmirler, Mar.~2026.

#strong[2023-2024]

9. Data Science Bootcamp, a case study, June 19, 2023.

#strong[2022-2023]

8. Peer evaluation for Raj Srinivasan, April 2023.

7. Peer evaluation for Saima Khosa, Dec.~2022.

#strong[2021-2022]

6. Peer Teaching Evaluation for Shahedul Khan, Nov.~2021.

5. Peer Teaching Evaluation for Li Xing, Nov.~2021.

#strong[2020-2021]

4. Peer Teaching Evaluation for Shahedul Khan, STAT 812, Nov.~12, 2020.

#strong[2019-2020]

3. Peer Teaching Evaluation for Annalizer McGillvray, Nov.~29, 2019.

#strong[2017-2018]

2. Peer Teaching Evaluation for Shahedul Khan, 2017-2018.

1. Peer Teaching Evaluation for Lawrence Chang, 2017-2018.

= 10. SUPERVISION AND ADVISORY ACTIVITIES
<supervision-and-advisory-activities>
== 10.1 Undergraduate Student Supervision
<undergraduate-student-supervision>
#strong[2025-2026]

16. George Chen, B.Sc., Computer Science, Simon Fraser University, June 1, 2025 -- Aug.~31, 2025, Supervised.

15. Shruti Kaur, B.Sc., Computer Science and Statistics, May -- Aug., 2025, Supervised.

#strong[2023-2024]

14. George Chen, B.Sc., Computer Science, Simon Fraser University, May 7, 2023 -- Aug.~25, 2023, Supervised.

#strong[2022-2023]

13. Noah Little, B.Sc., Anatomy and Cell Biology, April 2022 -- Aug.~31, 2022, Supervised.

#strong[2020-2021]

12. Noah Little, B.Sc., Anatomy and Cell Biology, Aug.~2020 -- Feb.~2021, Supervised.

11. Lifang Lei, B.Sc., Mechanical Engineering, Oct.~2020 -- March 2021, Supervised.

10. Yanping Li, B.Sc., Business, Edward Business School, Feb.~2021 -- June 2021, Supervised.

9. Lina Li, B.Sc., Statistics, May 2020 -- June 2020, Summer Research Assistant, Supervised.

#strong[2019-2020]

8. Hao Hu, B.Sc., Statistics, 2019--2020, Undergraduate Thesis Supervision, Supervised.

7. Steven Liu, B.Sc., Computer Science, July 2019 -- Oct.~2020, Summer Research Assistant, Supervised.

6. Steven Liu, B.Sc., Computer Science, June 17, 2019 -- Aug.~31, 2019, Supervised.

#strong[2018-2019]

5. Jian Su, B.Sc., Computer Science, May 1, 2018 -- Aug.~31, 2018, Supervised.

#strong[2016-2017]

4. Jiaqi Xiao, B.Sc., Economics, Research Assistant, May 2016 -- Aug.~2016, Supervised.

#strong[2015-2016]

3. Jiaqi Xiao, B.Sc., Economics, May 2015 -- Aug.~2015, Supervised.

#strong[2014-2015]

2. Zhouji Zhang, B.Sc., Mathematics, June 1, 2014 -- June 30, 2014, Supervised.

#strong[2013-2014]

1. Bei Zhang, B.Sc., Statistics, May 1, 2013 -- Aug.~31, 2013, Supervised.

== 10.2 Graduate Student Supervision
<graduate-student-supervision>
26. Jing Wang, Ph.D., Biostatistics, School of Public Health, Co-supervised with Prof.~Li Xing, 2023--2026 (Transferred to other supervisor)

25. Dananji Egodage, M.Sc., Statistics, Math & Stat, Co-supervised with Prof.~Cindy Feng, 2023--2025 (Defended: Aug.~30, 2025)

24. Wuqian Effie Gao, M.Sc., Biostatistics, School of Public Health, Co-supervised with Prof.~Cindy Feng, 2022--2024 (Defended: Aug.~30, 2024)

23. Lina Li, M.Sc., Statistics, Math & Stat, MITACS Project supervisor, Supervised, 2022--2022 (Completed: August 2022)

22. Hao Hu, Ph.D., Statistics, Math & Stat, Co-supervised with Prof.~Li Xing, 2021--2022 (Transferred to M.Sc. July 2022)

21. Hao Hu, M.Sc., Statistics, Math & Stat, Co-supervised with Prof.~Li Xing, 2021--2022 (Defended: Sept.~15, 2022)

20. Man Chen, M.Sc., Statistics, Math & Stat, Supervised, 2019--2021 (Defended: April 30, 2021)

19. Wutao Yin, Ph.D., Biomedical Engineering, Co-supervised with Prof.~FangXiang Wu, 2019--2021 (Defended: Dec.~17, 2021)

18. Wutao Yin, Ph.D., Statistics, Math & Stats, Supervised, 2018--2019 (Transferred to Engineering May 2019)

17. Tingxuan Wu, Ph.D., Biostatistics, School of Public Health, Co-supervised with Prof.~Cindy Feng, 2018--2023 (Defended: May 24, 2023)

16. Tingxuan Wu, M.Sc., Biostatistics, School of Public Health, Co-supervised with Prof.~Cindy Feng, 2017--2018 (Defended: Dec.~4, 2018)

15. Mei Dong, M.Sc., Statistics, Math & Stat, Co-supervised with Prof.~Lloyd Balbuena, 2017--2019 (Defended: May 23, 2019)

14. Alireza Sadeghpour, M.Sc., Statistics, Math & Stat, Co-supervised with Prof.~Cindy Feng, 2016--2017 (Defended: Sept.~19, 2017)

13. Xiaoying Wang, M.Sc., Statistics, Math & Stat, Supervised, 2016--2019 (Defended: March 12, 2019)

12. Wei Bai, M.Sc., Statistics, Math & Stat, Co-supervised with Prof.~Cindy Feng, 2016--2018 (Defended: July 12, 2018)

11. Yunyang Wang, M.Sc., Statistics, Math & Stat, Supervised, 2014--2017 (Defended: Nov.~18, 2017)

10. Naorin Islam, M.Sc., Statistics, Math & Stat, Co-supervised with Prof.~Shahedul Khan, 2014--2017 (Defended: Nov.~28, 2017)

9. Arash Shamloo, M.MATH., Statistics, Math & Stat, Supervised, 2016--2017 (Project Completed: August 31, 2017)

8. Arash Shamloo, M.Sc., Biostatistics, School of Public Health, Supervised, 2014--2016 (Defended: 2016)

7. Setu Chandra Kar, M.Sc., Statistics, Math & Stat, Supervised, 2014--2016 (Defended: 2016)

6. Shi Qiu, M.Sc., Statistics, Math & Stat, Co-supervised with Prof.~Cindy Feng, 2012--2015 (Defended: March 26, 2015)

5. Masud Rana, M.Sc., Statistics, Math & Stats, Co-supervised with Prof.~Shahedul Khan, 2010--2012 (Defended: Sept.~2012)

4. Saima Khan Khosa, Ph.D., Statistics, Math & Stats, Supervised, 2010--2012 (Transferred to other supervisor)

3. Lai Jiang, Ph.D., Statistics, Math & Stat, Supervised, 2009--2015 (Defended: Sept.~14, 2015)

2. Lai Jiang, M.Sc., Statistics, Math & Stats, Supervised, 2008--2009 (Transferred to Ph.D.; M.Sc. supervision ended)

1. Zhengrong Li, M.Sc., Statistics, Math & Stats, Supervised, 2007--2012 (Defended: May 2012)

== 10.3 Graduate Theses Supervised
<graduate-theses-supervised>
#strong[2025-2026]

17. Dananji Egodage, 2025, Component-wise Z-residuals for Checking Bayesian Hurdle Models, M.Sc., defended on Aug.~30, 2025.

#strong[2024-2025]

16. Effie Wuqian Gao, 2024, Z-residuals for Checking Bayesian Hurdle Models, M.Sc., defended on Aug.~30, 2024.

#strong[2023-2024]

15. Tingxuan Wu, 2023, Residual Diagnostics and Statistical Inference for Shared Frailty Models, Ph.D., defended on May 24, 2023.

#strong[2022-2023]

14. Hao Hu, 2022, Identifying Risk Factors for Cognitive Decline using Statistical Learning Techniques and Functional Data Analysis, M.Sc., defended on Sept.~15, 2022.

#strong[2021-2022]

13. Wutao Yin, 2021, Artificial Intelligence Based Methods for Autism Spectrum Disorder Diagnosis from fMRI Data, Ph.D., defended on Dec.~17, 2021.

12. Man Chen, 2021, Association Between Gut Microbiome and Parkinson's Disease Revealed by Sparse Learning, M.Sc., defended on April 30, 2021.

#strong[2019-2020]

11. Dong Mei, 2019, Feature Selection Bias in Assessing the Predictivity of SNPs for Alzheimer's Disease, M.Sc., defended on May 23, 2019.

10. Xiaoying Wang, 2019, Comparison of Statistical Testing and Predictive Analysis Methods for Feature Selection in Zero-inflated Microbiome Data, M.Sc., defended on March 12, 2019.

#strong[2018-2019]

9. Tingxuan Wu, 2018, Randomized Survival Probability Residuals for Assessing Parametric Survival Models, M.Sc., defended on Dec.~4, 2018.

8. Wei Bai, 2018, Randomized Quantile Residual for Assessing Generalized Linear Mixed Models with Application to Zero-Inflated Microbiome Data, M.Sc., defended on July 12, 2018.

#strong[2016-2017]

7. Yunyang Wang, 2016, Comparison of Stochastic Volatility Models Using Integrated Information Criteria, M.Sc., defended on Nov.~18, 2016.

6. Alireza Sadeghpour, 2016, Empirical Investigation of Randomized Quantile Residuals for Diagnosis of Non-Normal Regression Models, M.Sc., defended on Sept.~19, 2016.

5. Naorin Islam, 2016, Substance Abuse and Health: A Structural Equation Modeling Approach to Assess Latent Health Effects, M.Sc., defended on Nov.~28, 2016.

#strong[2015-2016]

4. Lai Jiang, 2015, Fully Bayesian T-probit Regression with Heavy-tailed Priors for Selection in High-Dimensional Features with Grouping Structure, Ph.D., defended on Sept.~14, 2015.

#strong[2014-2015]

3. Shi Qiu, 2015, Cross-validatory Model Comparison and Divergent Regions Detection using iIS and iWAIC for Disease Mapping, M.Sc., defended on March 26, 2015.

#strong[2012-2013]

2. Masud Rana, 2012, Spatial-Longitudinal Bent-Cable Model with An Application to Atmospheric CFC Data, M.Sc., defended in Sept.~2012.

1. Zhengrong Li, 2012, A Non-MCMC Procedure for Fitting Dirichlet Process Mixture Models, M.Sc., defended in May 2012.

== 10.4 Supervision of Post-Doctoral Fellows and Research Associates
<supervision-of-post-doctoral-fellows-and-research-associates>
4. Tingxuan Wu, University of Saskatchewan, Postdoc Research Associate, Jan.~2025 -- Dec.~2026.

3. Tingxuan Wu, University of Saskatchewan, Postdoc Fellow, June 2023 -- April 2024.

2. Ming Ming Zhang, MITACS Postdoc, 2022-2025.

1. Jinhong Shi, team-supervised for CFREF projects, Sept.~2016 - Aug.~2019.

== 10.5 Staff Supervision
<staff-supervision>
- Saima Khosa, faculty mentoring, Sept.~2022- Dec.~2022.

== 10.6 Thesis Committee Memberships
<thesis-committee-memberships>
#figure([
#{set text(font: ("system-ui", "Segoe UI", "Roboto", "Helvetica", "Arial", "sans-serif", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji") , size: 9pt); table(
  columns: (5%, 25%, 10%, 20%, 30%, 10%),
  align: (center,left,center,left,left,center,),
  table.header(table.cell(align: bottom + center, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); \#], table.cell(align: bottom + left, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); NAME], table.cell(align: bottom + center, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); DEG], table.cell(align: bottom + left, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); PROGRAM], table.cell(align: bottom + left, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); TIME FRAME], table.cell(align: bottom + center, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); ROLE],),
  table.hline(),
  table.cell(align: horizon + center)[31], table.cell(align: horizon + left)[Tiansui Wu], table.cell(align: horizon + center)[M.Sc.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2025--Present], table.cell(align: horizon + center)[Chair],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[30], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Prabhawi Kahatapitiye], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Statistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2025--Present], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[29], table.cell(align: horizon + left)[Rasel Kabir], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2025--Present], table.cell(align: horizon + center)[Chair],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[28], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Mohammad Toranjsimin], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[M.Sc.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Biostatistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2023--2025 (Def. 09/2025)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[27], table.cell(align: horizon + left)[Lina Li], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2023--Present], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[26], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Kyle Gardiner], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[M.Sc.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Statistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2023--2024 (Def. 09/2024)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[25], table.cell(align: horizon + left)[Mangladeep Bhullar], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Physics], table.cell(align: horizon + left)[2023--2025 (Def. 11/2025)], table.cell(align: horizon + center)[Cognate],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[24], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Hammed Jimoh], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[M.Sc.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Statistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2022--2023], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[23], table.cell(align: horizon + left)[Qi Zhang], table.cell(align: horizon + center)[M.Sc.], table.cell(align: horizon + left)[Sociology], table.cell(align: horizon + left)[2021--2022], table.cell(align: horizon + center)[External],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[22], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Han Wang], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Sociology], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2020--Present], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Cognate],
  table.cell(align: horizon + center)[21], table.cell(align: horizon + left)[Yanzhao Cheng], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2020--2022 (Def. 10/2021)], table.cell(align: horizon + center)[Chair],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[20], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Naeima Ashleik], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Statistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2017--2018 (Def. 03/2018)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[19], table.cell(align: horizon + left)[Mehdi Rostami], table.cell(align: horizon + center)[M.Sc.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2014--2016 (Def. 06/2016)], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[18], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Sanjeev Rijal], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[M.Sc.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Statistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2014--2018 (Def. 07/2017)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[17], table.cell(align: horizon + left)[Farhad Maleki], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Bioinformatics], table.cell(align: horizon + left)[2014--2019], table.cell(align: horizon + center)[Cognate],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[16], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Saima Khan Khosa], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Statistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2014--2017], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[15], table.cell(align: horizon + left)[Yue Dong], table.cell(align: horizon + center)[M.Sc.], table.cell(align: horizon + left)[Statistics], table.cell(align: horizon + left)[2014--2016 (Def. 06/2016)], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[14], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Temitope Adesina], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[M.Sc.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Biostatistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2014--2015], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Chair],
  table.cell(align: horizon + center)[13], table.cell(align: horizon + left)[Sudhakar Achath], table.cell(align: horizon + center)[M.Sc.], table.cell(align: horizon + left)[Statistics], table.cell(align: horizon + left)[2014--2017 (Def. 05/2017)], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[12], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Xiaolei Yu], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Geography], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2012--2022 (Def. 06/2022)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Cognate],
  table.cell(align: horizon + center)[11], table.cell(align: horizon + left)[Matthew Schmirler], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Statistics], table.cell(align: horizon + left)[2012--2022 (Def. 07/2022)], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[10], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Masha Naseri], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Computer Sci.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2012--2014 (Def. 02/2014)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Cognate],
  table.cell(align: horizon + center)[9], table.cell(align: horizon + left)[Chel Hee Lee], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Statistics], table.cell(align: horizon + left)[2012--2013], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[8], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Weiwei Fan], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[M.Sc.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Bioinformatics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2012--2014 (Def. 01/2014)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[7], table.cell(align: horizon + left)[Zhaoqin Li], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Geography], table.cell(align: horizon + left)[2011--2017 (Def. 04/2017)], table.cell(align: horizon + center)[Cognate],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[6], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Courtney Kendall], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[M.Sc.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Statistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2011--2014 (Def. 08/2014)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[5], table.cell(align: horizon + left)[Michael Janzen], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Computer Sci.], table.cell(align: horizon + left)[2011--2012 (Def. 03/2012)], table.cell(align: horizon + center)[Cognate],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[4], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Matthew Schmirler], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[M.Sc.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Statistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2010--2013 (Def. 09/2012)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[3], table.cell(align: horizon + left)[Mohammed Obeidat], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Statistics], table.cell(align: horizon + left)[2010--2014 (Def. 07/2014)], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[2], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Lingling Jin], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Bioinformatics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2010--2018 (Def. 08/2017)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Cognate],
  table.cell(align: horizon + center)[1], table.cell(align: horizon + left)[Tolulope Sajobi], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2008--2012 (Def. 03/2012)], table.cell(align: horizon + center)[Member],
)}
], caption: figure.caption(
position: top, 
[
Thesis Committee Memberships
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-thesis-committee>


= 11. BOOKS AND CHAPTERS IN BOOKS
<books-and-chapters-in-books>
== 11.1 Authored Books
<authored-books>
2. Soltanifar, M., Li, L., and Rosenthal, J., 2010. A Collection of Exercises in Advanced Probability Theory - the solutions manual of all even-numbered exercises from “A First Look at Rigorous Probability Theory”, World Scientific Publishing, (Second Edition, 2006), Singapore.

1. Li, L., 2007. Bayesian Classification and Regression with High Dimensional Features. (Ph.D.~Thesis), Toronto: University of Toronto.

== 11.3 Chapters in Books
<chapters-in-books>
- Feng, C. X. and Li, L ., 2016. Modeling Zero Inflation and Overdispersion in the Length of Hospital Stay for Patients with Ischaemic Heart Disease, in the book Advanced Statistical Methods in Big-Data Sciences, edited by D. Chen, J. Chen, X. Lu, G. Yi and H. Yu, Springer, Chapter 3, pp.~35-53.

= 12. PAPERS IN REFERRED JOURNALS
<papers-in-referred-journals>
#strong[2025-2026]

33. Wu, T., Gao, WE, Feng, C., and Li, L., Z-residuals for Diagnosing Bayesian Models, #emph[Journal of American Statistical Association], under revision.

32. Wu, T., Li, L., and Feng, C., $Z$-residuals Diagnostics for Cox Proportional Hazards Models: Distinguishing Functional Form Misspecification from Nonproportional Hazards, with an Application to Biliary Cirrhosis Survival Times, #emph[Canadian Journal of Statistics], Accepted on June 5, 2026.

31. Nolan, J., Su, C., Li, L., 2025. Evaluating Railroad Duopoly Behavior: A Market Level Analysis. #emph[Review of Network Economics] 24, 87--111. #link("https://doi.org/10.1515/rne-2025-0034")

#strong[2024-2025]

30. Wu, T., Feng, C., Li, L., 2025. Cross-validatory Z-Residual for Diagnosing Shared Frailty Models. #emph[The American Statistician], 79(2), 198--211. #link("https://doi.org/10.1080/00031305.2024.2421370")

29. Wu, T., Li, L., Feng, C., 2025. Z-residual diagnostic tool for assessing covariate functional form in shared frailty models. #emph[Journal of Applied Statistics], 52(1), 28--58. #link("https://doi.org/10.1080/02664763.2024.2355551")

28. Wu, T., Feng, C., Li, L., 2024+. A Comparison of Estimation Methods for Shared Gamma Frailty Models. #emph[Statistics in Biosciences], accepted 24 June 2024. #link("https://doi.org/10.1007/s12561-024-09444-7")

#strong[2023-2024]

27. Feng, C., Li, L., Xu, C., 2023. Advancements in predicting and modeling rare event outcomes for enhanced decision-making. #emph[BMC Medical Research Methodology] 23, Article 243 (pp.~1-3). #link("https://doi.org/10.1186/s12874-023-02060-x")

#strong[2021-2022]

26. Yin, W., Li, L., Wu, F.-X., 2022. A semi-supervised autoencoder for autism disease diagnosis. #emph[Neurocomputing], 483, 140--147. #link("https://doi.org/10.1016/j.neucom.2022.02.017")

25. Cheng, H., Wang, W., Li, L., 2022. Determinants of Citizen Acceptance of White-Collar Crime in China. #emph[Journal of Asian and African Studies], 59(3), 826-843. #link("https://doi.org/10.1177/00219096221123742") (Published OnlineFirst; final pagination may vary.)

24. Yin, W., Li, L., Wu, F.-X., 2022. Corrigendum to “Deep learning for brain disorder diagnosis based on fMRI images, Neurocomputing 469 (2022) 332--345”. #emph[Neurocomputing] 509, 271. #link("https://doi.org/10.1016/j.neucom.2022.08.074")

23. Yin, W., Li, L., Wu, F.-X., 2022. Deep learning for brain disorder diagnosis based on fMRI images. #emph[Neurocomputing] 469, 332--345. #link("https://doi.org/10.1016/j.neucom.2020.05.113")

#strong[2020-2021]

22. Bai, W., Dong, M., Li, L., Feng, C., Xu, W., 2021. Randomized quantile residuals for diagnosing zero-inflated generalized linear mixed models with applications to microbiome count data. #emph[BMC Bioinformatics] 22, Article 564 (pp.~1-17). #link("https://doi.org/10.1186/s12859-021-04371-6")

21. Li, L., Wu, T., Feng, C., 2021. Model Diagnostics for Censored Regression via Randomized Survival Probabilities. #emph[Statistics in Medicine] 40(6), 1482--1497. #link("https://doi.org/10.1002/sim.8852")

20. Dagasso, G., Yan, Y., Wang, L., Li, L., Kutcher, R., Zhang, W., Jin, L., 2021. Leveraging Machine Learning to Advance Genome-Wide Association Studies. #emph[International Journal of Data Mining and Bioinformatics], 25(1/2), 17--36. #link("https://doi.org/10.1504/ijdmb.2021.116881")

#strong[2019-2020]

19. Dong, M., Li, L., Chen, M., Kusalik, A., Xu, W., 2020. Predictive analysis methods for human microbiome data with application to Parkinson's disease. #emph[PLOS ONE] 15(8), e0237779 (pp.~1-20). #link("https://doi.org/10.1371/journal.pone.0237779")

18. Feng, C., Li, L., Sadeghpour, A., 2020. A comparison of residual diagnosis tools for diagnosing regression models for count data. #emph[BMC Medical Research Methodology] 20, Article 175 (pp.~1-11). #link("https://doi.org/10.1186/s12874-020-01055-2")

17. Jiang, L., Greenwood, C.M.T., Yao, W., Li, L., 2020. Bayesian Hyper-LASSO Classification for Feature Selection with Application to Endometrial Cancer RNA-seq Data. #emph[Scientific Reports] 10, Article 9747 (pp.~1-12). #link("https://doi.org/10.1038/s41598-020-66466-z")

#strong[2018-2019]

16. Shi, J., Yan, Y., Links, M.G., Li, L., Dillon, J.-A.R., Horsch, M., Kusalik, A., 2019. Antimicrobial resistance genetic factor identification from whole-genome sequence data using deep feature selection. #emph[BMC Bioinformatics] 20, Article 535 (pp.~1-14). #link("https://doi.org/10.1186/s12859-019-3054-4")

#strong[2017-2018]

15. Essien, S. K., Feng, C., Sun, W., Farag, M., Li, L., Gao, Y., 2018. Sleep duration and sleep disturbances in association with falls among the middle-aged and older adults in China: a population-based nationwide study. #emph[BMC Geriatrics] 18, Article 196 (pp.~1-9). #link("https://doi.org/10.1186/s12877-018-0889-x")

14. Li, L., Yao, W., 2018. Fully Bayesian Logistic Regression with Hyper-Lasso Priors for High-dimensional Feature Selection. #emph[Journal of Statistical Computation and Simulation], 88(14), 2827--2851. #link("https://doi.org/10.1080/00949655.2018.1490418")

#strong[2016-2017]

13. Jin, L., McQuillan, I., Li, L., 2017. Computational Identification of Harmful Mutation Regions to the Activity of Transposable Elements. #emph[BMC Genomics] 18, Article 862 (pp.~1-10). #link("https://doi.org/10.1186/s12864-017-4227-z")

12. Li, L., Feng, C.X., Qiu, S., 2017. Estimating Cross-validatory Predictive P-values with Integrated Importance Sampling for Disease Mapping Models. #emph[Statistics in Medicine], 36(14), 2220--2236. #link("https://doi.org/10.1002/sim.7278")

11. Feng, C. X., Rostami, M., Li, L., 2017. Impact of Misspecified Residual Correlation Structure on the Parameter Estimates in a Shared Spatial Frailty Model. #emph[Journal of Statistical Computation and Simulation], 87(12), 2384--2410. #link("https://doi.org/10.1080/00949655.2017.1332196")

#strong[2015-2016]

10. Li, L., Qiu, S., Zhang, B., Feng, C.X., 2016. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC. #emph[Statistics and Computing], 26(4), 881--897. #link("https://doi.org/10.1007/s11222-015-9577-2")

#strong[2013-2014]

9. Yao, W., Li, L., 2014. A New Regression Model: Modal Linear Regression. #emph[Scandinavian Journal of Statistics], 41(3), 656--671. #link("https://doi.org/10.1111/sjos.12054")

8. Yao, W., Li, L., 2014. Bayesian Mixture Labeling by Minimizing Deviance of Classification Probabilities to Reference Labels. #emph[Journal of Statistical Computation and Simulation], 84(2), 310--323.

#strong[2011-2012]

7. Khan, S. A., Rana, M., Li, L., Dubin, J. A., 2012. A Comparative Case Study to Monitor and Understand Atmospheric CFC Decline with the Spatial-Longitudinal Bent-Cable Model. #emph[International Journal of Statistics and Probability], 1(2), 56--68.

6. Li, L., 2012. Bias-corrected Hierarchical Bayesian Classification with a Selected Subset of High-dimensional Features. #emph[Journal of American Statistical Association], 107(497), 120--134. #link("https://doi.org/10.1198/JASA.2011.AP10446")

5. Sajobi, T.T., Lix, L. M., Dansu, B. M., Laverty, W., Li, L., 2012. Robust Descriptive Discriminant Analysis for Repeated Measures Data. #emph[Computational Statistics & Data Analysis], 56(9), 2782--2794. #link("https://doi.org/10.1016/j.csda.2012.02.029")

#strong[2010-2011]

4. Sajobi, T. T., Lix, L., Li, L., Laverty, W., 2011. Discriminant Analysis for Repeated Measures Data: Effects of Mean and Covariance Misspecification on Bias and Error in Discriminant Function Coefficients. #emph[Journal of Modern Applied Statistical Methods], 10(2), 571--582. #link("https://doi.org/10.22237/jmasm/1320120840")

#strong[2009-2010]

3. Li, L., 2010. Are Bayesian Inferences Weak for Wasserman's Example? #emph[Communications in Statistics -- Simulation and Computation], 39(4), 655--667. #link("https://doi.org/10.1080/03610910903576540")

#strong[2007-2008]

2. Li, L., Zhang, J., Neal, R.M., 2008. A method for avoiding bias from features selection with application to naive Bayes classification models. #emph[Bayesian Analysis], 3(1), 171--196. #link("https://doi.org/10.1214/08-BA307")

1. Li, L., Neal, R.M., 2008. Compressing Parameters in Bayesian High-order Models with Application to Logistic Sequence Models. #emph[Bayesian Analysis], 3(4), 793--822. #link("https://doi.org/10.1214/08-BA330")

= 13. REFERRED CONFERENCE PUBLICATIONS
<referred-conference-publications>
3. Yin, W., Li, L., Wu, F.-X., 2021. A Graph Attention Neural Network for Diagnosing ASD with fMRI Data, in: 2021 IEEE International Conference on Bioinformatics and Biomedicine (BIBM). pp.~1131--1136. #link("https://doi.org/10.1109/BIBM52615.2021.9669849")

2. Dagasso, G., Yan, Y., Wang, L., Li, L., Kutcher, R., Zhang, W., Jin, L., 2020. Comprehensive-GWAS: a pipeline for genome-wide association studies utilizing cross-validation to assess the predictivity of genetic variations, in: 2020 IEEE International Conference on Bioinformatics and Biomedicine (BIBM). Presented at the 2020 IEEE International Conference on Bioinformatics and Biomedicine (BIBM), pp.~1361--1367. #link("https://doi.org/10.1109/BIBM49941.2020.9313355")

1. Jin, L., McQuillan, I., and Li, L., 2016, Computational Identification of Regions that Influence Activity of Transposable Elements in the Human Genome. Proceeding of 2016 IEEE International Conference on Bioinformatics and Biomedicine, pp.~592-599.

= 14. PRESENTATIONS
<presentations>
== 14.1 Invited Presentations
<invited-presentations>
#strong[2025-2026]

33. Z-residuals for Checking Bayesian Models. Presented at: University of Calgary, Calgary, AB, Canada; July 28, 2025

32. Sparse Learning for Assessing the Association Between Gut Microbiome and Parkinson's Disease. Presented at: The 3rd JCSDS, Hangzhou, China, July 13, 2025.

#strong[2024-2025]

31. Z-residuals for Checking Bayesian Models. Presented at: International Conference on Statistics and Data Science, Vancouver, BC, Canada; June 24, 2025

30. Z-residuals for Checking Bayesian Hurdle Models. Presented at: EcoStat 2024; July 17, 2024; Beijing, China.

#strong[2023-2024]

29. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, ICSA Canada Chapter Symp., June 9, 2024, Niagara Falls, Canada

28. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, Annual Meeting of SSC, St John's, Canada, June 2, 2024

27. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, Dept. Seminar, Texas State University, USA, March 8, 2024

26. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, Dept. Seminar, Sun Yat-sen University, China, Jan.~4, 2024

#strong[2022-2023]

25. Cross-validatory Residual Diagnostics for Bayesian Spatial Models, Annual Meeting of SSC, Ottawa, May 29, 2023

24. Model Diagnostics for Censored Regression via Randomized Survival Probabilities, the 5th ICSA Canada Symposium, 9 July 2022, Banff, AB, Canada

23. Model Diagnostics for Censored Regression via Randomized Survival Probabilities, 17 Aug.~2022, Statistics Conference in Genomics, Pharmaceutical Science, and Health Data Science, University of Victoria, Victoria, BC, Canada

#strong[2021-2022]

22. Randomized quantile residuals for diagnosing zero-inflated generalized linear mixed models with applications to microbiome count data, SSC Annual Meeting (virtual), May 2022.

21. Model Diagnostics for Censored Regression via Randomized Survival Probabilities, The 6th Canadian Conference in Applied Statistics, Hosted by Concordia University (virtual), 16 July 2021.

#strong[2019-2020]

20. Estimating Cross-validatory Predictive P-values with Integrated Importance Sampling for Disease Mapping Models, Aug.~2019, the 4th ICSA-Canada Symposium held at Queen's University.

#strong[2018-2019]

19. Feature Selection Bias in Assessing the Predictivity of SNPs for Alzheimer's Disease, June 2019, Seminar talk, University of Manitoba, Canada

#strong[2017-2018]

18. Randomized Quantile Residuals for Checking GLMM with Application to Zero-inflated Microbiome Data, June 2018, Annual Meeting of Statistical Society of Canada, McGill University, Canada.

17. Fully Bayesian Classification with Heavy-tailed Priors for Selection in High-Dimensional Features with Grouping Structure, Aug.~2017, the 3rd ICSA-Canada Symposium held at Vancouver.

#strong[2016-2017]

16. Randomized Quantile Residuals: an Omnibus Model Diagnostic Tool with Unified Reference Distribution, June 2017, Seminar talk, School of Mathematical Sciences, Xiamen University, China.

15. Fully Bayesian Classification with Heavy-tailed Priors for Selection in High-Dimensional Features with Grouping Structure, June 2017, Seminar talk, School of Mathematical Sciences, Xiamen University, China.

14. Randomized Quantile Residuals: an Omnibus Model Diagnostic Tool with Unified Reference Distribution, June 2017, Seminar talk, Department of Biostatistics, Southern Medical University, Guangzhou, China.

13. Estimating Cross-validatory Predictive P-values with Integrated Importance Sampling for Disease Mapping Models, June 2017, Annual Meeting of Statistical Society of Canada, University of Manitoba, Canada.

12. Fully Bayesian Classification with Heavy-tailed Priors for Selection in High-Dimensional Features with Grouping Structure, Dec., 2016, Wuhan University, China.

#strong[2015-2016]

11. Cross-validatory Model Comparison and Divergent Regions Detection using iIS for Disease Mapping, Seminar of Dept of Math & Stat, University of Calgary, April 2016, Calgary, AB.

10. Cross-validatory Model Comparison and Divergent Regions Detection using iIS for Disease Mapping, Seminar of Dept of Math & Stat, University of Alberta, Edmonton, AB.

9. Cross-validatory Model Comparison and Divergent Regions Detection using iIS for Disease Mapping, Seminar of Department of Statistics, University of Manitoba, Jan.~2016, Winnipeg, MB.

8. Bias-corrected Hierarchical Bayesian Classification with a Selected Subset of High-dimensional Features, ICSA Canada Chapter Annual Meeting, University of Calgary, Aug.~2015, Calgary, AB.

#strong[2014-2015]

7. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC, Dec.~2014, Tongji University, Shanghai, China.

6. An Introduction to Microarray Data. Workshop on “Statistical Issues in Biomarker and Drug Co-development”, Nov.~2014, Fields Institute, Toronto, ON, Canada.

#strong[2013-2014]

5. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC. Statistics Seminar, April, Kansas State University, Manhattan, Kansas, USA.

#strong[2011-2012]

4. High-dimensional Feature Selection Using Hierarchical Bayesian Logistic Regression with Heavy-tailed Priors. CRM-ISM-GERAD Colloque de Statistique, April, McGill University, Montreal, Quebec, Canada.

#strong[2010-2011]

3. High-dimensional Classification using Hierarchical Bayesian Polychotomous Logistic Regression Models. Colloquia talk, Jan., The University of Western Ontario, London, ON, Canada.

2. High-dimensional Classification using Hierarchical Bayesian Polychotomous Logistic Regression Models. Colloquia talk, Sept., Penn State University, University Park, PA, USA.

#strong[2007-2008]

1. Avoiding Bias from Feature Selection. CRISM 'workshop on Bayesian Analysis of High-dimensional Data, April, University of Warwick, Coventry, UK.

== 14.2 Contributed Presentations
<contributed-presentations>
#strong[2013-2014]

10. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC. Annual Meeting of Statistical Society of Canada, May 27, 2014, Toronto, ON, Canada.

#strong[2010-2011]

9. High-dimensional Classification using Hierarchical Bayesian Polychotomous Logistic Regression Models. The 8th ICSA International Conference, Dec.~20, 2010, Guangzhou, China.

#strong[2009-2010]

8. Sajobi, T., Lix, L., Laverty, W., and Li, L., 2010. Discriminant Analysis for Repeated Measures Data: Effects of Covariance Structure on Bias and Error in Discriminant Function Coefficients. Annual Meeting of Statistical Society of Canada, May 24, 2010, Quebec City, QC, Canada.

7. Are Bayesian Inferences Weak for Wasserman's Example? Annual Meeting of Statistical Society of Canada, May 25, 2010, Quebec City, QC, Canada.

#strong[2008-2009]

6. Calibrating Predictions Based on a Selected Subset of Features from Bayesian Gaussian Classification Models. Annual meeting of Statistical Society of Canada, January, Vancouver, BC, Canada.

5. Calibrating Predictions Based on a Selected Subset of Features from Bayesian Gaussian Classification Models. Bayesian Biostatistics Conference, January, Houston, TX, USA.

#strong[2007-2008]

4. Compressing Parameters in Bayesian High-order Models. Annual Meeting of Statistical Society of Canada, May, Ottawa, ON, Canada.

#strong[2006-2007]

3. Compressing Parameters in Bayesian Models with High-order Interactions. The 3rd Monte Carlo Workshop, Harvard University, May, Cambridge, MA, USA.

#strong[2005-2006]

2. Avoiding Bias from Feature Selection in Regression and Classification Models. Joint Statistical Meeting, August, Seattle, WA, USA.

1. Analysis of Obstructive Sleep Apnea Data with Bayesian Neural Network. Annual Meeting of Statistical Society of Canada, June, London, ON, Canada.

= 15. REPORTS AND OTHER OUTPUTS
<reports-and-other-outputs>
== 15.1 Software Released Publicly
<software-released-publicly>
11. Wu, T. and Li, L., 2026. #NormalTok("Zresidual");: Computing and Diagnosing Gaussian-like Residuals. #link("https://tiw150.github.io/Zresidual/index.html")[\[Github\]] #link("https://tiw150.github.io/Zresidual_demo.html")[\[Demo\]]. Version 0.1-0 on Github (2026).

10. Li, L., 2026. R Functions for Computing Z-residuals for #NormalTok("survreg"); and #NormalTok("coxph"); Objects. #link("https://longhaisk.github.io/software/NRSP/index.html")[\[URL\]].

9. Li, L., et al., 2021. Real-time estimates of $R_t$ for Covid-19 in Canada. #link("https://longhaisk.github.io/CanadaCovidRt/")[\[URL\]].

8. Li, L. and Liu, S., 2019--2026. #NormalTok("HTLR");: Bayesian Logistic Regression with Hyper-LASSO priors. DOI: 10.32614/CRAN.package.HTLR. #link("https://cran.r-project.org/web/packages/HTLR/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/HTLR")[\[Github\]] #link("https://longhaisk.github.io/software/BLRHL/index.html")[\[URL\]]. Version 0.4 (2019), version 0.4-1 (2019), version 0.4-2 (2020), version 0.4-3 (2020), version 0.4-4 (2022), version 1.0 (2026).

7. Li, L., 2011--2026. #NormalTok("BCBCSF");: Bias-corrected Bayesian Classification with Selected Features. DOI: 10.32614/CRAN.package.BCBCSF. #link("https://cran.r-project.org/web/packages/BCBCSF/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/software/BCBCSF/index.html")[\[URL\]]. Version 0.0-0 (2011), version 0.0-1 (2011), version 0.0-2 (2012), version 1.0-0 (2013), version 1.0-1 (2015), updated to version 1.0-2 (2026).

6. Li, L., 2018. #NormalTok("HTLR");: Bayesian Logistic Regression with Hyper-LASSO priors. #link("https://longhaisk.github.io/software/BLRHL/index.html")[\[URL\]]. Pre-CRAN version (2018).

5. Li, L., 2016. #NormalTok("iIS");: R code for computing predictive p-values in disease mapping models. #link("https://longhaisk.github.io/software/dmpvalues/dmpvalues-larynx.R")[\[URL\]].

4. Li, L., 2008. #NormalTok("gibbs.met");: Naive Gibbs Sampling with Metropolis Steps. #link("https://cran.r-project.org/web/packages/gibbs.met/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/software/gibbs.met/release.html")[\[URL\]].

3. Li, L., 2008. #NormalTok("BPHO");: Bayesian Prediction with High-order Interactions. #link("https://cran.r-project.org/web/packages/BPHO/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/software/BPHO/release.html")[\[URL\]].

2. Li, L., 2007. #NormalTok("predmixcor");: Classification rule based on Bayesian mixture models with feature selection bias corrected. #link("https://cran.r-project.org/web/packages/predmixcor/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/software/predmixcor/release.html")[\[URL\]].

1. Li, L., 2007. #NormalTok("predbayescor");: Classification Rule Based on Bayesian Naive Bayes Models with Features Selection Bias Corrected. #link("https://cran.r-project.org/web/packages/predbayescor/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/software/predbayescor/release.html")[\[URL\]].

== 15.2 Technical Reports
<technical-reports>
12. Wu, T., Feng, C. and Li, L., 2023. Cross-validatory Z-Residual for Diagnosing Shared Frailty Models. #link("https://doi.org/10.48550/arXiv.2303.09616"). 32 pages, 14 figures.

11. Wu, T., Li, L. and Feng, C., 2023. Z-residual diagnostics for detecting misspecification of the functional form of covariates for shared frailty models. #link("https://doi.org/10.48550/arXiv.2302.09106"). 21 pages, 7 figures.

10. Li, L., Wu, T. and Feng, C., 2019. Model diagnostics for censored regression via randomized survival probabilities. #link("https://doi.org/10.48550/arXiv.1911.00198"). 12 pages. (Journal-ref: Statistics in Medicine, 2021, 40(6), 1482-1497).

9. Feng, C., Sadeghpour, A. and Li, L., 2017. Randomized Predictive P-values: A Versatile Model Diagnostic Tool with Unified Reference Distribution. #link("https://doi.org/10.48550/arXiv.1708.08527"). 26 pages. (Journal-ref: BMC Medical Research Methodology, 2020, 20(175)).

8. Jiang, L., Li, L. and Yao, W., 2016. Fully Bayesian Classification with Heavy-tailed Priors for Selection in High-dimensional Features with Grouping Structure. #link("https://doi.org/10.48550/arXiv.1607.00098"). 31 pages. (Journal-ref: Sci Rep, 2020, 10(9747)).

7. Li, L., Feng, C.X. and Qiu, S., 2016. Estimating Cross-validatory Predictive P-values with Integrated Importance Sampling for Disease Mapping Models. #link("https://doi.org/10.48550/arXiv.1603.07668"). 18 pages. (Journal-ref: Statistics in Medicine, 2017, 36(14), 2220-2236).

6. Li, L. and Yao, W., 2014. Fully Bayesian Logistic Regression with Hyper-Lasso Priors for High-dimensional Feature Selection. #link("https://doi.org/10.48550/arXiv.1405.3319"). 33 pages. (Journal-ref: Journal of Statistical Computation and Simulation, 2018, 88(14), 2827-2851).

5. Li, L., Qiu, S., Zhang, B. and Feng, C.X., 2014. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC. #link("https://doi.org/10.48550/arXiv.1404.2918"). 38 pages. (Journal-ref: Statistics and Computing, 2016, 26(4), 881-897).

4. Li, L. and Yao, W., 2013. High-dimensional Feature Selection Using Hierarchical Bayesian Logistic Regression with Heavy-tailed Priors. #link("https://doi.org/10.48550/arXiv.1308.4690"). (Earlier version of arXiv:1405.3319).

3. Li, L. and Neal, R.M., 2007. A Method for Compressing Parameters in Bayesian Models with Application to Logistic Sequence Prediction Models. #link("https://doi.org/10.48550/arXiv.0711.4983"). 29 pages. (Journal-ref: Bayesian Analysis, 2008, 3(4), 793-822).

2. Li, L., 2007. Bayesian Classification and Regression with High Dimensional Features. #link("https://doi.org/10.48550/arXiv.0709.2936"). PhD Thesis Submitted to University of Toronto, 129 pages.

1. Li, L., Zhang, J. and Neal, R.M., 2007. A method for avoiding bias from features selection with application to naive Bayes classification models. Technical Report No 0705, Department of Statistics, University of Toronto.

= 17. RESEARCH FUNDING HISTORY
<research-funding-history>
#strong[2025-2026]

17. #strong[NSERC Individual Discovery Grant (No.~2026-07053)] -- #emph[Prediction-based Methods for Statistical Learning and Inference in Biosciences and Epidemiology], \$185,000 (37K per year), 2026-2031, PI.

16. #strong[CANSSI Collaborative Research Team Projects] -- #emph[Statistical Methodologies and Computational Tools to Identify Microbial Correlates of Canadian Bee Gut Health], Project 29, 2025-2028, Co-PI.

#strong[2021-2022]

15. #strong[MITACS Accelerate Grant] -- #emph[Geospatial Artificial Intelligence Algorithms for Automating Manual Observation Associated with Wheat Production], \$280,000, 2021-2025, PI.

#strong[2020-2021]

14. #strong[MITACS Accelerate Grant] -- #emph[Develop a web based geospatial artificial intelligence framework to track, visualize, analyze, model, and predict infectious disease spread in real-time], \$105,000, 2020-2021, PI.

#strong[2019-2020]

13. #strong[NSERC Individual Discovery Grant] -- #emph[Predictive Methods for Analyzing High-throughput and Spatial-temporal Data], \$140,000 (20K per year), 2019-2026, PI.

#strong[2017-2018]

12. #strong[The Western Canadian Universities Collaborative Project Seed Funding] -- #emph[Genome-wide diet-gene interaction analysis for risk of psychiatric comorbidity in inflammatory bowel disease], \$20,000, 2017-2019, Co-PI.

#strong[2016-2017]

11. #strong[Canada First Research Excellence Fund (CFREF)] - #emph[Designing Crops for Global Food Security, Genotype & Environment to Phenotype], \$756,918, 2016-2019, Co-PI.

10. #strong[MITACS Accelerate Internship] -- #emph[Applications of Neural Network Curve Fitting Methods for Least-squares Monte Carlo Simulations in Financial Risk Management], \$15,000, 2016, PI.

#strong[2014-2015]

9. #strong[NSERC Individual Discovery Grant] -- #emph[Bayesian Methods for High-Dimensional and Correlated Data], \$70,000, 2014-2019, PI.

#strong[2011-2012]

8. #strong[NSERC Individual Discovery Grant ECR Supplement] -- #emph[Efficient Bayesian Analysis for Complex Models], \$5,000/year, 2011-2014, PI.

#strong[2009-2010]

7. #strong[NSERC Individual Discovery Grant] -- #emph[Efficient Bayesian Analysis for Complex Models], \$80,000, 2009-2014, PI.

6. #strong[CFI Leaders Opportunity Funds] -- #emph[A Computer Cluster for Research on Efficient Bayesian Statistical Methods], \$160,000, 2009, PI.

#strong[2008-2009]

5. #strong[MITACS Accelerate Internship] -- #emph[Clustering Analysis for Detecting the Types of Vehicles], \$15,000, 2008, Co-PI.

4. #strong[University of Saskatchewan President's Award], \$5,000, 2008, PI.

3. #strong[College of Graduate Studies and Research at the University of Saskatchewan Award], \$15,000, 2008, PI.

2. #strong[College of Arts and Science at the University of Saskatchewan -- Supplemental start-up operating grant], \$15,000, 2008, PI.

#strong[2007-2008]

1. #strong[University of Saskatchewan -- Start-up operating grant], \$5,000, 2007, PI.

= 18. PRACTICE OF PROFESSIONAL SKILLS
<practice-of-professional-skills>
#strong[2025-2026]

68. Refereeing for #emph[Journal of Statistical Computation and Simulation], June, 2026

67. Refereeing for #emph[Journal of Statistical Computation and Simulation], April, 2026

66. Refereeing for #emph[Journal of the Royal Statistical Society: Series C], April 2026

65. Refereeing for #emph[Bioinformatics], March 2026

64. Refereeing for #emph[Journal of Computational and Graphical Statistics], March 2026

63. External Referee for a tenure and promotion of SFU, Dec.~2025

62. External Examiner for the doctoral thesis by Xiaoqing Zhang at University of Regina, Dec.~8, 2025

61. Refereeing for #emph[Journal of Statistical Computation and Simulation], Dec.~2025

60. Refereeing for #emph[Journal of Computational and Graphical Statistics], Sept.~2025

59. External Examiner for the doctoral thesis by Na Zhang at University of Alberta, August 28, 2025

58. Refereeing for #emph[Journal of the Royal Statistical Society: Series C], August 2025

57. Refereeing for #emph[Journal of Applied Statistics], August 2025

#strong[2024-2025]

56. Organizing an invited Session for the 7th Symposium of ICSA Canada Chapter, McGill University, August 2026

55. Organizing an invited Session for 2025 SSC Annual Meeting, Saskatoon, SK, Canada, June 2025

#strong[2023-2024]

54. External Examiner for the doctoral thesis by Yuping Yang at SFU, June 25, 2024

53. Refereeing for #emph[Journal of Computational and Graphical Statistics], Sept.~2024

52. Refereeing for #emph[Journal of Applied Statistics], Jan.~2024

51. Review an MITACS Accelerate Grant, Dec.~2023

#strong[2022-2023]

50. Refereeing for #emph[Statistical Methods in Medical Research], April 2023

49. Refereeing for #emph[Statistical Methods in Medical Research], Jan.~2023

48. Refereeing for #emph[Journal of Computational and Graphical Statistics], Jan.~2023

47. Refereeing for #emph[Statistical Methods in Medical Research], Aug.~2022

46. External Examiner for the M.Sc. thesis by Xiangling Ji, University of Victoria, 27 July 2022

45. Refereeing for #emph[Canadian Journal of Statistics], July 2022

#strong[2021-2022]

44. Organizer of an invited session for ICSA Canada Symposium 2022, Banff, AB, Canada, July 2022

43. External Examiner for one NSERC IDG application

42. External Examiner for another NSERC IDG application

41. External Examiner for one MITACS Accelerate grant application

40. Reviewer for a Canada Research Chair Position

39. External M.Sc. Thesis Examiner for Zhongyuan Zhang, University of Toronto

38. Refereeing for #emph[Statistical Methods in Medical Research]

37. Refereeing for #emph[Journal of Statistical Computation and Simulation]

36. Refereeing for #emph[BMC Cancer]

35. Refereeing for #emph[Journal of Computational and Graphical Statistics]

34. Refereeing for #emph[Canadian Journal of Statistics]

33. Refereeing for #emph[IEEE Transactions on Neural Networks and Learning Systems]

#strong[2020-2021]

32. Grant refereeing for an application to MITACS Accelerate, May 2021

31. External Examination for a PhD thesis of University of Montreal, May 2021

30. Grant refereeing for an application to NSERC IDG, Jan.~2021

29. Refereeing for #emph[Statistics in Medicine]

28. Refereeing for #emph[Computational Statistics and Data Analysis]

27. Refereeing for #emph[Frontiers in Genetics]

26. Refereeing for #emph[Statistical Methods for Medical Research]

25. Refereeing for #emph[Journal of Statistical Computation and Simulation]

24. Refereeing for #emph[BMC Cancer]

#strong[2019-2020]

23. External doctoral thesis examiner for Shijia Wang, Simon Fraser University

22. External doctoral thesis examiner for Kexin Luo, Western University

21. Grant Refereeing for an application to MITACS

20. Grant Refereeing for an application to NSERC IDG

19. Refereeing for #emph[Computational Statistics and Data Analysis]

18. Refereeing for #emph[Frontiers in Genetics]

17. Refereeing for #emph[Communications in Statistics - Simulation and Computation]

#strong[2017-2018]

16. Referee a NSERC discovery grant application

15. Refereeing for #emph[Canadian Journal of Statistics]

14. Refereeing for #emph[Journal of Royal Statistical Society (C)]

#strong[2016-2017]

13. Referee two applications for MITACS Accelerate Grant

12. Refereeing for #emph[Statistics in Medicine]

11. Refereeing for #emph[Statistics and Computing]

10. Refereeing for #emph[PLOS ONE]

#strong[2015-2016]

9. Organizer, Invited session “Recent Advances in Statistical Inference Methods in Regression Models for Complex and Big Data”, China Statistics Conference, June 2016, Qingdao, China

8. Refereeing application for NSERC individual discovery grant (2015)

#strong[2013-2014]

7. Reviewing and revision services for an SHRF Establishment Grant application (Prof.~Kelly Penz), funded 2013

6. Refereeing for #emph[Biometrika]

5. Refereeing for #emph[Statistics In Medicine]

4. Refereeing for #emph[Statistical Papers]

3. Refereeing for #emph[Computational Statistics]

2. Refereeing for #emph[Statistica Sinica]

#strong[2011-2012]

1. Refereeing application for NSERC individual discovery grant (2011)

= 19. ADMINISTRATIVE SERVICE
<administrative-service>
== 19.1 University Committees
<university-committees>
#strong[2025-2026]

10. Chair, Collaborative Biostatistics Program, University of Saskatchewan.

9. USASK NSERC Discovery Grant (DG), Internal Reviewer.

#strong[2020-2021]

8. USASK NSERC Discovery Grant (DG), Internal Reviewer.

#strong[2019-2020]

7. Chair, Collaborative Biostatistics Program, University of Saskatchewan.

#strong[2018-2019]

6. Member, Academic Programming Committee, University of Saskatchewan.

#strong[2017-2018]

5. Member, Academic Programming Committee, University of Saskatchewan.

#strong[2016-2017]

4. Member, Academic Programming Committee, University of Saskatchewan.

3. Member, University of Saskatchewan Bioinformatics Program Committee.

#strong[2015-2016]

2. Member, University of Saskatchewan Bioinformatics Program Committee.

#strong[2013-2014]

1. Dean's Designate for the Ph.D.~Defense of Rui Zhang, Department of Veterinary Microbiology, June 12, 2014.

== 19.2 College and Departmental Committees
<college-and-departmental-committees>
#strong[2025-2026]

45. Member, Budgeting and Planning Committee, Dept of Math & Stat

44. Co-Chair, Undergraduate Committee (Statistics), Dept of Math & Stat

43. Member, Graduate Program Committee in Statistics, Dept of Math & Stat

#strong[2024-2025]

42. Member, Graduate Program Committee in Statistics, Dept of Math & Stat

41. Search subcommittee for a faculty position in statistics

#strong[2023-2024]

40. Member, Graduate Program Committee in Statistics, Dept of Math & Stat

39. Member, Sub Search Committee, 4-Year Lecturer Position

#strong[2022-2023]

38. Statistics Advisor (credit transferring for the whole university)

37. Member, Department Promotion (Associate) Committee (1-Case), Dept of Math & Stat

36. Member, Department Renewals and Tenure Committee (1-Case: Tenure), Dept of Math & Stat

35. Member, Department Promotion (Full) Committee (1-Case), Dept of Math & Stat

#strong[2021-2022]

34. Statistics Advisor (credit transferring for the whole university)

33. Member, Department Renewals and Tenure Committee (1-Case), Dept of Math & Stat

32. Member, Department Promotion (Full) Committee (1-Case), Dept of Math & Stat

31. Search subcommittee for a 4-year term lecturer position (two rounds of searching, Jan 2022--June 2022)

#strong[2019-2020]

30. Member, Tenure Committee (1 case), Dept of Math & Stat

29. Member, Promotion Committee (1 case), Dept of Math & Stat

28. Member, Renewal of Probation Committee (1 case), Dept of Math & Stat

27. Member, Graduate Committee, Dept of Math & Stat

26. Organizer, Team discussion towards renovating undergraduate statistics program, Dept of Math & Stat

#strong[2018-2019]

25. Committee Member, Data Science Boot Camp, University of Saskatchewan (June 10--21, 2019)

24. Member, Curriculum Renewal Committee, Dept of Math & Stat, Term 1

23. Member, Undergraduate Committee, Dept of Math & Stat, Term 1

#strong[2017-2018]

22. Member, Salary Review Committee, Dept of Math & Stat, University of Saskatchewan

21. Member, Search Committee, Dept of Math & Stat, University of Saskatchewan

#strong[2016-2017]

20. Member, Sub Search Committee for a joint position in \`\`data science/big data'', College of Arts and Science, University of Saskatchewan.

19. Member, Graduate Committee, Dept of Math & Stat

18. Member, Sub Search Committee, APA position, Dept of Math & Stat, University of Saskatchewan

17. Member, Sub Search Committee, 4 lecturer positions, Dept of Math & Stat, University of Saskatchewan

16. Organizer, Statistics and Probability Alumni Networking Day (Nov.~2016)

15. Organizer, Qualifying Exams for Trisha Lawrence (Nov.~2016)

#strong[2015-2016]

14. Member, Graduate Committee, Dept of Math & Stat

13. Organizer, Student Seminar Day, Dept of Math & Stat (May 2016)

12. Team leader, submission of U of S courses for accreditation by the Statistical Society of Canada (May 2016)

11. Organizer, Qualifying Exams for Trisha Lawrence (May 2016)

#strong[2014-2015]

10. Member, Academic Program Committee, College of Arts and Science.

9. Member, Graduate Committee, Dept of Math & Stat

8. Organizer, Seminar Series, Dept of Math & Stat

#strong[2012-2013]

7. Member, Curriculum Renewal Committee, Dept of Math & Stat

6. Member, Budget Planning Committee, Dept of Math & Stat

5. Member, Colloquium Committee, Dept of Math & Stat

#strong[2011-2012]

4. Member, Salary Review Committee, Dept of Math & Stat, University of Saskatchewan

3. Organizer, Seminar Series, Dept of Math & Stat

2. Member, Colloquium Committee, Dept of Math & Stat

#strong[2009-2010]

1. Member, Sub Search Committee, Dept of Math & Stat

= 20. PROFESSIONAL OR ASSOCIATION OFFICES AND COMMITTEE ACTIVITY
<professional-or-association-offices-and-committee-activity>
#strong[2024-2025]

9. Member of NSERC Discovery Grant EG 1508 Committee

8. Local Organizing Committee, 2025 Annual Meeting of the Statistical Society of Canada held at the U of S

#strong[2023-2024]

7. Member of NSERC Discovery Grant EG 1508 Committee

#strong[2022-2023]

6. Member of NSERC Discovery Grant EG 1508 Committee

5. Co-editor for a special issue "Prediction Methods for Rare Diseases or Outcomes" in the journal #emph[BMC Medical Research Methodology]

#strong[2021-2022]

4. Member, CANSSI-SK Health Research Collaborating Center. Participate Substantially in organizing a semester-long seminar series

#strong[2019-2020]

3. Program Committee Member for the 4th ICSA-Canada Symposium, Queens University (Aug.~2019)

#strong[2017-2018]

2. Co-chair of the scientific program, the 3rd ICSA Canada Chapter Symposium held in Vancouver (Aug.~2017)

#strong[2016-2017]

1. Judge for case study competition, Annual Meeting of Statistical Society of Canada (June 2017)
