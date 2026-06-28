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
  [*Name:* #underline[Longhai Li]], [*Date:* #underline[June 30, 2024]],
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
= 9. TEACHING ACTIVITIES
<teaching-activities>
== 9.1 Scheduled Instructional Activity
<scheduled-instructional-activity>
#block[
#[
#set table(inset: (x: 5pt, y: 2.5pt))
#set par(leading: 0.45em)
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
]
]
== 9.5 Other Teaching-Related Activities
<other-teaching-related-activities>
#strong[2023-2024]

1. Data Science Bootcamp, a case study, June 19, 2023.

= 10. SUPERVISION AND ADVISORY ACTIVITIES
<supervision-and-advisory-activities>
== 10.1 Undergraduate Student Supervision
<undergraduate-student-supervision>
#strong[2023-2024]

1. George Chen, B.Sc., Computer Science, Simon Fraser University, May 7, 2023 -- Aug.~25, 2023, Supervised.

== 10.2 Graduate Student Supervision
<graduate-student-supervision>
3. Jing Wang, Ph.D., Biostatistics, School of Public Health, Co-supervised with Prof.~Li Xing, 2023--2026 (Transferred to other supervisor)

2. Dananji Egodage, M.Sc., Statistics, Math & Stat, Co-supervised with Prof.~Cindy Feng, 2023--2025 (Defended: Aug.~30, 2025)

1. Wuqian Effie Gao, M.Sc., Biostatistics, School of Public Health, Co-supervised with Prof.~Cindy Feng, 2022--2024 (Defended: Aug.~30, 2024)

== 10.3 Graduate Theses Supervised
<graduate-theses-supervised>
#strong[2023-2024]

1. Tingxuan Wu, 2023, Residual Diagnostics and Statistical Inference for Shared Frailty Models, Ph.D., defended on May 24, 2023.

== 10.4 Supervision of Post-Doctoral Fellows and Research Associates
<supervision-of-post-doctoral-fellows-and-research-associates>
2. Tingxuan Wu, University of Saskatchewan, Postdoc Fellow, June 2023 -- April 2024.

1. Ming Ming Zhang, MITACS Postdoc, 2022-2025.

== 10.6 Thesis Committee Memberships
<thesis-committee-memberships>
#figure([
#{set text(font: ("system-ui", "Segoe UI", "Roboto", "Helvetica", "Arial", "sans-serif", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji") , size: 9pt); table(
  columns: (5%, 25%, 5%, 20%, 30%, 10%),
  align: (center,left,center,left,left,center,),
  table.header(table.cell(align: bottom + center, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); \#], table.cell(align: bottom + left, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); NAME], table.cell(align: bottom + center, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); DEG], table.cell(align: bottom + left, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); PROGRAM], table.cell(align: bottom + left, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); TIME FRAME], table.cell(align: bottom + center, fill: rgb("#d9d9d9"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); ROLE],),
  table.hline(),
  table.cell(align: horizon + center)[28], table.cell(align: horizon + left)[Mohammad Toranjsimin], table.cell(align: horizon + center)[M.Sc.], table.cell(align: horizon + left)[Biostatistics], table.cell(align: horizon + left)[2023--2025 (Def. 09/2025)], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[27], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Lina Li], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Biostatistics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2023--Present], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Member],
  table.cell(align: horizon + center)[26], table.cell(align: horizon + left)[Kyle Gardiner], table.cell(align: horizon + center)[M.Sc.], table.cell(align: horizon + left)[Statistics], table.cell(align: horizon + left)[2023--2024 (Def. 09/2024)], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[25], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Mangladeep Bhullar], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Physics], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2023--2025 (Def. 11/2025)], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Cognate],
  table.cell(align: horizon + center)[24], table.cell(align: horizon + left)[Hammed Jimoh], table.cell(align: horizon + center)[M.Sc.], table.cell(align: horizon + left)[Statistics], table.cell(align: horizon + left)[2022--2023], table.cell(align: horizon + center)[Member],
  table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[22], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Han Wang], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Ph.D.], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[Sociology], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%))[2020--Present], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%))[Cognate],
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
#strong[2023-2024]

1. Feng, C., Li, L., Xu, C., 2023. Advancements in predicting and modeling rare event outcomes for enhanced decision-making. #emph[BMC Medical Research Methodology] 23, Article 243 (pp.~1-3). #link("https://doi.org/10.1186/s12874-023-02060-x")

= 14. PRESENTATIONS
<presentations>
== 14.1 Invited Presentations
<invited-presentations>
#strong[2023-2024]

4. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, ICSA Canada Chapter Symp., June 9, 2024, Niagara Falls, Canada

3. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, Annual Meeting of SSC, St John's, Canada, June 2, 2024

2. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, Dept. Seminar, Texas State University, USA, March 8, 2024

1. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, Dept. Seminar, Sun Yat-sen University, China, Jan.~4, 2024

= 15. REPORTS AND OTHER OUTPUTS
<reports-and-other-outputs>
== 15.1 Software Released Publicly
<software-released-publicly>
2. Li, L. and Liu, S., 2019--2026. #NormalTok("HTLR");: Bayesian Logistic Regression with Hyper-LASSO priors. DOI: 10.32614/CRAN.package.HTLR. #link("https://cran.r-project.org/web/packages/HTLR/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/HTLR")[\[Github\]] #link("https://longhaisk.github.io/software/BLRHL/index.html")[\[URL\]]. Version 0.4 (2019), version 0.4-1 (2019), version 0.4-2 (2020), version 0.4-3 (2020), version 0.4-4 (2022), version 1.0 (2026).

1. Li, L., 2011--2026. #NormalTok("BCBCSF");: Bias-corrected Bayesian Classification with Selected Features. DOI: 10.32614/CRAN.package.BCBCSF. #link("https://cran.r-project.org/web/packages/BCBCSF/index.html")[\[CRAN\]] #link("https://longhaisk.github.io/software/BCBCSF/index.html")[\[URL\]]. Version 0.0-0 (2011), version 0.0-1 (2011), version 0.0-2 (2012), version 1.0-0 (2013), version 1.0-1 (2015), updated to version 1.0-2 (2026).

== 15.2 Technical Reports
<technical-reports>
2. Wu, T., Feng, C. and Li, L., 2023. Cross-validatory Z-Residual for Diagnosing Shared Frailty Models. #link("https://doi.org/10.48550/arXiv.2303.09616"). 32 pages, 14 figures.

1. Wu, T., Li, L. and Feng, C., 2023. Z-residual diagnostics for detecting misspecification of the functional form of covariates for shared frailty models. #link("https://doi.org/10.48550/arXiv.2302.09106"). 21 pages, 7 figures.

= 18. PRACTICE OF PROFESSIONAL SKILLS
<practice-of-professional-skills>
#strong[2023-2024]

4. External Examiner for the doctoral thesis by Yuping Yang at SFU, June 25, 2024

3. Refereeing for #emph[Journal of Computational and Graphical Statistics], Sept.~2024

2. Refereeing for #emph[Journal of Applied Statistics], Jan.~2024

1. Review an MITACS Accelerate Grant, Dec.~2023

= 19. ADMINISTRATIVE SERVICE
<administrative-service>
== 19.2 College and Departmental Committees
<college-and-departmental-committees>
#strong[2023-2024]

2. Member, Graduate Program Committee in Statistics, Dept of Math & Stat

1. Member, Sub Search Committee, 4-Year Lecturer Position

= 20. PROFESSIONAL OR ASSOCIATION OFFICES AND COMMITTEE ACTIVITY
<professional-or-association-offices-and-committee-activity>
#strong[2023-2024]

1. Member of NSERC Discovery Grant EG 1508 Committee

#colbreak()

#align(right)[#text(size: 14pt, weight: "bold")[Form 2]]
#v(1em)
#grid(
  columns: (1fr, 1fr),
  row-gutter: 1em,
  [*Name:* #underline[Longhai Li]], [*Date:* #underline[June 30, 2024]],
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
#align(center)[*Nothing to report for timeframe: 2023-2024*]



