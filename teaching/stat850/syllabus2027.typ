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
#let color-link = rgb("#4f2fcd")
#let color-ref = rgb("#1a1ad6")
#show link: set text(fill: color-link)
#show ref: set text(fill: color-ref)
#show cite: set text(fill: color-ref)
#import "@preview/fontawesome:0.5.0": *
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
  title: [STAT 850/442 Statistical Inference (Univ. of Saskatchewan, 2027 Winter)],
  fontsize: 11pt,
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)

= Description
<description>
This course presents a rigorous theoretical treatment of statistical inference, offering a comparative analysis of frequentist and Bayesian paradigms. The curriculum explores several core areas of statistical theory, beginning with foundational concepts in Decision theory (Risk Function, Minimaxity Theorem) before moving into a comprehensive treatment of Bayesian inference (Posterior, Bayes Rules, Bayes Risk, Minimax Rules, James-Stein Estimator, Empirical Bayes, Hierarchical Bayesian, MCMC, Case Study). The course then transitions to focus heavily on Likelihood theory (Sufficient Statistic, Bartlett's Identities, Cramér-Rao Lower Bound, Exponential Families) and the mechanics of MLE (Score, Fisher Information, Newton-Raphson Methods, Asymptotics of Maximum Likelihood Estimators, Alkeike Information Criteria, Deep Learning). Finally, we cover hypothesis testing and optimal point estimation through the lens of the Likelihood ratio test (Neyman-Pearson Lemma, Monotone Likelihood Test, Likelihood-based Tests) and UMVUE (Complete Statistic, Uniformly Minimum Variance Unbiased Estimators/Tests).

#strong[Prerequisite(s):] STAT 342.

This course requires a strong command of multivariate calculus, alongside a rigorous foundation in intermediate probability theory including asymptotic theorey for probability. Students should also possess prior exposure to applied statistical methods and familiar with basic statistical concepts such as standard error, p-value, and confidence internal.

= Instructor
<instructor>
- #link("https://longhaisk.github.io")[Longhai Li], Professor
- Department of Mathematics and Statistics, University of Saskatchewan
- Email: longhai.li\@usask.ca.

= Times and Places
<times-and-places>
- #strong[Lectures:] TTH 11:30-12:20, MCLN 242.1
- #strong[Office Hours:] TBA
- #strong[No lab]

= Textbook and Course Materials
<textbook-and-course-materials>
- #link("https://longhaisk.github.io/teaching/stat850/")[The course page] contains the links to my lecture notes and assingments.

- #strong[Recommended Text:]

  Young G. A. & R. L. Smith, #emph[Essentials of Statistical Inference], Cambridge University Press, 2005.

= Tentative Schedule
<tentative-schedule>
#{set text(font: ("system-ui", "Segoe UI", "Roboto", "Helvetica", "Arial", "sans-serif", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji") , size: 9.75pt); table(
  columns: (10%, 15%, 50%, 25%),
  align: (left,center,left,left,),
  table.header(table.cell(align: bottom + left, fill: rgb("#f0f0f0"), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[#set text(size: 1.0em , weight: "regular" , fill: rgb("#333333")); #strong[Date]], table.cell(align: bottom + center, fill: rgb("#f0f0f0"), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[#set text(size: 1.0em , weight: "regular" , fill: rgb("#333333")); #strong[Academic Week]], table.cell(align: bottom + left, fill: rgb("#f0f0f0"), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[#set text(size: 1.0em , weight: "regular" , fill: rgb("#333333")); #strong[Topic]], table.cell(align: bottom + left, fill: rgb("#f0f0f0"), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[#set text(size: 1.0em , weight: "regular" , fill: rgb("#333333")); #strong[Task]],),
  table.hline(),
  table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Jan 04], table.cell(align: horizon + center, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[1], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[1. Introduction: Likelihood Function, and MLE], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[#strong[Course Starts (Jan 06)]],
  table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Jan 11], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[2], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[2. Likelihood Theory: Sufficient Statistic], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Jan 18], table.cell(align: horizon + center, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[3], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[3. Likelihood Theory: Bartlett\'s Identities, CR Lower Bound], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Jan 25], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[4], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[3. Likelihood Theory: Exponential Families], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Feb 01], table.cell(align: horizon + center, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[5], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[4. Maximum Likelihood Estimation: Score, Fisher Information, Newton-Raphson Methods], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Feb 08], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[6], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[4. Maximum Likelihood Estimation: Asymptotics of MLE, AIC, Deep Learning], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[#strong[Assignment 1 due]],
  table.cell(align: horizon + left, fill: rgb("#d1e7dd"), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[#set text(style: "italic" , weight: "bold"); Feb 15], table.cell(align: horizon + center, fill: rgb("#d1e7dd"), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[#set text(style: "italic" , weight: "bold"); N/A], table.cell(align: horizon + left, fill: rgb("#d1e7dd"), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[#set text(style: "italic" , weight: "bold"); ---], table.cell(align: horizon + left, fill: rgb("#d1e7dd"), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[#set text(style: "italic" , weight: "bold"); #strong[Reading Week -- No classes]],
  table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Feb 22], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[7], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[5. Hypothesis Testing: NP Lemma, Monotone Likelihood Test, Likelihood-based Tests], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[#strong[Midterm (during class)]],
  table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Mar 01], table.cell(align: horizon + center, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[8], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[6. Uniformly Minimum Variance Unbiased Tests: Complete Statistic, UMVUE], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Mar 08], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[9], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[7. Decision Theory: Risk, Minimaxity Theorem], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[#strong[Assignment 2 due]],
  table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Mar 15], table.cell(align: horizon + center, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[10], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[7. Bayesian Inference: Posterior, Bayes Rules, Bayes Risk], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Mar 22], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[11], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[7. Bayesian Inference: Minimax Rules, James-Stein Estimator], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Mar 29], table.cell(align: horizon + center, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[12], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[7. Bayesian Inference: Empirical Bayes, Hierarchical Bayesian, MCMC, Case Study], table.cell(align: horizon + left, stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Apr 05], table.cell(align: horizon + center, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[13], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[Review], table.cell(align: horizon + left, fill: rgb(128, 128, 128, 5%), stroke: (left: (paint: rgb("#d3d3d3"), thickness: 0.75pt), right: (paint: rgb("#d3d3d3"), thickness: 0.75pt), top: (paint: rgb("#e0e0e0"), thickness: 0.75pt)))[#strong[Assignment 3 due]#strong[Course Ends (Apr 08)]],
)}
#block[
#callout(
body: 
[
The schedule may change depending on the course pace. The exact assignment and test dates are given on Canvas.

]
, 
title: 
[
Important
]
, 
background_color: 
rgb("#f7dddc")
, 
icon_color: 
rgb("#CC1914")
, 
icon: 
fa-exclamation()
, 
body_background_color: 
white
)
]
= Learning Outcomes
<learning-outcomes>
After completing this course, students are expected to grasp the following knowledges and skills:

#{set text(font: ("system-ui", "Segoe UI", "Roboto", "Helvetica", "Arial", "sans-serif", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji") , size: 9pt); table(
  columns: (15%, 35%, 40%, 10%),
  align: (left,left,left,right,),
  table.header(table.cell(align: bottom + left, fill: rgb("#e0e0e0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); #strong[Topic]], table.cell(align: bottom + left, fill: rgb("#e0e0e0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); #strong[Knowledge]], table.cell(align: bottom + left, fill: rgb("#e0e0e0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); #strong[Skills]], table.cell(align: bottom + right, fill: rgb("#e0e0e0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); #strong[Perc]],),
  table.hline(),
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[#set text(weight: "bold"); Likelihood Theory], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Define minimal sufficient statistic. Understand Bartlett\'s Identities, the Cramér-Rao Lower Bound (CRLB), and the mathematical properties of Exponential Families.], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Identify minimal sufficient statistic, compute Fisher Information matrices, Bartlett Identities, verify CRLB attainment, identify natural parameters and calculate moments of suff. statistics in Exponential Families], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[10%],
  table.cell(align: horizon + left, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[#set text(weight: "bold"); Maximum Likelihood Estimation], table.cell(align: horizon + left, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Define the score function and Fisher Information. Understand the Newton-Raphson algorithm, MLE asymptotic normality, and information criteria (AIC).], table.cell(align: horizon + left, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Derive MLEs analytically, calculate asymptotic variances using Fisher information, find the asymptotic distributions of estimators, compute AIC.], table.cell(align: horizon + right, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[30%],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[#set text(weight: "bold"); Hypothesis Testing], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Grasp the size, power, Neyman-Pearson Lemma, Monotone Likelihood Ratios (MLR), and the theoretical logic of likelihood-based testing.], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Construct UMP tests using MLR, derive Likelihood Ratio tests, Score tests, and Wald tests with specified rejection regions.], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[20%],
  table.cell(align: horizon + left, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[#set text(weight: "bold"); UMVUE], table.cell(align: horizon + left, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Understand completeness, the Lehmann-Scheffé theorem, and Rao-Blackwell Theorem.], table.cell(align: horizon + left, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Derive UMVUE in exponential families.], table.cell(align: horizon + right, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[10%],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[#set text(weight: "bold"); Decision Theory], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Understand risk functions, admissibility, and the theoretical foundation of decision rules.], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Calculate frequentist risk function for given estimators and evaluate admissibility under simple loss functions.], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[10%],
  table.cell(align: horizon + left, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[#set text(weight: "bold"); Bayesian Inference], table.cell(align: horizon + left, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Define prior/posterior distributions and Bayes risk. Understand shrinkage via the James-Stein estimator, Empirical Bayes, hierarchical models, and MCMC principles.], table.cell(align: horizon + left, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[Derive posterior distributions, find Bayes estimators, calculate Bayes risk, and find minimax rules.], table.cell(align: horizon + right, fill: rgb("#f5f5f5"), stroke: (top: (paint: rgb("#b0b0b0"), thickness: 0.75pt)))[20%],
)}
= Evaluation
<evaluation>
== Grading Scheme
<grading-scheme>
#strong[3 Assignments: 3 x 10%, 1 Term Test: 20%, 1 Final Exam: 50%.]

== Assignments and Tests
<assignments-and-tests>
#strong[Assignment questions are released in the one-drive folder]. You will submit your solutions via Canvas. #strong[If you miss an assignment without proper excuse, the weight will NOT be shifted to the final.] Undergraduate students will be assigned with different assignments and tests.

== Assignments
<assignments>
- I will accept late assignments only for three (3) days beyond the due date. The penalty for your delay is 10 percentage points per day of lateness from the value of the assignment (including weekends). #strong[Extensions are only granted in rare instances (notably as a result of family or medical emergencies) and upon receipt of adequate documentation/proof.]
- Answer the questions in the order they appear in the assignment. Neatness is important.
- Solutions to problems are to be included. Hence, simple answers without work will receive few (or no!) marks.
- Most problems in statistics have a “real-life” basis. Hence, solutions should include not only numerical solutions but also a statement as to what the numbers say about the problem.
- The work handed in must not be an exact duplicate of others.
- Submitting Assignments: The assignment can be typed and/or handwritten. Save your assignment as #strong[one PDF file] (for handwritten assignments, feel free to take a picture/scan of your work and save it as one PDF file). Upload the #strong[PDF file] as an assignment submission in Canvas.
- More details will be provided ahead of each assignment.
- Due Date: See Course Schedule.

== Midterm
<midterm>
- The midterm is given in class period.
- Midterms must be written on the dates scheduled. Students must do midterms completely on their own. More details (including syllabus) will be provided ahead of each midterm.
- Type: Short-answer questions, problem-solving, open-book.
- Calculator: A scientific calculator is allowed.
- Make-up exam will not be given. If you miss an exam for a legitimate reason (e.g., illness, emergency) and notify me within 48 hours of the scheduled exam, the weight of the missed exam will be transferred to the final exam.

== Final Exam
<final-exam>
- Scheduling: Final examinations may be scheduled at any time during the examination period; students should therefore avoid making prior travel, employment, or other commitments for this period. If a student is unable to write an exam through no fault of their own for medical or other valid reasons, documentation must be provided and an opportunity to write the missed exam may be given. Students are encouraged to review all examination policies and procedures: #link("http://students.usask.ca/academics/exams.php").
- The final exam will cover material of the entire course. More details will be provided ahead of the exam.
- Length: 3-hour in-person exam.
- Type: Short-answer questions, problem-solving, open-book.

== Criteria That Must Be Met to Pass
<criteria-that-must-be-met-to-pass>
The #strong[final exam is a required component of the course]. Students must complete the final exam in order to be eligible to receive a passing grade in this class.

= Attendance Expectation
<attendance-expectation>
Attendance is highly correlated with student performance. While a syllabus and suggested readings are provided, it is not an adequate substitute for attending class. Your #strong[attendance is highly recommended] but not required, and you will not be graded on your attendance.

= Recording of the Course
<recording-of-the-course>
Recording of the lectures will only be allowed in certain circumstances. Please see the instructor for information on how to receive approval. In general, there will be no videos available for in-person lectures. Therefore, #strong[attendance is strongly recommended].

= Use of Generative AI and Electronic Devices
<use-of-generative-ai-and-electronic-devices>
+ AI for Learning vs.~Assessment. Students are free (and encouraged) to use Generative AI tools as a study aid to understand course concepts, debug code, or explain complex theorems. However, #strong[all submitted work for assignments must be your own.] You must write your own solutions. Directly copying text, derivations, or code from an AI tool and submitting it as your own may receive a #strong[severe penalty] (up to receiving a 0% on the assignment.

+ Electronic Devices During Tests. All term tests and the final exam are #strong[Open Book], meaning you may bring printed notes, textbooks, and lecture slides.

  - #strong[No Electronic Devices:] You are #strong[NOT allowed] to use laptops, tablets, smartwatches, or any other electronic devices during the exam.

  - #strong[Phone Exception:] You are permitted to bring a smartphone, but it must remain stowed away during the writing period. It may #strong[only] be used at the very end of the exam for the specific purpose of taking photos of your answer sheets for submission (if required). Using the phone for any other reason during the exam will be treated as academic misconduct.
