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
  fontsize: 11pt,
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)

#align(right)[#text(size: 14pt, weight: "bold")[Form 1]]
#v(1em)
#grid(
  columns: (1fr, 1fr),
  row-gutter: 1em,
  [*Name:* #underline[Longhai Li]], [*Date:* #underline[June 30, 2026]],
  [*College:* #underline[Arts & Science]], [*Department:* #underline[Mathematics & Statistics]]
)
#v(0.5em)
#line(length: 100%)
#v(1em)
#align(center)[
  #strong[
    INFORMATION FOR UPDATE OF CURRICULUM VITAE -- NEW ITEMS \
    (ITEMS NOT PREVIOUSLY REPORTED) \
    The cut off date for items to be reported is JUNE 30.
  ]
]
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

1. Peer evaluation for Matthew Schmirler, Mar.~2026.

= 10. SUPERVISION AND ADVISORY ACTIVITIES
<supervision-and-advisory-activities>
== 10.1 Undergraduate Student Supervision
<undergraduate-student-supervision>
#strong[2025-2026]

2. George Chen, B.Sc., Computer Science, Simon Fraser University, June 1, 2025 -- Aug.~31, 2025, Supervised.

1. Shruti Kaur, B.Sc., Computer Science and Statistics, May -- Aug., 2025, Supervised.

== 10.2 Graduate Student Supervision
<graduate-student-supervision>
2. Jing Wang, Ph.D., Biostatistics, School of Public Health, Co-supervised with Prof.~Li Xing, 2023--2026 (Transferred to other supervisor)

1. Dananji Egodage, M.Sc., Statistics, Math & Stat, Co-supervised with Prof.~Cindy Feng, 2023--2025 (Defended: Aug.~30, 2025)

== 10.3 Graduate Theses Supervised
<graduate-theses-supervised>
#strong[2025-2026]

2. Dananji Egodage, 2025, Component-wise Z-residuals for Checking Bayesian Hurdle Models, M.Sc., defended on Aug.~30, 2025.

#strong[2024-2025]

1. Effie Wuqian Gao, 2024, Z-residuals for Checking Bayesian Hurdle Models, M.Sc., defended on Aug.~30, 2024.

== 10.4 Supervision of Post-Doctoral Fellows and Research Associates
<supervision-of-post-doctoral-fellows-and-research-associates>
2. Tingxuan Wu, University of Saskatchewan, Postdoc Research Associate, Jan.~2025 -- Dec.~2026.

1. Ming Ming Zhang, MITACS Postdoc, 2022-2025.

== 10.6 Thesis Committee Memberships
<thesis-committee-memberships>
#figure([
#{set text(font: ("system-ui", "Segoe UI", "Roboto", "Helvetica", "Arial", "sans-serif", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji") , size: 9pt); table(
  columns: (19.23%, 7.69%, 42.31%, 7.69%, 7.69%, 7.69%),
  align: (center,left,center,left,left,center,),
  table.header(table.cell(align: bottom + center, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); \#], table.cell(align: bottom + left, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); NAME], table.cell(align: bottom + center, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); DEG], table.cell(align: bottom + left, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); PROGRAM], table.cell(align: bottom + left, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); TIME FRAME], table.cell(align: bottom + center, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); ROLE],),
  table.hline(),
  table.cell(align: horizon + center)[31], table.cell(align: horizon + left)[Tiansui Wu], table.cell(align: horizon + center)[M.Sc.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2025--Present], table.cell(align: horizon + center)[Chair],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[30], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Prabhawi Kahatapitiye], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Statistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2025--Present], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[29], table.cell(align: horizon + left)[Rasel Kabir], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2025--Present], table.cell(align: horizon + center)[Chair],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[28], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Mohammad Toranjsimin], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[M.Sc.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Biostatistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2023--2025 (Def. 09/2025)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[27], table.cell(align: horizon + left)[Lina Li], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2023--Present], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[25], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Mangladeep Bhullar], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Physics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2023--2025 (Def. 11/2025)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Cognate],
  table.cell(align: horizon + center)[22], table.cell(align: horizon + left)[Han Wang], table.cell(align: horizon + center)[Ph.D.], table.cell(align: horizon + left)[Sociology], table.cell(align: horizon + left)[2020--Present], table.cell(align: horizon + center)[Cognate],
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


= 12. PAPERS IN REFERRED JOURNALS
<papers-in-referred-journals>
#strong[2025-2026]

6. Wu, T., Gao, WE, Feng, C., and Li, L., Z-residuals for Diagnosing Bayesian Models, #emph[Journal of American Statistical Association], under revision.

5. Wu, T., Li, L., and Feng, C., $Z$-residuals Diagnostics for Cox Proportional Hazards Models: Distinguishing Functional Form Misspecification from Nonproportional Hazards, with an Application to Biliary Cirrhosis Survival Times, #emph[Canadian Journal of Statistics], Accepted on June 5, 2026.

4. Nolan, J., Su, C., Li, L., 2025. Evaluating Railroad Duopoly Behavior: A Market Level Analysis. #emph[Review of Network Economics] 24, 87--111. #link("https://doi.org/10.1515/rne-2025-0034")

#strong[2024-2025]

3. Wu, T., Feng, C., Li, L., 2025. Cross-validatory Z-Residual for Diagnosing Shared Frailty Models. #emph[The American Statistician], 79(2), 198--211. #link("https://doi.org/10.1080/00031305.2024.2421370")

2. Wu, T., Li, L., Feng, C., 2025. Z-residual diagnostic tool for assessing covariate functional form in shared frailty models. #emph[Journal of Applied Statistics], 52(1), 28--58. #link("https://doi.org/10.1080/02664763.2024.2355551")

1. Wu, T., Feng, C., Li, L., 2024+. A Comparison of Estimation Methods for Shared Gamma Frailty Models. #emph[Statistics in Biosciences], accepted 24 June 2024. #link("https://doi.org/10.1007/s12561-024-09444-7")

= 14. PRESENTATIONS
<presentations>
== 14.1 Invited Presentations
<invited-presentations>
#strong[2025-2026]

4. Z-residuals for Checking Bayesian Models. Presented at: University of Calgary, Calgary, AB, Canada; July 28, 2025

3. Sparse Learning for Assessing the Association Between Gut Microbiome and Parkinson's Disease. Presented at: The 3rd JCSDS, Hangzhou, China, July 13, 2025.

#strong[2024-2025]

2. Z-residuals for Checking Bayesian Models. Presented at: International Conference on Statistics and Data Science, Vancouver, BC, Canada; June 24, 2025

1. Z-residuals for Checking Bayesian Hurdle Models. Presented at: EcoStat 2024; July 17, 2024; Beijing, China.

= 15. REPORTS AND OTHER OUTPUTS
<reports-and-other-outputs>
== 15.1 Software Released Publicly
<software-released-publicly>
4. Wu, T. and Li, L., 2026. #NormalTok("Zresidual");: Computing and Diagnosing Gaussian-like Residuals. #link("https://tiw150.github.io/Zresidual/index.html")[\[Github\]] #link("https://tiw150.github.io/Zresidual_demo.html")[\[Demo\]]. Version 0.1-0 on Github (2026).

3. Li, L., 2026. R Functions for Computing Z-residuals for #NormalTok("survreg"); and #NormalTok("coxph"); Objects. #link("https://longhaisk.github.io/software/NRSP/index.html")[\[URL\]].

2. Li, L. and Liu, S., 2019--2026. #NormalTok("HTLR");: Bayesian Logistic Regression with Hyper-LASSO priors. DOI: 10.32614/CRAN.package.HTLR. #link("https://cran.r-project.org/web/packages/HTLR/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/HTLR")[\[Github\]] #link("https://longhaisk.github.io/software/BLRHL/index.html")[\[URL\]]. Version 0.4 (2019), version 0.4-1 (2019), version 0.4-2 (2020), version 0.4-3 (2020), version 0.4-4 (2022), version 1.0 (2026).

1. Li, L., 2011--2026. #NormalTok("BCBCSF");: Bias-corrected Bayesian Classification with Selected Features. DOI: 10.32614/CRAN.package.BCBCSF. #link("https://cran.r-project.org/web/packages/BCBCSF/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/software/BCBCSF/index.html")[\[URL\]]. Version 0.0-0 (2011), version 0.0-1 (2011), version 0.0-2 (2012), version 1.0-0 (2013), version 1.0-1 (2015), updated to version 1.0-2 (2026).

= 17. RESEARCH FUNDING HISTORY
<research-funding-history>
#strong[2025-2026]

2. #strong[NSERC Individual Discovery Grant (No.~2026-07053)] -- #emph[Prediction-based Methods for Statistical Learning and Inference in Biosciences and Epidemiology], \$185,000 (37K per year), 2026-2031, PI.

1. #strong[CANSSI Collaborative Research Team Projects] -- #emph[Statistical Methodologies and Computational Tools to Identify Microbial Correlates of Canadian Bee Gut Health], Project 29, 2025-2028, Co-PI.

= 18. PRACTICE OF PROFESSIONAL SKILLS
<practice-of-professional-skills>
#strong[2025-2026]

14. Refereeing for #emph[Journal of Statistical Computation and Simulation], June, 2026

13. Refereeing for #emph[Journal of Statistical Computation and Simulation], April, 2026

12. Refereeing for #emph[Journal of the Royal Statistical Society: Series C], April 2026

11. Refereeing for #emph[Bioinformatics], March 2026

10. Refereeing for #emph[Journal of Computational and Graphical Statistics], March 2026

9. External Referee for a tenure and promotion of SFU, Dec.~2025

8. External Examiner for the doctoral thesis by Xiaoqing Zhang at University of Regina, Dec.~8, 2025

7. Refereeing for #emph[Journal of Statistical Computation and Simulation], Dec.~2025

6. Refereeing for #emph[Journal of Computational and Graphical Statistics], Sept.~2025

5. External Examiner for the doctoral thesis by Na Zhang at University of Alberta, August 28, 2025

4. Refereeing for #emph[Journal of the Royal Statistical Society: Series C], August 2025

3. Refereeing for #emph[Journal of Applied Statistics], August 2025

#strong[2024-2025]

2. Organizing an invited Session for the 7th Symposium of ICSA Canada Chapter, McGill University, August 2026

1. Organizing an invited Session for 2025 SSC Annual Meeting, Saskatoon, SK, Canada, June 2025

= 19. ADMINISTRATIVE SERVICE
<administrative-service>
== 19.1 University Committees
<university-committees>
#strong[2025-2026]

2. Chair, Collaborative Biostatistics Program, University of Saskatchewan.

1. USASK NSERC Discovery Grant (DG), Internal Reviewer.

== 19.2 College and Departmental Committees
<college-and-departmental-committees>
#strong[2025-2026]

5. Member, Budgeting and Planning Committee, Dept of Math & Stat

4. Co-Chair, Undergraduate Committee (Statistics), Dept of Math & Stat

3. Member, Graduate Program Committee in Statistics, Dept of Math & Stat

#strong[2024-2025]

2. Member, Graduate Program Committee in Statistics, Dept of Math & Stat

1. Search subcommittee for a faculty position in statistics

= 20. PROFESSIONAL OR ASSOCIATION OFFICES AND COMMITTEE ACTIVITY
<professional-or-association-offices-and-committee-activity>
#strong[2024-2025]

2. Member of NSERC Discovery Grant EG 1508 Committee

1. Local Organizing Committee, 2025 Annual Meeting of the Statistical Society of Canada held at the U of S

#colbreak()

#align(right)[#text(size: 14pt, weight: "bold")[Form 2]]
#v(1em)
#grid(
  columns: (1fr, 1fr),
  row-gutter: 1em,
  [*Name:* #underline[Longhai Li]], [*Date:* #underline[June 30, 2026]],
  [*College:* #underline[Arts & Science]], [*Department:* #underline[Mathematics & Statistics]]
)
#v(0.5em)
#line(length: 100%)
#v(1em)
#align(center)[
  #strong[
    INFORMATION FOR UPDATE OF CURRICULUM VITAE \
    (REVISION OF ITEMS PREVIOUSLY REPORTED AND CONSIDERED) \
    #v(0.5em)
    The cut off date for items to be reported is JUNE 30.
  ]
]
#v(2em)
#align(center)[*Nothing to report for timeframe: 2025-2026*]
]
]



