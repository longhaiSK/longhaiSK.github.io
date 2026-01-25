// Some definitions presupposed by pandoc's typst output.
#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
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
  subrefnumbering: "1a",
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
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
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
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
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

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
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
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
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

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
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

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)
#import "@preview/ctheorems:1.1.3": *
#show: thmrules
#let definition = thmbox("definition", "Definition")
#let theorem = thmbox("theorem", "Theorem")
#let example = thmbox("example", "Example")
#let lemma = thmbox("lemma", "Lemma")
#import "@preview/fontawesome:0.5.0": *
#let algorithm = thmbox("algorithm", "Algorithm")
#let corollary = thmbox("corollary", "Corollary")

#set page(
  paper: "us-letter",
  margin: (left: 20mm,top: 30mm,),
  numbering: "1",
)

#show: doc => article(
  title: [Theory of Linear Models],
  authors: (
    ( name: [Longhai Li],
      affiliation: [],
      email: [] ),
    ),
  date: [2026-01-25],
  font: ("Times New Roman",),
  heading-family: ("Times New Roman",),
  sectionnumbering: "1.1.a",
  toc: true,
  toc_title: [Table of contents],
  toc_depth: 1,
  cols: 1,
  doc,
)

/* In resources/homework.typ */

/* --- Heading Formatting --- */
#show heading.where(level: 1): set text(size: 12pt)
#show heading.where(level: 1): set block(below: 1em)

#show heading.where(level: 2): set text(size: 11pt)
#show heading.where(level: 2): set block(below: 1em)

/* --- Global Text Settings --- */
#set text(
  font: "Times New Roman",
  size: 12pt
)

/* --- Paragraph Settings --- */
#set par(
  leading: 0.65em, 
  justify: true
)

// 1. Define the Color Palette (Backgrounds set to white)
#let themes = (
  theorem:    (bg: white, border: rgb("#cfe2ff"), header-bg: rgb("#cfe2ff"), text: rgb("#084298")),
  definition: (bg: white, border: rgb("#badbcc"), header-bg: rgb("#badbcc"), text: rgb("#0f5132")),
  example:    (bg: white, border: rgb("#ffeebb"), header-bg: rgb("#ffeebb"), text: rgb("#664d03")),
  proof:      (bg: white, border: rgb("#e2e3e5"), header-bg: rgb("#a6a4a4"), text: rgb("#41464b")),
  sol:        (bg: white, border: rgb("#d9534f"), header-bg: rgb("#d9534f"), text: rgb("#ffffff")),
  solution:   (bg: white, border: rgb("#d9534f"), header-bg: rgb("#d9534f"), text: rgb("#ffffff")),
  algorithm:  (bg: white, border: rgb("#e0cffc"), header-bg: rgb("#e0cffc"), text: rgb("#440099")),
  remark:     (bg: white, border: rgb("#cff4fc"), header-bg: rgb("#cff4fc"), text: rgb("#055160")),
)

// 2. The Master Environment Function (Combined Stack + Figure)
#let colored-env(type, title: none, body) = {
  let theme = if type in themes { themes.at(type) } else { themes.theorem }
  
  let supplement = if type == "sol" or type == "solution" {
    "Solution"
  } else {
    type.at(0).upper() + type.slice(1)
  }

  // Wraps the content in a figure for referencing (e.g. @thm-1)
  figure(
    kind: type,            
    supplement: supplement,
    numbering: "1.1",      
    outlined: false,       
    caption: none,         
    
    context {
      let num = counter(figure.where(kind: type)).display(figure.numbering)
      
      let full-title = if title != none {
        [#supplement #num: #title]
      } else {
        [#supplement #num]
      }

      block(
        fill: theme.bg,
        stroke: 2pt + theme.border,
        radius: 5pt,
        width: 100%,
        inset: 0pt,
        clip: true,
        breakable: true, 
        stack(
          dir: ttb,
          
          // Header
          block(
            width: 100%,
            fill: theme.header-bg,
            inset: (x: 1em, y: 0.6em),
            stroke: (bottom: 1pt + black.transparentize(95%)),
            [#set text(fill: theme.text, weight: "bold"); #full-title]
          ),
          
          // Body
          block(
            width: 100%,
            inset: 1em,
            body
          )
        )
      )
    }
  )
}

// 3. User-Facing Wrappers (Robust Argument Handling)
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

#let theorem(..args)    = env-wrapper("theorem", ..args)
#let definition(..args) = env-wrapper("definition", ..args)
#let example(..args)    = env-wrapper("example", ..args)
#let proof(..args)      = env-wrapper("proof", ..args)
#let algorithm(..args)  = env-wrapper("algorithm", ..args)
#let remark(..args)     = env-wrapper("remark", ..args)
#let sol(..args)        = env-wrapper("sol", ..args)
#let solution(..args)   = env-wrapper("solution", ..args)
#block[
#heading(
level: 
1
, 
numbering: 
none
, 
[
Preface
]
)
]
#block[
#heading(
level: 
2
, 
numbering: 
none
, 
[
Key Features
]
)
]
This text adopts a geometric approach to the statistical theory of linear models, aiming to provide a deeper understanding than standard algebraic treatments. Key features include:

- #strong[Projection Perspective:] We prioritize the geometric interpretation of least squares, viewing estimation as a projection of the response vector onto a model subspace. This visual framework unifies diverse topics---from simple regression to complex ANOVA designs---under a single theoretical umbrella.

- #strong[Interactive Visualizations:] Abstract concepts are brought to life through interactive 3D plots. Readers can rotate and inspect vector spaces, residual planes, and projection geometries to build a tangible intuition for high-dimensional operations.

- #strong[Computational Integration:] Theory is seamlessly integrated with practice. The text provides implementation examples using R (and Python), demonstrating how theoretical matrix equations translate directly into computational code.

- #strong[Rigorous Foundations:] While visually driven, the text maintains mathematical rigor, covering essential topics such as spectral theory, the generalized inverseand the multivariate normal distribution to ensure a solid theoretical grounding.

#block[
#heading(
level: 
2
, 
numbering: 
none
, 
[
#strong[Overview]
]
)
]
This course is a rigorous examination of the general linear models using vector space theory, in particular the approach of regarding least square as projection. The topics includes: vector space; projection; matrix algebra; generalized inverses; quadratic forms; theory for point estimation; theory for hypothesis test; theory for non-full-rank models.

#block[
#heading(
level: 
2
, 
numbering: 
none
, 
[
#strong[Audience]
]
)
]
This book is designed for graduate students and advanced undergraduate students in statistics, data science, and related quantitative fields. It serves as a bridge between applied regression analysis and the theoretical foundations of linear models. Researchers and practitioners seeking a deeper geometric and algebraic understanding of the statistical methods they use daily will also find this text valuable.

#block[
#heading(
level: 
2
, 
numbering: 
none
, 
[
#strong[Prerequisites]
]
)
]
To get the most out of this book, readers should have a comfortable grasp of the following topics:

#strong[Linear Algebra];: An elementary understanding of matrix operations is essential. You should be familiar with matrix multiplication, determinants, inversion, and the basic concepts of vector spaces (such as linear independence, basis vectors, and subspaces). While we review key spectral theory concepts (like eigenvalues and the singular value decomposition) in the early chapters, prior exposure to these ideas is helpful.

#strong[Probability and Statistics];: A standard introductory course in probability and mathematical statistics is required. Readers should be familiar with random variables, expectation, variance, covariance, common probability distributions (especially the Normal distribution), and fundamental concepts of hypothesis testing and estimation.

#pagebreak()
= Introduction
<introduction>
== Multiple Linear Regression
<multiple-linear-regression>
Suppose we have observations on $Y$ and $X_j$. The data can be represented in matrix form.

$ y_(n times 1) = X_(n times p) beta + epsilon.alt_(n times 1) $

where the error terms are distributed as: $ epsilon.alt tilde.op N_n (0 \, sigma^2 I_n) \, $

in which $I_n$ is the identity matrix: $ I_n = mat(delim: "(", 1, 0, dots.h, 0; 0, 1, dots.h, 0; dots.v, dots.v, dots.down, dots.v; 0, 0, dots.h, 1) $ The scalar equation for a single observation is: $ Y_i = beta_0 + beta_1 X_(i 1) + dots.h + beta_p X_(i p) + epsilon.alt_i $

== Examples
<examples>
=== Polynomial Regression
<polynomial-regression>
Polynomial regression fits a curved line to the data points but remains linear in the parameters ($beta$).

The model equation is: $ y_i = beta_0 + beta_1 x_i + beta_2 x_i^2 + dots.h + beta_(p - 1) x_i^(p - 1) $

=== Design Matrix Construction
<design-matrix-construction>
The design matrix $X$ is constructed by taking powers of the input variable.

$ y = vec(y_1, dots.v, y_n) = mat(delim: "(", 1, x_1, x_1^2, dots.h, x_1^(p - 1); 1, x_2, x_2^2, dots.h, x_2^(p - 1); dots.v, dots.v, dots.v, dots.down, dots.v; 1, x_n, x_n^2, dots.h, x_n^(p - 1)) vec(beta_0, beta_1, dots.v, beta_(p - 1)) + vec(epsilon.alt_1, epsilon.alt_2, dots.v, epsilon.alt_n) $

=== One-Way ANOVA
<one-way-anova>
ANOVA can be expressed as a linear model using categorical predictors (dummy variables).

Suppose we have 3 groups ($G_1 \, G_2 \, G_3$) with observations: $ Y_(i j) = mu_i + epsilon.alt_(i j) \, quad epsilon.alt_(i j) tilde.op N (0 \, sigma^2) $

$ #box(stroke: black, inset: 3pt, [$ Y_11\
Y_12 $])^(G_1) quad #box(stroke: black, inset: 3pt, [$ Y_21\
Y_22 $])^(G_2) quad #box(stroke: black, inset: 3pt, [$ Y_31\
Y_32 $])^(G_3) $

We construct the matrix $X$ to select the group mean ($mu$) corresponding to the observation:

$ y_(6 times 1) = X_(6 times 3) vec(mu_1, mu_2, mu_3) + epsilon.alt $

$ mat(delim: "[", Y_11; Y_12; Y_21; Y_22; Y_31; Y_32) = mat(delim: "[", 1, 0, 0; 1, 0, 0; 0, 1, 0; 0, 1, 0; 0, 0, 1; 0, 0, 1) mat(delim: "[", mu_1; mu_2; mu_3) + epsilon.alt $

=== Analysis of Covariance (ANCOVA)
<analysis-of-covariance-ancova>
ANCOVA combines continuous variables and categorical (dummy) variables in the same design matrix.

$ mat(delim: "[", Y_1; dots.v; Y_n) = mat(delim: "[", X_(1 \, upright("cont")), 1, 0; X_(2 \, upright("cont")), 1, 0; dots.v, 0, 1; X_(n \, upright("cont")), 0, 1) beta + epsilon.alt $

== Least Squares Estimation
<least-squares-estimation>
For the general linear model $y = X beta + epsilon.alt$, the Least Squares estimator is:

$ hat(beta) = (X ' X)^(- 1) X' y $

The predicted values ($hat(y)$) are obtained via the Projection Matrix (Hat Matrix) $P_X$:

$ hat(y) = X hat(beta) = X (X ' X)^(- 1) X' y = P_X y $

The residuals and Sum of Squared Errors are:

$ hat(e) = y - hat(y) $ $ upright("SSE") = lr(||) hat(e) lr(||)^2 $

The coefficient of determination is: $ R^2 = frac(upright("SST") - upright("SSE"), upright("SST")) $ where $upright("SST") = sum (y_i - macron(y))^2$.

== Geometric Perspective of Least Square Estimation
<geometric-perspective-of-least-square-estimation>
We align the coordinate system to the models for clarity:

+ #strong[Reduced Model (];$M_0$): Represented by the #strong[X-axis] (labeled $j_3$).
  - $hat(y)_0$ is the projection of $y$ onto this axis.
+ #strong[Full Model (];$M_1$): Represented by the #strong[XY-plane] (the floor).
  - $hat(y)_1$ is the projection of $y$ onto this plane ($z = 0$).
+ #strong[Observed Data (];$y$): A point in 3D space.

The "improvement" due to adding predictors is the distance between $hat(y)_0$ and $hat(y)_1$.

#figure([
#box(image("figs/3d-lm.png", width: 90.0%))
], caption: figure.caption(
position: bottom, 
[
Geometric Interpretation: Projection onto Axis (M0) vs Plane (M1)
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-geometry-simple>


The geometric perspective is not merely for intuition, but as the most robust framework for mastering linear models. This approach offers three distinct advantages:

- #strong[Statistical Clarity:] Geometry provides the most natural path to understanding the properties of estimators. By viewing least square estimation as an orthogonal projection, the decomposition of sums of squares into independent components becomes visually obvious, demystifying how degrees of freedom relate to subspace dimensions rather than abstract algebraic constants. The sampling distribution of the sum squares become straightforward.
- #strong[Computational Stability:] A geometric understanding is essential for implementing efficient and numerically stable algorithms. While the algebraic "Normal Equations" ($(X ' X)^(- 1) X' y$) are theoretically valid, they are often computationally hazardous. The geometric approach leads directly to superior methods---such as QR and Singular Value Decompositions---that are the backbone of modern statistical software.
- #strong[Generalizability:] The principles of projection and orthogonality extend far beyond the Gaussian linear model. These geometric insights provide the foundational intuition needed for tackling non-Gaussian optimization problems, including Generalized Linear Models (GLMs) and convex optimization, where solutions can often be viewed as projections onto convex sets.

#pagebreak()
= Projection in Vector Space
<projection-in-vector-space>
== Vector and Projection onto a Line
<vector-and-projection-onto-a-line>
=== Vectors and Operations
<vectors-and-operations>
The concept of a vector is fundamental to linear algebra and linear models. We begin by formally defining what a vector is in the context of Euclidean space.

#definition("Vector")[
A #strong[vector] $x$ is defined as a point in $n$-dimensional space ($bb(R)^n$). It is typically represented as a column vector containing $n$ real-valued components: $ x = vec(x_1, x_2, dots.v, x_n) $

] <def-vector>
Vectors are not just static points; they can be combined and manipulated. The two most basic geometric operations are addition and subtraction.

#strong[Vector Arithmetic:] Vectors can be manipulated geometrically:

#definition("Vector Addition")[
The sum of two vectors $x$ and $y$ creates a new vector. The operation is performed component-wise, adding corresponding elements from each vector. Geometrically, this follows the "parallelogram rule" or the "head-to-tail" method, where you place the tail of $y$ at the head of $x$. $ x + y = vec(x_1 + y_1, dots.v, x_n + y_n) $

] <def-vector-addition>
#definition("Vector Subtraction")[
The difference $d = y - x$ is the vector that "closes the triangle" formed by $x$ and $y$. It represents the displacement vector that connects the tip of $x$ to the tip of $y$, such that $x + d = y$.

] <def-vector-subtraction>
=== Scalar Multiplication and Distance
<scalar-multiplication-and-distance>
In addition to combining vectors with each other, we can modify a single vector using a real number, known as a scalar.

#definition("Scalar Multiplication")[
Multiplying a vector by a scalar $c$ scales its magnitude (length) without changing its line of direction. If $c$ is positive, the direction remains the same; if $c$ is negative, the direction is reversed. $ c x = vec(c x_1, dots.v, c x_n) $

] <def-scalar-mult>
We often need to quantify the "size" of a vector. This is done using the concept of length, or norm.

#definition("Euclidean Distance (Length)")[
The length (or norm) of a vector $x = (x_1 \, dots.h \, x_n)^T$ corresponds to the straight-line distance from the origin to the point defined by $x$. It is defined as the square root of the sum of squared components: $ lr(||) x lr(||)^2 = sum_(i = 1)^n x_i^2 $

$ lr(||) x lr(||) = sqrt(sum_(i = 1)^n x_i^2) $

] <def-euclidean-distance>
=== Angle and Inner Product
<angle-and-inner-product>
To understand the relationship between two vectors $x$ and $y$ beyond just their lengths, we must look at the angle between them. Consider the triangle formed by the vectors $x$, $y$, and their difference $y - x$. By applying the classic #strong[Law of Cosines] to this triangle, we can relate the geometric angle to the vector lengths.

#theorem("Law of Cosines")[
For a triangle with sides $a \, b \, c$ and angle $theta$ opposite to side $c$: $ c^2 = a^2 + b^2 - 2 a b cos theta $

] <thm-law-of-cosines>
Translating this geometric theorem into vector notation where the side lengths correspond to the norms of the vectors, we get: $ lr(||) y - x lr(||)^2 = lr(||) x lr(||)^2 + lr(||) y lr(||)^2 - 2 lr(||) x lr(||) dot.op lr(||) y lr(||) cos theta $

This equation provides a critical link between the geometric angle $theta$ and the algebraic norms of the vectors.

#strong[Derivation of Inner Product]

We can express the squared distance term $lr(||) y - x lr(||)^2$ purely algebraically by expanding the components:

$ lr(||) y - x lr(||)^2 = sum_(i = 1)^n (x_i - y_i)^2 $

$ = sum_(i = 1)^n (x_i^2 + y_i^2 - 2 x_i y_i) $

$ = lr(||) x lr(||)^2 + lr(||) y lr(||)^2 - 2 sum_(i = 1)^n x_i y_i $

By comparing this expanded form with the result from the Law of Cosines derived previously, we can identify a corresponding interaction term. This term is so important that we give it a special name: the #strong[Inner Product] (or dot product).

#definition("Inner Product")[
The inner product of two vectors $x$ and $y$ is defined as the sum of the products of their corresponding components: $ x' y = sum_(i = 1)^n x_i y_i = angle.l x \, y angle.r $

] <def-inner-product>
Thus, equating the geometric and algebraic forms yields the fundamental relationship: $ x' y = lr(||) x lr(||) dot.op lr(||) y lr(||) cos theta $

=== Coordinate (Scalar) Projection
<coordinate-scalar-projection>
The inner product allows us to calculate projections, which quantify how much of one vector "lies along" another. If we rearrange the cosine formula derived above, we can isolate the term that represents the length of the "shadow" cast by vector $y$ onto vector $x$.

The length of this projection is given by:

$ lr(||) y lr(||) cos theta = frac(x' y, lr(||) x lr(||)) $

This expression can be interpreted as the inner product of $y$ with the normalized (unit) vector in the direction of $x$:

$ upright("Scalar Projection") = ⟨frac(x, lr(||) x lr(||)) \, y⟩ $

=== Vector Projection Formula
<vector-projection-formula>
The scalar projection only gives us a magnitude (a number). To define the projection as a vector in the same space, we need to multiply this scalar magnitude by the direction of the vector we are projecting onto.

#definition("Vector Projection")[
The projection of vector $y$ onto vector $x$, denoted $hat(y)$, is calculated as: $ upright("Projection Vector") = (upright("Length")) dot.op (upright("Direction")) $

$ hat(y) = (frac(x' y, lr(||) x lr(||))) dot.op frac(x, lr(||) x lr(||)) $

This is often written compactly by combining the denominators:

$ hat(y) = frac(x' y, lr(||) x lr(||)^2) x $

] <def-vector-projection>
=== Perpendicularity (Orthogonality)
<perpendicularity-orthogonality>
A special case of the angle between vectors arises when $theta = 90^circle.stroked.tiny$. This geometric concept of perpendicularity is central to the theory of projections and least squares.

#definition("Perpendicularity")[
Two vectors are defined as #strong[perpendicular] (or orthogonal) if the angle between them is $90^circle.stroked.tiny$ ($pi \/ 2$).

Since $cos (90^circle.stroked.tiny) = 0$, the condition for orthogonality simplifies to the inner product being zero:

$ x' y = 0 arrow.l.r.double x perp y $

] <def-perpendicularity>
#example("Orthogonal Vectors")[
Consider two vectors in $bb(R)^2$: $x = (1 \, 1)'$ and $y = (1 \, - 1)'$. $ x' y = 1 (1) + 1 (- 1) = 1 - 1 = 0 $

Since their inner product is zero, these vectors are orthogonal to each other.

] <exm-orthogonal-vectors>
=== Projection onto a Line (Subspace)
<projection-onto-a-line-subspace>
We can generalize the concept of projecting onto a single vector to projecting onto the entire line (a 1-dimensional subspace) defined by that vector.

#definition("Line Spanned by a Vector")[
The line space $L (x)$, or the space spanned by a vector $x$, is defined as the set of all scalar multiples of $x$: $ L (x) = { c x divides c in bb(R) } $

] <def-line-space>
The projection of $y$ onto $L (x)$, denoted $hat(y)$, is defined by the geometric property that it is the closest point on the line to $y$. This implies that the error vector (or residual) must be perpendicular to the line itself.

#definition("Projection onto a Line")[
A vector $hat(y)$ is the projection of $y$ onto the line $L (x)$ if:

+ $hat(y)$ lies on the line $L (x)$ (i.e., $hat(y) = c x$ for some scalar $c$).

+ The residual vector $(y - hat(y))$ is perpendicular to the direction vector $x$.

] <def-projection-line>
#strong[Derivation:] To find the value of the scalar $c$, we apply the orthogonality condition: $ (y - hat(y)) perp x arrow.r.double.long x' (y - c x) = 0 $

Expanding this inner product gives:

$ x' y - c (x ' x) = 0 $

Solving for $c$, we obtain:

$ c = frac(x' y, lr(||) x lr(||)^2) $

This confirms the formula derived previously using the inner product geometry. It shows that the least squares principle (shortest distance) leads to the same result as the geometric projection.

#strong[Alternative Forms of the Projection Formula]

We can express the projection vector $hat(y)$ in several equivalent ways to highlight different geometric interpretations.

#definition("Forms of Projection")[
The projection of $y$ onto the vector $x$ is given by: $ hat(y) = frac(x' y, lr(||) x lr(||)^2) x = ⟨y \, frac(x, lr(||) x lr(||))⟩ frac(x, lr(||) x lr(||)) $

This second form separates the components into:

$ upright("Projection") = (upright("Scalar Projection")) times (upright("Unit Direction")) $

] <def-projection-formulae>
=== Projection Matrix ($P_x$)
<projection-matrix-p_x>
In linear models, it is often more convenient to view projection as a linear transformation applied to the vector $y$. This allows us to define a #strong[Projection Matrix];.

We can rewrite the formula for $hat(y)$ by factoring out $y$:

$ hat(y) = upright("proj") (y \| x) = x frac(x' y, lr(||) x lr(||)^2) = frac(x x', lr(||) x lr(||)^2) y $

This leads to the definition of the projection matrix $P_x$.

#definition("Projection Matrix onto a Single Vector")[
The matrix $P_x$ that projects any vector $y$ onto the line spanned by $x$ is defined as: $ P_x = frac(x x', lr(||) x lr(||)^2) $

Using this matrix, the projection is simply:

$ hat(y) = P_x y $

If $x in bb(R)^n$, then $P_x$ is a $n times n$ symmetric matrix.

] <def-projection-matrix>
Let's apply these concepts to a concrete example.

#example("Numerical Projection")[
Let $y = (1 \, 3)'$ and $x = (1 \, 1)'$. We want to find the projection of $y$ onto $x$.

#strong[Method 1: Using the Vector Formula] First, calculate the inner products:

$ x' y = 1 (1) + 1 (3) = 4 $ $ lr(||) x lr(||)^2 = 1^2 + 1^2 = 2 $

Now, apply the formula:

$ hat(y) = 4 / 2 vec(1, 1) = 2 vec(1, 1) = vec(2, 2) $

#strong[Method 2: Using the Projection Matrix] Construct the matrix $P_x$:

$ P_x = 1 / 2 vec(1, 1) mat(delim: "(", 1, 1) = 1 / 2 mat(delim: "(", 1, 1; 1, 1) = mat(delim: "(", 0.5, 0.5; 0.5, 0.5) $

Multiply by $y$:

$ hat(y) = P_x y = mat(delim: "(", 0.5, 0.5; 0.5, 0.5) vec(1, 3) = vec(0.5 (1) + 0.5 (3), 0.5 (1) + 0.5 (3)) = vec(2, 2) $

] <exm-projection-r2>
#strong[Example: Projection onto the Ones Vector (];$j_n$)

A very common operation in statistics is calculating the sample mean. This can be viewed geometrically as a projection onto a specific vector.

#example("Projection onto the Ones Vector")[
Let $y = (y_1 \, dots.h \, y_n)'$ be a data vector. Let $j_n = (1 \, 1 \, dots.h \, 1)'$ be a vector of all ones.

The projection of $y$ onto $j_n$ is:

$ upright("proj") (y \| j_n) = frac(j_n' y, lr(||) j_n lr(||)^2) j_n $

Calculating the components:

$ j_n' y = sum_(i = 1)^n y_i quad upright("(Sum of observations)") $ $ lr(||) j_n lr(||)^2 = sum_(i = 1)^n 1^2 = n $

Substituting these back:

$ hat(y) = frac(sum y_i, n) j_n = macron(y) j_n = vec(macron(y), dots.v, macron(y)) $

Thus, replacing a data vector with its mean vector is geometrically equivalent to projecting the data onto the line spanned by the vector of ones.

] <exm-mean-projection>
=== Pythagorean Theorem
<pythagorean-theorem>
The Pythagorean theorem generalizes from simple geometry to vector spaces using the concept of orthogonality defined by the inner product.

#theorem("Pythagorean Theorem")[
If two vectors $x$ and $y$ are orthogonal (i.e., $x perp y$ or $x' y = 0$), then the squared length of their sum is equal to the sum of their squared lengths: $ lr(||) x + y lr(||)^2 = lr(||) x lr(||)^2 + lr(||) y lr(||)^2 $

] <thm-pythagorean>
#block[
#emph[Proof];. We expand the squared norm using the inner product: $ lr(||) x + y lr(||)^2 & = (x + y)' (x + y)\
 & = x' x + x' y + y' x + y' y\
 & = lr(||) x lr(||)^2 + 2 x' y + lr(||) y lr(||)^2 $

Since $x perp y$, the inner product $x' y = 0$. Thus, the term $2 x' y$ vanishes, leaving:

$ lr(||) x + y lr(||)^2 = lr(||) x lr(||)^2 + lr(||) y lr(||)^2 $

]
The proof after defining inner product to represent $cos (theta)$ is trivival. #ref(<fig-pythagoras-proof>, supplement: [Figure]) shows a geometric proof of the fundamental Pythagorean Theorem.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-pythagoras-proof-1.png"))
], caption: figure.caption(
position: bottom, 
[
Proof of Pythagorean Theorem using Area Scaling
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-pythagoras-proof>


=== Least Square Property
<least-square-property>
One of the most important properties of the orthogonal projection is that it minimizes the distance between the vector $y$ and the subspace (or line) onto which it is projected.

#theorem("Least Square Property")[
Let $hat(y)$ be the projection of $y$ onto the line $L (x)$. For any other vector $y^(\*)$ on the line $L (x)$, the distance from $y$ to $y^(\*)$ is always greater than or equal to the distance from $y$ to $hat(y)$. $ lr(||) y - y^(\*) lr(||) gt.eq lr(||) y - hat(y) lr(||) $

] <thm-shortest-distance>
#block[
#emph[Proof];. Since both $hat(y)$ and $y^(\*)$ lie on the line $L (x)$, their difference $(hat(y) - y^(\*))$ also lies on $L (x)$. From the definition of projection, the residual $(y - hat(y))$ is orthogonal to the line $L (x)$. Therefore: $ (y - hat(y)) perp (hat(y) - y^(\*)) $

We can write the vector $(y - y^(\*))$ as:

$ y - y^(\*) = (y - hat(y)) + (hat(y) - y^(\*)) $

Applying the Pythagorean Theorem:

$ lr(||) y - y^(\*) lr(||)^2 = lr(||) y - hat(y) lr(||)^2 + lr(||) hat(y) - y^(\*) lr(||)^2 $

Since $lr(||) hat(y) - y^(\*) lr(||)^2 gt.eq 0$, it follows that:

$ lr(||) y - y^(\*) lr(||)^2 gt.eq lr(||) y - hat(y) lr(||)^2 $

]
== Vector Space
<vector-space>
We now generalize our discussion from lines to broader spaces.

#definition("Vector Space")[
A set $V subset.eq bb(R)^n$ is called a #strong[Vector Space] if it is closed under vector addition and scalar multiplication:

+ #strong[Closed under Addition:] If $x_1 in V$ and $x_2 in V$, then $x_1 + x_2 in V$.
+ #strong[Closed under Scalar Multiplication:] If $x in V$, then $c x in V$ for any scalar $c in bb(R)$.

] <def-vector-space>
It follows that the zero vector $0$ must belong to any subspace (by choosing $c = 0$).

=== Spanned Vector Space
<spanned-vector-space>
The most common way to construct a vector space in linear models is by spanning it with a set of vectors.

#definition("Spanned Vector Space")[
Let $x_1 \, dots.h \, x_p$ be a set of vectors in $bb(R)^n$. The space spanned by these vectors, denoted $L (x_1 \, dots.h \, x_p)$, is the set of all possible linear combinations of them: $ L (x_1 \, dots.h \, x_p) = { r divides r = c_1 x_1 + dots.h + c_p x_p \, upright(" for ") c_i in bb(R) } $

] <def-spanned-space>
=== Column Space and Row Space
<column-space-and-row-space>
When vectors are arranged into a matrix, we define specific spaces based on their columns and rows.

#definition("Column Space")[
For a matrix $X = (x_1 \, dots.h \, x_p)$, the #strong[Column Space];, denoted $upright("Col") (X)$, is the vector space spanned by its columns: $ upright("Col") (X) = L (x_1 \, dots.h \, x_p) $

] <def-column-space>
#definition("Row Space")[
The #strong[Row Space];, denoted $upright("Row") (X)$, is the vector space spanned by the rows of the matrix $X$.

] <def-row-space>
=== Linear Independence and Rank
<linear-independence-and-rank>
Not all vectors in a spanning set contribute new dimensions to the space. This concept is captured by linear independence.

#definition("Linear Independence")[
A set of vectors $x_1 \, dots.h \, x_p$ is said to be #strong[Linearly Independent] if the only solution to the linear combination equation equal to zero is the trivial solution: $ sum_(i = 1)^p c_i x_i = 0 arrow.r.double.long c_1 = c_2 = dots.h = c_p = 0 $

If there exist non-zero $c_i$'s such that sum is zero, the vectors are #strong[Linearly Dependent];.

] <def-linear-independence>
== Rank of Matrices and Dim of Vector Space
<rank-of-matrices-and-dim-of-vector-space>
#definition("Rank")[
The #strong[Rank] of a matrix $X$, denoted $upright("Rank") (X)$, is the maximum number of linearly independent columns in $X$. This is equivalent to the dimension of the column space: $ upright("Rank") (X) = upright("Dim") (upright("Col") (X)) $

] <def-rank>
There are several fundamental properties regarding the rank of a matrix.

#example("Example of the Equality of Row and Col Rank")[
Consider the following $3 times 4$ matrix ($n = 3 \, p = 4$): $ X = mat(delim: "(", 1, 0, 1, 0; 0, 1, 0, 1; 1, 1, 1, 1) $ Notice that the third row is the sum of the first two ($r_3 = r_1 + r_2$).

+ Row Rank and Basis $U$ The first two rows are linearly independent. We set the row rank $r = 2$ and use these rows as our basis matrix $U$ ($2 times 4$):

$ U = mat(delim: "(", 1, 0, 1, 0; 0, 1, 0, 1) $

#block[
#set enum(numbering: "1.", start: 2)
+ Coefficient Matrix $C$ We express every row of $X$ as a linear combination of the rows of $U$:

  - Row 1: $1 dot.op u_1 + 0 dot.op u_2$
  - Row 2: $0 dot.op u_1 + 1 dot.op u_2$
  - Row 3: $1 dot.op u_1 + 1 dot.op u_2$
]

These coefficients form the matrix $C$ ($3 times 2$):

$ C = mat(delim: "(", 1, 0; 0, 1; 1, 1) $

+ The Decomposition $X = C U$) We verify that $X$ is the product of $C$ and $U$: $ underbrace(mat(delim: "(", 1, 0, 1, 0; 0, 1, 0, 1; 1, 1, 1, 1), X med (3 times 4)) = underbrace(mat(delim: "(", 1, 0; 0, 1; 1, 1), C med (3 times 2)) underbrace(mat(delim: "(", 1, 0, 1, 0; 0, 1, 0, 1), U med (2 times 4)) $

+ Conclusion on Column Rank The columns of $X$ are linear combinations of the columns of $C$. $ upright("Col") (X) subset.eq upright("Col") (C) $ Since $C$ has only 2 columns, the dimension of its column space (and thus $X$'s column space) cannot exceed 2. $ upright("Dim") (upright("Col") (X)) lt.eq 2 $ This confirms that Row Rank (2) $gt.eq$ Column Rank. (By symmetry, they are equal).

] <exm-row-rank-equal-col-rank>
#theorem("Row Rank equals Column Rank")[
~

+ #strong[Row Rank equals Column Rank:] The dimension of the column space is equal to the dimension of the row space.

$ upright("Dim") (upright("Col") (X)) = upright("Dim") (upright("Row") (X)) arrow.r.double.long upright("Rank") (X) = upright("Rank") (X ') $

#block[
#set enum(numbering: "1.", start: 2)
+ #strong[Bounds:] For an $n times p$ matrix $X$:
]

$ upright("Rank") (X) lt.eq min (n \, p) $

] <thm-rank-properties>
=== Orthogonality to a Subspace
<orthogonality-to-a-subspace>
We can extend the concept of orthogonality from single vectors to entire subspaces.

#definition("Orthogonality to a Subspace")[
A vector $y$ is orthogonal to a subspace $V$ (denoted $y perp V$) if $y$ is orthogonal to #strong[every] vector $x$ in $V$. $ y perp V arrow.l.r.double y' x = 0 quad forall x in V $

] <def-orth-subspace>
#definition("Orthogonal Complement")[
The set of all vectors that are orthogonal to a subspace $V$ is called the #strong[Orthogonal Complement] of $V$, denoted $V^perp$. $ V^perp = { y in bb(R)^n divides y perp V } $

] <def-orthogonal-complement>
=== Kernel (Null Space) and Image
<kernel-null-space-and-image>
For a matrix transformation defined by $X$, we define two key spaces: the Image (Column Space) and the Kernel (Null Space).

#definition("Image and Kernel")[
~

+ #strong[Image (Column Space):] The set of all possible outputs.

$ upright("Im") (X) = upright("Col") (X) = { X beta divides beta in bb(R)^p } $

#block[
#set enum(numbering: "1.", start: 2)
+ #strong[Kernel (Null Space):] The set of all inputs mapped to the zero vector.
]

$ upright("Ker") (X) = { beta in bb(R)^p divides X beta = 0 } $

] <def-image-kernel>
#theorem("Relationship between Kernel and Row Space")[
The kernel of $X$ is the orthogonal complement of the row space of $X$: $ upright("Ker") (X) = [upright("Row") (X)]^perp $

] <thm-kernel-rowspace>
#block[
#emph[Proof];. Let $x in bb(R)^p$. $x in upright("Ker") (X)$ if and only if $X x = 0$. If we denote the rows of $X$ as $r_1' \, dots.h \, r_n'$, then the equation $X x = 0$ is equivalent to the system of equations: $ vec(r_1', dots.v, r_n') x = vec(0, dots.v, 0) arrow.l.r.double r_i' x = 0 upright(" for all ") i = 1 \, dots.h \, n $ This means $x$ is orthogonal to every row of $X$. Since the rows span the row space $upright("Row") (X)$, being orthogonal to every generator $r_i$ implies $x$ is orthogonal to the entire space $upright("Row") (X)$. Thus, $upright("Ker") (X) = { x divides x perp upright("Row") (X) } = [upright("Row") (X)]^perp$.

]
=== Nullity Theorem
<nullity-theorem>
There is a fundamental relationship between the dimensions of these spaces.

#theorem("Rank-Nullity Theorem")[
For an $n times p$ matrix $X$: $ upright("Rank") (X) + upright("Nullity") (X) = p $ where $upright("Nullity") (X) = upright("Dim") (upright("Ker") (X))$.

] <thm-nullity>
#block[
#emph[Proof];. From the previous theorem, we established that the kernel is the orthogonal complement of the row space: $ upright("Ker") (X) = [upright("Row") (X)]^perp $

Since the row space is a subspace of $bb(R)^p$, the entire space can be decomposed into the direct sum of the row space and its orthogonal complement:

$ bb(R)^p = upright("Row") (X) xor [upright("Row") (X)]^perp = upright("Row") (X) xor upright("Ker") (X) $

Taking the dimensions of these spaces:

$ upright("Dim") (bb(R)^p) = upright("Dim") (upright("Row") (X)) + upright("Dim") (upright("Ker") (X)) $

Substituting the definitions of Rank (dimension of row/column space) and Nullity:

$ p = upright("Rank") (X) + upright("Nullity") (X) $

]
#strong[Comparing Ranks via Kernel Containment]

The Rank-Nullity Theorem provides a powerful and convenient tool for comparing the ranks of two matrices $A$ and $B$ (with the same number of columns) by inspecting their null spaces.

#theorem("Kernel Containment and Rank Inequality")[
Let $A$ and $B$ be two matrices with $p$ columns. If the kernel of $A$ is contained within the kernel of $B$, then the rank of $A$ is greater than or equal to the rank of $B$. $ upright("Ker") (A) subset.eq upright("Ker") (B) arrow.r.double.long upright("Rank") (A) gt.eq upright("Rank") (B) $

] <thm-rank-kernel>
#block[
#emph[Proof];. From the subspace inclusion $upright("Ker") (A) subset.eq upright("Ker") (B)$, it follows that the dimension of the smaller space cannot exceed the dimension of the larger space: $ upright("Nullity") (A) lt.eq upright("Nullity") (B) $ Using the Rank-Nullity Theorem ($upright("Rank") = p - upright("Nullity")$), we reverse the inequality: $ p - upright("Nullity") (A) gt.eq p - upright("Nullity") (B) $ $ upright("Rank") (A) gt.eq upright("Rank") (B) $

]
=== Rank Inequalities
<rank-inequalities>
Understanding the bounds of the rank of matrix products is crucial for deriving properties of linear estimators.

#theorem("Rank of a Matrix Product")[
Let $X$ be an $n times p$ matrix and $Z$ be a $p times k$ matrix. The rank of their product $X Z$ is bounded by the rank of the individual matrices: $ upright("Rank") (X Z) lt.eq min (upright("Rank") (X) \, upright("Rank") (Z)) $

] <thm-rank-product>
#block[
#emph[Proof];. The columns of $X Z$ are linear combinations of the columns of $X$. Thus, the column space of $X Z$ is a subspace of the column space of $X$: $ upright("Col") (X Z) subset.eq upright("Col") (X) arrow.r.double.long upright("Rank") (X Z) lt.eq upright("Rank") (X) $ Similarly, the rows of $X Z$ are linear combinations of the rows of $Z$. Thus, the row space of $X Z$ is a subspace of the row space of $Z$: $ upright("Row") (X Z) subset.eq upright("Row") (Z) arrow.r.double.long upright("Rank") (X Z) lt.eq upright("Rank") (Z) $

]
#strong[Rank and Invertible Matrices]

Multiplying by an invertible (non-singular) matrix preserves the rank. This is a very useful property when manipulating linear equations.

#theorem("Rank with Non-Singular Multiplication")[
Let $A$ be an $n times n$ invertible matrix (i.e., $upright("Rank") (A) = n$) and $X$ be an $n times p$ matrix. Then: $ upright("Rank") (A X) = upright("Rank") (X) $

Similarly, if $B$ is a $p times p$ invertible matrix, then:

$ upright("Rank") (X B) = upright("Rank") (X) $

] <thm-rank-invertible>
#block[
#emph[Proof];. From the previous theorem, we know $upright("Rank") (A X) lt.eq upright("Rank") (X)$. Since $A$ is invertible, we can write $X = A^(- 1) (A X)$. Applying the theorem again: $ upright("Rank") (X) = upright("Rank") (A^(- 1) (A X)) lt.eq upright("Rank") (A X) $ Thus, $upright("Rank") (A X) = upright("Rank") (X)$.

]
=== Rank of $X' X$ and $X X'$
<rank-of-xx-and-xx>
The matrix $X' X$ (the Gram matrix) appears in the normal equations for least squares ($X' X beta = X' y$). Its properties are closely tied to $X$.

#theorem("Rank of Gram Matrix")[
For any real matrix $X$, the rank of $X' X$ and $X X'$ is the same as the rank of $X$ itself: $ upright("Rank") (X ' X) = upright("Rank") (X) $ $ upright("Rank") (X X ') = upright("Rank") (X) $

] <thm-rank-gram>
#block[
#emph[Proof];. We first show that the null space (kernel) of $X$ is the same as the null space of $X' X$. If $v in upright("Ker") (X)$, then $X v = 0 arrow.r.double.long X' X v = 0 arrow.r.double.long v in upright("Ker") (X ' X)$. Conversely, if $v in upright("Ker") (X ' X)$, then $X' X v = 0$. Multiply by $v'$: $ v' X' X v = 0 arrow.r.double.long (X v)' (X v) = 0 arrow.r.double.long lr(||) X v lr(||)^2 = 0 arrow.r.double.long X v = 0 $ So $upright("Ker") (X) = upright("Ker") (X ' X)$. By the Rank-Nullity Theorem, since they have the same number of columns and same nullity, they must have the same rank.

]
#strong[Column Space of] $X X'$

Beyond just the rank, the column spaces themselves are related.

#theorem("Column Space Equivalence")[
The column space of $X X'$ is identical to the column space of $X$: $ upright("Col") (X X ') = upright("Col") (X) $

] <thm-colspace-gram>
#block[
#emph[Proof];. 

+ #strong[Forward (];$subset.eq$): Let $z in upright("Col") (X X ')$. Then $z = X X' w$ for some vector $w$. We can rewrite this as $z = X (X ' w)$. Since $z$ is a linear combination of columns of $X$ (with coefficients $X' w$), $z in upright("Col") (X)$. Thus, $upright("Col") (X X ') subset.eq upright("Col") (X)$.

+ #strong[Equality via Rank:] From the previous theorem, we know that $upright("Rank") (X X ') = upright("Rank") (X)$. Since $upright("Col") (X X ')$ is a subspace of $upright("Col") (X)$ and they have the same finite dimension (Rank), the subspaces must be identical.

]
#strong[Implication:] This property ensures that for any $y$, the projection of $y$ onto $upright("Col") (X)$ lies in the same space as the projection onto $upright("Col") (X X ')$. This is vital for the existence of solutions in generalized least squares.

== Orthogonal Projection onto a Subspace
<orthogonal-projection-onto-a-subspace>
#block[
Let $V$ be a subspace of $bb(R)^n$. For any vector $y in bb(R)^n$, there exists a #strong[unique] vector $hat(y) in V$ such that the residual is orthogonal to the subspace: $ (y - hat(y)) perp V $

Equivalently:

$ angle.l y - hat(y) \, v angle.r = 0 quad forall v in V $

]
=== Equivalence to Least Squares
<equivalence-to-least-squares>
The geometric definition of projection (orthogonality) is mathematically equivalent to the optimization problem of minimizing distance (least squares).

#theorem("Best Approximation Theorem (Least Squares Property)")[
Let $V$ be a subspace of $bb(R)^n$ and $y in bb(R)^n$. Let $hat(y)$ be the orthogonal projection of $y$ onto $V$. Then $hat(y)$ is the closest point in $V$ to $y$. That is, for any vector $v in V$ such that $v eq.not hat(y)$: $ parallel y - hat(y) parallel^2 < parallel y - v parallel^2 $

] <thm-best-approximation>
#block[
#emph[Proof];. Let $v$ be any vector in $V$. We can rewrite the difference vector $y - v$ by adding and subtracting the projection $hat(y)$: $ y - v = (y - hat(y)) + (hat(y) - v) $

Observe the properties of the two terms on the right-hand side:

+ #strong[Residual:] $(y - hat(y))$ is orthogonal to $V$ by definition.
+ #strong[Difference in Subspace:] Since both $hat(y) in V$ and $v in V$, their difference $(hat(y) - v)$ is also in $V$.

Therefore, the two terms are orthogonal to each other:

$ (y - hat(y)) perp (hat(y) - v) $

Applying the Pythagorean Theorem:

$ parallel y - v parallel^2 = parallel y - hat(y) parallel^2 + parallel hat(y) - v parallel^2 $

Since squared norms are non-negative, and $parallel hat(y) - v parallel^2 > 0$ (because $v eq.not hat(y)$):

$ parallel y - v parallel^2 > parallel y - hat(y) parallel^2 $ The projection $hat(y)$ minimizes the squared error distance (and error distance itself).

]
#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-3d-proof-1.png"))
], caption: figure.caption(
position: bottom, 
[
Visualization of the Best Approximation Theorem
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-3d-proof>


=== Uniqueness of Projection
<uniqueness-of-projection>
While the existence of a least-squares solution is guaranteed, we must also prove that there is only one such vector.

#theorem("Uniqueness of Orthogonal Projection")[
For a given vector $y$ and subspace $V$, the projection vector $hat(y)$ satisfying $(y - hat(y)) perp V$ is unique.

] <thm-projection-uniqueness>
#block[
#emph[Proof];. Assume there are two vectors $hat(y)_1 in V$ and $hat(y)_2 in V$ that both satisfy the orthogonality condition. $ (y - hat(y)_1) perp V quad upright("and") quad (y - hat(y)_2) perp V $ This means that for any $v in V$, both inner products are zero: $ angle.l y - hat(y)_1 \, v angle.r = 0 $ $ angle.l y - hat(y)_2 \, v angle.r = 0 $

Subtracting the second equation from the first:

$ angle.l y - hat(y)_1 \, v angle.r - angle.l y - hat(y)_2 \, v angle.r = 0 $ Using the linearity of the inner product: $ angle.l (y - hat(y)_1) - (y - hat(y)_2) \, v angle.r = 0 $ $ angle.l hat(y)_2 - hat(y)_1 \, v angle.r = 0 $

This equation holds for #strong[all] $v in V$. Since $hat(y)_1$ and $hat(y)_2$ are both in $V$, their difference $d = hat(y)_2 - hat(y)_1$ must also be in $V$. We can therefore choose $v = d = hat(y)_2 - hat(y)_1$.

$ angle.l hat(y)_2 - hat(y)_1 \, hat(y)_2 - hat(y)_1 angle.r = 0 arrow.r.double.long parallel hat(y)_2 - hat(y)_1 parallel^2 = 0 $ The only vector with a norm of zero is the zero vector itself. $ hat(y)_2 - hat(y)_1 = 0 arrow.r.double.long hat(y)_1 = hat(y)_2 $ Thus, the projection is unique.

]
== Projection via Orthonormal Basis ($Q$)
<projection-via-orthonormal-basis-q>
=== Orthonomal Basis
<orthonomal-basis>
Before discussing projections onto general subspaces, we must formally define the coordinate system of a subspace, known as a basis.

#definition("Basis")[
A set of vectors ${ x_1 \, dots.h \, x_k }$ is a #strong[Basis] for a vector space $V$ if:

+ The vectors span the space: $V = L (x_1 \, dots.h \, x_k)$.
+ The vectors are linearly independent.

] <def-basis>
The number of vectors in a basis is unique and is defined as the #strong[Dimension] of $V$.

Calculations become significantly simpler if we choose a basis with special geometric properties.

#definition("Orthonormal Basis")[
A basis ${ q_1 \, dots.h \, q_k }$ is called an #strong[Orthonormal Basis] if:

+ #strong[Orthogonal:] Each pair of vectors is perpendicular.

$ q_i' q_j = 0 quad upright("for ") i eq.not j $

#block[
#set enum(numbering: "1.", start: 2)
+ #strong[Normalized:] Each vector has unit length.
]

$ lr(||) q_i lr(||)^2 = q_i' q_i = 1 $

Combining these, we write $q_i' q_j = delta_(i j)$ (Kronecker delta).

] <def-orthonormal-basis>
We now generalize the projection problem. Instead of projecting $y$ onto a single line, we project it onto a subspace $V$ of dimension $k$.

If we have an orthonormal basis ${ q_1 \, dots.h \, q_k }$ for $V$, the projection $hat(y)$ is simply the sum of the projections onto the individual basis vectors.

#definition("Projection Defined with Orthonormal Basis")[
The projection of $y$ onto the subspace $V = L (q_1 \, dots.h \, q_k)$ is: $ hat(y) = sum_(i = 1)^k upright("proj") (y \| q_i) = sum_(i = 1)^k (q_i ' y) q_i $

Since the basis vectors are normalized, we do not need to divide by $lr(||) q_i lr(||)^2$.

] <def-proj-orthonormal>
#theorem("Projection via Orthonormal Basis")[
Let ${ q_1 \, dots.h \, q_k }$ be an orthonormal basis for the subspace $V subset.eq bb(R)^n$. The vector defined by the sum of individual projections: $ hat(y) = sum_(i = 1)^k angle.l y \, q_i angle.r q_i $ is indeed the orthogonal projection of $y$ onto $V$. That is, it satisfies $(y - hat(y)) perp V$.

] <thm-orthonormal-basis-proj>
#block[
#emph[Proof];. To prove this, we must check two conditions:

+ $hat(y) in V$: This is immediate because $hat(y)$ is a linear combination of the basis vectors ${ q_1 \, dots.h \, q_k }$.

+ $(y - hat(y)) perp V$: It suffices to show that the error vector $e = y - hat(y)$ is orthogonal to every basis vector $q_j$ (for $j = 1 \, dots.h \, k$).

  Let's calculate the inner product $angle.l y - hat(y) \, q_j angle.r$:

  $ angle.l y - hat(y) \, q_j angle.r & = angle.l y \, q_j angle.r - angle.l hat(y) \, q_j angle.r\
   & = angle.l y \, q_j angle.r - ⟨sum_(i = 1)^k angle.l y \, q_i angle.r q_i \, q_j⟩\
   & = angle.l y \, q_j angle.r - sum_(i = 1)^k angle.l y \, q_i angle.r underbrace(angle.l q_i \, q_j angle.r, delta_(i j)) $

  Since the basis is orthonormal, $angle.l q_i \, q_j angle.r$ is 1 if $i = j$ and 0 otherwise. Thus, the summation collapses to a single term where $i = j$:

  $ angle.l y - hat(y) \, q_j angle.r & = angle.l y \, q_j angle.r - angle.l y \, q_j angle.r dot.op 1\
   & = 0 $

  Since $(y - hat(y))$ is orthogonal to every basis vector $q_j$, it is orthogonal to the entire subspace $V$. Thus, $hat(y)$ is the unique orthogonal projection.

]
=== Projection Matrix via Orthonomal Basis ($Q$)
<projection-matrix-via-orthonomal-basis-q>
#strong[Matrix Form with Orthonormal Basis]

We can express the summation formula for $hat(y)$ compactly using matrix notation.

Let $Q$ be an $n times k$ matrix whose columns are the orthonormal basis vectors $q_1 \, dots.h \, q_k$.

$ Q = mat(delim: "(", q_1, q_2, dots.h, q_k) $

Properties of $Q$:

- $Q' Q = I_k$ (Identity matrix of size $k times k$).
- $Q Q'$ is #strong[not] necessarily $I_n$ (unless $k = n$).

#definition("Projection Matrix in Terms of $Q$")[
The projection $hat(y)$ can be written as: $ hat(y) = mat(delim: "(", q_1, dots.h, q_k) vec(q_1' y, dots.v, q_k' y) = Q (Q ' y) = (Q Q ') y $

Thus, the projection matrix $P$ onto the subspace $V$ is:

$ P = Q Q' $

] <def-proj-matrix-orthonormal>
#strong[Properties of Projection Matrices]

We have defined the projection matrix as $P = X (X ' X)^(- 1) X'$ (or $P = Q Q'$ for orthonormal bases). All orthogonal projection matrices share two fundamental algebraic properties.

#theorem("Symmeticity and Idempotence")[
A square matrix $P$ represents an orthogonal projection onto some subspace if and only if it satisfies:

+ #strong[Idempotence:] $P^2 = P$ (Applying the projection twice is the same as applying it once).
+ #strong[Symmetry:] $P' = P$.

] <thm-projection-properties>
#block[
#emph[Proof];. If $hat(y) = P y$ is already in the subspace $upright("Col") (X)$, then projecting it again should not change it. $ P (P y) = P y arrow.r.double.long P^2 y = P y quad forall y $ Thus, $P^2 = P$.

]
#strong[Example: ANOVA (Analysis of Variance)]

One of the most common applications of projection is in Analysis of Variance (ANOVA). We can view the calculation of group means as a projection onto a subspace defined by group indicator variables.

#example("Finding Projection for One-way ANOVA")[
Consider a one-way ANOVA model with $k$ groups: $ y_(i j) = mu_i + epsilon.alt_(i j) $ where $i in { 1 \, dots.h \, k }$ represents the group and $j in { 1 \, dots.h \, n_i }$ represents the observation within the group. Let $N = sum_(i = 1)^k n_i$ be the total number of observations.

+ #strong[Matrix Definitions]

  We define the data vector $y$ and the design matrix $X$ as follows:

  - #strong[Data Vector] ($y$): An $N times 1$ vector containing all observations by group:

  $ y = vec(y_11, dots.v, y_(1 n_1), y_21, dots.v, y_(k n_k)) $

  - #strong[Design Matrix] ($X$): An $N times k$ matrix constructed from $k$ column vectors, $X = (x_1 \, x_2 \, dots.h \, x_k)$. Each vector $x_g$ is an #strong[indicator] (dummy variable) for group $g$:

  $ x_g = vec(0, dots.v, 1, dots.v, 0) quad arrow.l upright("Entries are 1 if observation belongs to group ") g $

+ #strong[Orthogonality]

  These column vectors $x_1 \, dots.h \, x_k$ are mutually orthogonal because no observation can belong to two groups at once. The dot product of any two distinct columns is zero:

  $ angle.l x_g \, x_h angle.r = 0 quad upright("for ") g eq.not h $ This allows us to find the projection onto the column space of $X$ by simply summing the projections onto each column individually.

+ #strong[Calculating Individual Projections]

  For a specific group vector $x_g$, the projection is:

  $ upright("proj") (y \| x_g) = frac(angle.l y \, x_g angle.r, angle.l x_g \, x_g angle.r) x_g $

  We calculate the two scalar terms:

  - #strong[Denominator] ($angle.l x_g \, x_g angle.r$): The sum of squared elements of $x_g$. Since $x_g$ contains $n_g$ ones and zeros elsewhere:

  $ angle.l x_g \, x_g angle.r = sum bb(1)_({ i = g })^2 = n_g $

  - #strong[Numerator] ($angle.l y \, x_g angle.r$): The dot product sums only the $y$ values belonging to group $g$:

  $ angle.l y \, x_g angle.r = sum_(i \, j) y_(i j) dot.op bb(1)_({ i = g }) = sum_(j = 1)^(n_g) y_(g j) = y_(g .) quad (upright("Group Total")) $

+ #strong[The Resulting Projection]

  Substituting these back into the formula gives the coefficient for the vector $x_g$:

  $ upright("proj") (y \| x_g) = y_(g .) / n_g x_g = macron(y)_(g .) x_g $

  The total projection $hat(y)$ is the sum over all groups:

  $ hat(y) = sum_(g = 1)^k macron(y)_(g .) x_g $ This confirms that the fitted value for any specific observation $y_(i j)$ is simply its group mean $macron(y)_(i .)$.

] <exm-anova-projection>
=== Gram-Schmidt Process
<gram-schmidt-process>
To use the simplified formula $P = Q Q'$, we need an orthonormal basis. The Gram-Schmidt process provides a method to construct such a basis from any set of linearly independent vectors.

#algorithm[
#strong[Gram-Schmidt Process] Given linearly independent vectors $x_1 \, dots.h \, x_p$:

+ #strong[Step 1:] Normalize the first vector.

$ q_1 = frac(x_1, lr(||) x_1 lr(||)) $

#block[
#set enum(numbering: "1.", start: 2)
+ #strong[Step 2:] Project $x_2$ onto $q_1$ and subtract it to find the orthogonal component.
]

$ v_2 = x_2 - (x_2 ' q_1) q_1 $ Then normalize: $ q_2 = frac(v_2, lr(||) v_2 lr(||)) $

#block[
#set enum(numbering: "1.", start: 3)
+ #strong[Step k:] Subtract the projections onto all previous $q$ vectors.
]

$ v_k = x_k - sum_(j = 1)^(k - 1) (x_k ' q_j) q_j $ $ q_k = frac(v_k, lr(||) v_k lr(||)) $

]
#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-gram-schmidt-python-3.png"))
], caption: figure.caption(
position: bottom, 
[
Gram-Schmidt Process: Projecting $x_2$ onto $x_1$
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-gram-schmidt-python>


This process leads to the #strong[QR Decomposition] of a matrix: $X = Q R$, where $Q$ is orthogonal and $R$ is upper triangular.

== Hat Matrix (Projection Matrix via $X$)
<hat-matrix-projection-matrix-via-x>
=== Norm Equations
<norm-equations>
Let $X = (x_1 \, dots.h \, x_p)$ be an $n times p$ matrix, where each column $x_j$ is a predictor vector.

We want to project the target vector $y$ onto the column space $upright("Col") (X)$. This is equivalent to finding a coefficient vector $beta in bb(R)^p$ such that the error vector (residual) is orthogonal to the entire subspace $upright("Col") (X)$.

$ y - X beta perp upright("Col") (X) $

Since the columns of $X$ span the subspace, the residual must be orthogonal to #strong[every] column vector $x_j$ individually:

$ y - X beta perp x_j quad upright("for ") j = 1 \, dots.h \, p $

Writing this geometric condition as an algebraic dot product (where $x_j'$ denotes the transpose):

$ x_j' (y - X beta) = 0 quad upright("for each ") j $

We can stack these $p$ separate linear equations into a single matrix equation. Since the rows of $X'$ are the columns of $X$, this becomes:

$ vec(x_1', dots.v, x_p') (y - X beta) = upright(bold(0)) arrow.r.double.long X' (y - X beta) = 0 $

Finally, we distribute the matrix transpose and rearrange terms to solve for $beta$:

$ X' y - X' X beta & = 0\
X' X beta & = X' y $

This system is known as the #strong[Normal Equations];.

#theorem("Least Squares Estimator")[
If $X' X$ is invertible (i.e., $X$ has full column rank), the unique solution for $beta$ is: $ hat(beta) = (X ' X)^(- 1) X' y $

] <thm-least-squares-estimator>
=== Hat Matrix
<hat-matrix>
Substituting the estimator $hat(beta)$ back into the equation for $hat(y)$ gives us the projection matrix.

#definition("Hat Matrix")[
The projection of $y$ onto $upright("Col") (X)$ is given by: $ hat(y) = X hat(beta) = X (X ' X)^(- 1) X' y $

Thus, the hat matrix $H$ is defined as:

$ H = X (X ' X)^(- 1) X' $

] <def-projection-matrix-general>
=== Equivalence of Hat Matrix and $Q Q'$
<equivalence-of-hat-matrix-and-qq>
If we use the QR decomposition such that $X = Q R$, where the columns of $Q$ form an orthonormal basis for $upright("Col") (X)$, the formula simplifies significantly.

Recall that for orthonormal columns, $Q' Q = I$. Substituting $X = Q R$ into the general formula:

$ H & = Q R ((Q R) ' (Q R))^(- 1) (Q R)'\
 & = Q R (R ' Q ' Q R)^(- 1) R' Q'\
 & = Q R (R ' underbrace(Q' Q, I) R)^(- 1) R' Q'\
 & = Q R (R ' R)^(- 1) R' Q'\
 & = Q R R^(- 1) (R ')^(- 1) R' Q'\
 & = Q underbrace(R R^(- 1), I) underbrace((R ')^(- 1) R', I) Q'\
 & = Q Q' $

This confirms that $H = Q Q'$ is consistent with the general formula $H = X (X ' X)^(- 1) X'$.

=== Properties of Hat Matrix
<properties-of-hat-matrix>
We revisit the properties of projection matrices in this general context.

#theorem("Properties of Hat Matrix")[
The matrix $H = X (X ' X)^(- 1) X'$ satisfies:

+ #strong[Symmetric:] $H' = H$
+ #strong[Idempotent:] $H^2 = H$
+ #strong[Trace:] The trace of a projection matrix equals the dimension of the subspace it projects onto. $ upright("tr") (H) = upright("tr") (X (X ' X)^(- 1) X ') = upright("tr") ((X ' X)^(- 1) X ' X) = upright("tr") (I_p) = p $

] <thm-projection-properties-revisited>
== Projection Defined with Orthogonal Projection Matrix
<projection-defined-with-orthogonal-projection-matrix>
Projection don't have to be defined with a subspace or a matrix $X$ as we discussed before. Projection matrix is a self-contained definition of the subspace it projects onto.

=== Orthogonal Projection Matrix
<orthogonal-projection-matrix>
#definition("Orthogonal Projection Matrix")[
A square matrix $P$ is called an #strong[orthogonal projection matrix] if it satisfies two conditions:

+ #strong[Symmetry:] $P^tack.b = P$
+ #strong[Idempotency:] $P^2 = P$

] <def-proj-matrix>
#theorem("Projection onto Column Space")[
Let $P$ be a $p times p$ symmetric ($P^tack.b = P$) and idempotent ($P^2 = P$) matrix in $bb(R)^p$. Then $P$ represents the orthogonal projection onto its column space, $upright("Col") (P)$.

Specifically, for any vector $y in bb(R)^p$, the vector $hat(y) = P y$ satisfies the definition of orthogonal projection:

+ $hat(y) in upright("Col") (P)$
+ $y - hat(y) perp upright("Col") (P)$

] <thm-proj-col>
#block[
#emph[Proof];. To prove that $P$ is the orthogonal projector onto $upright("Col") (P)$, we verify the two conditions for an arbitrary vector $y in bb(R)^p$.

+ Condition: $hat(y) in upright("Col") (P)$

  By the definition of matrix-vector multiplication, $hat(y) = P y$ is a linear combination of the columns of $P$. Therefore, $hat(y)$ is, by definition, an element of $upright("Col") (P)$.

+ Condition: $y - hat(y) perp upright("Col") (P)$

  Let $e = y - hat(y) = (I_n - P) y$. To verify that $e$ is orthogonal to $upright("Col") (P)$, it suffices to show that $e$ is orthogonal to every column of $P$. In matrix notation, this is equivalent to showing $e^tack.b P = 0$. We compute this directly:

$ e^tack.b P & = [(I_p - P) y]^tack.b P\
 & = y^tack.b (I_p - P)^tack.b P\
 & = y^tack.b (I_p - P) P & (upright("Symmetry: ") P^tack.b = P)\
 & = y^tack.b (P - P^2)\
 & = y^tack.b (P - P) & (upright("Idempotency: ") P^2 = P)\
 & = 0 $

Since $e^tack.b P = 0$, the residual $e$ is orthogonal to every column of $P$. Consequently, $e$ is orthogonal to the space spanned by those columns, $upright("Col") (P)$.

]
#lemma("0-1 Projection")[
Let $P$ be a $n times n$ matrix. $P$ is the orthogonal projection matrix onto $upright("Col") (P)$ if and only if:

#block[
#set enum(numbering: "1)", start: 1)
+ $P v = v$ for all $v in upright("Col") (P)$.
+ $P v = 0$ for all $v perp upright("Col") (P)$.
]

] <lem-projection-props>
#block[
#emph[Proof];. #strong[Forward Implication ($arrow.r.double.long$):] Given $P$ is an orthogonal projection ($P^2 = P \, P^tack.b = P$).

#block[
#set enum(numbering: "(1)", start: 1)
+ #strong[Proof of (1):] Let $v in upright("Col") (P)$. Then $v = P x$ for some $x$. $ P v = P (P x) = P^2 x = P x = v $
+ #strong[Proof of (2):] Let $v perp upright("Col") (P)$. Then $v$ is orthogonal to every column of $P$, so $v^tack.b P = 0$. Since $P$ is symmetric:
]

$ P v = (v^tack.b P^tack.b)^tack.b = (v^tack.b P)^tack.b = 0^tack.b = 0 $

#strong[Reverse Implication ($arrow.l.double.long$):] Given conditions (1) and (2) hold.

We must show that $P$ is idempotent ($P^2 = P$) and symmetric ($P^tack.b = P$).

#block[
#set enum(numbering: "(1)", start: 1)
+ #strong[Proof of Idempotence ($P^2 = P$):] For any vector $x in bb(R)^n$, let $y = P x$. By definition, $y in upright("Col") (P)$. Applying condition (1) to the vector $y$: $ P y = y arrow.r.double.long P (P x) = P x arrow.r.double.long P^2 x = P x $ Since this holds for all $x$, $P^2 = P$.

+ #strong[Proof of Symmetry ($P^tack.b = P$):] We decompose any two vectors $x \, y in bb(R)^n$ into components inside and orthogonal to $upright("Col") (P)$. Let $x = x_1 + x_2$ and $y = y_1 + y_2$, where $x_1 \, y_1 in upright("Col") (P)$ and $x_2 \, y_2 perp upright("Col") (P)$. Using conditions (1) and (2): $ P x = P (x_1 + x_2) = P x_1 + P x_2 =^((1) \, (2)) x_1 + 0 = x_1 $ \
  $ P y = P (y_1 + y_2) = P y_1 + P y_2 =^((1) \, (2)) y_1 + 0 = y_1 $ Now we compare the inner products $angle.l P x \, y angle.r$ and $angle.l x \, P y angle.r$: $ angle.l P x \, y angle.r = angle.l x_1 \, y_1 + y_2 angle.r = angle.l x_1 \, y_1 angle.r + underbrace(angle.l x_1 \, y_2 angle.r, 0) = angle.l x_1 \, y_1 angle.r $
]

$ angle.l x \, P y angle.r = angle.l x_1 + x_2 \, y_1 angle.r = angle.l x_1 \, y_1 angle.r + underbrace(angle.l x_2 \, y_1 angle.r, 0) = angle.l x_1 \, y_1 angle.r $ Since $angle.l P x \, y angle.r = angle.l x \, P y angle.r$ implies $x^tack.b P^tack.b y = x^tack.b P y$ for all $x \, y$, we conclude $P^tack.b = P$.

Since $P$ is symmetric and idempotent, it is the orthogonal projection matrix.

]
=== Projection onto Complement Space
<projection-onto-complement-space>
#theorem("Projection onto Orthogonal Complement")[
Let $P$ be a $n times n$ orthogonal projection matrix operating in the space $bb(R)^n$. The matrix $M$ defined as: $ M = I_p - P $ is the orthogonal projection matrix onto the orthogonal complement of the column space of $P$, denoted $upright("Col") (P)^perp subset.eq bb(R)^n$.

] <thm-complement-proj>
#block[
#emph[Proof];. 

#block[
#set enum(numbering: "(1)", start: 1)
+ #strong[Symmetry and Idempotency] Since $P$ is a projection matrix, $P^tack.b = P$ and $P^2 = P$. We verify these properties for $M$: #math.equation(block: true, numbering: "(1)", [ $ M^tack.b = (I_p - P)^tack.b = I_p - P^tack.b = I_p - P = M $ ])<eq-m-sym> #math.equation(block: true, numbering: "(1)", [ $ M^2 = (I_p - P) (I_p - P) = I_p - 2 P + P^2 = I_p - 2 P + P = I_p - P = M $ ])<eq-m-idemp> By #ref(<eq-m-sym>, supplement: [Equation]) and #ref(<eq-m-idemp>, supplement: [Equation]), $M$ is symmetric and idempotent, so it is an orthogonal projection matrix.

+ #strong[Identifying the Subspace] We now show that $upright("Col") (M) = upright("Col") (P)^perp$ by mutual inclusion.

  #block[
  #set enum(numbering: "(1)", start: 1)
  + #strong[Direction 1];: $upright("Col") (M) subset.eq upright("Col") (P)^perp$ Let $v in upright("Col") (M)$. Then $v = M x$ for some vector $x$. Multiplying by $P$: $ P v = P (I_p - P) x = (P - P^2) x = 0 $ Since $P$ is symmetric ($P = P'$), taking the transpose of $P v = 0$ gives $v' P = 0$. This means $v$ is orthogonal to every column of $P$. Therefore, $v in upright("Col") (P)^perp$.

  + #strong[Direction 2];: $upright("Col") (P)^perp subset.eq upright("Col") (M)$ Let $v in upright("Col") (P)^perp$. By definition, $v$ is orthogonal to the columns of $P$, so $v' P = 0$. Taking the transpose and using symmetry ($P' = P$), we get $P v = 0$. \
    Now applying $M$ to $v$: $ M v = (I_p - P) v = v - P v = v $ Since $M v = v$, $v$ lies in the column space of $M$. Therefore, $v in upright("Col") (M)$.
  ]
]

Since both inclusions hold, $upright("Col") (M) = upright("Col") (P)^perp$.

]
=== Projections onto Nested Subspaces
<projections-onto-nested-subspaces>
==== Iterative Projections
<iterative-projections>
#theorem("Iterative Projections")[
Let $P_0$ and $P_1$ be $n times n$ orthogonal projection matrices such that $upright("Col") (P_0) subset.eq upright("Col") (P_1)$. Then:

#block[
#set enum(numbering: "(1)", start: 1)
+ $P_1 P_0 = P_0$
+ $P_0 P_1 = P_0$
]

] <thm-nested-projections>
#block[
#emph[Proof];. #strong[Method 1];:

Proof of $P_1 P_0 = P_0$:

Let $y in bb(R)^n$ be an arbitrary vector. By definition, the vector $v = P_0 y$ lies in $upright("Col") (P_0)$. Given $upright("Col") (P_0) subset.eq upright("Col") (P_1)$, it follows that $v in upright("Col") (P_1)$.

Using #strong[Lemma #ref(<lem-projection-props>, supplement: [Lemma])];, since $v in upright("Col") (P_1)$, $P_1$ acts as the identity on $v$, so $P_1 v = v$. Substituting $v = P_0 y$:

$ P_1 (P_0 y) = P_0 y $

Since $P_1 P_0 y = P_0 y$ holds for all $y in bb(R)^n$, we conclude $P_1 P_0 = P_0$.

Proof of $P_0 P_1 = P_0$:

Taking the transpose of the result from part 1 and applying the symmetry property ($P' = P$):

$ (P_1 P_0)' = P_0' arrow.r.double.long P_0' P_1' = P_0' arrow.r.double.long P_0 P_1 = P_0 $

#strong[Method 2];:

To prove $P_0 P_1 = P_0$, for any $y in bb(R)^n$, let $hat(y)_1 = P_1 y$, $hat(y)_0 = P_0 y$, $e_1 = y - hat(y)_1$, and $e_0 = y - hat(y)_0$. Note that both $e_0$ and $e_1$ are orthogonal to $upright("Col") (P_0)$ (since $upright("Col") (P_0) subset.eq upright("Col") (P_1)$).

We have:

$ P_0 (P_1 - P_0) y = P_0 (hat(y)_1 - hat(y)_0) = P_0 (e_0 - e_1) = 0 $

This implies $P_0 P_1 - P_0 = 0$, so $P_0 P_1 = P_0$.

]
==== Difference of Projections
<difference-of-projections>
#theorem("Difference Projection")[
The matrix $P_Delta = P_1 - P_0$ is an orthogonal projection matrix onto the subspace $upright("Col") (P_1) sect upright("Col") (P_0)^perp$. This subspace represents the "extra" information in the full model that is orthogonal to the reduced model. Additionally, the following column space relationship holds: $ upright("Col") (P_1 - P_0) = upright("Col") (P_0)^perp sect upright("Col") (P_1) $

] <thm-diff-projection>
#block[
#emph[Proof];. 

+ #strong[Symmetry:] Since $P_1$ and $P_0$ are symmetric:

$ (P_1 - P_0)' = P_1' - P_0' = P_1 - P_0 $

#block[
#set enum(numbering: "1.", start: 2)
+ #strong[Idempotency:]
]

$ (P_1 - P_0)^2 & = (P_1 - P_0) (P_1 - P_0)\
 & = P_1^2 - P_1 P_0 - P_0 P_1 + P_0^2 $ Using the projection property ($P^2 = P$) and the nested property ($P_1 P_0 = P_0$ and $P_0 P_1 = P_0$): $ = P_1 - P_0 - P_0 + P_0 = P_1 - P_0 $

#block[
#set enum(numbering: "1.", start: 3)
+ #strong[Orthogonality to $P_0$:]
]

$ (P_1 - P_0) P_0 = P_1 P_0 - P_0^2 = P_0 - P_0 = 0 $

#block[
#set enum(numbering: "1.", start: 4)
+ #strong[Column Space Identity:] We show $upright("Col") (P_1 - P_0) = upright("Col") (P_0)^perp sect upright("Col") (P_1)$ via double containment.

  #strong[$(subset.eq)$ Forward Containment:] Let $y in upright("Col") (P_1 - P_0)$. By definition, $y = (P_1 - P_0) x$ for some $x$.

  - Check $y in upright("Col") (P_1)$: $P_1 y = P_1 (P_1 - P_0) x = (P_1 - P_0) x = y$. Thus $y in upright("Col") (P_1)$.
  - Check $y in upright("Col") (P_0)^perp$: $P_0 y = P_0 (P_1 - P_0) x = (P_0 - P_0) x = 0$. Thus $y in upright("Col") (P_0)^perp$.
  - Therefore, $upright("Col") (P_1 - P_0) subset.eq upright("Col") (P_0)^perp sect upright("Col") (P_1)$.

  #strong[$(supset.eq)$ Reverse Containment];: Let $y in upright("Col") (P_0)^perp sect upright("Col") (P_1)$.

  - Since $y in upright("Col") (P_1)$, $P_1 y = y$.
  - Since $y in upright("Col") (P_0)^perp$, $P_0 y = 0$.
  - Observe $(P_1 - P_0) y = P_1 y - P_0 y = y - 0 = y$.
  - This implies $y$ is in the range of $(P_1 - P_0)$. Therefore, $upright("Col") (P_0)^perp sect upright("Col") (P_1) subset.eq upright("Col") (P_1 - P_0)$.
]

]
#block[
#callout(
body: 
[
This is important as we can use $P_2 - P_1$ to construct the projection matrix and the space that it projects onto.

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
#strong[Hat Matrix of Incremental Space]

#theorem("Hat Matrix of Incremental Space")[
Let $X_1$ be a design matrix of dimension $n times k_1$ and $X_2$ be a design matrix of dimension $n times k_2$, such that the combined matrix $X = [X_1 \, X_2]$ has full column rank. Let $V_1 = upright("Col") (X_1)$ and $V_2 = upright("Col") ([X_1 \, X_2])$. Let $P_1$ and $P_2$ be the orthogonal projection matrices onto $V_1$ and $V_2$, respectively.

Define the matrix of residuals $tilde(X)_2$ as:

$ tilde(X)_2 = (I - P_1) X_2 $

Let $W = upright("Col") (tilde(X)_2)$. Let $P_W$ be the $n times n$ projection matrix onto $W$, which is the hat matrix constructed from $tilde(X)_2$:

$ P_W = tilde(X)_2 (tilde(X)_2^T tilde(X)_2)^(- 1) tilde(X)_2^T $

#block[
#set enum(numbering: "(a)", start: 1)
+ Let $X^(\*) = [X_1 \, tilde(X)_2]$. Prove that the column space of the original design matrix $X$ is identical to the column space of the modified design matrix $X^(\*)$:
]

$ upright("Col") ([X_1 \, X_2]) = upright("Col") ([X_1 \, tilde(X)_2]) $

#block[
#set enum(numbering: "(a)", start: 2)
+ Using the result from Part (a) and the definition of the Hat Matrix, prove that:
]

$ P_W = P_2 - P_1 $

] <thm-hat-matrix-incremental>
#block[
#emph[Proof];. Assignment question.

]
=== Projection onto Three Multually Orthogonal Subspaces
<projection-onto-three-multually-orthogonal-subspaces>
#theorem("Orthogonal Decomposition")[
Let $M_0 subset M_1$ be two nested linear models associated with orthogonal projection matrices $P_0$ and $P_1$, such that $upright("Col") (P_0) subset upright("Col") (P_1)$.

For any observation vector $y$, we have the decomposition:

$ y = underbrace(P_0 y, hat(y)_0) + underbrace((P_1 - P_0) y, hat(y)_1 - hat(y)_0) + underbrace((I - P_1) y, y - hat(y)_1) $

#strong[Geometric Interpretation:]

+ $hat(y)_0 in upright("Col") (P_0)$: The fit of the reduced model.
+ $(hat(y)_1 - hat(y)_0) in upright("Col") (P_0)^perp sect upright("Col") (P_1)$: The additional fit provided by $M_1$ over $M_0$.
+ $(y - hat(y)_1) in upright("Col") (P_1)^perp$: The projection of $y$ onto the #strong[orthogonal complement] of $upright("Col") (P_1)$.

The three component vectors are mutually orthogonal. Consequently, their squared norms sum to the total squared norm:

$ parallel y parallel^2 = parallel hat(y)_0 parallel^2 + parallel hat(y)_1 - hat(y)_0 parallel^2 + parallel y - hat(y)_1 parallel^2 $

] <thm-nested-decomposition>
#theorem("Orthogonal Decomposition")[
Let $M_0 subset M_1$ be two nested linear models associated with orthogonal projection matrices $P_0$ and $P_1$, such that $upright("Col") (P_0) subset upright("Col") (P_1)$.

For any observation vector $y$, we have the decomposition:

$ y = underbrace(P_0 y, hat(y)_0) + underbrace((P_1 - P_0) y, hat(y)_1 - hat(y)_0) + underbrace((I - P_1) y, y - hat(y)_1) $

#strong[Geometric Interpretation:]

+ $hat(y)_0 in upright("Col") (P_0)$: The fit of the reduced model.
+ $(hat(y)_1 - hat(y)_0) in upright("Col") (P_0)^perp sect upright("Col") (P_1)$: The additional fit provided by $M_1$ over $M_0$.
+ $(y - hat(y)_1) in upright("Col") (P_1)^perp$: The projection of $y$ onto the #strong[orthogonal complement] of $upright("Col") (P_1)$.

The three component vectors are mutually orthogonal. Consequently, their squared norms sum to the total squared norm:

$ parallel y parallel^2 = parallel hat(y)_0 parallel^2 + parallel hat(y)_1 - hat(y)_0 parallel^2 + parallel y - hat(y)_1 parallel^2 $

] <thm-nested-hatmatrix>
#block[
#emph[Proof];. 

+ #strong[Definition of Vectors and Nested Spaces]

  Let $I$ be the identity matrix, which is the orthogonal projection onto the entire space $bb(R)^n$. We effectively have a three-level nested sequence of subspaces:

  $ upright("Col") (P_0) subset upright("Col") (P_1) subset bb(R)^n $ We define the components of the decomposition using successive difference projections:

  - $v_0 = P_0 y$
  - $v_1 = (P_1 - P_0) y$
  - $v_2 = (I - P_1) y$

  Summing these gives the identity: $y = v_0 + v_1 + v_2$.

+ #strong[Sequential Orthogonality via #ref(<thm-diff-projection>, supplement: [Theorem])]

  We apply the Difference Projection Theorem (#ref(<thm-diff-projection>, supplement: [Theorem])) to each successive pair of nested spaces to establish orthogonality.

  - #strong[Step 1: Verify $v_1 perp v_0$]
    - Consider the nested pair $P_0$ and $P_1$.
    - By #ref(<thm-diff-projection>, supplement: [Theorem]), the matrix $(P_1 - P_0)$ projects onto $upright("Col") (P_0)^perp sect upright("Col") (P_1)$.
    - Since $v_0 in upright("Col") (P_0)$ and $v_1$ lies in the orthogonal complement $upright("Col") (P_0)^perp$, we have #strong[$v_1 perp v_0$];.
  - #strong[Step 2: Verify $v_2 perp { v_0 \, v_1 }$]
    - Consider the nested pair $P_1$ and $I$ (where $I$ projects onto $bb(R)^n$).
    - By #ref(<thm-diff-projection>, supplement: [Theorem]), the matrix $(I - P_1)$ projects onto $upright("Col") (P_1)^perp sect bb(R)^n = upright("Col") (P_1)^perp$.
    - Since both $v_0$ and $v_1$ reside within $upright("Col") (P_1)$ (as shown in Step 1), and $v_2$ lies in the orthogonal complement $upright("Col") (P_1)^perp$, it follows that $v_2$ is orthogonal to the entire subspace $upright("Col") (P_1)$.
    - Therefore, #strong[$v_2 perp v_0$] and #strong[$v_2 perp v_1$];.

+ #strong[Conclusion]

  Since ${ v_0 \, v_1 \, v_2 }$ are mutually orthogonal, the Pythagorean theorem applies:

  $ parallel y parallel^2 = parallel v_0 parallel^2 + parallel v_1 parallel^2 + parallel v_2 parallel^2 $ Substituting the original definitions back in: $ parallel y parallel^2 = parallel hat(y)_0 parallel^2 + parallel hat(y)_1 - hat(y)_0 parallel^2 + parallel y - hat(y)_1 parallel^2 $

]
#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-anova-decomp-5.png"))
], caption: figure.caption(
position: bottom, 
[
Illustration of Projections onto Nested Subspaces
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-anova-decomp>


#example("ANOVA Sum Squares")[
We apply the #strong[Nested Model Theorem] ($M_0 subset M_1$) to the One-way ANOVA setting.

+ Notation and Definitions

  Consider a dataset with $k$ groups. Let $i = 1 \, dots.h \, k$ index the groups, and $j = 1 \, dots.h \, n_i$ index the observations within group $i$.

  - $N$: Total number of observations, $N = sum_(i = 1)^k n_i$.

  - $y_(i j)$: The $j$-th observation in the $i$-th group.

  - $macron(y)_(i .)$: The sample mean of group $i$.

  $ macron(y)_(i .) = 1 / n_i sum_(j = 1)^(n_i) y_(i j) $

  - $macron(y)_(. .)$: The grand mean of all observations.

  $ macron(y)_(. .) = 1 / N sum_(i = 1)^k sum_(j = 1)^(n_i) y_(i j) $

+ The Data and Projection Vectors

  #figure([
  #table(
    columns: (33.33%, 33.33%, 33.33%),
    align: (center,center,center,),
    table.header([Observation ($y$)], [Null Projection ($hat(y)_0$)], [Full Projection ($hat(y)_1$)],),
    table.hline(),
    [$vec(y_11, dots.v, y_(1 n_1), dots.v, y_(k 1), dots.v, y_(k n_k))$], [$vec(macron(y)_(. .), dots.v, macron(y)_(. .), dots.v, macron(y)_(. .), dots.v, macron(y)_(. .))$], [$vec(macron(y)_(1 .), dots.v, macron(y)_(1 .), dots.v, macron(y)_(k .), dots.v, macron(y)_(k .))$],
  )
  ], caption: figure.caption(
  position: top, 
  [
  ANOVA Vectors: Data, Null Model, and Full Model
  ]), 
  kind: "quarto-float-tbl", 
  supplement: "Table", 
  )
  <tbl-anova-vectors>


  #block[
  #set enum(numbering: "1.", start: 3)
  + Decomposition and Sum of Squares
  ]

  #table(
    columns: (19.18%, 19.18%, 19.18%, 19.18%, 23.29%),
    align: (left,center,center,left,left,),
    table.header([Component], [Notation], [Definition], [Vector Elements], [Squared Norm (Sum of Squares)],),
    table.hline(),
    [#strong[Null Proj.];], [$hat(y)_0$], [$P_0 y$], [Grand Mean ($macron(y)_(. .)$)], [$parallel hat(y)_0 parallel^2 = N macron(y)_(. .)^2$],
    [#strong[Full Proj.];], [$hat(y)_1$], [$P_1 y$], [Group Means ($macron(y)_(i .)$)], [$parallel hat(y)_1 parallel^2 = sum_(i = 1)^k n_i macron(y)_(i .)^2$],
  )

+ Geometric Justification of Shortcut Formulas

  #strong[\A. Total Sum of Squares (SST)] Since $hat(y)_0 perp (y - hat(y)_0)$, we have $parallel y parallel^2 = parallel hat(y)_0 parallel^2 + parallel y - hat(y)_0 parallel^2$:

  $ upright("SST") = parallel y - hat(y)_0 parallel^2 = parallel y parallel^2 - parallel hat(y)_0 parallel^2 $ $ upright("SST") = sum_(i = 1)^k sum_(j = 1)^(n_i) y_(i j)^2 - N macron(y)_(. .)^2 $

  #strong[\B. Between Group Sum of Squares (SSB)] Since $hat(y)_0 perp (hat(y)_1 - hat(y)_0)$, we have $parallel hat(y)_1 parallel^2 = parallel hat(y)_0 parallel^2 + parallel hat(y)_1 - hat(y)_0 parallel^2$:

  $ upright("SSB") = parallel hat(y)_1 - hat(y)_0 parallel^2 = parallel hat(y)_1 parallel^2 - parallel hat(y)_0 parallel^2 $ $ upright("SSB") = sum_(i = 1)^k n_i macron(y)_(i .)^2 - N macron(y)_(. .)^2 $

  #strong[\C. Within Group Sum of Squares (SSW)] Since $hat(y)_1 perp (y - hat(y)_1)$, we have $parallel y parallel^2 = parallel hat(y)_1 parallel^2 + parallel y - hat(y)_1 parallel^2$:

  $ upright("SSW") = parallel y - hat(y)_1 parallel^2 = parallel y parallel^2 - parallel hat(y)_1 parallel^2 $ $ upright("SSW") = sum_(i = 1)^k sum_(j = 1)^(n_i) y_(i j)^2 - sum_(i = 1)^k n_i macron(y)_(i .)^2 $

  #strong[Conclusion:]

  $ underbrace(parallel y parallel^2 - N macron(y)_(. .)^2, upright("SST")) = underbrace((sum n_i macron(y)_(i .)^2 - N macron(y)_(. .)^2), upright("SSB")) + underbrace((sum sum y_(i j)^2 - sum n_i macron(y)_(i .)^2), upright("SSW")) $

+ Visualizing ANOVA Components in Data Space

] <exm-anova-ss>
```python
import matplotlib.pyplot as plt
import numpy as np

# 1. Generate Data
np.random.seed(42)
group_names = ['A', 'B', 'C', 'D']
n_i = [10, 12, 8, 15]
means = [10, 15, 12, 18]
std_dev = 1.5

# Define colors and markers for each group
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
markers = ['o', 's', '^', 'D']

data_x = []
data_y = []
group_boundaries = [0]
group_indices = [] # To store indices for each group

current_idx = 0
for i, n in enumerate(n_i):
    group_data = np.random.normal(means[i], std_dev, n)
    indices = np.arange(current_idx, current_idx + n)
    data_x.extend(indices)
    data_y.extend(group_data)
    group_indices.append(indices) # Store indices for plotting later
    current_idx += n
    group_boundaries.append(current_idx)

data_x = np.array(data_x)
data_y = np.array(data_y)

# Calculate Stats
grand_mean = np.mean(data_y)
group_means = [np.mean(data_y[group_boundaries[i]:group_boundaries[i+1]]) for i in range(len(n_i))]

# 2. Plotting
plt.figure(figsize=(12, 6))

# Draw Grand Mean (Full span)
plt.axhline(y=grand_mean, color='red', linestyle='--', linewidth=2, label=f'Grand Mean ($\\bar{{y}}_{{..}}$ = {grand_mean:.2f})')

# Iterate through each group to plot points and means with matching colors
for i in range(len(n_i)):
    start, end = group_boundaries[i], group_boundaries[i+1]
    idx = group_indices[i]
    
    # 1. Scatter plot for the group with unique color and marker
    plt.scatter(data_x[idx], data_y[idx], color=colors[i], marker=markers[i], 
                alpha=0.7, s=60, label=f'Group {group_names[i]}')
    
    # 2. Horizontal line for group mean with the SAME color
    plt.hlines(y=group_means[i], xmin=start, xmax=end-1, color=colors[i], linewidth=3)
    
    # 3. Visualizing the "Within" residuals (faint lines)
    for j in idx:
        plt.vlines(x=j, ymin=min(data_y[j], group_means[i]), 
                   ymax=max(data_y[j], group_means[i]), 
                   color=colors[i], alpha=0.3, linestyle=':')

# Formatting
plt.title("One-Way ANOVA: Data, Group Means, and Grand Mean", fontsize=14)
plt.xlabel("Observation Index ($j$ grouped by $i$)", fontsize=12)
plt.ylabel("Value ($y_{ij}$)", fontsize=12)

# Set x-ticks at the center of each group
plt.xticks(np.array(group_boundaries[:-1]) + np.array(n_i)/2 - 0.5, 
           [f"Group {g}\n($n_{{{g.lower()}}}={n}$)" for g, n in zip(group_names, n_i)])
```

```python
plt.grid(axis='y', alpha=0.3)

# Adjust legend to show group markers and the grand mean line
handles, labels = plt.gca().get_legend_handles_labels()

# Reorder legend: Groups first, then Grand Mean
order = [1, 2, 3, 4, 0]
plt.legend([handles[idx] for idx in order], [labels[idx] for idx in order], 
           bbox_to_anchor=(1.02, 1), loc='upper left', borderaxespad=0.)

plt.tight_layout()
plt.show()
```

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-anova-data-space-colored-7.png"))
], caption: figure.caption(
position: bottom, 
[
Visualization of Group Means vs.~Grand Mean
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-anova-data-space-colored>


== Projections onto More than Three Orthogonal Subspaces
<projections-onto-more-than-three-orthogonal-subspaces>
Finally, we consider the case where the entire space $bb(R)^n$ is decomposed into mutually orthogonal subspaces.

#theorem("General Orthogonal Projections")[
If $bb(R)^n$ is the direct sum of orthogonal subspaces $V_1 \, V_2 \, dots.h \, V_k$: $ bb(R)^n = V_1 xor V_2 xor dots.h xor V_k $ where $V_i perp V_j$ for all $i eq.not j$.

Then any vector $y$ can be uniquely written as:

$ y = hat(y)_1 + hat(y)_2 + dots.h + hat(y)_k $ where $hat(y)_i in V_i$.

Furthermore, each component $hat(y)_i$ is simply the projection of $y$ onto the subspace $V_i$:

$ hat(y)_i = P_i y $

] <thm-orth-decomposition>
#block[
#emph[Proof];. 

+ Existence: Since $bb(R)^n$ is the direct sum of $V_1 \, dots.h \, V_k$, by definition, any vector $y in bb(R)^n$ can be written as a sum $y = v_1 + dots.h + v_k$ where $v_i in V_i$.

+ Uniqueness: Suppose there are two such representations: $y = sum v_i = sum w_i$, with $v_i \, w_i in V_i$. Then $sum (v_i - w_i) = 0$. Since subspaces in a direct sum are independent, the only way for the sum of elements to be zero is if each individual element is zero. Thus, $v_i - w_i = 0 arrow.r.double.long v_i = w_i$. The representation is unique. Let $hat(y)_i = v_i$.

+ Projection Property: We claim that the $i$-th component $hat(y)_i$ is the orthogonal projection of $y$ onto $V_i$. We must show that the residual $(y - hat(y)_i)$ is orthogonal to $V_i$.

  $ y - hat(y)_i = sum_(j eq.not i) hat(y)_j $ Let $z$ be any vector in $V_i$. We calculate the inner product: $ angle.l y - hat(y)_i \, z angle.r = ⟨sum_(j eq.not i) hat(y)_j \, z⟩ = sum_(j eq.not i) angle.l hat(y)_j \, z angle.r $ Since $hat(y)_j in V_j$ and $z in V_i$, and the subspaces are mutually orthogonal ($V_j perp V_i$ for $j eq.not i$), every term in the sum is zero. Therefore, $(y - hat(y)_i) perp V_i$. By the definition of orthogonal projection, $hat(y)_i = P_i y$.

]
This implies that the identity matrix can be decomposed into a sum of projection matrices: $ I_n = P_1 + P_2 + dots.h + P_k $

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-orthogonal-decomp-rotated-9.png"))
], caption: figure.caption(
position: bottom, 
[
Orthogonal decomposition of vector y into subspaces
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-orthogonal-decomp-rotated>


#theorem("Complete Orthogonal Decomposition of $bb(R)^n$")[
Let $P_0 \, P_1 \, dots.h \, P_k$ be a sequence of orthogonal projection matrices with nested column spaces: $ upright("Col") (P_0) subset.eq upright("Col") (P_1) subset.eq dots.h subset.eq upright("Col") (P_k) $

Define the sequence of difference matrices $Delta P_i$ and their column spaces $V_i$ as follows:

#strong[Conclusion:]

+ #strong[Projection Property:] Each $Delta P_i$ is the orthogonal projection matrix onto $V_i$ for $i = 0 \, dots.h \, k + 1$.

+ #strong[Mutual Orthogonality:] The collection ${ Delta P_i }$ are mutually orthogonal operators:

$ Delta P_i Delta P_j = 0 quad upright("for all ") i eq.not j $

#block[
#set enum(numbering: "1.", start: 3)
+ #strong[Direct Sum Decomposition:] The vector space $bb(R)^n$ is the direct sum of these orthogonal subspaces:
]

$ bb(R)^n = V_0 xor V_1 xor dots.h xor V_(k + 1) $

] <thm-complete-decomposition>
#block[
#emph[Proof];. 

+ Proof that $Delta P_i$ is the Projection onto $V_i$

  We must show each $Delta P_i$ is symmetric and idempotent.

  - For $Delta P_0 = P_0$: True by definition.
  - For $Delta P_i$ ($1 lt.eq i lt.eq k$):
    - #strong[Symmetry:] Difference of symmetric matrices (\$P\_i, P\_{i-1} \$) is symmetric.
    - #strong[Idempotency:] $(Delta P_i)^2 = (P_i - P_(i - 1))^2 = P_i^2 - P_i P_(i - 1) - P_(i - 1) P_i + P_(i - 1)^2$. Using nested properties ($P_i P_(i - 1) = P_(i - 1)$), this simplifies to $P_i - P_(i - 1) = Delta P_i$.
  - For $Delta P_(k + 1) = I - P_k$:
    - #strong[Symmetry:] $(I - P_k)' = I - P_k$.
    - #strong[Idempotency:] $(I - P_k)^2 = I - 2 P_k + P_k^2 = I - P_k$.

+ Proof of Mutual Orthogonality

  We show $Delta P_j Delta P_i = 0$ for $i < j$.

  - #strong[Case 1: Both indices] $lt.eq k$ (i.e., $1 lt.eq i < j lt.eq k$):

  $ (P_j - P_(j - 1)) (P_i - P_(i - 1)) = P_j P_i - P_j P_(i - 1) - P_(j - 1) P_i + P_(j - 1) P_(i - 1) $ Since $upright("Col") (P_i) subset.eq upright("Col") (P_(j - 1))$, all terms reduce to $P_i - P_(i - 1) - P_i + P_(i - 1) = 0$.

  - #strong[Case 2: One index is the residual] ($j = k + 1$): We check $Delta P_(k + 1) Delta P_i = (I - P_k) Delta P_i$ for any $i lt.eq k$. Since $V_i subset.eq upright("Col") (P_k)$, we have $P_k Delta P_i = Delta P_i$.

  $ (I - P_k) Delta P_i = Delta P_i - P_k Delta P_i = Delta P_i - Delta P_i = 0 $

+ Proof of Direct Sum

  The sum of the difference matrices forms a telescoping series:

  $ sum_(j = 0)^(k + 1) Delta P_j = P_0 + sum_(i = 1)^k (P_i - P_(i - 1)) + (I - P_k) $ $ = P_k + (I - P_k) = I $ Since the identity operator $I$ (which maps $bb(R)^n$ to itself) is the sum of mutually orthogonal projection operators, the space $bb(R)^n$ decomposes into the direct sum of their respective image subspaces $V_i$.

]
#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-venn-nested-projection-1.png"))
], caption: figure.caption(
position: bottom, 
[
Venn Diagram of Nested Projections with Colored Increments
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-venn-nested-projection>


#pagebreak()
= Matrix Algebra
<matrix-algebra>
This chapter covers a review of matrix algebra concepts essential for linear models, including eigenvalues, spectral decomposition, singular value decomposition.

== Eigenvalues and Eigenvectors
<eigenvalues-and-eigenvectors>
#definition("Eigenvalues and Eigenvectors")[
For a square matrix $A$ ($n times n$), a scalar $lambda$ is an #strong[eigenvalue] and a non-zero vector $x$ is the corresponding #strong[eigenvector] if:

$ A x = lambda x arrow.l.r.double (A - lambda I_n) x = 0 $

The eigenvalues are found by solving the characteristic equation: $ lr(|A - lambda I_n|) = 0 $

] <def-eigen>
== Spectral Theory for Symmetric Matrices
<spectral-theory-for-symmetric-matrices>
=== Spectral Decomposition
<spectral-decomposition>
For symmetric matrices, we have a powerful decomposition theorem.

#theorem("Spectral Decomposition")[
If $A$ is a symmetric $n times n$ matrix, all its eigenvalues $lambda_1 \, dots.h \, lambda_n$ are real. Furthermore, there exists an orthogonal matrix $Q$ such that:

$ A = Q Lambda Q' = sum_(i = 1)^n lambda_i q_i q_i' $

where:

- $Lambda = upright("diag") (lambda_1 \, dots.h \, lambda_n)$ contains the eigenvalues.
- $Q = (q_1 \, dots.h \, q_n)$ contains the corresponding orthonormal eigenvectors ($q_i' q_j = delta_(i j)$).

] <thm-spectral>
#strong[Explantion];: This allows us to view the transformation $A x$ as a rotation ($Q'$), a scaling ($Lambda$), and a rotation back ($Q$). For a symmetric matrix $A$, we can write the spectral decomposition as a product of the eigenvector matrix $Q$ and eigenvalue matrix $Lambda$:

$ A & = Q Lambda Q'\
 & = mat(delim: "(", q_1, q_2, dots.h.c, q_n) mat(delim: "(", lambda_1, 0, dots.h.c, 0; 0, lambda_2, dots.h.c, 0; dots.v, dots.v, dots.down, dots.v; 0, 0, dots.h.c, lambda_n) vec(q_1', q_2', dots.v, q_n')\
 & = mat(delim: "(", lambda_1 q_1, lambda_2 q_2, dots.h.c, lambda_n q_n) vec(q_1', q_2', dots.v, q_n')\
 & = lambda_1 q_1 q_1' + lambda_2 q_2 q_2' + dots.h.c + lambda_n q_n q_n'\
 & = sum_(i = 1)^n lambda_i q_i q_i' $

where the eigenvectors $q_i$ satisfy the orthogonality conditions: $ q_i' q_j = cases(delim: "{", 1 & upright("if ") i = j, 0 & upright("if ") i eq.not j) $ And $Q$ is an orthogonal matrix: $Q' Q = Q Q' = I_n$.

```r
library(ggplot2)
library(gridExtra)

# --- 1. MATRIX SETUP ---
# Symmetric Matrix where eigenvectors are tilted
A <- matrix(c(1.5, 0.8, 0.8, 1.5), nrow = 2)

# Decomposition A = QDQ'
eig <- eigen(A)
Q <- eig$vectors
D_mat <- diag(eig$values)

# --- 2. DEFINE THE 6 VECTORS ---

# 1 & 2: Standard Axes (We will label these x1, x2)
v1 <- c(1, 0)
v2 <- c(0, 1)
# 3 & 4: Eigenvectors
v3 <- Q[,1]
v4 <- Q[,2]
# 5 & 6: Filler vectors at random angles
v5 <- c(cos(pi/3), sin(pi/3))
v6 <- c(cos(4*pi/3), sin(4*pi/3))

# Combine into starting matrix V_start
V_start <- cbind(v1, v2, v3, v4, v5, v6)

# Define 6 Distinct Colors
my_colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#A65628")
names(my_colors) <- 1:6

# Background Circle Points used for reference path in all plots
theta_c <- seq(0, 2*pi, length.out = 150)
C_start <- rbind(cos(theta_c), sin(theta_c))

# --- 3. DATA PROCESSING HELPER FUNCTION ---

# This function prepares the data frames for ggplot for a given stage
prepare_data <- function(V_mat, C_mat, stage_title, label_text_pair) {
  # Prepare Vectors data frame
  df_v <- data.frame(t(V_mat))
  colnames(df_v) <- c("x", "y")
  df_v$vec_id <- factor(1:6) # Unique ID for coloring
  
  # Add labels only for vector 1 and 2
  df_v$label <- ""
  df_v$label[1] <- label_text_pair[1]
  df_v$label[2] <- label_text_pair[2]
  
  # Calculate nudge for labels based on vector direction so they don't overlap arrow tip
  df_v$nudge_x <- sign(df_v$x) * 0.25
  df_v$nudge_y <- sign(df_v$y) * 0.25
  # Don't nudge unlabelled vectors
  df_v$nudge_x[3:6] <- 0
  df_v$nudge_y[3:6] <- 0

  # Prepare Background Path data frame
  df_c <- data.frame(t(C_mat))
  colnames(df_c) <- c("px", "py")
  
  list(vecs = df_v, path = df_c, title = stage_title)
}


# --- 4. PERFORM TRANSFORMATIONS ---

# Stage 1: Start (x)
d1 <- prepare_data(V_start, C_start, 
                   "1. Start (x)", c("x[1]", "x[2]"))

# Stage 2: Rotate (Q'x)
V2 <- t(Q) %*% V_start
C2 <- t(Q) %*% C_start
d2 <- prepare_data(V2, C2, 
                   "2. Rotate (Q'x)", c("z[1]", "z[2]"))

# Stage 3: Stretch (DQ'x)
V3 <- D_mat %*% V2
C3 <- D_mat %*% C2
d3 <- prepare_data(V3, C3, 
                   "3. Stretch (DQ'x)", c("y[1]", "y[2]"))

# Stage 4: Rotate Back (QDQ'x)
V4 <- Q %*% V3
C4 <- Q %*% C3
d4 <- prepare_data(V4, C4, 
                   "4. Final (QDQ'x)", c("w[1]", "w[2]"))


# --- 5. PLOTTING FUNCTION ---

plot_stage_final <- function(data_list) {
  ggplot() +
    # Background path (gray dashed)
    geom_path(data = data_list$path, aes(x=px, y=py), 
              color="gray70", linetype="dashed") +
    # The 6 vectors
    geom_segment(data = data_list$vecs, aes(x=0, y=0, xend=x, yend=y, color=vec_id), 
                 arrow = arrow(length = unit(0.3, "cm")), size=1.1) +
    # The labels for v1 and v2 using parsed expressions for subscripts
    geom_text(data = data_list$vecs, aes(x=x, y=y, label=label, color=vec_id),
              parse = TRUE, fontface="bold", size=5,
              nudge_x = data_list$vecs$nudge_x,
              nudge_y = data_list$vecs$nudge_y) +
    scale_color_manual(values = my_colors) +
    # Fixed coordinates to ensure realistic rotation/stretching view
    coord_fixed(xlim = c(-2.5, 2.5), ylim = c(-2.5, 2.5)) +
    theme_bw() +
    theme(legend.position = "none",
          panel.grid.minor = element_blank(),
          plot.title = element_text(face="bold", hjust=0.5),
          axis.title = element_blank()) +
    labs(title = data_list$title)
}

# Generate the 4 plots
p1 <- plot_stage_final(d1)
p2 <- plot_stage_final(d2)
p3 <- plot_stage_final(d3)
p4 <- plot_stage_final(d4)

# Arrange them in a grid
grid.arrange(p1, p2, p3, p4, nrow = 2)
```

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-eigen-1.png"))
], caption: figure.caption(
separator: "", 
position: bottom, 
[
#block[
]
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-eigen>


=== Quadratic Form
<quadratic-form>
#definition()[
A #strong[quadratic form] in $n$ variables $x_1 \, x_2 \, dots.h \, x_n$ is a scalar function defined by a symmetric matrix $A$: $ Q (x) = x' A x = sum_(i = 1)^n sum_(j = 1)^n a_(i j) x_i x_j $

] <def-quadratic-form>
=== Positive and Non-Negative Definite Matrices
<positive-and-non-negative-definite-matrices>
#definition("Positive and Non-Negative Definite Matrices")[
A symmetric matrix $A$ is #strong[positive definite (p.d.)] if: $ x' A x > 0 quad forall x eq.not 0 $ It is #strong[non-negative definite (n.n.d.)] if: $ x' A x gt.eq 0 quad forall x $

] <def-pos-def>
#theorem("Properties of Definite Matrices")[
Let $A$ be a symmetric $n times n$ matrix with eigenvalues $lambda_1 \, dots.h \, lambda_n$.

+ #strong[Eigenvalue Characterization:]

  - $A$ is p.d. $arrow.l.r.double$ all $lambda_i > 0$.
  - $A$ is n.n.d. $arrow.l.r.double$ all $lambda_i gt.eq 0$.

+ #strong[Determinant and Inverse:]

  - If $A$ is p.d., then $lr(|A|) > 0$ and $A^(- 1)$ exists.
  - If $A$ is n.n.d. and singular, then $lr(|A|) = 0$ (at least one $lambda_i = 0$).

+ #strong[Gram Matrices ($B' B$):] Let $B$ be an $n times p$ matrix.

  - If $upright("rank") (B) = p$, then $B' B$ is p.d.
  - If $upright("rank") (B) < p$, then $B' B$ is n.n.d.

] <thm-nnd-properties>
=== Properties of Symmetric Matrices
<properties-of-symmetric-matrices>
#theorem("Properties of Symmetric Matrices")[
Let $A$ be a symmetric matrix with spectral decomposition $A = Q Lambda Q'$. The following properties hold:

+ #strong[Trace:] $upright("tr") (A) = sum lambda_i$.
+ #strong[Determinant:] $lr(|A|) = product lambda_i$.
+ #strong[Singularity:] $A$ is singular if and only if at least one $lambda_i = 0$.
+ #strong[Inverse:] If $A$ is non-singular ($lambda_i eq.not 0$), then $A^(- 1) = Q Lambda^(- 1) Q'$.
+ #strong[Powers:] $A^k = Q Lambda^k Q'$.
  - #emph[Square Root:] $A^(1 \/ 2) = Q Lambda^(1 \/ 2) Q'$ (if $lambda_i gt.eq 0$).
+ #strong[Spectral Representation of Quadratic Forms:] The quadratic form $x' A x$ can be diagonalized using the eigenvectors of $A$: $ x' A x = x' Q Lambda Q' x = y' Lambda y = sum_(i = 1)^n lambda_i y_i^2 $ where $y = Q' x$ represents a rotation of the coordinate system.

] <thm-symmetric-properties>
=== Spectral Representation of Projection Matrices
<spectral-representation-of-projection-matrices>
We revisit projection matrices in the context of eigenvalues.

#theorem("Eigenvalues of Projection Matrices")[
A symmetric matrix $P$ is a projection matrix (idempotent, $P^2 = P$) if and only if its eigenvalues are either 0 or 1.

$ P^2 x = lambda^2 x quad upright("and") quad P x = lambda x arrow.r.double.long lambda^2 = lambda arrow.r.double.long lambda in { 0 \, 1 } $

] <thm-proj-eigen>
For a projection matrix $P$:

- If $x in upright("Col") (P)$, $P x = x$ (Eigenvalue 1).
- If $x perp upright("Col") (P)$, $P x = 0$ (Eigenvalue 0).
- $upright("rank") (P) = upright("tr") (P) = sum lambda_i$ (Count of 1s).

#example()[
For $P = 1 / n J_n J_n'$, the rank is $upright("tr") (P) = 1$.

] <exm-trace-P>
== Singular Value Decomposition (SVD)
<singular-value-decomposition-svd>
#theorem("Singular Value Decomposition (SVD)")[
Let $X$ be an $n times p$ matrix with rank $r lt.eq min (n \, p)$. $X$ can be decomposed into the product of three matrices:

$ X = U upright(bold(D)) V' $

+ Partitioned Matrix Form

$ X = (U_1 \, U_2)_(n times n) mat(delim: "(", Lambda_r, O_(r times (p - r)); O_((n - r) times r), O_((n - r) times (p - r))) vec(V_1', V_2')_(p times p) $

#block[
#set enum(numbering: "1.", start: 2)
+ Detailed Matrix Form
]

Expanding the diagonal matrix explicitly:

$ X = (u_1 \, dots.h \, u_n)_(n times n) mat(delim: "(", lambda_1, 0, dots.h, 0, ; 0, lambda_2, dots.h, 0, O_12; dots.v, dots.v, dots.down, dots.v, ; 0, 0, dots.h, lambda_r, ; #none, O_21, , , O_22) vec(v_1', dots.v, v_p')_(p times p) $

#block[
#set enum(numbering: "1.", start: 3)
+ Reduced Form
]

$ X = U_1 Lambda_r V_1' = sum_(i = 1)^r lambda_i u_i v_i' $

#strong[Properties:]

+ #strong[Singular Values ($Lambda_r$):] $Lambda_r = upright("diag") (lambda_1 \, dots.h \, lambda_r)$ contains the singular values ($lambda_i > 0$), which are the square roots of the non-zero eigenvalues of $X' X$.
+ #strong[Orthogonality:]
  - $U$ is $n times n$ orthogonal ($U' U = I_n$).
  - $V$ is $p times p$ orthogonal ($V' V = I_p$).

] <thm-svd>
==== Connection to Gram Matrices
<connection-to-gram-matrices>
The matrices $U$ and $V$ provide the basis vectors (eigenvectors) for the Gram matrices of $X$.

+ #strong[Right Singular Vectors ($V$):] The columns of $V$ are the eigenvectors of the Gram matrix $X' X$. $ X' X = (U Lambda V ')' (U Lambda V ') = V Lambda U' U Lambda V' = V Lambda^2 V' $

  - The eigenvalues of $X' X$ are the squared singular values $lambda_i^2$.

+ #strong[Left Singular Vectors ($U$):] The columns of $U$ are the eigenvectors of the Gram matrix $X X'$. $ X X' = (U Lambda V ') (U Lambda V ')' = U Lambda V' V Lambda U' = U Lambda^2 U' $

  - The eigenvalues of $X X'$ are also $lambda_i^2$ (for non-zero values).

#example("Example of SVD")[
Consider the matrix $X = mat(delim: "(", 1, 1; 2, 2)$.

+ #strong[Compute $X' X$ and find $V$:] $ X' X = mat(delim: "(", 1, 2; 1, 2) mat(delim: "(", 1, 1; 2, 2) = mat(delim: "(", 5, 5; 5, 5) $

  - Eigenvalues of $X' X$: Trace is 10, Determinant is 0. Thus, $mu_1 = 10 \, mu_2 = 0$.
  - #strong[Singular Values:] $lambda_1 = sqrt(10) \, lambda_2 = 0$.
  - Eigenvector for $mu_1 = 10$: Normalized $v_1 = 1 / sqrt(2) vec(1, 1)$.
  - Eigenvector for $mu_2 = 0$: Normalized $v_2 = 1 / sqrt(2) vec(1, - 1)$.
  - Therefore, $V = 1 / sqrt(2) mat(delim: "(", 1, 1; 1, - 1)$.

+ #strong[Compute $X X'$ and find $U$:] $ X X' = mat(delim: "(", 1, 1; 2, 2) mat(delim: "(", 1, 2; 1, 2) = mat(delim: "(", 2, 4; 4, 8) $

  - Eigenvalues are again 10 and 0.
  - Eigenvector for $mu_1 = 10$: Normalized $u_1 = 1 / sqrt(5) vec(1, 2)$.
  - Eigenvector for $mu_2 = 0$: Normalized $u_2 = 1 / sqrt(5) vec(2, - 1)$.
  - Therefore, $U = 1 / sqrt(5) mat(delim: "(", 1, 2; 2, - 1)$.

+ #strong[Verification:] $ X = sqrt(10) u_1 v_1' = sqrt(10) vec(1 / sqrt(5), 2 / sqrt(5)) mat(delim: "(", 1 / sqrt(2), 1 / sqrt(2)) = mat(delim: "(", 1, 1; 2, 2) $

] <exm-svd>
== Cholesky Decomposition
<cholesky-decomposition>
A symmetric matrix $A$ has a Cholesky decomposition if and only if it is #strong[non-negative definite] (i.e., $x' A x gt.eq 0$ for all $x$).

$ A = B' B $

where $B$ is an #strong[upper triangular] matrix with non-negative diagonal entries.

=== Matrix Representation of the Algorithm
<matrix-representation-of-the-algorithm>
To derive the algorithm, we equate the elements of $A$ with the product of the lower triangular matrix $B'$ and the upper triangular matrix $B$.

For a $3 times 3$ matrix, this looks like:

$ underbrace(mat(delim: "(", a_11, a_12, a_13; a_21, a_22, a_23; a_31, a_32, a_33), A) = underbrace(mat(delim: "(", b_11, 0, 0; b_12, b_22, 0; b_13, b_23, b_33), B') underbrace(mat(delim: "(", b_11, b_12, b_13; 0, b_22, b_23; 0, 0, b_33), B) $

Multiplying the matrices on the right yields the system of equations:

$ A = mat(delim: "(", upright(bold(b_11^2)), b_11 b_12, b_11 b_13; b_12 b_11, upright(bold(b_12^2 + b_22^2)), b_12 b_13 + b_22 b_23; b_13 b_11, b_13 b_12 + b_23 b_22, upright(bold(b_13^2 + b_23^2 + b_33^2))) $

By solving for the bolded diagonal terms and substituting known values from previous rows, we get the recursive algorithm.

#algorithm("Choleski Decomposition")[
~

+ #strong[Row 1:] Solve for $b_11$ using $a_11$, then solve the rest of the row ($b_(1 j)$) by division.
  - $b_11 = sqrt(a_11)$
  - $b_(1 j) = a_(1 j) \/ b_11$
+ #strong[Row 2:] Solve for $b_22$ using $a_22$ and the known $b_12$, then solve $b_(2 j)$.
  - $b_22 = sqrt(a_22 - b_12^2)$
  - $b_(2 j) = (a_(2 j) - b_12 b_(1 j)) \/ b_22$
+ #strong[Row 3:] Solve for $b_33$ using $a_33$ and the known $b_13 \, b_23$.
  - $b_33 = sqrt(a_33 - b_13^2 - b_23^2)$

] <alg-chosk-decomp>
#block[
#emph[Remark];. #strong[Handling the Singular Case]

If $A$ is positive semi-definite (singular), a diagonal element $b_(i i)$ may evaluate to 0 (or a very small number close to 0 due to floating-point error). Standard algorithms often crash here because calculating off-diagonal terms involves division by $b_(i i)$.

To handle this robustly without pivoting:

- If $b_(i i) approx 0$, it implies that the entire remaining row $b_(i \, i : n)$ must be 0 for the matrix to remain consistent with being positive semi-definite.
- The algorithm should explicitly set $b_(i j) = 0$ for all $j gt.eq i$ and proceed to the next row, rather than attempting division.

]
#example("Example of Cholesky Decomposition")[
Consider the positive definite matrix $A$: $ A = mat(delim: "(", 4, 2, - 2; 2, 10, 2; - 2, 2, 6) $

We find $B$ such that $A = B' B$:

+ #strong[First Row of B ($b_11 \, b_12 \, b_13$):]
  - $b_11 = sqrt(4) = 2$
  - $b_12 = 2 \/ 2 = 1$
  - $b_13 = - 2 \/ 2 = - 1$
+ #strong[Second Row of B ($b_22 \, b_23$):]
  - $b_22 = sqrt(10 - (1)^2) = sqrt(9) = 3$
  - $b_23 = (2 - (1) (- 1)) \/ 3 = 3 \/ 3 = 1$
+ #strong[Third Row of B ($b_33$):]
  - $b_33 = sqrt(6 - (- 1)^2 - (1)^2) = sqrt(4) = 2$

#strong[Result:] $ B = mat(delim: "(", 2, 1, - 1; 0, 3, 1; 0, 0, 2) $

] <exm-chol>
=== Applications in Statistics
<applications-in-statistics>
Cholesky decomposition is preferred over other methods (like LU or SVD) for symmetric positive-definite matrices because it is numerically stable and roughly twice as fast.

+ Solving Linear Equations

  In linear regression, we solve the normal equations $(X ' X) beta = X' y$. Since $X' X$ is symmetric and positive definite, we can decompose it as $B' B$. The system becomes: $ B' B beta = X' y $ This allows us to solve for $beta$ using two efficient triangular substitutions (first solving $B' z = X' y$ for $z$, then $B beta = z$ for $beta$) without explicitly inverting the matrix, which is computationally expensive and unstable.

+ Computing the Determinant

  The determinant of a triangular matrix is simply the product of its diagonal entries. Therefore, the determinant of $A$ can be computed instantly from $B$: $ det (A) = det (B ' B) = det (B ') det (B) = (product_(i = 1)^n b_(i i))^2 $ This is widely used in Maximum Likelihood Estimation (e.g., REML in mixed models) where log-determinants of large covariance matrices are required.

+ Generating Multivariate Normal Random Variables

  To generate a random vector $Y tilde.op N (mu \, Sigma)$, we first generate a vector of independent standard normal variables $Z tilde.op N (0 \, I)$. Using the Cholesky decomposition $Sigma = B' B$: $ Y = mu + B' Z $ The covariance of $Y$ is confirmed by $upright("Cov") (Y) = B' upright("Cov") (Z) B = B' I B = B' B = Sigma$. This is the standard method used by functions like `mvrnorm` in R.

#pagebreak()
= Multivariate Normal Distribution
<multivariate-normal-distribution>
== Motivation
<motivation>
Consider the linear model: $ y = X beta + epsilon.alt \, quad epsilon.alt_i tilde.op N (0 \, sigma^2) $

We are often interested in the distributional properties of the response vector $y$ and the residuals. Specifically, if $y = (y_1 \, dots.h \, y_n)'$, we need to understand its multivariate distribution. $ hat(y) = P y \, quad e = y - hat(y) = (I_n - P) y $

== Random Vectors and Matrices
<random-vectors-and-matrices>
#definition("Random Vector and Matrix")[
A #strong[Random Vector] is a vector whose elements are random variables. E.g., $ x_(k times 1) = (x_1 \, x_2 \, dots.h \, x_k)^T $ where $x_1 \, dots.h \, x_k$ are each random variables.

A #strong[Random Matrix] is a matrix whose elements are random variables. E.g., $X_(n times k) = (x_(i j))$, where $x_11 \, dots.h \, x_(n k)$ are each random variables.

] <def-random-vector>
#definition("Expected Value")[
The expected value (population mean) of a random matrix (or vector) is the matrix (or vector) of expected values of its elements.

For $X_(n times k)$: $ E (X) = mat(delim: "(", E (x_11), dots.h, E (x_(1 k)); dots.v, dots.down, dots.v; E (x_(n 1)), dots.h, E (x_(n k))) $

$ E (vec(x_1, dots.v, x_k)) = vec(E (x_1), dots.v, E (x_k)) $

] <def-expected-value>
#definition("Variance-Covariance Matrix")[
For a random vector $x_(k times 1) = (x_1 \, dots.h \, x_k)^T$, the matrix is:

$ upright("Var") (x) = Sigma_x = mat(delim: "(", sigma_11, sigma_12, dots.h, sigma_(1 k); sigma_21, sigma_22, dots.h, sigma_(2 k); dots.v, dots.v, dots.down, dots.v; sigma_(k 1), sigma_(k 2), dots.h, sigma_(k k)) $

Where:

- $sigma_(i j) = upright("Cov") (x_i \, x_j) = E [(x_i - mu_i) (x_j - mu_j)]$
- $sigma_(i i) = upright("Var") (x_i) = E [(x_i - mu_i)^2]$

In matrix notation: $ upright("Var") (x) = E [(x - mu_x) (x - mu_x)^T] $ Note: $upright("Var") (x)$ is symmetric.

] <def-variance-covariance>
=== Derivation of Covariance Matrix Structure
<derivation-of-covariance-matrix-structure>
Expanding the vector multiplication for variance: $ (x - mu_x) (x - mu_x)' quad upright("where ") mu_x = (mu_1 \, dots.h \, mu_n)' $ $ = vec(x_1 - mu_1, dots.v, x_n - mu_n) (x_1 - mu_1 \, dots.h \, x_n - mu_n) $ This results in the matrix $A = (a_(i j))$ where $a_(i j) = (x_i - mu_i) (x_j - mu_j)$. Taking expectations yields the covariance matrix elements $sigma_(i j)$.

#definition("Covariance Matrix (Two Vectors)")[
For random vectors $x_(k times 1)$ and $y_(n times 1)$, the covariance matrix is: $ upright("Cov") (x \, y) = E [(x - mu_x) (y - mu_y)^T] = mat(delim: "(", upright("Cov") (x_1 \, y_1), dots.h, upright("Cov") (x_1 \, y_n); dots.v, dots.down, dots.v; upright("Cov") (x_k \, y_1), dots.h, upright("Cov") (x_k \, y_n)) $ Note that $upright("Cov") (x \, x) = upright("Var") (x)$.

] <def-covariance-matrix-two>
#definition("Correlation Matrix")[
The correlation matrix of a random vector $x$ is: $ upright("corr") (x) = mat(delim: "(", 1, rho_12, dots.h, rho_(1 k); dots.v, dots.down, dots.v; rho_(k 1), rho_(k 2), dots.h, 1) $ where $rho_(i j) = upright("corr") (x_i \, x_j)$.

#strong[Relationships:] Let $V_x = upright("diag") (upright("Var") (x_1) \, dots.h \, upright("Var") (x_k))$. $ Sigma_x = V_x^(1 \/ 2) rho_x V_x^(1 \/ 2) quad upright("and") quad rho_x = (V_x^(1 \/ 2))^(- 1) Sigma_x (V_x^(1 \/ 2))^(- 1) $ Similarly for two vectors: $ Sigma_(x y) = V_x^(1 \/ 2) rho_(x y) V_y^(1 \/ 2) $

] <def-correlation-matrix>
== Properties of Mean and Variance
<properties-of-mean-and-variance>
We can derive several key algebraic properties for operations on random vectors.

+ $E (X + Y) = E (X) + E (Y)$
+ $E (A X B) = A E (X) B$ (In particular, $E (A X) = A mu_x$)
+ $upright("Cov") (x \, y) = upright("Cov") (y \, x)^T$
+ $upright("Cov") (x + c \, y + d) = upright("Cov") (x \, y)$
+ $upright("Cov") (A x \, B y) = A upright("Cov") (x \, y) B^T$
  - Special case for scalars: $upright("Cov") (a x \, b y) = a b dot.op upright("Cov") (x \, y)$
+ $upright("Cov") (x_1 + x_2 \, y_1) = upright("Cov") (x_1 \, y_1) + upright("Cov") (x_2 \, y_1)$
+ $upright("Var") (x + c) = upright("Var") (x)$
+ $upright("Var") (A x) = A upright("Var") (x) A^T$
+ $upright("Var") (x_1 + x_2) = upright("Var") (x_1) + upright("Cov") (x_1 \, x_2) + upright("Cov") (x_2 \, x_1) + upright("Var") (x_2)$
+ $upright("Var") (sum x_i) = sum upright("Var") (x_i)$ if independent.

#block[
#emph[Proof];. #strong[Property 5 (Covariance of Linear Transformation):] $ upright("Cov") (A x \, B y) & = E [(A x - A mu_x) (B y - B mu_y)^T]\
 & = A E [(x - mu_x) (y - mu_y)^T] B^T\
 & = A upright("Cov") (x \, y) B^T $ #strong[Property 2 (Expectation of Linear Transformation)];:

To prove $E (A X B) = A E (X) B$: First consider $E (A x_j)$ where $x_j$ is a column of $X$. $ E (A x_j) = E vec(a_1' x_j, dots.v, a_n' x_j) = vec(E (a_1 ' x_j), dots.v, E (a_n ' x_j)) $ Since $a_i$ are constants: $ E (a_i ' x_j) = E (sum_(k = 1)^p a_(i k) x_(k j)) = sum_(k = 1)^p a_(i k) E (x_(k j)) = a_i' E (x_j) $ Thus $E (A x_j) = A E (x_j)$. Applying this to all columns of $X$: $ E (A X) = [E (A x_1) \, dots.h \, E (A x_m)] = [A E (x_1) \, dots.h \, A E (x_m)] = A E (X) $ Similarly, $E (X B) = E (X) B$.

#strong[Proof of Property 9 (Variance of Sum):]

$ upright("Var") (x_1 + x_2) = E [(x_1 + x_2 - mu_1 - mu_2) (x_1 + x_2 - mu_1 - mu_2)^T] $ Let centered variables be denoted by differences. $ = E [((x_1 - mu_1) + (x_2 - mu_2)) ((x_1 - mu_1) + (x_2 - mu_2))^T] $ Expanding terms: $ = E [(x_1 - mu_1) (x_1 - mu_1)^T + (x_1 - mu_1) (x_2 - mu_2)^T + (x_2 - mu_2) (x_1 - mu_1)^T + (x_2 - mu_2) (x_2 - mu_2)^T] $ $ = upright("Var") (x_1) + upright("Cov") (x_1 \, x_2) + upright("Cov") (x_2 \, x_1) + upright("Var") (x_2) $

]
== The Multivariate Normal Distribution
<the-multivariate-normal-distribution>
=== Definition and Density
<definition-and-density>
#definition("Independent Standard Normal")[
Let $z = (z_1 \, dots.h \, z_n)'$ where $z_i tilde.op N (0 \, 1)$ are independent. We say $z tilde.op N_n (0 \, I_n)$. The joint PDF is the product of marginals: $ f (z) = product_(i = 1)^n 1 / sqrt(2 pi) e^(- z_i^2 / 2) = 1 / (2 pi)^(n \/ 2) e^(- 1 / 2 z^T z) $ Properties: $E (z) = 0$ and $upright("Var") (z) = I_n$ (Covariance is 0 for $i eq.not j$, Variance is 1).

] <def-standard-normal>
#definition("Multivariate Normal Distribution")[
A random vector $x$ ($n times 1$) has a #strong[multivariate normal distribution] if it has the same distribution as: $ x = A_(n times p) z_(p times 1) + mu_(n times 1) $ where $z tilde.op N_p (0 \, I_p)$, $A$ is a matrix of constants, and $mu$ is a vector of constants. The moments are:

- $E (x) = mu$
- $upright("Var") (x) = A A^T = Sigma$

] <def-mvn>
=== Geometric Interpretation
<geometric-interpretation>
Using Spectral Decomposition, $Sigma = Q Lambda Q'$. We can view the transformation $x = A z + mu$ as:

+ Scaling by eigenvalues ($Lambda^(1 \/ 2)$).
+ Rotation by eigenvectors ($Q$).
+ Shift by mean ($mu$).

=== Probability Density Function
<probability-density-function>
If $Sigma$ is positive definite, the PDF exists. We use the change of variable formula for $x = A z + mu$: $ f_x (x) = f_z (g^(- 1) (x)) dot.op lr(|J|) $ where $z = A^(- 1) (x - mu)$ and $J = det (A^(- 1)) = lr(|A|)^(- 1)$.

$ f_x (x) = (2 pi)^(- p \/ 2) lr(|A|)^(- 1) exp {- 1 / 2 (A^(- 1) (x - mu))^T (A^(- 1) (x - mu))} $

Using $lr(|Sigma|) = lr(|A A^T|) = lr(|A|)^2$ and $Sigma^(- 1) = (A A^T)^(- 1)$, we get: $ f_x (x) = (2 pi)^(- p \/ 2) lr(|Sigma|)^(- 1 \/ 2) exp {- 1 / 2 (x - mu)^T Sigma^(- 1) (x - mu)} $

=== Moment Generating Function
<moment-generating-function>
#definition("Moment Generating Function (MGF)")[
The MGF of a random vector $x$ is $M_x (t) = E (e^(t^T x))$. For $x = A z + mu$: $ M_x (t) = E [e^(t^T (A z + mu))] = e^(t^T mu) E [e^((A^T t)^T z)] = e^(t^T mu) M_z (A^T t) $ Since $M_z (u) = e^(u^T u \/ 2)$: $ M_x (t) = e^(t^T mu) exp (1 / 2 t^T (A A^T) t) = exp (t^T mu + 1 / 2 t^T Sigma t) $

] <def-mgf>
Key Properties:

+ #strong[Uniqueness:] Two random vectors with the same MGF have the same distribution.

+ #strong[Independence:] $y_1$ and $y_2$ are independent iff $M_y (t) = M_(y_1) (t_1) M_(y_2) (t_2)$.

== Construction and Linear Transformations
<construction-and-linear-transformations>
#theorem("Constructing MVN Random Vector")[
Let $mu in bb(R)^n$ and $Sigma$ be an $n times n$ symmetric non-negative definitive (n.n.d) matrix. Then there exists a multivariate normal distribution with mean $mu$ and covariance $Sigma$.

] <thm-construction>
#block[
#emph[Proof];. Since $Sigma$ is n.n.d., there exists $B$ such that $Sigma = B B^T$ (e.g., via Cholesky or Spetral Decomposition). Let $z tilde.op N_n (0 \, I)$ and define $x = B z + mu$.

]
#theorem("Linear Transformation Theorem")[
Let $x tilde.op N_n (mu \, Sigma)$. Let $y = C x + d$ where $C$ is $r times n$ and $d$ is $r times 1$. Then: $ y tilde.op N_r (C mu + d \, C Sigma C^T) $

] <thm-linear-transform>
#block[
#emph[Proof];. $x = A z + mu$ where $A A^T = Sigma$. $ y = C (A z + mu) + d = (C A) z + (C mu + d) $ This fits the definition of MVN with mean $C mu + d$ and variance $C Sigma C^T$.

]
=== Important Corollaries of #ref(<thm-linear-transform>, supplement: [Theorem])
<important-corollaries-of-thm-linear-transform>
#corollary("Marginals")[
Any subvector of a multivariate normal vector is also multivariate normal.

] <cor-marginals>
#block[
#emph[Proof];. If we partition $x = (x_1 ' \, x_2 ')'$, we can use $C = (I_r \, 0)$ to show $x_1 tilde.op N (mu_1 \, Sigma_11)$.

]
#corollary("Univariate Combinations")[
Any linear combination $a^T x$ is univariate normal: $ a^T x tilde.op N (a^T mu \, a^T Sigma a) $

] <cor-univariate>
#corollary("Orthogonal Transformations")[
If $x tilde.op N (0 \, I_n)$ and $Q$ is orthogonal ($Q' Q = I$), then $y = Q' x tilde.op N (0 \, I_n)$.

] <cor-orthogonal>
#corollary("Standardization")[
If $y tilde.op N_n (mu \, Sigma)$ and $Sigma$ is positive definite: $ Sigma^(- 1 \/ 2) (y - mu) tilde.op N_n (0 \, I_n) $

] <cor-standardization>
#block[
#emph[Proof];. Let $z = Sigma^(- 1 \/ 2) (y - mu)$. Then $upright("Var") (z) = Sigma^(- 1 \/ 2) Sigma Sigma^(- 1 \/ 2) = I_n$.

]
== Independence
<independence>
#theorem("Independence in MVN")[
Let $y tilde.op N (mu \, Sigma)$ be partitioned into $y_1$ and $y_2$. $ Sigma = mat(delim: "(", Sigma_11, Sigma_12; Sigma_21, Sigma_22) $ Then $y_1$ and $y_2$ are independent if and only if $Sigma_12 = 0$ (zero covariance).

] <thm-independence>
#block[
#emph[Proof];. 

+ Independence $arrow.r.double.long$ Covariance is 0: This holds generally for any distribution. $ upright("Cov") (y_1 \, y_2) = E [(y_1 - mu_1) (y_2 - mu_2) '] = 0 $

+ Covariance is 0 $arrow.r.double.long$ Independence: This is specific to MVN. We use MGFs. If $Sigma_12 = 0$, the quadratic form in the MGF splits: $ t^T Sigma t = t_1^T Sigma_11 t_1 + t_2^T Sigma_22 t_2 $ The MGF becomes: $ M_y (t) = exp (t_1^T mu_1 + 1 / 2 t_1^T Sigma_11 t_1) times exp (t_2^T mu_2 + 1 / 2 t_2^T Sigma_22 t_2) $ $ M_y (t) = M_(y_1) (t_1) M_(y_2) (t_2) $ Thus, they are independent.

]
== Signal-Noise Decomposition for Multivariate Normal Distribution
<signal-noise-decomposition-for-multivariate-normal-distribution>
We can formalize the relationship between two random vectors $y$ and $x$ through a decomposition theorem that separates the systematic signal from the stochastic noise.

#theorem("Regression Decomposition Theorem")[
Let the random vector $V$ of dimension $p times 1$ be partitioned into two subvectors $y$ ($p_1 times 1$) and $x$ ($p_2 times 1$). Assume $V$ follows a multivariate normal distribution:

$ vec(y, x) tilde.op N_p (vec(mu_y, mu_x) \, mat(delim: "(", Sigma_(y y), Sigma_(y x); Sigma_(x y), Sigma_(x x))) $

The response vector $y$ can be uniquely decomposed into a systematic component and a stochastic error: $ y = m (x) + e $ where we define the #strong[Regression Coefficient Matrix] $B$ and the components as:

$ B = Sigma_(y x) Sigma_(x x)^(- 1) $

$ m (x) = mu_y + B (x - mu_x) $

$ e = y - m (x) $

#strong[Properties:]

+ #strong[Independence:] The noise vector $e$ is statistically independent of the predictor $x$ (and consequently independent of $m (x)$).

+ #strong[Marginal Distributions:]

  - $m (x) tilde.op N_(p_1) (mu_y \, #h(0em) B Sigma_(x x) B^T)$
  - $e tilde.op N_(p_1) (0 \, #h(0em) Sigma_(y y) - B Sigma_(x x) B^T)$

+ #strong[Conditional Distribution:] Since $y = m (x) + e$, and $e$ is independent of $x$, the conditional distribution is: $ y \| x tilde.op N_(p_1) (m (x) \, Sigma_(y \| x)) $ where: $ m (x) = mu_y + B (x - mu_x) = mu_y + Sigma_(y x) Sigma_(x x)^(- 1) (x - mu_x) $ $ Sigma_(y \| x) = Sigma_(y y) - B Sigma_(x x) B^T = Sigma_(y y) - Sigma_(y x) Sigma_(x x)^(- 1) Sigma_(x y) $

] <thm-reg-decomp>
#block[
#emph[Proof];. We define a transformation from the input vector $V = vec(y, x)$ to the target vector $W = vec(m (x), e)$.

Using the linear transformation $W = C V + d$:

$ underbrace(vec(m (x), e), W) = underbrace(mat(delim: "(", 0, B; I, - B), C) underbrace(vec(y, x), V) + underbrace(vec(mu_y - B mu_x, - (mu_y - B mu_x)), d) $

+ Mean Vector

$ E [W] = C E [V] + d = mat(delim: "(", 0, B; I, - B) vec(mu_y, mu_x) + vec(mu_y - B mu_x, - mu_y + B mu_x) = vec(B mu_x, mu_y - B mu_x) + vec(mu_y - B mu_x, - mu_y + B mu_x) = vec(mu_y, 0) $

#block[
#set enum(numbering: "1.", start: 2)
+ Covariance Matrix
]

We compute $upright("Var") (W) = C Sigma C^T$ directly:

$ C Sigma C^T & = mat(delim: "(", 0, B; I, - B) mat(delim: "(", Sigma_(y y), Sigma_(y x); Sigma_(x y), Sigma_(x x)) mat(delim: "(", 0, I; B^T, - B^T)\
 & = mat(delim: "(", B Sigma_(x y), B Sigma_(x x); Sigma_(y y) - B Sigma_(x y), Sigma_(y x) - B Sigma_(x x)) mat(delim: "(", 0, I; B^T, - B^T)\
 & = mat(delim: "(", B Sigma_(x x) B^T, B Sigma_(x y) - B Sigma_(x x) B^T; Sigma_(y x) B^T - B Sigma_(x x) B^T, (Sigma_(y y) - B Sigma_(x y)) - (Sigma_(y x) - B Sigma_(x x)) B^T)\
 & = mat(delim: "(", B Sigma_(x x) B^T, 0; 0, Sigma_(y y) - B Sigma_(x x) B^T) $

#block[
#set enum(numbering: "1.", start: 3)
+ Conditional Distribution
]

We have established that $y = m (x) + e$ where $e$ is independent of $x$. To find the distribution of $y$ conditional on $x$, we observe that $m (x)$ becomes a constant vector when $x$ is fixed, and the randomness comes solely from $e$:

$ E [y \| x] = m (x) + E [e \| x] = m (x) + 0 = m (x) $ $ upright("Var") (y \| x) = upright("Var") (m (x) \| x) + upright("Var") (e \| x) = 0 + upright("Var") (e) = Sigma_(y \| x) $

Thus, $y \| x tilde.op N (m (x) \, Sigma_(y \| x))$.

]
=== Connections with Other Formulas
<connections-with-other-formulas>
==== Rao-Blackwell Decomposition of Variance
<rao-blackwell-decomposition-of-variance>
The Law of Total Variance (Rao-Blackwell theorem) allows us to decompose the total variance of $y$ into two orthogonal components based on the predictor $x$:

$ upright("Var") (y) = underbrace(E [upright("Var") (y \| x)], upright("Unexplained (Noise)")) + underbrace(upright("Var") [E (y \| x)], upright("Explained (Signal)")) $

In the Multivariate Normal case, this decomposition perfectly aligns with our regression model $y = m (x) + e$.

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Variance of Noise
]
)
]
This term represents the average variance remaining in $y$ after accounting for $x$. It corresponds to the variance of the error term $e$:

$ E [upright("Var") (y \| x)] = upright("Var") (e) = Sigma_(y y) - B Sigma_(x x) B^T $

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Variance of Signal
]
)
]
This term represents the variability of the conditional mean $m (x)$ itself. Using the matrix $B$, this takes the quadratic form:

$ upright("Var") [E (y \| x)] = upright("Var") [m (x)] = B Sigma_(x x) B^T $

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Total Variance
]
)
]
Summing the Signal and Noise components recovers the total marginal variance of $y$:

$ Sigma_(y y) = underbrace(Sigma_(y y) - B Sigma_(x x) B^T, upright("Unexplained (Noise)")) + underbrace(B Sigma_(x x) B^T, upright("Explained (Signal)")) $

==== Connection to OLS Regression Estimators
<connection-to-ols-regression-estimators>
In OLS regression, centering the data allows us to separate the intercept from the slopes. Let $upright(bold(y))_c$ and $upright(bold(X))_c$ be the centered response and design matrices (where $upright(bold(X))_c$ #strong[excludes the column of 1s];). Using this centered form, the total sum of squares decomposes exactly like the population variance:

$ upright("SST") = upright("SSR") + upright("SSE") $

Comparing the sample quantities to their population counterparts:

+ #strong[Regression Coefficients:] $ hat(beta)^T = (upright(bold(X))_c^T upright(bold(X))_c)^(- 1) upright(bold(X))_c^T upright(bold(y))_c approx B $ #emph[Note: $hat(beta)$ here represents only the slope coefficients, matching the dimensions of the covariance matrix $Sigma_(x x)$.]

+ #strong[Explained Variation (Signal):] $ upright("SSR") = hat(beta)^T (upright(bold(X))_c^T upright(bold(X))_c) hat(beta) quad approx quad (n - 1) B Sigma_(x x) B^T $

+ #strong[Unexplained Variation (Noise):] $ upright("SSE") = upright(bold(y))_c^T upright(bold(y))_c - hat(beta)^T (upright(bold(X))_c^T upright(bold(X))_c) hat(beta) quad approx quad (n - 1) (Sigma_(y y) - B Sigma_(x x) B^T) $

== Partial and Multiple Correlation
<partial-and-multiple-correlation>
#definition("Partial Correlation")[
The partial correlation between elements $y_i$ and $y_j$ given a set of variables $x$ is derived from the conditional covariance matrix $Sigma_(y \| x)$: $ rho_(i j \| x) = sigma_(i j \| x) / sqrt(sigma_(i i \| x) sigma_(j j \| x)) $ where $sigma_(i j \| x)$ are elements of $Sigma_(y \| x) = Sigma_(y y) - Sigma_(y x) Sigma_(x x)^(- 1) Sigma_(x y)$.

] <def-partial-corr>
#definition("Multiple Correlation ($R^2$)")[
For a scalar $y$ and vector $x$, the squared multiple correlation is the proportion of variance of $y$ explained by the conditional mean: $ R_(y \| x)^2 = frac(upright("Var") (E (y \| x)), upright("Var") (y)) = frac(Sigma_(y x) Sigma_(x x)^(- 1) Sigma_(x y), sigma_y^2) $

] <def-multiple-corr>
Note: this definition is the population or theretical $R^2$, which is estimated by adjusted $R^2$ using sample in linear regression.

== Examples
<examples-1>
#example("Bivariate Normal")[
Let the random vector $vec(y, x)$ follow a bivariate normal distribution: $ vec(y, x) tilde.op N (vec(1, 2) \, mat(delim: "(", 2, 2; 2, 4)) $ Here, $mu_y = 1 \, mu_x = 2 \, Sigma_(y y) = 2 \, Sigma_(x x) = 4$, and $Sigma_(y x) = 2$.

+ Finding the Regression Coefficient Matrix $B$ Using the population formula: $ B = Sigma_(y x) Sigma_(x x)^(- 1) = 2 (4)^(- 1) = 0.5 $

+ Finding the Conditional Mean $m (x)$ (The Signal) The systematic component represents the projection of $y$ onto $x$: $ m (x) & = mu_y + B (x - mu_x)\
   & = 1 + 0.5 (x - 2) = 0.5 x $

+ Variance of the Signal $upright("Var") (m (x))$ Using the quadratic form established in the theorem: $ upright("Var") (m (x)) = B Sigma_(x x) B^T = 0.5 (4) (0.5) = 1 $

+ Variance of the Noise $upright("Var") (y \| x)$ (The Residual) By the Signal-Noise Decomposition: $ upright("Var") (y \| x) & = Sigma_(y y) - upright("Var") (m (x))\
   & = 2 - 1 = 1 $ Thus, $y \| x tilde.op N (m (x) \, 1)$. The total variance (2) is split equally between signal (1) and noise (1).

+ Multiple Correlation Coefficient ($R^2$) $ R^2 = frac(upright("Var") (m (x)), Sigma_(y y)) = 1 / 2 = 0.5 $

] <exm-numerical>
#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-variance-decomp-scaled-1.png"))
], caption: figure.caption(
position: bottom, 
[
Illustration of Rao-Blackwell Variance Decomposition in Bivariate Normal
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-variance-decomp-scaled>


#example("Trivariate Normal with 2 Predictors")[
Let $V = (y \, x_1 \, x_2)' tilde.op N_3 (mu \, Sigma)$ with: $ mu = vec(1, 2, 3) \, quad Sigma = mat(delim: "(", 10, 3, 4; 3, 2, 1; 4, 1, 4) $ We partition these into $Sigma_(y y) = 10$, $Sigma_(y x) = mat(delim: "(", 3, 4)$, and $Sigma_(x x) = mat(delim: "(", 2, 1; 1, 4)$.

+ Finding the Regression Coefficient Matrix $B$ $ Sigma_(x x)^(- 1) = 1 / 7 mat(delim: "(", 4, - 1; - 1, 2) arrow.r.double.long B = Sigma_(y x) Sigma_(x x)^(- 1) = mat(delim: "(", 8 / 7, 5 / 7) $

+ Finding the Conditional Mean $m (x)$ (The Signal) $ m (x) = 1 + 8 / 7 (x_1 - 2) + 5 / 7 (x_2 - 3) $

+ Variance of the Signal $upright("Var") (m (x))$ $ upright("Var") (m (x)) = B Sigma_(x x) B^T = mat(delim: "(", 8 / 7, 5 / 7) vec(3, 4) = 44 / 7 approx 6.29 $

+ Variance of the Noise $upright("Var") (y \| x)$ (The Residual) Using the Signal-Noise Decomposition: $ Sigma_(y \| x) = Sigma_(y y) - upright("Var") (m (x)) = 10 - 6.29 = 3.71 $

+ Multiple Correlation Coefficient ($R^2$) $ R^2 = 6.29 / 10 = 0.629 $

] <exm-trivariate>
```r
library(ggplot2)
library(mvtnorm)

mu <- c(1, 2, 3)
sigma <- matrix(c(10, 3, 4, 3, 2, 1, 4, 1, 4), nrow=3, byrow=TRUE)

var_total <- sigma[1,1]
S_yx <- matrix(sigma[1, 2:3], nrow=1)
S_xx <- sigma[2:3, 2:3]
B_mat <- S_yx %*% solve(S_xx)
var_signal <- as.numeric(B_mat %*% S_xx %*% t(B_mat))
var_noise <- var_total - var_signal

set.seed(2024)
dat <- rmvnorm(1000, mean=mu, sigma=sigma)
df <- data.frame(y=dat[,1], x1=dat[,2], x2=dat[,3])
df$m_x <- 1 + (8/7)*(df$x1 - 2) + (5/7)*(df$x2 - 3)

limit_min <- -12
limit_max <- 12
seq_vals <- seq(limit_min, limit_max, length.out=300)
scale_factor <- 20 

df_total <- data.frame(y = seq_vals, x = 9 + dnorm(seq_vals, 1, sqrt(var_total)) * scale_factor)
df_signal <- data.frame(x = seq_vals, y = -8 - dnorm(seq_vals, 1, sqrt(var_signal)) * scale_factor)
df_noise <- data.frame(y = seq_vals, x = 5 + dnorm(seq_vals, 5, sqrt(var_noise)) * scale_factor)

ggplot(df, aes(x=m_x, y=y)) +
  geom_abline(intercept=0, slope=1, color="red", linewidth=0.5, alpha=0.3) +
  geom_point(alpha=0.15, size=1.5, color="black") +
  geom_polygon(data=df_signal, aes(x=x, y=y), fill="red", alpha=0.3) +
  geom_path(data=df_signal, aes(x=x, y=y), color="red", linewidth=1) +
  annotate("text", x=1, y=-11, label="Signal Var\n(m(x))", color="red", size=3, fontface="bold") +
  geom_polygon(data=df_total, aes(x=x, y=y), fill="gray40", alpha=0.3) +
  geom_path(data=df_total, aes(x=x, y=y), color="gray40", linewidth=1) +
  annotate("text", x=11, y=6, label="Total Var\n(y)", color="gray40", size=3, fontface="bold") +
  geom_polygon(data=df_noise, aes(x=x, y=y), fill="blue", alpha=0.3) +
  geom_path(data=df_noise, aes(x=x, y=y), color="blue", linewidth=1) +
  annotate("text", x=6, y=9, label="Noise Var\n(y|x)", color="blue", size=3, fontface="bold") +
  scale_x_continuous(limits=c(-12, 14)) + scale_y_continuous(limits=c(-14, 12)) +
  coord_fixed(ratio=1) + labs(x = "Signal m(x)", y = "Observed y") + theme_minimal()
```

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-trivariate-refined-1.png"))
], caption: figure.caption(
position: bottom, 
[
Signal-Noise Variance Decomposition in Multivariate Normal
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-trivariate-refined>


#pagebreak()
= Distribution of Quadratic Forms
<distribution-of-quadratic-forms>
This chapter covers the distribution of quadratic forms (sums of squares), which is crucial for hypothesis testing in linear models.

== Quadratic Forms
<quadratic-forms>
A quadratic form is a polynomial with terms all of degree two.

#definition("Quadratic Form")[
Let $y = (y_1 \, dots.h \, y_n)'$ be a random vector and $A$ be a symmetric $n times n$ matrix. The scalar quantity $y' A y$ is called a #strong[quadratic form] in $y$.

$ y' A y = sum_(i = 1)^n sum_(j = 1)^n a_(i j) y_i y_j $

] <def-quadratic-form-matrix>
#strong[Examples:]

- #strong[Squared Norm:] If $A = I_n$, then $y' I_n y = y' y = sum y_i^2 = lr(||) y lr(||)^2$.
- #strong[Weighted Sum of Squares:] If $A$ is diagonal with elements $lambda_i$, then $y' A y = sum lambda_i y_i^2$.
- #strong[Projection Sum of Squares:] If $P$ is a projection matrix, $lr(||) P y lr(||)^2 = (P y)' (P y) = y' P' P y = y' P y$ (since $P$ is symmetric and idempotent).

== Mean of Quadratic Forms
<mean-of-quadratic-forms>
We can find the expected value of a quadratic form without assuming normality.

#lemma("Mean of Simplified Quadratic Form")[
If $y$ is a random vector with mean $E (y) = mu$ and covariance matrix $upright("Var") (y) = I_n$, then: $ E (y ' y) = upright("tr") (I_n) + mu' mu = n + mu' mu $

] <lem-simple-qf>
#block[
#emph[Proof];. Let us decompose $y$ into its mean and a stochastic component: $y = mu + z$, where $E (z) = 0$ and $upright("Var") (z) = E (z z ') = I_n$. Substituting this into the quadratic form: $ y' y & = (mu + z)' (mu + z)\
 & = mu' mu + mu' z + z' mu + z' z\
 & = mu' mu + 2 mu' z + z' z $ Taking the expectation: $ E (y ' y) & = mu' mu + 2 mu' E (z) + E (z ' z)\
 & = mu' mu + 0 + E (sum_(i = 1)^n z_i^2) $ Since $upright("Var") (z_i) = E (z_i^2) - (E (z_i))^2 = 1 - 0 = 1$, we have $E (sum z_i^2) = sum 1 = n$. Thus, $E (y ' y) = n + mu' mu$.

]
```r
library(ggplot2)
library(MASS)
library(dplyr)

# --- 1. Setup Data & Parameters ---
set.seed(42)
n <- 100
sigma_val <- 1          
Sigma <- diag(2) * sigma_val^2

mu_orig <- c(5, 6)      # Original Mean
y_orig  <- c(7, 5)      # Updated Point y

# Generate 100 Points from N(mu, I)
data_orig <- mvrnorm(n, mu_orig, Sigma)

# Define Rotation Angles
angles <- c(0, 70, 180)

# --- 2. Process Data for Each Angle ---
points_list <- list()
vectors_list <- list()

for (deg in angles) {
  theta <- deg * pi / 180
  rot_mat <- matrix(c(cos(theta), -sin(theta), 
                      sin(theta),  cos(theta)), nrow = 2, byrow = TRUE)
  
  # A. Rotate Points
  data_rot <- data_orig %*% t(rot_mat)
  df_pts <- data.frame(x = data_rot[,1], y = data_rot[,2])
  df_pts$Angle <- factor(paste0(deg, "°"), levels = paste0(angles, "°"))
  points_list[[length(points_list) + 1]] <- df_pts
  
  # B. Rotate Vectors (mu and y)
  mu_rot <- as.vector(rot_mat %*% mu_orig)
  y_rot  <- as.vector(rot_mat %*% y_orig)
  
  df_vec <- data.frame(
    Angle = factor(paste0(deg, "°"), levels = paste0(angles, "°")),
    mu_x = mu_rot[1], mu_y = mu_rot[2],
    y_x  = y_rot[1],  y_y  = y_rot[2]
  )
  vectors_list[[length(vectors_list) + 1]] <- df_vec
}

all_points  <- do.call(rbind, points_list)
all_vectors <- do.call(rbind, vectors_list)

# --- 3. Create Circle Data ---
# Radius Is the Length of Mu
radius_mu <- sqrt(sum(mu_orig^2))
circle_data <- data.frame(
  x0 = 0, y0 = 0, r = radius_mu
)

# --- 4. Generate the Plot ---
ggplot() +
  # 1. Circle through the mu's (Centered at 0,0)
  ggforce::geom_circle(aes(x0 = 0, y0 = 0, r = radius_mu), 
                       color = "gray50", linetype = "dotted", size = 0.5) +
  
  # 2. Points (Data Cloud)
  geom_point(data = all_points, aes(x = x, y = y, color = Angle), 
             size = 0.5, alpha = 0.5) +
  
  # 3. Vector mu (Origin -> mu)
  geom_segment(data = all_vectors, 
               aes(x = 0, y = 0, xend = mu_x, yend = mu_y, color = Angle),
               arrow = arrow(length = unit(0.2, "cm")), size = 0.8) +
  
  # 4. Vector y (Origin -> y)
  geom_segment(data = all_vectors, 
               aes(x = 0, y = 0, xend = y_x, yend = y_y, color = Angle),
               arrow = arrow(length = unit(0.2, "cm")), size = 0.8) +
  
  # 5. Vector y - mu (mu -> y)
  geom_segment(data = all_vectors, 
               aes(x = mu_x, y = mu_y, xend = y_x, yend = y_y, color = Angle),
               arrow = arrow(length = unit(0.15, "cm")), 
               linetype = "dashed", size = 0.6) +
  
  # 6. Labels for mu, y, and y-mu
  geom_text(data = all_vectors, aes(x = mu_x, y = mu_y, label = expression(mu), color = Angle),
            parse = TRUE, vjust = -0.5, size = 4, show.legend = FALSE) +
  
  geom_text(data = all_vectors, aes(x = y_x, y = y_y, label = "y", color = Angle),
            vjust = -0.5, hjust = -0.2, size = 4, fontface = "italic", show.legend = FALSE) +
  
  # Label for y - mu (placed at midpoint)
  geom_text(data = all_vectors, aes(x = (mu_x + y_x)/2, y = (mu_y + y_y)/2, 
                                    label = expression(y - mu), color = Angle),
            parse = TRUE, size = 3, vjust = 1.5, show.legend = FALSE) +

  # 7. Origin Marker
  geom_point(aes(x=0, y=0), color="black", size=2) +
  
  # Formatting
  coord_fixed() +
  theme_minimal() +
  labs(title = "Rotations of Normal Cloud",
       x = "x", y = "y") +
  theme(legend.position = "bottom")
```

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-qf-norm-1.png"))
], caption: figure.caption(
position: bottom, 
[
Illustration of the Mean and Distribution of Quadratic Forms
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-qf-norm>


#theorem("Mean of Quadratic Form")[
If $y$ is a random vector with mean $E (y) = mu$ and covariance matrix $upright("Var") (y) = Sigma$, and $A$ is a symmetric matrix of constants, then:

$ E (y ' A y) = upright("tr") (A Sigma) + mu' A mu $

] <thm-mean-qf>
#block[
#emph[Proof];. We present three methods to derive the expectation of the quadratic form.

#strong[Method 1: Using the Trace Trick]

Using the fact that a scalar is equal to its own trace ($upright("tr") (c) = c$) and the linearity of expectation: $ E (y ' A y) & = E [upright("tr") (y ' A y)]\
 & = E [upright("tr") (A y y ')] quad upright("(cyclic property of trace)")\
 & = upright("tr") (A E [y y ']) quad upright("(linearity of expectation)") $ Recall that the covariance matrix is defined as $Sigma = E [(y - mu) (y - mu) '] = E (y y ') - mu mu'$. Rearranging this gives the second moment: $E (y y ') = Sigma + mu mu'$. Substituting this back: $ E (y ' A y) & = upright("tr") (A (Sigma + mu mu '))\
 & = upright("tr") (A Sigma) + upright("tr") (A mu mu ')\
 & = upright("tr") (A Sigma) + upright("tr") (mu ' A mu) quad upright("(cyclic property on second term)")\
 & = upright("tr") (A Sigma) + mu' A mu $

#strong[Method 2: Using Scalar Summation]

We can express the quadratic form in scalar notation using the entries of $A = (a_(i j))$, $Sigma = (sigma_(i j))$, and $mu = (mu_i)$: $ E (y ' A y) & = E (sum_(i = 1)^n sum_(j = 1)^n a_(i j) y_i y_j)\
 & = sum_(i = 1)^n sum_(j = 1)^n a_(i j) E (y_i y_j)\
 & = sum_(i = 1)^n sum_(j = 1)^n a_(i j) (sigma_(i j) + mu_i mu_j)\
 & = sum_(i = 1)^n sum_(j = 1)^n a_(i j) sigma_(j i) + sum_(i = 1)^n sum_(j = 1)^n mu_i a_(i j) mu_j quad (upright("since ") Sigma upright(" is symmetric, ") sigma_(i j) = sigma_(j i))\
 & = upright("tr") (A Sigma) + mu' A mu $

#strong[Method 3: Using Spectral Decomposition of A]

Since $A$ is symmetric, we use its spectral decomposition $A = sum_(i = 1)^n lambda_i q_i q_i'$. Substituting this into the quadratic form: $ y' A y = y' (sum_(i = 1)^n lambda_i q_i q_i ') y = sum_(i = 1)^n lambda_i (q_i ' y)^2 $ Let $w_i = q_i' y$. This is a scalar random variable which is a linear transformation of $y$. Its properties are:

+ #strong[Mean:] $E (w_i) = q_i' E (y) = q_i' mu$.
+ #strong[Variance:] $upright("Var") (w_i) = upright("Var") (q_i ' y) = q_i' upright("Var") (y) q_i = q_i' Sigma q_i$.

Using the relation $E (w_i^2) = upright("Var") (w_i) + [E (w_i)]^2$, we have: $ E [(q_i ' y)^2] = q_i' Sigma q_i + (q_i ' mu)^2 $ Summing over all $i$ weighted by $lambda_i$: $ E (y ' A y) & = sum_(i = 1)^n lambda_i [q_i ' Sigma q_i + (q_i ' mu)^2]\
 & = sum_(i = 1)^n upright("tr") (lambda_i q_i ' Sigma q_i) + mu' (sum_(i = 1)^n lambda_i q_i q_i ') mu\
 & = upright("tr") (Sigma sum_(i = 1)^n lambda_i q_i q_i ') + mu' A mu\
 & = upright("tr") (Sigma A) + mu' A mu $

]
#block[
#emph[Remark] (Geometric Interpretation via Sigma). If we further decompose $Sigma = sum_(j = 1)^n gamma_j v_j v_j'$ (where $gamma_j \, v_j$ are eigenvalues/vectors of $Sigma$), the trace term becomes: $ upright("tr") (A Sigma) = sum_(i = 1)^n sum_(j = 1)^n lambda_i gamma_j (q_i ' v_j)^2 $ Here, $(q_i ' v_j)^2 = cos^2 (theta_(i j))$ represents the alignment between the axes of the quadratic form ($A$) and the axes of the data covariance ($Sigma$). The expectation is maximized when the eigenspaces of $A$ and $Sigma$ align.

]
#corollary("Expectation with Projection Matrix")[
Consider the special case where:

+ $P$ is a #strong[projection matrix] (symmetric and idempotent, $P^2 = P$).
+ The covariance is #strong[spherical];: $Sigma = sigma^2 I_n$.

Then the expectation simplifies to: $ E (y ' P y) = sigma^2 r + lr(||) P mu lr(||)^2 $ where $r = upright("rank") (P) = upright("tr") (P)$.

#strong[Proof:] Using #ref(<thm-mean-qf>, supplement: [Theorem]) with $A = P$ and $Sigma = sigma^2 I_n$:

+ #strong[Trace Term:] $upright("tr") (P Sigma) = upright("tr") (P (sigma^2 I_n)) = sigma^2 upright("tr") (P)$. Since $P$ is idempotent, its eigenvalues are either 0 or 1, so $upright("tr") (P) = upright("rank") (P) = r$.
+ #strong[Mean Term:] Since $P$ is symmetric and idempotent ($P' P = P^2 = P$), we can rewrite the quadratic form: $ mu' P mu = mu' P' P mu = (P mu)' (P mu) = lr(||) P mu lr(||)^2 $

] <cor-projection-mean>
#example("Expectation of Sum of Squares Decomposition (i.i.d. Case)")[
Consider a random vector $y = (y_1 \, dots.h \, y_n)'$ with mean vector $mu_y = mu j_n$ and covariance $Sigma = sigma^2 I_n$. We analyze the two components of the total sum of squares by projecting $y$ onto the mean space ($P_(j_n)$) and the residual space ($I - P_(j_n)$).

+ The Projection Vectors

First, we write the explicit forms of the projected vectors using $P_(j_n) = 1 / n j_n j_n'$:

- #strong[Mean Vector ($P_(j_n) y$):] Projecting $y$ onto the column space of $j_n$ replaces every element with the sample mean $macron(y)$. $ P_(j_n) y = macron(y) j_n = vec(macron(y), macron(y), dots.v, macron(y)) $

- #strong[Residual Vector ($(I - P_(j_n)) y$):] Subtracting the mean projection from $y$ yields the deviations. $ (I - P_(j_n)) y = y - macron(y) j_n = vec(y_1 - macron(y), y_2 - macron(y), dots.v, y_n - macron(y)) $

#block[
#set enum(numbering: "1.", start: 2)
+ Expectations of Squared Norms
]

We now find the expectation of the squared length of these vectors using #ref(<cor-projection-mean>, supplement: [Corollary]).

#strong[Part A: Sum of Squares for Mean] The quadratic form is the squared norm of the projected mean vector: $ y' P_(j_n) y = lr(||) P_(j_n) y lr(||)^2 = sum_(i = 1)^n macron(y)^2 = n macron(y)^2 $ Applying the corollary with $P = P_(j_n)$:

- #strong[Rank:] $upright("tr") (P_(j_n)) = 1$.
- #strong[Mean:] $P_(j_n) mu_y = P_(j_n) (mu j_n) = mu j_n$. The squared norm is $n mu^2$.

$ E [lr(||) P_(j_n) y lr(||)^2] = sigma^2 (1) + n mu^2 $

#strong[Part B: Sum of Squared Errors (SSE)] The quadratic form is the squared norm of the residual vector: $ y' (I - P_(j_n)) y = lr(||) (I - P_(j_n)) y lr(||)^2 = sum_(i = 1)^n (y_i - macron(y))^2 $ Applying the corollary with $P = I - P_(j_n)$:

- #strong[Rank:] $upright("tr") (I - P_(j_n)) = n - 1$.
- #strong[Mean:] $(I - P_(j_n)) mu_y = mu_y - P_(j_n) mu_y = mu j_n - mu j_n = 0$. The squared norm is $0$.

$ E [lr(||) (I - P_(j_n)) y lr(||)^2] = sigma^2 (n - 1) + 0 $

#strong[Conclusion] These results confirm the standard properties: $E (macron(y)^2) = sigma^2 / n + mu^2$ and $E (S^2) = sigma^2$.

] <exm-mean-ss-decomposition>
#example("Expectation of Total Sum of Squares (Regression Case)")[
Consider now a regression setting where the mean of $y$ depends on covariates (e.g., $mu_i = beta_0 + beta_1 x_i$). The mean vector $mu_y$ is #strong[not] proportional to $j_n$. We are interested in the expectation of the #strong[Total Sum of Squares (SST)];.

+ Identification The SST measures the variation of $y$ around the #emph[global sample mean] $macron(y)$, ignoring the covariates: $ upright("SST") = sum_(i = 1)^n (y_i - macron(y))^2 = y' (I - P_(j_n)) y $ This is the same quadratic form as Part B in the previous example, but the underlying mean $mu_y$ has changed.

+ Calculation We apply #ref(<cor-projection-mean>, supplement: [Corollary]) with $P = I - P_(j_n)$ and general $mu_y$:

- #strong[Rank Term:] Same as before, $upright("tr") (I - P_(j_n)) = n - 1$.
- #strong[Mean Term:] The projection of the mean vector is no longer zero. $ (I - P_(j_n)) mu_y = mu_y - macron(mu) j_n = vec(mu_1 - macron(mu), dots.v, mu_n - macron(mu)) $ where $macron(mu) = 1 / n sum mu_i$ is the average of the true means. The squared norm is the sum of squared deviations of the true means: $ lr(||) (I - P_(j_n)) mu_y lr(||)^2 = sum_(i = 1)^n (mu_i - macron(mu))^2 $

#strong[Conclusion] $ E (upright("SST")) = (n - 1) sigma^2 + sum_(i = 1)^n (mu_i - macron(mu))^2 $ This shows that in regression, the SST estimates $(n - 1) sigma^2$ #emph[plus] the variability introduced by the regression signal (the spread of the true means $mu_i$).

] <exm-mean-sst-regression>
```r
library(ggplot2)
library(dplyr)
library(patchwork)

set.seed(123)
n <- 20
sigma <- 1

# --- Data Generation ---

# Case 1: I.i.d. Case (common Mean)
mu_iid <- rep(3, n)
y_iid <- mu_iid + rnorm(n, 0, sigma)

# Case 2: Regression Case (sorted Mean)
# Mu_i Is Sampled from N(3, Sd=3) and Sorted
mu_reg <- sort(rnorm(n, 3, 3)) 
y_reg <- mu_reg + rnorm(n, 0, sigma)

df_iid <- data.frame(
  id = 1:n,
  y = y_iid,
  mu = mu_iid,
  y_bar = mean(y_iid),
  type = "i.i.d. Case (Common Mean)"
)

df_reg <- data.frame(
  id = 1:n,
  y = y_reg,
  mu = mu_reg,
  y_bar = mean(y_reg),
  type = "Regression Case (Sorted Mean)"
)

# Determine Common Y Limits for Comparison Across Both Plots
y_min <- min(c(df_iid$y, df_reg$y, df_iid$mu, df_reg$mu)) - 1
y_max <- max(c(df_iid$y, df_reg$y, df_iid$mu, df_reg$mu)) + 1
y_lims <- c(y_min, y_max)

# --- Plotting Function ---

plot_func <- function(df, title, ylims) {
  ggplot(df, aes(x = id)) +
    # Vertical lines for the deviations (y_i - y_bar)
    geom_segment(aes(xend = id, y = y_bar, yend = y), 
                 color = "gray50", linetype = "solid", alpha = 0.6) +
    # True means mu_i (red X)
    geom_point(aes(y = mu, shape = "True Mean (μ_i)"), color = "red", size = 3) +
    # Observations y_i (black dots)
    geom_point(aes(y = y, shape = "Observed (y_i)"), color = "black", size = 2) +
    # Global Sample Mean line (y_bar)
    geom_hline(aes(yintercept = y_bar, linetype = "Sample Mean (ȳ)"), 
               color = "blue", linewidth = 0.8) +
    scale_shape_manual(name = "", values = c("True Mean (μ_i)" = 4, "Observed (y_i)" = 16)) +
    scale_linetype_manual(name = "", values = c("Sample Mean (ȳ)" = "dashed")) +
    scale_y_continuous(limits = ylims) +
    labs(title = title, x = "Observation Index (Sorted by μ_i)", y = "Value") +
    theme_minimal() +
    theme(legend.position = "bottom")
}

# --- Combine Plots ---

p1 <- plot_func(df_iid, "i.i.d. Case: E(SST) = (n-1)σ²", y_lims)
p2 <- plot_func(df_reg, "Regression Case: E(SST) = (n-1)σ² + Σ(μ_i - μ̄)²", y_lims)

p1 + p2 + plot_layout(guides = "collect") & theme(legend.position = "bottom")
```

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-sst-comparison-sorted-v2-1.png"))
], caption: figure.caption(
position: bottom, 
[
Comparison of SST components with increased variation in the true means. The vertical lines represent the deviations $(y_i - macron(y))$. With $upright("sd") (mu_i) = 3$, the regression case (right) shows significantly larger deviations, illustrating how the systematic spread of the means dominates the Total Sum of Squares.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-sst-comparison-sorted-v2>


== Non-central $chi^2$ Distribution
<non-central-chi2-distribution>
To understand the distribution of quadratic forms under normality, we introduce the non-central chi-square distribution.

#definition("Non-central $chi^2$ Distribution")[
Let $y tilde.op N_n (mu \, I_n)$. The random variable $V = y' y = sum y_i^2$ follows a #strong[non-central chi-square distribution] with $n$ degrees of freedom and non-centrality parameter $lambda$.

$ V tilde.op chi^2 (n \, lambda) quad upright("where ") lambda = mu' mu = lr(||) mu lr(||)^2 $

] <def-nc-chisq>
#block[
#callout(
body: 
[
#strong[Note on NCP Definition:] Some definitions of non-central $chi^2$ use $lambda = 1 / 2 mu' mu$. In this course, we use $lambda = mu' mu$. With this convention, the Poisson-mixture representation below uses Poisson($lambda \/ 2$) weights.

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
=== Visualizing $chi^2$ Distributions
<visualizing-chi2-distributions>
Here is a plot visualizing the difference between central and non-central Chi-square distributions.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-plot-chisq-1.png"))
], caption: figure.caption(
position: bottom, 
[
Central vs Non-central Chi-square Distribution
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-plot-chisq>


The density of the non-central chi-square distribution shifts to the right and becomes flatter as the non-centrality parameter $lambda$ increases.

=== Mean, Variance, and MGF
<mean-variance-and-mgf>
We summarize the key properties of the non-central chi-square distribution.

#theorem("Properties of Non-central Chi-square")[
Let $V tilde.op chi^2 (n \, lambda)$. Then:

+ #strong[Mean:] $E (V) = n + lambda$
+ #strong[Variance:] $upright("Var") (V) = 2 n + 4 lambda$
+ #strong[Moment Generating Function (MGF):] $ m_V (t) = frac(exp [- lambda / 2 {1 - frac(1, 1 - 2 t)}], (1 - 2 t)^(n \/ 2)) quad upright("for ") t < 1 \/ 2 $

] <thm-chisq-properties>
#block[
#emph[Proof] (Mean). By definition, $V tilde.op chi^2 (n \, lambda)$ is the distribution of $y' y$ where $y tilde.op N_n (mu \, I_n)$ and the non-centrality parameter is $lambda = mu' mu = lr(||) mu lr(||)^2$. Applying #ref(<lem-simple-qf>, supplement: [Lemma]) to the random vector $y$: $ E (V) = E (y ' y) = n + mu' mu = n + lambda $

]
#block[
#emph[Proof] (MGF). Since the components $y_i$ of the vector $y$ are independent $N (mu_i \, 1)$, and $V = sum_(i = 1)^n y_i^2$, the MGF of $V$ is the product of the MGFs of each $y_i^2$: $ m_V (t) = E [e^(t sum y_i^2)] = product_(i = 1)^n E [e^(t y_i^2)] $ Consider a single component $y_i tilde.op N (mu_i \, 1)$. Its squared expectation is: $ E [e^(t y_i^2)] & = integral_(- oo)^oo 1 / sqrt(2 pi) e^(t y^2) e^(- 1 / 2 (y - mu_i)^2) d y\
 & = 1 / sqrt(2 pi) integral_(- oo)^oo exp {- 1 / 2 [(1 - 2 t) y^2 - 2 mu_i y + mu_i^2]} d y $ Completing the square in the exponent for $y$ (assuming $t < 1 \/ 2$): $ (1 - 2 t) y^2 - 2 mu_i y + mu_i^2 = (1 - 2 t) (y - frac(mu_i, 1 - 2 t))^2 + mu_i^2 - frac(mu_i^2, 1 - 2 t) $ The integral of the Gaussian kernel $exp { - 1 / 2 (1 - 2 t) (y - dots.h)^2 }$ yields $sqrt(frac(2 pi, 1 - 2 t))$. The remaining constant term is: $ exp {- 1 / 2 (mu_i^2 - frac(mu_i^2, 1 - 2 t))} = exp {mu_i^2 / 2 (frac(1, 1 - 2 t) - 1)} = exp {frac(mu_i^2 t, 1 - 2 t)} $ Thus, for a single component: $ m_(y_i^2) (t) = (1 - 2 t)^(- 1 \/ 2) exp (frac(mu_i^2 t, 1 - 2 t)) $ Multiplying the MGFs for all $n$ components: $ m_V (t) & = product_(i = 1)^n (1 - 2 t)^(- 1 \/ 2) exp (frac(mu_i^2 t, 1 - 2 t))\
 & = (1 - 2 t)^(- n \/ 2) exp (frac(t sum mu_i^2, 1 - 2 t)) $ Substituting $lambda = sum mu_i^2$ (so $sum mu_i^2 = lambda$): $ m_V (t) = (1 - 2 t)^(- n \/ 2) exp (frac(lambda t, 1 - 2 t)) $ Note that $frac(lambda t, 1 - 2 t) = - lambda / 2 (1 - frac(1, 1 - 2 t))$, which leads to the Poisson-mixture representation with $J tilde.op upright("Poisson") (lambda \/ 2)$.

]
#block[
#emph[Proof] (Variance). We use the #strong[Cumulant Generating Function];, $K_V (t) = ln m_V (t)$, as its derivatives yield the mean and variance directly: $ K_V (t) = - n / 2 ln (1 - 2 t) + frac(lambda t, 1 - 2 t) $ First derivative (Mean): $ K'_V (t) & = - n / 2 (frac(- 2, 1 - 2 t)) + lambda [frac(1 (1 - 2 t) - t (- 2), (1 - 2 t)^2)]\
 & = frac(n, 1 - 2 t) + lambda / (1 - 2 t)^2 $ Second derivative (Variance): $ K''_V (t) & = n (- 1) (1 - 2 t)^(- 2) (- 2) + lambda (- 2) (1 - 2 t)^(- 3) (- 2)\
 & = frac(2 n, (1 - 2 t)^2) + frac(4 lambda, (1 - 2 t)^3) $ Evaluating at $t = 0$: $ upright("Var") (V) = K''_V (0) = 2 n + 4 lambda $

]
=== Additivity
<additivity>
#theorem("Additivity of Chi-square")[
If $v_1 \, dots.h \, v_k$ are independent random variables distributed as $chi^2 (n_i \, lambda_i)$, then their sum follows a chi-square distribution:

$ sum_(i = 1)^k v_i tilde.op chi^2 (sum_(i = 1)^k n_i \, sum_(i = 1)^k lambda_i) $

] <thm-chisq-additivity>
#block[
#emph[Proof];. #strong[Method 1: Using MGFs]

The moment generating function of $v_i tilde.op chi^2 (n_i \, lambda_i)$ is: $ M_(v_i) (t) = frac(exp [- lambda_i / 2 (1 - frac(1, 1 - 2 t))], (1 - 2 t)^(n_i \/ 2)) $

Since $v_1 \, dots.h \, v_k$ are independent, the MGF of their sum $V = sum v_i$ is the product of their individual MGFs:

$ M_V (t) & = product_(i = 1)^k M_(v_i) (t)\
 & = product_(i = 1)^k frac(exp [- lambda_i / 2 (1 - frac(1, 1 - 2 t))], (1 - 2 t)^(n_i \/ 2))\
 & = frac(exp [- frac(sum lambda_i, 2) (1 - frac(1, 1 - 2 t))], (1 - 2 t)^(sum n_i \/ 2)) $

This is the MGF of a non-central chi-square distribution with degrees of freedom $sum n_i$ and non-centrality parameter $sum lambda_i$.

#strong[Method 2: Geometric Interpretation]

Let $v_i = lr(||) y_i lr(||)^2$ where $y_i tilde.op N_(n_i) (mu_i \, I_(n_i))$. Since the vectors $y_i$ are independent, we can stack them into a larger vector $y = (y_1 ' \, dots.h \, y_k ')'$.

$ y tilde.op N_(sum n_i) (mu \, I_(sum n_i)) quad upright("where ") mu = (mu_1 ' \, dots.h \, mu_k ')' $

The sum of squares is: $ sum v_i = sum lr(||) y_i lr(||)^2 = lr(||) y lr(||)^2 $

By definition, $lr(||) y lr(||)^2$ follows a non-central chi-square distribution with degrees of freedom equal to the dimension of $y$ ($sum n_i$) and non-centrality parameter $lambda = lr(||) mu lr(||)^2$.

$ lambda = sum_(i = 1)^k lr(||) mu_i lr(||)^2 = sum_(i = 1)^k lambda_i $

]
=== Poisson Mixture Representation
<poisson-mixture-representation>
#theorem("Poisson Mixture Representation")[
Let $v tilde.op chi^2 (n \, lambda)$ be a non-central chi-square random variable. Its probability density function can be represented as a Poisson-weighted sum of central chi-square density functions:

$ f (v ; n \, lambda) = sum_(j = 0)^oo (frac(e^(- lambda \/ 2) (lambda \/ 2)^j, j !)) f (v ; n + 2 j \, 0) $

where $f (v ; nu \, 0)$ is the density of a central chi-square distribution with $nu$ degrees of freedom.

] <thm-chisq-poisson-mixture>
#block[
#emph[Proof];. We use the Moment Generating Function (MGF) approach. The MGF of a non-central chi-square distribution $v tilde.op chi^2 (n \, lambda)$ is: $ M_v (t) = (1 - 2 t)^(- n \/ 2) exp (lambda / 2 [frac(1, 1 - 2 t) - 1]) $

We can expand the exponential term using the power series $e^x = sum_(j = 0)^oo frac(x^j, j !)$: $ M_v (t) & = (1 - 2 t)^(- n \/ 2) e^(- lambda \/ 2) exp (frac(lambda \/ 2, 1 - 2 t))\
 & = e^(- lambda \/ 2) (1 - 2 t)^(- n \/ 2) sum_(j = 0)^oo frac(1, j !) (frac(lambda \/ 2, 1 - 2 t))^j\
 & = sum_(j = 0)^oo (frac(e^(- lambda \/ 2) (lambda \/ 2)^j, j !)) (1 - 2 t)^(- (n + 2 j) \/ 2) $

Recognizing the terms:

+ The term in parentheses, $P (J = j) = frac(e^(- lambda \/ 2) (lambda \/ 2)^j, j !)$, is the probability mass function of a #strong[Poisson] random variable $J tilde.op upright("Poisson") (lambda \/ 2)$.
+ The term $(1 - 2 t)^(- (n + 2 j) \/ 2)$ is the MGF of a #strong[central chi-square] distribution with $n + 2 j$ degrees of freedom.

Since the MGF of the mixture is the sum of the MGFs of the components weighted by the mixture probabilities, the density must follow the same mixture structure.

]
#block[
#emph[Remark];. This theorem implies a hierarchical model for generating a non-central chi-square variable:

+ Sample $J tilde.op upright("Poisson") (lambda \/ 2)$.
+ Given $J = j$, sample $V tilde.op chi^2 (n + 2 j \, 0)$.

This is particularly useful for numerical computation, as it allows the non-central CDF to be approximated by a finite sum of central chi-square CDFs.

]
```r
library(ggplot2)
library(dplyr)

# Parameters
n <- 4          # Base degrees of freedom
lambda <- 4     # Non-centrality parameter (lambda = ||mu||^2)
x_limit <- 25   # X-axis range
j_values <- 0:15 # Sequence of J = 0, 1, 2...

# Generate Data for the Mixture Components
x <- seq(0, x_limit, length.out = 400)
mixture_df <- do.call(rbind, lapply(j_values, function(j) {
  weight <- dpois(j, lambda/2)
  data.frame(
    x = x,
    y = dchisq(x, df = n + 2*j),
    j = j,
    weight = weight
  )
}))

# Generate Data for the True Non-central Chi-square
# R Uses Ncp = ||mu||^2 (we set lambda = ||mu||^2)
true_nc <- data.frame(
  x = x,
  y = dchisq(x, df = n, ncp = lambda)
) 

# Plotting
ggplot() +
  # Draw weighted central chi-square curves (the "cloud")
  geom_line(data = mixture_df, 
            aes(x = x, y = y, group = j, alpha = weight), 
            color = "black", 
            linewidth = 0.8) +
  # Draw the true non-central chi-square density
  geom_line(data = true_nc, aes(x = x, y = y), 
            color = "blue", 
            linewidth = 1.3) +
  # Aesthetics
  scale_alpha_continuous(range = c(0.01, 0.8), guide = "none") +
  labs(
    title = "Poisson Mixture Representation of Non-central Chi-square",
    subtitle = paste0("n = ", n, ", λ = ", lambda, " (Blue line = True Non-central)"),
    x = "Value (v)",
    y = "Density"
  ) +
  theme_minimal()
```

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-chisq-poisson-mixture-fixed-1.png"))
], caption: figure.caption(
position: bottom, 
[
The non-central chi-square distribution as a Poisson mixture. The black curves represent central chi-square densities with $d f = n + 2 j$, with transparency (alpha) proportional to the Poisson weight $P (J = j)$. The solid blue line is the true non-central chi-square density.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-chisq-poisson-mixture-fixed>


== Distribution of Quadratic Forms
<distribution-of-quadratic-forms-1>
=== MGF of Quadratic Forms
<mgf-of-quadratic-forms>
To determine the distribution of general quadratic forms $y' A y$, we look at their MGF.

#theorem("MGF of Quadratic Form")[
If $y tilde.op N_p (mu \, Sigma)$, then the MGF of $Q = y' A y$ is:

$ M_Q (t) = lr(|I - 2 t A Sigma|)^(- 1 \/ 2) exp (- 1 / 2 mu ' [I - (I - 2 t A Sigma)^(- 1)] Sigma^(- 1) mu) $

] <thm-mgf-quad>
=== Distribution of the Sum Squares of Projected Spherical Normal
<distribution-of-the-sum-squares-of-projected-spherical-normal>
We will prove a simplified version of #ref(<thm-dist-quad>, supplement: [Theorem]) first.

#theorem("Distribution of Projected Spherical Normal")[
If $y tilde.op N_n (mu \, sigma^2 I_n)$ and $P_V$ is a projection matrix onto a subspace $V$ of dimension $r$, then:

$ 1 / sigma^2 y' P_V y = frac(lr(||) P_V y lr(||)^2, sigma^2) tilde.op chi^2 (r \, frac(lr(||) P_V mu lr(||)^2, sigma^2)) $

This holds because $1 / sigma^2 P_V (sigma^2 I) = P_V$, which is idempotent.

] <thm-proj-matrix>
#block[
#callout(
body: 
[
This is one of the most important theorems in the course, establishing the fundamental conditions under which a quadratic form follows a chi-square distribution.

]
, 
title: 
[
Crucial Theorem
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
#block[
#emph[Proof];. #strong[When $sigma^2 = 1$]

Let $P_V$ be the projection matrix. We know $P_V = Q Q'$ where $Q = (q_1 \, dots.h \, q_r)$ is an $n times r$ matrix with orthonormal columns ($Q' Q = I_r$).

The projection of vector $y$ onto the subspace $V$ can be expressed using the orthonormal basis vectors: $ P_V y = Q Q' y = (q_1 \, dots.h \, q_r) vec(q_1' y, dots.v, q_r' y) = sum_(i = 1)^r (q_i ' y) q_i $

The squared norm of the projection is: $ y' P_V y = y' Q Q' y = (Q ' y)' (Q ' y) = lr(||) Q' y lr(||)^2 $

Since $y tilde.op N (mu \, I_n)$, the linear transformation $w = Q' y$ follows: $ w tilde.op N (Q ' mu \, Q ' I_n Q) = N (Q ' mu \, I_r) $

Thus, $w$ is a vector of $r$ independent normal variables with variance 1. The sum of squares $lr(||) w lr(||)^2$ is by definition non-central chi-square:

$ lr(||) w lr(||)^2 tilde.op chi^2 (r \, lambda) $ where the non-centrality parameter is: $ lambda = lr(||) E (w) lr(||)^2 = lr(||) Q' mu lr(||)^2 $

Note that $lr(||) Q' mu lr(||)^2 = mu' Q Q' mu = mu' P_V mu = lr(||) P_V mu lr(||)^2$.

Thus, $y' P_V y tilde.op chi^2 (r \, lr(||) P_V mu lr(||)^2)$.

#strong[When $sigma^2 eq.not 1$]

If $y tilde.op N (mu \, sigma^2 I_n)$, we standardize by dividing by $sigma$.

Let $w = y \/ sigma$. Then $w tilde.op N (mu \/ sigma \, I_n)$. Applying the previous result to $w$:

$ w' P_V w = frac(y' P_V y, sigma^2) tilde.op chi^2 (r \, lr(|lr(|P_V mu / sigma|)|)^2) $ which simplifies to: $ frac(lr(||) P_V y lr(||)^2, sigma^2) tilde.op chi^2 (r \, frac(lr(||) P_V mu lr(||)^2, sigma^2)) $

]
#block[
#callout(
body: 
[
The term $parallel P_V y parallel^2$ itself is #strong[not] a standard chi-square variable; it is a scaled chi-square variable. Its mean is:

$ E (parallel P_V y parallel^2) = sigma^2 (r + frac(parallel P_V mu parallel^2, sigma^2)) = r sigma^2 + parallel P_V mu parallel^2 $

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
=== Distribution of General Quadratic Forms
<distribution-of-general-quadratic-forms>
#lemma("Idempotent Matrix Property")[
Let $Sigma$ be a positive definite matrix such that $Sigma = Sigma^(1 \/ 2) Sigma^(1 \/ 2)$. The matrix $A Sigma$ is idempotent if and only if $Sigma^(1 \/ 2) A Sigma^(1 \/ 2)$ is idempotent.

] <lem-idempotent-sigma>
#block[
#emph[Proof];. $(arrow.r.double)$ Assume $A Sigma$ is idempotent, so $A Sigma A Sigma = A Sigma$. Then: $ (Sigma^(1 \/ 2) A Sigma^(1 \/ 2))^2 & = Sigma^(1 \/ 2) A (Sigma^(1 \/ 2) Sigma^(1 \/ 2)) A Sigma^(1 \/ 2)\
 & = Sigma^(1 \/ 2) (A Sigma A) Sigma^(1 \/ 2) $ From the assumption $A Sigma A Sigma = A Sigma$, post-multiplying by $Sigma^(- 1)$ gives $A Sigma A = A$. Substituting this back: $ Sigma^(1 \/ 2) (A) Sigma^(1 \/ 2) = Sigma^(1 \/ 2) A Sigma^(1 \/ 2) $

$(arrow.l.double)$ Assume $Sigma^(1 \/ 2) A Sigma^(1 \/ 2)$ is idempotent. Then: $ (Sigma^(1 \/ 2) A Sigma^(1 \/ 2)) (Sigma^(1 \/ 2) A Sigma^(1 \/ 2)) = Sigma^(1 \/ 2) A Sigma^(1 \/ 2) $ Expanding the left side: $ Sigma^(1 \/ 2) A (Sigma^(1 \/ 2) Sigma^(1 \/ 2)) A Sigma^(1 \/ 2) = Sigma^(1 \/ 2) A Sigma A Sigma^(1 \/ 2) $ Equating this to the right side: $ Sigma^(1 \/ 2) A Sigma A Sigma^(1 \/ 2) = Sigma^(1 \/ 2) A Sigma^(1 \/ 2) $ Pre-multiply by $Sigma^(- 1 \/ 2)$ and post-multiply by $Sigma^(1 \/ 2)$ (which exist since $Sigma$ is positive definite): $ Sigma^(- 1 \/ 2) (Sigma^(1 \/ 2) A Sigma A Sigma^(1 \/ 2)) Sigma^(1 \/ 2) & = Sigma^(- 1 \/ 2) (Sigma^(1 \/ 2) A Sigma^(1 \/ 2)) Sigma^(1 \/ 2)\
I (A Sigma A) Sigma & = I (A) Sigma\
A Sigma A Sigma & = A Sigma $

]
#lemma("Rank Invariance")[
Under the conditions of #ref(<lem-idempotent-sigma>, supplement: [Lemma]), if $A Sigma$ is idempotent, then: $ upright("rank") (A Sigma) = upright("rank") (Sigma^(1 \/ 2) A Sigma^(1 \/ 2)) = upright("tr") (A Sigma) $

] <lem-rank-sigma>
#block[
#emph[Proof];. Since $A Sigma$ and $Sigma^(1 \/ 2) A Sigma^(1 \/ 2)$ are both idempotent (by #ref(<lem-idempotent-sigma>, supplement: [Lemma])), their ranks are equal to their traces.

Using the cyclic property of the trace operator ($upright("tr") (X Y Z) = upright("tr") (Z X Y)$): $ upright("rank") (A Sigma) & = upright("tr") (A Sigma)\
 & = upright("tr") (A Sigma^(1 \/ 2) Sigma^(1 \/ 2))\
 & = upright("tr") (Sigma^(1 \/ 2) A Sigma^(1 \/ 2))\
 & = upright("rank") (Sigma^(1 \/ 2) A Sigma^(1 \/ 2)) $ Alternatively, notice that $A Sigma$ is similar to $Sigma^(1 \/ 2) A Sigma^(1 \/ 2)$: $ A Sigma = Sigma^(- 1 \/ 2) (Sigma^(1 \/ 2) A Sigma^(1 \/ 2)) Sigma^(1 \/ 2) $ Since similar matrices have the same rank, the equality holds.

]
#theorem("Distribution of y'Ay")[
Let $y tilde.op N_p (mu \, Sigma)$. Let $A$ be a symmetric matrix of rank $r$. Then $y' A y tilde.op chi^2 (r \, lambda)$ with $lambda = mu' A mu$ #strong[if and only if] $A Sigma$ is idempotent ($A Sigma A Sigma = A Sigma$).

#strong[Special Case ($Sigma = I$):] If $Sigma = I$, the condition simplifies to $A$ being idempotent ($A^2 = A$).

] <thm-dist-quad>
#block[
#emph[Proof];. Let $y^(\*) = Sigma^(- 1 \/ 2) y$, so $y^(\*) tilde.op N_n (Sigma^(- 1 \/ 2) mu \, I_n)$. We rewrite the quadratic form: $ y' A y = y' Sigma^(- 1 \/ 2) (Sigma^(1 \/ 2) A Sigma^(1 \/ 2)) Sigma^(- 1 \/ 2) y = (y^(\*))' P_V y^(\*) = parallel P_V y^(\*) parallel^2 $ Since $A Sigma$ is idempotent, $P_V = Sigma^(1 \/ 2) A Sigma^(1 \/ 2)$ is a projection matrix with rank $r$. By the definition of the non-central chi-square, $y' A y tilde.op chi^2 (r \, parallel P_V Sigma^(- 1 \/ 2) mu parallel^2)$. The non-centrality parameter simplifies to $lambda = mu' A mu$.

]
=== Standardized Distance Distribution
<standardized-distance-distribution>
#corollary("Standardized Distance Distribution")[
Suppose $y tilde.op N_n (mu \, Sigma)$. Then the quadratic form representing the standardized distance from a constant vector $mu_0$ follows a non-central chi-square distribution: $ (y - mu_0)' Sigma^(- 1) (y - mu_0) tilde.op chi^2 (n \, lambda = (mu - mu_0) ' Sigma^(- 1) (mu - mu_0)) $

] <cor-standardized-mvn>
#block[
#emph[Proof];. Let $A = Sigma^(- 1)$. Then $A Sigma = Sigma^(- 1) Sigma = I_n$, which is clearly idempotent. Alternatively, let $w = Sigma^(- 1 \/ 2) (y - mu_0)$, then $w tilde.op N_n (Sigma^(- 1 \/ 2) (mu - mu_0) \, I_n)$. By the definition of chi-square, $parallel w parallel^2 = (y - mu_0)' Sigma^(- 1) (y - mu_0)$ follows the stated distribution.

]
#block[
#callout(
body: 
[
This is an important theorem we will use later.

]
, 
title: 
[
Crucial Theorem
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
== Distributions of Projections of Spherical Normal
<distributions-of-projections-of-spherical-normal>
#theorem("Distribution of Projections")[
Let $V$ be a $k$-dimensional subspace of $cal(R)^n$ with projection matrix $P_V$, and let $y$ be a random vector in $cal(R)^n$ with mean $E (y) = mu$. Then:

+ $E (P_V y) = P_V mu$.
+ If $upright("Var") (y) = sigma^2 I_n$, then $upright("Var") (P_V y) = sigma^2 P_V$ and $E (parallel P_V y parallel^2) = sigma^2 k + parallel P_V mu parallel^2$.
+ If $y tilde.op N_n (mu \, sigma^2 I_n)$, then $1 / sigma^2 parallel P_V y parallel^2 = 1 / sigma^2 y' P_V y tilde.op chi^2 (k \, 1 / sigma^2 parallel P_V mu parallel^2)$.

] <thm-proj-dist>
#block[
#emph[Proof];. 

+ Since the projection operation is linear, $E (P_V y) = P_V E (y) = P_V mu$.
+ $upright("Var") (P_V y) = P_V upright("Var") (y) P_V^T = P_V sigma^2 I_n P_V = sigma^2 P_V$. The expectation of the squared norm follows from the mean of a quadratic form: $E (y ' P_V y) = upright("tr") (P_V sigma^2 I) + mu' P_V mu = sigma^2 k + parallel P_V mu parallel^2$.
+ This is a special case of the general quadratic distribution theorem where $A = 1 / sigma^2 P_V$ and $A (sigma^2 I) = P_V$, which is idempotent.

]
#theorem("Orthogonal Projections")[
Let $V_1 \, dots.h \, V_k$ be mutually orthogonal subspaces with dimensions d\_i and projection matrices $P_i$. If $y tilde.op N_n (mu \, sigma^2 I_n)$, then:

+ The projections $hat(y)_i = P_i y$ are independent with $hat(y)_i tilde.op N (P_i mu \, sigma^2 P_i)$.
+ The squared norms $parallel hat(y)_i parallel^2$ are mutually independent.
+ $1 / sigma^2 parallel hat(y)_i parallel^2 tilde.op chi^2 (d_i \, 1 / sigma^2 parallel P_i mu parallel^2)$.

] <thm-ortho-indep>
#block[
#emph[Proof];. 

+ For $i eq.not j$, $upright("Cov") (P_i y \, P_j y) = sigma^2 P_i P_j = 0$ because orthogonal projection matrices satisfy $P_i P_j = 0$. Under normality, zero covariance implies independence.
+ Since $hat(y)_i$ are independent, any measurable functions of them, such as their squared norms, are also independent.
+ This follows directly from applying the projection distribution theorem to each independent subspace.

]
=== Independence of Forms
<independence-of-forms>
#theorem("Independence Conditions")[
Suppose $y tilde.op N_n (mu \, Sigma)$.

- #strong[Linear and Quadratic:] $B y$ and $y' A y$ (where $A$ is symmetric) are independent if and only if $B Sigma A = 0$.
- #strong[Quadratic and Quadratic:] $y' A y$ and $y' B y$ (where $A \, B$ are symmetric) are independent if and only if $A Sigma B = 0$.

] <thm-indep-mvn>
#block[
#emph[Proof];. If $B Sigma A = 0$, the normal vectors $B y$ and $A y$ have zero covariance and are independent. Because $B y$ is independent of $A y$, it is also independent of any measurable function of $A y$, specifically $y' A y = parallel A y parallel^2$ (if $A$ is idempotent).

]
=== Cochran's Theorem
<cochrans-theorem>
#theorem("Cochran's Result")[
Let $y tilde.op N_n (mu \, sigma^2 I)$ and $y' y = sum y' A_i y$. The quadratic forms $y^T A_i y \/ sigma^2$ are mutually independent $chi^2 (r_i \, lambda_i)$ if and only if any one of the following holds:

- Each $A_i$ is idempotent.
- $A_i A_j = 0$ for all $i eq.not j$.
- $n = sum r_i$.

] <thm-cochran-result>
== Non-central Distributions Derived from Non-central $chi^2$
<non-central-distributions-derived-from-non-central-chi2>
We begin by defining two independent Chi-squared random variables that form the building blocks for statistical power analysis.

- #strong[Non-central Component ($X_1$):] $X_1 tilde.op chi^2 (upright("df")_1 \, lambda)$. Here, $lambda$ is the non-centrality parameter, defined as the sum of squared means, $lambda = lr(||) mu lr(||)^2$. This is consistent with the definition used throughout this chapter. #emph[(Note: This definition is also used by R's `ncp` argument.)]

- #strong[Central Component ($X_2$):] $X_2 tilde.op chi^2 (upright("df")_2)$. $X_2$ often represents the #strong[Noise Sum of Squares];, SSE$""_1$ of an adequate model, which is assume to follow a central $chi^2$,

We visualize these components as using the follow diagram.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-variance-partition-1.png"))
], caption: figure.caption(
position: bottom, 
[
A diagram of two independent $chi^2$ random variables
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-variance-partition>


=== The Non-central F-distribution $F (upright("df")_1 \, upright("df")_2 \, lambda)$
<the-non-central-f-distribution-ftextdf_1-textdf_2-lambda>
#definition("Non-central F")[
Let $X_1 tilde.op chi^2 (upright("df")_1 \, lambda)$ and $X_2 tilde.op chi^2 (upright("df")_2)$ be independent. The random variable $F$ follows a #strong[non-central F-distribution];: $ F = frac(X_1 \/ upright("df")_1, X_2 \/ upright("df")_2) tilde.op F (upright("df")_1 \, upright("df")_2 \, lambda) $

] <def-noncentral-f>
- #strong[Expectation:]
  - #strong[Under $H_0$ ($lambda = 0$):] Exact mean is $frac(upright("df")_2, upright("df")_2 - 2)$ (for $upright("df")_2 > 2$).
  - #strong[Under $H_1$ ($lambda eq.not 0$):] Approximate mean is $1 + lambda / upright("df")_1$.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-nc-f-1.png"))
], caption: figure.caption(
position: bottom, 
[
Densities of Non-Central F ($lambda$ defined as sum of squares).
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-nc-f>


=== Type I Non-central Beta $upright("Beta")_1 (upright("df")_1 \/ 2 \, upright("df")_2 \/ 2 \, lambda)$
<type-i-non-central-beta-textbeta_1textdf_12-textdf_22-lambda>
#definition("Type I Non-central Beta")[
The random variable $B_I$ follows a #strong[Type I non-central Beta distribution];, defined as the signal's proportion of the total sum ($R^2$): $ B_I = frac(X_1, X_1 + X_2) tilde.op upright("Beta")_1 (upright("df")_1 / 2 \, upright("df")_2 / 2 \, lambda) $

] <def-noncentral-beta1>
- #strong[Relationship to F:] $B_I = frac((upright("df")_1 \/ upright("df")_2) F, 1 + (upright("df")_1 \/ upright("df")_2) F)$
- #strong[Expectation:]
  - #strong[Under $H_0$ ($lambda = 0$):] Exact mean is $frac(upright("df")_1, upright("df")_1 + upright("df")_2)$.
  - #strong[Under $H_1$ ($lambda eq.not 0$):] Approximate mean is $frac(upright("df")_1 + lambda, upright("df")_1 + upright("df")_2 + lambda)$.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-nc-beta1-1.png"))
], caption: figure.caption(
position: bottom, 
[
Densities of Type I Beta ($R^2$).
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-nc-beta1>


=== Type II Non-central Beta $upright("Beta")_2 (upright("df")_2 \/ 2 \, upright("df")_1 \/ 2 \, lambda)$
<type-ii-non-central-beta-textbeta_2textdf_22-textdf_12-lambda>
#definition("Type II Non-central Beta")[
$ B_(I I) = frac(X_2, X_1 + X_2) = 1 - B_I tilde.op upright("Beta")_2 (upright("df")_2 / 2 \, upright("df")_1 / 2 \, lambda) $

] <def-noncentral-beta2>
- #strong[Relationship to F:] $B_(I I) = frac(1, 1 + (upright("df")_1 \/ upright("df")_2) F)$
- #strong[Expectation:]
  - #strong[Under $H_0$ ($lambda = 0$):] Exact mean is $frac(upright("df")_2, upright("df")_1 + upright("df")_2)$.
  - #strong[Under $H_1$ ($lambda eq.not 0$):] Approximate mean is $frac(upright("df")_2, upright("df")_1 + upright("df")_2 + lambda)$.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-beta-ii-1.png"))
], caption: figure.caption(
position: bottom, 
[
Densities of Type II Beta ($S S E \/ S S T$). Support is \[0, 1\].
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-beta-ii>


=== Scaled Type II Beta $upright("Scaled-Beta")_2 (upright("df")_2 \/ 2 \, upright("df")_1 \/ 2 \, lambda)$
<scaled-type-ii-beta-textscaled-beta_2textdf_22-textdf_12-lambda>
#definition("Scaled Type II Beta")[
$ S = frac(X_2 \/ upright("df")_2, (X_1 + X_2) \/ (upright("df")_1 + upright("df")_2)) tilde.op upright("Scaled-Beta")_2 $

] <def-scaled-beta>
- #strong[Relationship to F:] $S = frac(upright("df")_1 + upright("df")_2, upright("df")_2 + upright("df")_1 F)$
- #strong[Expectation:]
  - #strong[Under $H_0$ ($lambda = 0$):] Exact mean is $1$.
  - #strong[Under $H_1$ ($lambda eq.not 0$):] Approximate mean is $frac(upright("df")_1 + upright("df")_2, upright("df")_1 + upright("df")_2 + lambda)$.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-scaled-beta-1.png"))
], caption: figure.caption(
position: bottom, 
[
Densities of Scaled Type II Beta ($M S E \/ M S T$).
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-scaled-beta>


=== The Non-central t-distribution $t (upright("df")_2 \, delta)$
<the-non-central-t-distribution-ttextdf_2-delta>
#definition("Non-central t")[
Let $Z tilde.op N (delta \, 1)$ and $X_2 tilde.op chi^2 (upright("df")_2)$ be independent. The random variable $T$ follows a #strong[non-central t-distribution];: $ T = Z / sqrt(X_2 \/ upright("df")_2) tilde.op t (upright("df")_2 \, delta) $

] <def-noncentral-t>
- #strong[Relationship to F:] $F = T^2$ (when $upright("df")_1 = 1$). Note $delta^2 = lambda$.
- #strong[Expectation:]
  - #strong[Under $H_0$ ($delta = 0$):] Exact mean is $0$.
  - #strong[Under $H_1$ ($delta eq.not 0$):] Approximate mean is $delta$.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-nc-t-1.png"))
], caption: figure.caption(
position: bottom, 
[
Densities of Non-Central t ($d f = 20$).
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-nc-t>


== Example: Inference of the Mean of Normal Sample
<example-inference-of-the-mean-of-normal-sample>
Consider a random sample $y tilde.op N_n (mu j_n \, sigma^2 I_n)$. We wish to test:

- #strong[$M_1$ (Full Model):] $mu$ is unknown.
- #strong[$M_0$ (Reduced Model):] $mu = mu_0$.

Let's define the transformed vector $y^(\*) = y - mu_0 j_n$. Note that $y^(\*) tilde.op N_n ((mu - mu_0) j_n \, sigma^2 I_n)$.

=== Sum of Squares and Their Distributions
<sum-of-squares-and-their-distributions>
We use the projection matrix $P_(j_n) = 1 / n j_n j_n'$ and its complement $(I_n - P_(j_n))$ to partition the transformed vector.

- #strong[Total SSE ($S S E_0$ for $M_0$):] $ S S E_0 = parallel I_n y^(\*) parallel^2 = sum_(i = 1)^n (Y_i - mu_0)^2 $ This follows a non-central distribution with $upright("df")_(upright("total")) = n$: $ frac(S S E_0, sigma^2) tilde.op chi^2 (n \, lambda) quad upright("where ") lambda = frac(n (mu - mu_0)^2, sigma^2) $

- #strong[Residual SSE ($S S E_1$ for $M_1$):] $ S S E_1 = parallel (I_n - P_(j_n)) y^(\*) parallel^2 = sum_(i = 1)^n (Y_i - macron(Y))^2 $ This captures the random noise (central component) with $upright("df")_2 = n - 1$: $ frac(S S E_1, sigma^2) tilde.op chi^2 (n - 1) $

- #strong[Difference SS ($S S_(upright("diff"))$):] $ S S_(upright("diff")) = parallel P_(j_n) y^(\*) parallel^2 = n (macron(Y) - mu_0)^2 $ This captures the signal (non-central component) with $upright("df")_1 = 1$: $ frac(S S_(upright("diff")), sigma^2) tilde.op chi^2 (1 \, lambda) $

=== Distributions of Equivalent Statistics
<distributions-of-equivalent-statistics>
We can construct five equivalent statistics to compare $M_0$ and $M_1$.

- #strong[The t-statistic ($T$):] $ T = frac(macron(Y) - mu_0, S \/ sqrt(n)) $

- #strong[The F-statistic ($F$):] $ F = frac(n (macron(Y) - mu_0)^2, S^2) = T^2 $

- #strong[The Type I Beta statistic ($B_I$):] $ B_I = frac(S S_(upright("diff")), S S E_0) = frac(n (macron(Y) - mu_0)^2, sum (Y_i - mu_0)^2) $

- #strong[The Type II Beta statistic ($B_(I I)$):] $ B_(I I) = frac(S S E_1, S S E_0) = frac(sum (Y_i - macron(Y))^2, sum (Y_i - mu_0)^2) = 1 - B_I $

- #strong[The Scaled Type II Beta statistic ($S_(upright("scaled"))$):] $ S_(upright("scaled")) = frac(S S E_1 \/ (n - 1), S S E_0 \/ n) = (frac(n, n - 1)) B_(I I) $

=== Expectations Under $M_1$ and $M_0$
<expectations-under-m_1-and-m_0>
The table below contrasts the distributions and expected values of these statistics. We assume the sample size $n$ is large enough for the mean of $F$ to exist ($n > 3$).

- #strong[Degrees of Freedom:] $upright("df")_1 = 1$, $upright("df")_2 = n - 1$.
- #strong[Non-centrality:] $delta = frac(sqrt(n) (mu - mu_0), sigma)$ and $lambda = delta^2 = frac(n (mu - mu_0)^2, sigma^2)$.

#figure([
#table(
  columns: (25%, 25%, 25%, 25%),
  align: (left,left,left,left,),
  table.header([Statistic], [Distribution under $H_1$ ($mu eq.not mu_0$)], [Exact Mean under $H_0$ ($mu = mu_0$)], [Approximate Mean under $H_1$],),
  table.hline(),
  [#strong[$T$];], [$t (n - 1 \, delta)$], [$0$], [$frac(sqrt(n) (mu - mu_0), sigma)$],
  [#strong[$F$];], [$F (1 \, n - 1 \, lambda)$], [$frac(n - 1, n - 3) approx 1$], [$1 + frac(n (mu - mu_0)^2, sigma^2)$],
  [#strong[$B_I$];], [$upright("Beta")_1 (1 / 2 \, frac(n - 1, 2) \, lambda)$], [$1 / n$], [$frac(1 \/ n + (mu - mu_0)^2 / sigma^2, 1 + (mu - mu_0)^2 / sigma^2)$],
  [#strong[$B_(I I)$];], [$upright("Beta")_2 (frac(n - 1, 2) \, 1 / 2 \, lambda)$], [$frac(n - 1, n)$], [$frac((n - 1) \/ n, 1 + (mu - mu_0)^2 / sigma^2)$],
  [#strong[$S_(upright("scaled"))$];], [$upright("Scaled-Beta")_2 (frac(n - 1, 2) \, 1 / 2 \, lambda)$], [$1$], [$frac(1, 1 + (mu - mu_0)^2 / sigma^2)$],
)
], caption: figure.caption(
position: top, 
[
Expected Values of Test Statistics Under Null and Alternative Hypotheses
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-expected-values>


#strong[Key Interpretation:] All statistics are functionally driven by the signal energy. Notably, for #strong[$S_(upright("scaled"))$];, the sample size $n$ cancels out in the approximate mean. This makes it a direct measure of the ratio between Noise Variance and Total Variance (Noise + Signal) in the population distributions, connected to the Rao-Blackwell decomposition of variances.

#pagebreak()

#horizontalrule

= Inference for A Multiple Linear Regression Model
<inference-for-a-multiple-linear-regression-model>
== Linear Models and Least Square Estimator
<linear-models-and-least-square-estimator>
=== Assumptions in Linear Models
<assumptions-in-linear-models>
Suppose that on a random sample of $n$ units (patients, animals, trees, etc.) we observe a response variable $Y$ and explanatory variables $X_1 \, . . . \, X_k$. Our data are then $(y_i \, x_(i 1) \, . . . \, x_(i k))$, $i = 1 \, . . . \, n$, or in vector/matrix form $y \, x_1 \, . . . \, x_k$ where $y = (y_1 \, . . . \, y_n)$ and $x_j = (x_(1 j) \, . . . \, x_(n j))^T$ or $y \, X$ where $X = (x_1 \, . . . \, x_k)$.

Either by design or by conditioning on their observed values, $x_1 \, . . . \, x_k$ are regarded as vectors of known constants. The linear model in its classical form makes the following assumptions:

#strong[Assumptions on Linear Models]

- #strong[A1. (Additive Error)] $y = mu + e$ where $e = (e_1 \, . . . \, e_n)^T$ is an unobserved random vector with $E (e) = 0$. This implies that $mu = E (y)$ is the unknown mean of $y$.

- #strong[A2. (Linearity)] $mu = beta_1 x_1 + dot.op dot.op dot.op + beta_k x_k = X beta$ where $beta_1 \, . . . \, beta_k$ are unknown parameters. This assumption says that $E (y) = mu in upright("Col") (X)$ (lies in the column space of $X$); i.e., it is a linear combination of explanatory vectors $x_1 \, . . . \, x_k$ with coefficients the unknown parameters in $beta = (beta_1 \, . . . \, beta_k)^T$. Note that it is linear in $beta_1 \, . . . \, beta_k$, not necessarily in the $x$'s.

- #strong[A3. (Independence)] $e_1 \, . . . \, e_n$ are independent random variables (and therefore so are $y_1 \, . . . \, y_n \)$.

- #strong[A4. (Homoscedasticity)] $e_1 \, . . . \, e_n$ all have the same variance $sigma^2$; that is, $upright("Var") (e_1) = dot.op dot.op dot.op = upright("Var") (e_n) = sigma^2$ which implies $upright("Var") (y_1) = dot.op dot.op dot.op = upright("Var") (y_n) = sigma^2$.

- #strong[A5. (Normality)] $e tilde.op N_n (0 \, sigma^2 I_n)$.

=== Matrix Formulation
<matrix-formulation>
The model can be written algebraically as: $ y_i = beta_0 + beta_1 x_(i 1) + beta_2 x_(i 2) + dot.op dot.op dot.op + beta_k x_(i k) \, quad i = 1 \, . . . \, n $

Or in matrix notation: $ vec(y_1, y_2, dots.v, y_n) = mat(delim: "(", 1, x_11, x_12, dot.op dot.op dot.op, x_(1 k); 1, x_21, x_22, dot.op dot.op dot.op, x_(2 k); dots.v, dots.v, dots.v, dots.v, dots.v; 1, x_(n 1), x_(n 2), dot.op dot.op dot.op, x_(n k)) vec(beta_0, beta_1, dots.v, beta_k) + vec(e_1, e_2, dots.v, e_n) $

This is expressed compactly as: $ y = X beta + e $ where $X$ is the design matrix, and $e tilde.op N_n (0 \, sigma^2 I)$. Alternatively: $ y = beta_0 j_n + beta_1 x_1 + dot.op dot.op dot.op + beta_k x_k + e $

Taken together, all five assumptions can be stated more succinctly as: $ y tilde.op N_n (X beta \, sigma^2 I) $ with the mean vector $mu_y = X beta in upright("Col") (X)$.

#block[
#callout(
body: 
[
The effect of a parameter and the magnitude of the error variance depend upon what other explanatory variables are present in the model. For example, the coefficients $beta_0 \, beta_1$ and error standard deviation $sigma$ in the model: $ y = beta_0 j_n + beta_1 x_1 + beta_2 x_2 + e \, quad upright("Var") (e) = sigma^2 I $ will typically be different than $beta_0^(\*) \, beta_1^(\*)$ and $sigma^(\*)$ in the model: $ y = beta_0^(\*) j_n + beta_1^(\*) x_1 + e^(\*) \, quad upright("Var") (e^(\*)) = (sigma^(\*))^2 I $ In this context, $beta_0^(\*)$ and $beta_1^(\*)$ are the population-projected coefficients of the full model. Furthermore, $sigma^(\*)$ will typically be larger than $sigma$, as the error term $e^(\*)$ absorbs the variation previously explained by $x_2$.

]
, 
title: 
[
Coefficients and Variance of Reduced Models
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
#block[
#callout(
body: 
[
We will first consider the case that $upright("rank") (X) = k + 1$.

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
=== Least Squares Estimator of $beta$ and Fitted Value $hat(Y)$
<least-squares-estimator-of-beta-and-fitted-value-hat-y>
#definition("Least Squares Estimator")[
The #strong[Least Squares Estimator (LSE)] of $beta$, denoted as $hat(beta)$, is the vector that minimizes the Sum of Squared Errors (SSE), which measures the discrepancy between the observed responses $y$ and the fitted values $X hat(beta)$. $ Q (beta) = sum_(i = 1)^n (y_i - x_i^T beta)^2 = (y - X beta)' (y - X beta) $

] <def-least-squares>
#theorem("Least Squares Estimator")[
Consider the linear model $y = X beta + e$, where $X$ is of full column rank. The Ordinary Least Squares (OLS) estimator $hat(beta)$ is given by the closed-form solution:

$ hat(beta) = (X ' X)^(- 1) X' y $

Consequently, the vector of fitted values $hat(y)$ is the orthogonal projection of $y$ onto $upright("Col") (X)$:

$ hat(y) = X hat(beta) = H y $

where $H = X (X ' X)^(- 1) X'$ is the orthogonal projection matrix (hat matrix).

] <thm-leastsquare>
#block[
#emph[Proof];. The derivation relies on the geometry of orthogonal projections.

#strong[\1. Obtaining the Fitted Values $hat(y)$]

In the linear model, the systematic component $E [y]$ is constrained to lie in the column space of $X$, denoted as $upright("Col") (X)$. We seek the vector in $upright("Col") (X)$ that is "closest" to the observed data $y$. This vector is the #strong[orthogonal projection] of $y$ onto $upright("Col") (X)$, denoted as $hat(y)$. Using the projection matrix $H = X (X ' X)^(- 1) X'$, we have:

$ hat(y) = H y = X (X ' X)^(- 1) X' y $

#strong[\2. Obtaining $hat(beta)$ by Solving $X beta = hat(y)$]

Since $hat(y)$ is a projection onto $upright("Col") (X)$, the system $X hat(beta) = hat(y)$ is consistent. To isolate $hat(beta)$, we pre-multiply both sides by $(X ' X)^(- 1) X'$:

$ (X ' X)^(- 1) X' (X hat(beta)) & = (X ' X)^(- 1) X' hat(y)\
underbrace((X ' X)^(- 1) (X ' X), I) hat(beta) & = (X ' X)^(- 1) X' hat(y)\
hat(beta) & = (X ' X)^(- 1) X' hat(y) $

Finally, we express the estimator in terms of the observed $y$. Because $hat(y)$ is an orthogonal projection, the residual $y - hat(y)$ is orthogonal to the columns of $X$, implying $X' hat(y) = X' y$. Substituting this into the equation above yields the result:

$ hat(beta) = (X ' X)^(- 1) X' y $

]
=== Properties of the Estimator $hat(beta)$
<properties-of-the-estimator-hat-beta>
#theorem("Unbiasedness of $hat(beta)$")[
If $E (y) = X beta$, then $hat(beta)$ is an unbiased estimator for $beta$.

] <thm-unbiased>
#block[
#emph[Proof];. $ E (hat(beta)) & = E [(X^(') X)^(- 1) X^(') y]\
 & = (X^(') X)^(- 1) X^(') E (y) quad upright("[using linearity of expectation]")\
 & = (X^(') X)^(- 1) X^(') X beta\
 & = beta $

]
#theorem("Variance of $hat(beta)$")[
If $upright("Var") (y) = sigma^2 I$, the covariance matrix for $hat(beta)$ is given by $sigma^2 (X^(') X)^(- 1)$.

] <thm-covariance>
#block[
#emph[Proof];. $ upright("Var") (hat(beta)) & = upright("Var") [(X^(') X)^(- 1) X^(') y]\
 & = (X^(') X)^(- 1) X^(') upright("Var") (y) [(X^(') X)^(- 1) X^(')]^(') quad upright("[using ") upright("Var") (A y) = A upright("Var") (y) A' \]\
 & = (X^(') X)^(- 1) X^(') (sigma^2 I) X (X^(') X)^(- 1)\
 & = sigma^2 (X^(') X)^(- 1) X^(') X (X^(') X)^(- 1)\
 & = sigma^2 (X^(') X)^(- 1) $

]
#strong[Note:] These theorems require no assumption of normality.

== Best Linear Unbiased Estimator (BLUE)
<best-linear-unbiased-estimator-blue>
#theorem("Gauss-Markov Theorem")[
If $E (y) = X beta$ and $upright("Var") (y) = sigma^2 I$, the least-squares estimators $hat(beta)_j \, j = 0 \, 1 \, . . . \, k$ have minimum variance among all linear unbiased estimators.

] <thm-gauss-markov>
#block[
#emph[Proof];. We consider a linear estimator $A y$ of $beta$ and seek the matrix $A$ for which $A y$ is a minimum variance unbiased estimator.

#strong[\1. Unbiasedness Condition:] In order for $A y$ to be an unbiased estimator of $beta$, we must have $E (A y) = beta$. Using the assumption $E (y) = X beta$, this is expressed as: $ E (A y) = A E (y) = A X beta = beta $ which implies the condition $A X = I_(k + 1)$ since the relationship must hold for any $beta$.

#strong[\2. Minimizing Variance:] The covariance matrix for the estimator $A y$ is: $ upright("Var") (A y) = A upright("Var") (y) A' = A (sigma^2 I) A' = sigma^2 A A' $ We need to choose $A$ (subject to $A X = I$) so that the diagonal elements of $A A'$ are minimized.

To relate $A y$ to $hat(beta) = (X ' X)^(- 1) X' y$, we define $hat(A) = (X ' X)^(- 1) X'$ and write $A = (A - hat(A)) + hat(A)$. Then: $ A A' = [(A - hat(A)) + hat(A)] [(A - hat(A)) + hat(A)]' $ Expanding this, the cross terms vanish because $(A - hat(A)) hat(A)' = A hat(A)' - hat(A) hat(A)'$. Note that $hat(A) hat(A)' = (X ' X)^(- 1) X' X (X ' X)^(- 1) = (X ' X)^(- 1)$. Also, $A hat(A)' = A X (X ' X)^(- 1) = I (X ' X)^(- 1) = (X ' X)^(- 1)$ (since $A X = I$). Thus, $(A - hat(A)) hat(A)' = 0$.

The expansion simplifies to: $ A A' = (A - hat(A)) (A - hat(A))' + hat(A) hat(A)' $ The matrix $(A - hat(A)) (A - hat(A))'$ is positive semidefinite, meaning its diagonal elements are non-negative. To minimize the diagonal of $A A'$, we must set $A - hat(A) = 0$, which implies $A = hat(A)$.

Thus, the minimum variance estimator is: $ A y = (X ' X)^(- 1) X' y = hat(beta) $

]
=== Notes on Gauss-markov
<notes-on-gauss-markov>
+ #strong[Distributional Generality:] The remarkable feature of the Gauss-Markov theorem is that it holds for #emph[any] distribution of $y$; normality is not required. The only assumptions used are linearity ($E (y) = X beta$) and homoscedasticity ($upright("Var") (y) = sigma^2 I$).

+ #strong[Extension to All Linear Combinations:] The theorem extends beyond just the parameter vector $beta$ to any linear combination of the parameters.

+ #strong[Scaling Invariance:] The predictions made by the model are invariant to the scaling of the explanatory variables.

#corollary("BLUE for All Linear Combinations")[
If $E (y) = X beta$ and $upright("Var") (y) = sigma^2 I$, the best linear unbiased estimator of the scalar $a' beta$ is $a' hat(beta)$, where $hat(beta)$ is the least-squares estimator.

] <cor-linear-combo>
#block[
#emph[Proof];. Let $tilde(beta) = A y$ be any other linear unbiased estimator of $beta$. The variance of the linear combination $a' tilde(beta)$ is: $ 1 / sigma^2 upright("Var") (a ' tilde(beta)) = 1 / sigma^2 upright("Var") (a ' A y) = a' A A' a $ From the proof of the Gauss-Markov theorem, we established that $A A' = (A - hat(A)) (A - hat(A))' + (X ' X)^(- 1)$ where $hat(A) = (X ' X)^(- 1) X'$. Substituting this into the variance equation: $ a' A A' a = a' (A - hat(A)) (A - hat(A))' a + a' (X ' X)^(- 1) a $ The term $a' (A - hat(A)) (A - hat(A))' a$ is a quadratic form with a positive semidefinite matrix, so it is always non-negative. Therefore: $ a' A A' a gt.eq a' (X ' X)^(- 1) a = 1 / sigma^2 upright("Var") (a ' hat(beta)) $ The variance is minimized when $A = hat(A)$ (specifically when the first term is zero), proving that $a' hat(beta)$ has the minimum variance among all linear unbiased estimators.

]
#theorem("Scaling Explanatory Variables")[
If $x = (1 \, x_1 \, . . . \, x_k)'$ and $z = (1 \, c_1 x_1 \, . . . \, c_k x_k)'$, then the fitted values are identical: $hat(y) = hat(beta)' x = hat(beta)_z' z$.

] <thm-scaling>
#block[
#emph[Proof];. Let $D = upright("diag") (1 \, c_1 \, . . . \, c_k)$ such that the design matrix is transformed to $Z = X D$. The LSE for the transformed data is: $ hat(beta)_z & = (Z ' Z)^(- 1) Z' y = [(X D) ' (X D)]^(- 1) (X D)' y\
 & = D^(- 1) (X ' X)^(- 1) (D ')^(- 1) D' X' y\
 & = D^(- 1) (X ' X)^(- 1) X' y = D^(- 1) hat(beta) $ . Then, the prediction is: $ hat(beta)_z' z = (D^(- 1) hat(beta))' (D x) = hat(beta)' (D^(- 1))' D x = hat(beta)' x $ .

]
=== Limitations: Restriction to Unbiased Estimators
<limitations-restriction-to-unbiased-estimators>
It is crucial to recognize that the Gauss-Markov theorem only guarantees optimality within the class of #strong[linear] and #strong[unbiased] estimators.

- #strong[Assumption Sensitivity:] If the assumptions of linearity ($E (y) = X beta$) and homoscedasticity ($upright("Var") (y) = sigma^2 I$) do not hold, $hat(beta)$ may be biased or may have a larger variance than other estimators.
- #strong[Unbiasedness Constraint:] The theorem does not compare $hat(beta)$ to biased estimators. It is possible for a biased estimator (e.g., shrinkage estimators) to have a smaller Mean Squared Error (MSE) than the BLUE by accepting some bias to significantly reduce variance. The LSE is only "best" (minimum variance) among those estimators that satisfy the unbiasedness constraint.

== Estimator of Error Variance
<estimator-of-error-variance>
We estimate $sigma^2$ by the residual mean square:

#definition("Residual Variance Estimator")[
$ s^2 = frac(1, n - k - 1) sum_(i = 1)^n (y_i - x_i ' hat(beta))^2 = frac(upright("SSE"), n - k - 1) $ where $upright("SSE") = (y - X hat(beta))' (y - X hat(beta))$.

] <def-s2>
Alternatively, SSE can be written as: $ upright("SSE") = y' y - hat(beta)' X' y $ This is often useful for computation ($y' y$ is the total sum of squares of the raw data).

=== Unbiasedness of $s^2$
<unbiasedness-of-s2>
#theorem("Unbiasedness of s-squared")[
If $s^2$ is defined as above, and if $E (y) = X beta$ and $upright("Var") (y) = sigma^2 I$, then $E (s^2) = sigma^2$.

] <thm-unbiased-s2>
#block[
#emph[Proof];. We use the Hat Matrix $H = X (X ' X)^(- 1) X'$, which projects $y$ onto $upright("Col") (X)$. Thus, $hat(y) = H y$. The residuals are $y - hat(y) = (I - H) y$. The Sum of Squared Errors is: $ upright("SSE") = parallel (I - H) y parallel^2 = y' (I - H)' (I - H) y $ Since $H$ is symmetric and idempotent, $(I - H)$ is also symmetric and idempotent. Thus: $ upright("SSE") = y' (I - H) y $

To find the expectation, we use the trace trick for quadratic forms: $E [y ' A y] = upright("tr") (A upright("Var") (y)) + E [y]' A E [y]$. $ E (upright("SSE")) & = E [y ' (I - H) y]\
 & = upright("tr") ((I - H) sigma^2 I) + (X beta)' (I - H) (X beta)\
 & = sigma^2 upright("tr") (I - H) + beta' X' (I - H) X beta $ #strong[Trace Term:] $upright("tr") (I_n - H) = upright("tr") (I_n) - upright("tr") (H) = n - (k + 1)$, since $upright("tr") (H) = upright("tr") (X (X ' X)^(- 1) X ') = upright("tr") ((X ' X)^(- 1) X ' X) = upright("tr") (I_(k + 1)) = k + 1$.

#strong[Non-centrality Term:] Since $H X = X$, we have $(I - H) X = 0$. Therefore, the second term vanishes: $beta' X' (I - H) X beta = 0$.

Combining these: $ E (upright("SSE")) = sigma^2 (n - k - 1) $ Dividing by the degrees of freedom $(n - k - 1)$, we get $E (s^2) = sigma^2$.

]
== Distributions Under Normality
<distributions-under-normality>
If we add Assumption A5 ($y tilde.op N_n (X beta \, sigma^2 I)$), we can derive the exact sampling distributions.

#corollary("Estimated Covariance of Beta")[
An unbiased estimator of $upright("Cov") (hat(beta))$ is given by: $ hat(upright("Cov")) (hat(beta)) = s^2 (X ' X)^(- 1) $

] <cor-cov-beta>
#theorem("Sampling Distributions")[
Under assumptions A1-A5:

+ $hat(beta) tilde.op N_(k + 1) (beta \, sigma^2 (X ' X)^(- 1))$.
+ $(n - k - 1) s^2 \/ sigma^2 tilde.op chi^2 (n - k - 1)$.
+ $hat(beta)$ and $s^2$ are independent.

] <thm-sampling-dist>
#block[
#emph[Proof];. #strong[Part (i):] Since $hat(beta) = (X ' X)^(- 1) X' y$ is a linear transformation of the normal vector $y$, it is also normally distributed. We already established its mean and variance in #ref(<thm-unbiased>, supplement: [Theorem]) and #ref(<thm-covariance>, supplement: [Theorem]).

#strong[Part (ii):] We showed $upright("SSE") = y' (I - H) y$. Since $(I - H)$ is idempotent with rank $n - k - 1$, and $(I - H) X beta = 0$, by the theory of quadratic forms in normal variables, $upright("SSE") \/ sigma^2 tilde.op chi^2 (n - k - 1)$.

#strong[Part (iii):] $hat(beta)$ depends on $H y$ (or $X' y$), while $s^2$ depends on $(I - H) y$. Since $H (I - H) = H - H^2 = 0$, the linear forms defining the estimator and the residuals are orthogonal. For normal vectors, zero covariance implies independence.

]
== Maximum Likelihood Estimator (MLE)
<maximum-likelihood-estimator-mle>
#theorem("MLE for Linear Regression")[
If $y tilde.op N_n (X beta \, sigma^2 I)$, the Maximum Likelihood Estimators are: $ hat(beta)_(upright("MLE")) = (X ' X)^(- 1) X' y $ $ hat(sigma)_(upright("MLE"))^2 = 1 / n (y - X hat(beta))' (y - X hat(beta)) = upright("SSE") / n $

] <thm-mle>
#block[
#emph[Proof];. The log-likelihood function is: $ ln L (beta \, sigma^2) = - n / 2 ln (2 pi) - n / 2 ln (sigma^2) - frac(1, 2 sigma^2) (y - X beta)' (y - X beta) $ Maximizing this with respect to $beta$ is equivalent to minimizing the quadratic term $(y - X beta)' (y - X beta)$, which yields the Least Squares Estimator. Differentiating with respect to $sigma^2$ and setting to zero yields $hat(sigma)^2 = upright("SSE") \/ n$.

]
#strong[Note:] The MLE for $sigma^2$ is biased (denominator $n$), whereas $s^2$ is unbiased (denominator $n - k - 1$).

== Linear Models in Centered Form
<linear-models-in-centered-form>
The regression model can be written in a centered form by subtracting the means of the explanatory variables: $ y_i = alpha + beta_1 (x_(i 1) - overline(x)_1) + beta_2 (x_(i 2) - overline(x)_2) + dot.op dot.op dot.op + beta_k (x_(i k) - overline(x)_k) + e_i $ for $i = 1 \, . . . \, n$, where the intercept term is adjusted: $ alpha = beta_0 + beta_1 overline(x)_1 + beta_2 overline(x)_2 + dot.op dot.op dot.op + beta_k overline(x)_k $ and $overline(x)_j = 1 / n sum_(i = 1)^n x_(i j)$.

=== Matrix Formulation
<matrix-formulation-1>
In matrix form, the equivalence between the original model and the centered model is: $ y = X beta + e = (j_n \, X_c) vec(alpha, beta_1) + e $ where $beta_1 = (beta_1 \, . . . \, beta_k)^T$ represents the slope coefficients, and $X_c$ is the centered design matrix: $ X_c = (I - P_(j_n)) X_1 $ Here, $X_1$ consists of the original columns of $X$ excluding the intercept column.

To see the structure of $X_c$, we first calculate the projection of the data onto the intercept space, $P_(j_n) X_1$: $ P_(j_n) X_1 & = 1 / n j_n j_n' X_1\
 & = mat(delim: "(", 1 \/ n, 1 \/ n, dots.h.c, 1 \/ n; 1 \/ n, 1 \/ n, dots.h.c, 1 \/ n; dots.v, dots.v, dots.down, dots.v; 1 \/ n, 1 \/ n, dots.h.c, 1 \/ n) mat(delim: "(", x_11, x_12, dots.h.c, x_(1 k); x_21, x_22, dots.h.c, x_(2 k); dots.v, dots.v, dots.down, dots.v; x_(n 1), x_(n 2), dots.h.c, x_(n k))\
 & = mat(delim: "(", macron(x)_1, macron(x)_2, dots.h.c, macron(x)_k; macron(x)_1, macron(x)_2, dots.h.c, macron(x)_k; dots.v, dots.v, dots.down, dots.v; macron(x)_1, macron(x)_2, dots.h.c, macron(x)_k) $ This results in a matrix where every row is the vector of column means. Subtracting this from $X_1$ gives $X_c$: $ X_c & = X_1 - P_(j_n) X_1\
 & = mat(delim: "(", x_11, x_12, dots.h.c, x_(1 k); x_21, x_22, dots.h.c, x_(2 k); dots.v, dots.v, dots.down, dots.v; x_(n 1), x_(n 2), dots.h.c, x_(n k)) - mat(delim: "(", macron(x)_1, macron(x)_2, dots.h.c, macron(x)_k; macron(x)_1, macron(x)_2, dots.h.c, macron(x)_k; dots.v, dots.v, dots.down, dots.v; macron(x)_1, macron(x)_2, dots.h.c, macron(x)_k)\
 & = mat(delim: "(", x_11 - macron(x)_1, x_12 - macron(x)_2, dots.h.c, x_(1 k) - macron(x)_k; x_21 - macron(x)_1, x_22 - macron(x)_2, dots.h.c, x_(2 k) - macron(x)_k; dots.v, dots.v, dots.down, dots.v; x_(n 1) - macron(x)_1, x_(n 2) - macron(x)_2, dots.h.c, x_(n k) - macron(x)_k) $

=== Estimation in Centered Form
<estimation-in-centered-form>
Because the column space of the intercept $j_n$ is orthogonal to the columns of $X_c$ (since columns of $X_c$ sum to zero), the cross-product matrix becomes block diagonal: $ vec(j_n', X_c') (j_n \, X_c) = mat(delim: "(", j_n' j_n, j_n' X_c; X_c' j_n, X_c' X_c) = mat(delim: "(", n, 0; 0, X_c' X_c) $

#theorem("Centered Estimators")[
The least squares estimators for the centered parameters are: $ vec(hat(alpha), hat(beta)_1) = mat(delim: "(", n, 0; 0, X_c' X_c)^(- 1) vec(j_n' y, X_c' y) = vec(macron(y), (X_c ' X_c)^(- 1) X_c' y) $ Thus:

+ $hat(alpha) = macron(y)$ (The sample mean of $y$).
+ $hat(beta)_1 = S_(x x)^(- 1) S_(x y)$, using the sample covariance notations.

] <thm-centered-estimators>
Recovering the original intercept: $ hat(beta)_0 = hat(alpha) - hat(beta)_1 macron(x)_1 - dots.h - hat(beta)_k macron(x)_k = macron(y) - hat(beta)_1' macron(x) $

== Decomposition of Sum of Squares
<decomposition-of-sum-of-squares>
We partition the total variation based on the orthogonal subspaces.

#definition("Sum of Squares Components")[
The total variation is decomposed as $upright("SST") = upright("SSR") + upright("SSE")$.

+ #strong[Total Sum of Squares (SST):] The squared length of the centered response vector. $ upright("SST") = parallel y - macron(y) j_n parallel^2 = parallel (I - P_(j_n)) y parallel^2 $

+ #strong[Regression Sum of Squares (SSR):] The variation explained by the regressors $X_c$. $ upright("SSR") = parallel hat(y) - macron(y) j_n parallel^2 = parallel P_(X_c) y parallel^2 = hat(beta)_1' X_c' X_c hat(beta)_1 $

+ #strong[Sum of Squared Errors (SSE):] The residual variation. $ upright("SSE") = parallel y - hat(y) parallel^2 = parallel (I - H) y parallel^2 $

] <def-ss-components>
=== 3D Visualization of Decomposition of $y$
<d-visualization-of-decomposition-of-y>
We partition the total variation in $y$ based on the orthogonal subspaces.

+ #strong[Space of the Mean:] $L (j_n)$, spanned by the intercept vector $j_n$.
+ #strong[Space of the Regressors:] $L (X_c)$, spanned by the centered predictors $X_c$.
+ #strong[Error Space:] $upright("Col") (X)^perp$, orthogonal to the model space.

The vector $y$ can be decomposed into three orthogonal components: $ y = macron(y) j_n + P_(X_c) y + (y - hat(y)) $ Visually, this corresponds to projecting the vector $y$ onto three orthogonal axes.

#strong[Interactive Visualization:]

We generate a cloud of 100 observations of $y$ from $N (mu \, sigma = 1)$ where $mu = (5 \, 5 \, 0)$. The projections onto the Model Plane ($z = 0$) are highlighted in #strong[red];, and the projections onto the error axis ($z$) are in #strong[yellow];.

==== Effect Exists (signal)
#figure([
#box(image("figs/geometry-3d-signal.png", width: 100.0%))
], caption: figure.caption(
position: bottom, 
[
Scenario 1: Significant regression effect ($beta_1 o t = 0$). The mean vector projects significantly onto the predictor space.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


==== No Effect (noise)
#figure([
#box(image("figs/geometry-3d-noise.png", width: 100.0%))
], caption: figure.caption(
position: bottom, 
[
Scenario 2: No regression effect ($beta_1 = 0$). The mean vector lies purely on the intercept axis.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


=== A Diagram to Show Decomposition of Sum of Squares
<a-diagram-to-show-decomposition-of-sum-of-squares>
The decomposition of the total variation is visualized below. The total deviation (Orange) is the vector sum of the regression deviation (Green) and the residual error (Red).

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-ss-decomposition-legend-v2-1.png"))
], caption: figure.caption(
position: bottom, 
[
Geometric Decomposition: SST = SSR + SSE
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-ss-decomposition-legend-v2>


=== Distribution of Sum of Squares
<distribution-of-sum-of-squares>
We apply the general theory of projections to the specific components defined in #ref(<def-ss-components>, supplement: [Definition]).

#theorem("Distribution of Sum of Squares")[
Let $y tilde.op N (mu \, sigma^2 I_n)$, where $mu in upright("Col") (X)$. Consider the decomposition defined by the projection matrices $P_(X_c)$ and $M = I - H$.

- #strong[Independence:] The quadratic forms $upright("SSR")$ and $upright("SSE")$ are statistically independent because the subspaces $L (X_c)$ and $upright("Col") (X)^perp$ are orthogonal.

- #strong[Distribution of SSE:] The scaled sum of squared errors follows a central Chi-squared distribution: $ upright("SSE") / sigma^2 = frac(parallel (I - H) y parallel^2, sigma^2) tilde.op chi^2 (n - k - 1) $ #strong[Mean:] $ E [upright("SSE")] = sigma^2 (n - k - 1) $

- #strong[Distribution of SSR:] The scaled regression sum of squares follows a #strong[non-central] Chi-squared distribution: $ upright("SSR") / sigma^2 = frac(parallel P_(X_c) y parallel^2, sigma^2) tilde.op chi^2 (k \, lambda) $ #strong[Mean:] $ E [upright("SSR")] = sigma^2 k + parallel P_(X_c) mu parallel^2 $

#strong[Non-centrality Parameter ($lambda$):] $ lambda = 1 / sigma^2 parallel P_(X_c) mu parallel^2 $ where $ parallel P_(X_c) mu parallel^2 = parallel X_c beta_1 parallel^2 = (X_c beta_1)' (X_c beta_1) = beta_1' X_c' X_c beta_1 $

] <thm-distribution-ss-v2>
#block[
#emph[Proof];. We apply #ref(<thm-proj-dist>, supplement: [Theorem]) to the specific projection matrices identified in the definitions.

- #strong[For SSE (Error Space):] $upright("SSE")$ is defined by the projection matrix $P_V = I - H$.

  - #strong[Dimension:] The rank of $(I - H)$ is $n - upright("rank") (X) = n - (k + 1) = n - k - 1$.
  - #strong[Non-centrality:] Since $mu in upright("Col") (X)$, the projection onto the orthogonal complement is zero: $parallel (I - H) mu parallel^2 = 0$. Thus, $lambda = 0$.
  - #strong[Expectation:] Using Part 2 of #ref(<thm-proj-dist>, supplement: [Theorem]) ($E (parallel P_V y parallel^2) = sigma^2 upright("rank") (P_V) + parallel P_V mu parallel^2$): $ E [upright("SSE")] = sigma^2 (n - k - 1) + 0 = sigma^2 (n - k - 1) $

- #strong[For SSR (Regression Space):] $upright("SSR")$ is defined by the projection matrix $P_V = P_(X_c)$.

  - #strong[Dimension:] The rank of $P_(X_c)$ is $(k + 1) - 1 = k$.

  - #strong[Non-centrality:] The projection of $mu$ onto $L (X_c)$ is $P_(X_c) mu$. $ lambda = frac(1, 2 sigma^2) parallel P_(X_c) mu parallel^2 $

  - #strong[Expectation:] Using Part 2 of #ref(<thm-proj-dist>, supplement: [Theorem]): $ E [upright("SSR")] = sigma^2 k + parallel P_(X_c) mu parallel^2 $

  This shows that while $E [upright("SSE")]$ depends only on the noise variance and sample size, $E [upright("SSR")]$ is inflated by the magnitude of the true regression signal $parallel P_(X_c) mu parallel^2$.

]
== F-test for Testing Overall Regression Effect
<f-test-for-testing-overall-regression-effect>
We wish to test whether the regression model provides any explanatory power beyond the simple intercept-only model.

#strong[Hypotheses:]

- #strong[Null Hypothesis ($H_0$):] $beta_1 = beta_2 = dots.h = beta_k = 0$ (No regression effect). This implies $mu in upright("span") (j_n)$ and the true signal variance $parallel X_c beta_1 parallel^2 = 0$.

- #strong[Alternative Hypothesis ($H_1$):] At least one $beta_j eq.not 0$.

#block[
#heading(
level: 
3
, 
numbering: 
none
, 
[
The F-statistic
]
)
]
We construct the test statistic using the ratio of the Mean Squares defined previously:

$ F = upright("MSR") / upright("MSE") = frac(upright("SSR") \/ k, upright("SSE") \/ (n - k - 1)) $

#block[
#heading(
level: 
3
, 
numbering: 
none
, 
[
Understanding $F$ via Expectations
]
)
]
The logic of the F-test is transparent when we examine the expected values of the numerator and denominator:

$ E [upright("MSE")] & = sigma^2\
E [upright("MSR")] & = sigma^2 + frac(parallel X_c beta_1 parallel^2, k) $

- #strong[If $H_0$ is true:] The signal term is zero. Both Mean Squares estimate $sigma^2$ unbiasedly. We expect $F approx 1$.
- #strong[If $H_1$ is true:] The numerator includes the positive term $frac(parallel X_c beta_1 parallel^2, k)$. We expect $F > 1$.

Therefore, we reject $H_0$ for sufficiently large values of $F$. Specifically, we reject at level $alpha$ if $F_(o b s) > F_alpha (k \, n - k - 1)$.

=== Distributional Theory
<distributional-theory>
To derive the exact sampling distribution, we rely on the independence of the sums of squares (from #ref(<thm-distribution-ss-v2>, supplement: [Theorem])) and the definition of the non-central F-distribution given in #strong[#ref(<def-noncentral-f>, supplement: [Definition])];.

#theorem("Distribution of Regression F-Statistic")[
Under the assumption of normality, the regression F-statistic follows a #strong[non-central F-distribution];:

$ F tilde.op F (k \, n - k - 1 \, lambda) $

The non-centrality parameter $lambda$ is determined by the ratio of the signal sum of squares to the error variance: $ lambda = frac(parallel X_c beta_1 parallel^2, sigma^2) $

#strong[Special Cases:]

+ #strong[Under $H_1$ (Signal exists):] $lambda > 0$, so $F$ follows the non-central distribution.
+ #strong[Under $H_0$ (No signal):] $beta_1 = 0 arrow.r.double.long lambda = 0$. The distribution collapses to the #strong[central F-distribution];: $ F tilde.op F (k \, n - k - 1) $

] <thm-regression-f-dist>
#block[
#emph[Proof];. We identify the components from #ref(<def-noncentral-f>, supplement: [Definition]):

+ #strong[Numerator ($X_1$):] Let $X_1 = upright("SSR") \/ sigma^2$. From #ref(<thm-distribution-ss-v2>, supplement: [Theorem]), $X_1 tilde.op chi^2 (k \, lambda)$.
+ #strong[Denominator ($X_2$):] Let $X_2 = upright("SSE") \/ sigma^2$. From #ref(<thm-distribution-ss-v2>, supplement: [Theorem]), $X_2 tilde.op chi^2 (n - k - 1)$.
+ #strong[Independence:] $X_1$ and $X_2$ are independent.

Substituting these into the F-statistic: $ F = upright("MSR") / upright("MSE") = frac((upright("SSR") \/ sigma^2) \/ k, (upright("SSE") \/ sigma^2) \/ (n - k - 1)) = frac(X_1 \/ k, X_2 \/ (n - k - 1)) $ By definition #ref(<def-noncentral-f>, supplement: [Definition]), this ratio follows $F (k \, n - k - 1 \, lambda)$.

]
=== Visualization of the Rejection Region
<visualization-of-the-rejection-region>
The following plot illustrates the central F-distribution (valid under $H_0$) for $k = 3$ predictors and $n = 20$ observations ($d f_1 = 3 \, d f_2 = 16$). An observed statistic of $F = 2$ is marked, with the p-value represented by the shaded tail area.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-f-dist-example-1.png"))
], caption: figure.caption(
position: bottom, 
[
Probability Density Function of F(3, 16) under H0. The shaded region represents the p-value.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-f-dist-example>


== Raw Coefficient of Determination ($R^2$)
<raw-coefficient-of-determination-r2>
=== Definition
<definition>
The $R^2$ statistic measures the proportion of total variation explained by the regression model.

#definition("R-Squared")[
$ R^2 = upright("SSR") / upright("SST") = 1 - upright("SSE") / upright("SST") $ Since $0 lt.eq upright("SSE") lt.eq upright("SST")$, it follows that $0 lt.eq R^2 lt.eq 1$.

] <def-r2>
=== Expectation and Bias
<expectation-and-bias>
To understand the bias in $R^2$, it is more illuminating to analyze the expectation of the #strong[unexplained variance] ($1 - R^2$). This term represents the ratio of error sum of squares to the total sum of squares:

$ E [1 - R^2] = E [upright("SSE") / upright("SST")] $

Using the first-order approximation $E [X \/ Y] approx E [X] \/ E [Y]$, we examine the numerator and denominator separately:

$ E [upright("SSE")] & = sigma^2 (n - k - 1)\
E [upright("SST")] & = sigma^2 (n - 1) + sigma^2 lambda = sigma^2 ((n - 1) + frac(parallel X_c beta_1 parallel^2, sigma^2)) $

Substituting these back, we approximate the expected unexplained fraction:

$ E [1 - R^2] approx frac(sigma^2 (n - k - 1), sigma^2 ((n - 1) + frac(parallel X_c beta_1 parallel^2, sigma^2))) = frac(n - k - 1, (n - 1) + frac(parallel X_c beta_1 parallel^2, sigma^2)) $

#strong[Behavior under Null Hypothesis ($H_0$):] When there is no true signal ($beta_1 = 0$), the term $frac(parallel X_c beta_1 parallel^2, sigma^2)$ vanishes. The expected proportion of unexplained variance becomes:

$ E [1 - R^2 \| H_0] approx frac(n - k - 1, n - 1) $

#block[
#callout(
body: 
[
This result reveals the source of the bias:

+ Ideally, if predictors are noise, the model should explain nothing, and $E [1 - R^2]$ should be $1$.
+ Instead, the expected error ratio is #strong[less than 1];, specifically scaled by $frac(n - k - 1, n - 1)$.
+ This scaling factor is exactly what the #strong[Adjusted R-squared ($R_a^2$)] attempts to correct by multiplying the observed ratio by the inverse $frac(n - 1, n - k - 1)$.

]
, 
title: 
[
Note
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Exact Distribution
<exact-distribution>
The $R^2$ statistic follows the Type I Non-central Beta distribution derived from the ratio of independent Chi-squared variables.

#theorem("Distribution of R-Squared")[
$ R^2 tilde.op upright("Beta")_1 (k / 2 \, frac(n - k - 1, 2) \, lambda) $ where $upright("df")_1 = k$ and $upright("df")_2 = n - k - 1$.

] <thm-r2-dist>
== Adjusted R-squared ($R_a^2$)
<adjusted-r-squared-r2_a>
To correct for the inflation of $R^2$ due to model complexity ($k$), we introduce the Adjusted $R^2$. This statistic penalizes the sum of squares by their degrees of freedom:

$ R_a^2 = 1 - frac(upright("SSE") \/ (n - k - 1), upright("SST") \/ (n - 1)) = 1 - upright("MSE") / upright("MST") = 1 - (1 - R^2) frac(n - 1, n - k - 1) $

#strong[Expectation:]

Under $H_0$, since $E [upright("MSE")] = E [upright("MST")] = sigma^2$, the estimator is asymptotically unbiased:

$ E [R_a^2 \| H_0] approx 0 $

#strong[Variance and Stability:]

While $R_a^2$ corrects the bias, it introduces instability. The variance of $R_a^2$ under $H_0$ can be derived from the variance of the Beta distribution:

$ upright("Var") (R_a^2 \| H_0) = (frac(n - 1, n - k - 1))^2 upright("Var") (R^2 \| H_0) $

Substituting $upright("Var") (R^2 \| H_0) = frac(2 k (n - k - 1), (n - 1)^2 (n + 1))$, we obtain:

$ upright("Var") (R_a^2 \| H_0) = frac(2 k, (n - k - 1) (n + 1)) $

#strong[Key Insight:]

As the model complexity $k$ increases relative to $n$:

+ The denominator $(n - k - 1)$ shrinks.
+ The variance $upright("Var") (R_a^2)$ explodes.

This implies that for high-dimensional models (large $k \/ n$), $R_a^2$ becomes an extremely noisy estimator, often yielding large negative values even for null models.

== Population Proportion of Signals ($rho^2$)
<population-proportion-of-signals-rho2>
The formula for the expected Adjusted $R^2$ reveals a deep connection to the decomposition of variance in population quantities. Recall the Rao-Blackwell theorem (or Law of Total Variance), which decomposes the total variance of a single observation $Y_i$ into the expected conditional variance (noise) and the variance of the conditional expectation (signal). Let $sigma_mu^2$ denote the signal variance and $sigma^2$ denote the noise variance:

$ upright("Var") (Y_i) = E [upright("Var") (Y_i \| x_((i)))] + upright("Var") (E [Y_i \| x_((i))]) $ $ sigma_Y^2 = sigma^2 + sigma_mu^2 $

In our derived expectation for $R_a^2$: $ E [R_a^2] approx frac(frac(parallel X_c beta_1 parallel^2, n - 1), sigma^2 + frac(parallel X_c beta_1 parallel^2, n - 1)) $

The term in the numerator, $frac(parallel X_c beta_1 parallel^2, n - 1)$, is precisely the #strong[sample variance of the true means] $mu_i$. Let $mu = X beta$. We can expand the centered signal vector $X_c beta_1$ to see this explicitly. Since $mu in upright("Col") (X)$, we know $H mu = mu$:

$ X_c beta_1 = P_(X_c) mu = (H - P_(j_n)) mu = H mu - P_(j_n) mu = mu - macron(mu) j_n = vec(mu_1 - macron(mu), mu_2 - macron(mu), dots.v, mu_n - macron(mu)) $

This vector represents the deviation of each observation's true mean from the grand mean. Consequently, the squared norm divided by degrees of freedom is: $ frac(parallel X_c beta_1 parallel^2, n - 1) = frac(sum_(i = 1)^n (mu_i - macron(mu))^2, n - 1) = sigma_mu^2 $

Thus, $R_a^2$ is therefore an unbiased estimator for the #strong[proportion of variance explained by the signal] in the population: $ E [R_a^2] approx frac(sigma_mu^2, sigma^2 + sigma_mu^2) $

We will denote this 'parameter' by $rho^2$:

$ rho^2 = 1 - sigma^2 / sigma_Y^2 = sigma_mu^2 / sigma_Y^2 $

#block[
#emph[Remark];. In the fixed covariate framework, the 'parameter' $rho^2$ is a function of the specific design matrix $X$, the coefficients $beta$, and the sample size $n$. If we assume the $x_i$ are random draws from a population, then as $n arrow.r oo$, $sigma_mu^2$ converges to $upright("Var") (x^T beta)$ (where $x$ is a random vector), and $rho^2$ converges to the true population proportion of variance explained.

]
#block[
#callout(
body: 
[
- Observing that $E [upright("MST")] approx sigma^2 + sigma_mu^2$ and $E [upright("MSE")] = sigma^2$, we can see that the difference $upright("MST") - upright("MSE")$ provides a direct method-of-moments estimator for the variance of the signal itself ($sigma_mu^2$).

- It is important to recognize that the commonly used #strong[Mean Square Regression (MSR)];, defined as $upright("SSR") \/ k$, is #strong[not] an estimator of the signal variance. Because $E [upright("MSR")] = sigma^2 + frac(parallel X_c beta_1 parallel^2, k)$, it scales with the sample size $n$ (via the squared norm) rather than converging to a population parameter. MSR is designed for hypothesis testing (detecting #emph[existence] of signal), not for estimating the #emph[magnitude] of the signal variance.

]
, 
title: 
[
MSR Is Not a Variance Estimator
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
== Relationship between $R^2$ and $F$ Test
<relationship-between-r2-and-f-test>
The $F$-statistic for the overall regression effect is a monotonic function of the coefficient of determination. We can express $F$ directly in terms of both the standard $R^2$ and the adjusted $R_a^2$, as well as relate its expected value to the population variance components.

+ #strong[Expressing $F$ via Standard $R^2$:] Since $R^2 = upright("SSR") \/ upright("SST")$ and $1 - R^2 = upright("SSE") \/ upright("SST")$, we can substitute these into the definition of $F$: $ F = frac(upright("SSR") \/ k, upright("SSE") \/ (n - k - 1)) = frac((R^2 dot.op upright("SST")) \/ k, ((1 - R^2) dot.op upright("SST")) \/ (n - k - 1)) = frac(R^2, 1 - R^2) dot.op frac(n - k - 1, k) $

+ #strong[Expressing $F$ via Adjusted $R_a^2$:] The relationship becomes structurally identical to the population expectation if we use the estimated Signal-to-Noise Ratio. Since $frac(R_a^2, 1 - R_a^2) = hat(sigma)_mu^2 / hat(sigma)^2$, we have: $ F = 1 + frac(n - 1, k) (frac(R_a^2, 1 - R_a^2)) $ This form highlights that $F$ starts at a baseline of 1 (pure noise) and increases proportional to the estimated signal strength.

+ #strong[Expected Value of $F$ as a function of $sigma_mu^2$ and $sigma^2$:] Using the population signal variance $sigma_mu^2$ and noise variance $sigma^2$, the expected value of the $F$-statistic (using the first-order approximation $E [F] approx E [upright("MSR")] \/ E [upright("MSE")]$) is: $ E [F] approx 1 + frac(n - 1, k) (sigma_mu^2 / sigma^2) $ The exact mean, derived from the non-central $F$ distribution, is: $ E [F] = frac(n - k - 1, n - k - 3) (1 + frac(n - 1, k) sigma_mu^2 / sigma^2) \, quad upright("for ") n - k - 1 > 3 $

== Confidence Interval of Population $rho^2$
<confidence-interval-of-population-rho2>
While $R_a^2$ provides a point estimate, we can construct an exact confidence interval for $rho^2$ by exploiting the distribution of the $F$-statistic.

#strong[\1. The link between $lambda$ and $rho^2$:]

Recall that the $F$-statistic follows a non-central distribution $F (k \, n - k - 1 \, lambda)$. The non-centrality parameter $lambda$ is directly related to the population $rho^2$. Using the variance decomposition derived above:

$ lambda = frac(parallel X_c beta_1 parallel^2, sigma^2) = (n - 1) (sigma_mu^2 / sigma^2) $

Substituting the signal-to-noise ratio $sigma_mu^2 / sigma^2 = frac(rho^2, 1 - rho^2)$, we obtain a one-to-one mapping between $lambda$ and $rho^2$:

$ lambda (rho^2) = (n - 1) (frac(rho^2, 1 - rho^2)) $

To recover $rho^2$ from $lambda$, we invert the mapping:

$ rho^2 (lambda) = frac(lambda, lambda + n - 1) $

#strong[\2. Inverting the Test Statistic:]

We find a confidence interval $[lambda_L \, lambda_U]$ for $lambda$ by "inverting" the observed $F$-statistic ($F_(o b s)$). We search for two specific non-central F-distributions: one where $F_(o b s)$ cuts off the upper $alpha \/ 2$ tail, and one where it cuts off the lower $alpha \/ 2$ tail.

- #strong[Lower Bound ($lambda_L$):] The non-centrality parameter such that $F_(o b s)$ is the $1 - alpha \/ 2$ quantile.
- #strong[Upper Bound ($lambda_U$):] The non-centrality parameter such that $F_(o b s)$ is the $alpha \/ 2$ quantile.

This concept is illustrated in the figure below.

#figure([
#box(image("linearmodel-lli_files/figure-typst/fig-ci-inversion-1.png"))
], caption: figure.caption(
position: bottom, 
[
Illustration of constructing a confidence interval for the non-centrality parameter $lambda$ by inverting the F-test. The observed $F_(o b s)$ (dashed line) is the $97.5^(t h)$ percentile of the distribution defined by the lower bound $lambda_L$ (blue), and the $2.5^(t h)$ percentile of the distribution defined by the upper bound $lambda_U$ (red). The shaded areas each represent $alpha \/ 2$.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-ci-inversion>


#strong[\3. The Interval for $rho^2$:]

Once $[lambda_L \, lambda_U]$ are found numerically, we map them back to the population $R^2$ scale using the inverse relationship:

$ rho^2 = frac(lambda, lambda + (n - 1)) $

This produces an exact confidence interval $[rho_L^2 \, rho_U^2]$ for the proportion of variance explained by the model in the population.

== An Animation for Illustrating $R_a^2$ Under $H_0$ and $H_1$
<an-animation-for-illustrating-r2_a-under-h_0-and-h_1>
We simulate a dataset with $n = 30$ observations and consider a sequence of nested models adding groups of predictors.

#strong[Predictor Groups:]

+ #strong[Group 1 ($k = 1$):] Add $x_1$. (Signal under $H_1$).
+ #strong[Group 2 ($k = 6$):] Add $x_2 \, dots.h \, x_6$ (Noise).
+ #strong[Group 3 ($k = 11$):] Add $x_7 \, dots.h \, x_11$ (Noise).
+ #strong[Group 4 ($k = 20$):] Add $x_12 \, dots.h \, x_20$ (Noise).

==== Null Hypothesis ($H_0$)
Under $H_0$, the true coefficient for $x_1$ is $beta_1 = 0$. All predictors are noise.

#figure([
#box(image("figs/rss-h0-v6.png"))
], caption: figure.caption(
position: bottom, 
[
Simulation under H0: As predictors are added (pure noise), standard R-squared increases while Adjusted R-squared and MSE remain stable.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


==== Alternative Hypothesis ($H_1$)
Under $H_1$, $x_1$ is a true predictor ($beta_1 = 2$). The subsequent groups ($x_2 dots.h x_20$) remain noise.

#figure([
#box(image("figs/rss-h1-v6.png"))
], caption: figure.caption(
position: bottom, 
[
Simulation under H1: Adjusted R-squared correctly identifies the signal at k=1, then penalizes the subsequent noise predictors.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


== A Data Example with House Price Valuation
<a-data-example-with-house-price-valuation>
A real estate agency wants to refine their pricing model. They regress the selling price of houses ($y$) on five predictors ($X$): Size, Age, Bedrooms, Garage Capacity, and Lawn Size.

We assume the data has been collected and saved to `house_prices_5pred.csv`.

=== Visualize the Data
<visualize-the-data>
First, we load the dataset. We display the first 10 rows for PDF output, or a full paged table for HTML.

```r
# Load Data
df <- read.csv("house_prices_5pred.csv")

# Conditional Display
if (knitr::is_html_output()) {
  rmarkdown::paged_table(df)
} else {
  knitr::kable(head(df, 10), caption = "First 10 rows of House Prices")
}
```

#table(
  columns: 6,
  align: (right,right,right,right,right,right,),
  table.header([Price], [Size], [Age], [Beds], [Garage], [Lawn],),
  table.hline(),
  [497808], [3092], [4], [3], [2], [426],
  [364297], [1802], [26], [5], [0], [88],
  [610217], [2701], [22], [4], [1], [403],
  [536122], [2745], [38], [4], [0], [437],
  [347259], [2143], [18], [2], [1], [141],
  [343784], [2754], [49], [5], [1], [186],
  [379522], [2039], [53], [4], [0], [451],
  [341432], [1758], [43], [5], [1], [832],
  [515913], [3191], [19], [4], [0], [276],
  [292732], [1298], [17], [2], [2], [804],
)
=== Fit the Model
<fit-the-model>
We will solve for the coefficients $hat(beta)$ using three distinct methods.

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Method 1: Naive Matrix Formula
]
)
]
This method solves the normal equations directly on the raw data: $hat(beta) = (X^(') X)^(- 1) X^(') y$.

#block[
```r
# 1. Define Y and X (add Column of 1s for Intercept)
y <- as.matrix(df$Price)
# Note: "lawn" Is Included Here, Even Though It Is Irrelevant
X_naive <- as.matrix(cbind(Intercept = 1, 
                           df[, c("Size", "Age", "Beds", "Garage", "Lawn")]))

# 2. Compute Intermediate Matrices
XtX <- t(X_naive) %*% X_naive
Xty <- t(X_naive) %*% y

# Display Intermediate Steps
cat("Matrix X'X (Cross-products of predictors):\n")
```

#block[
```
Matrix X'X (Cross-products of predictors):
```

]
```r
print(round(XtX, 0))
```

#block[
```
          Intercept      Size     Age   Beds Garage     Lawn
Intercept        60    136483    1674    206     80    29392
Size         136483 343078981 3738402 469757 177877 63939128
Age            1674   3738402   63528   5874   2353   827130
Beds            206    469757    5874    776    281    98738
Garage           80    177877    2353    281    196    41915
Lawn          29392  63939128  827130  98738  41915 19306096
```

]
```r
cat("\nMatrix X'y (Cross-products with response):\n")
```

#block[
```

Matrix X'y (Cross-products with response):
```

]
```r
print(round(Xty, 0))
```

#block[
```
                 [,1]
Intercept    25884407
Size      63115001244
Age         694594579
Beds         89683035
Garage       34067413
Lawn      12402228016
```

]
```r
# 3. Solve Beta
beta_naive <- solve(XtX) %*% Xty

# Display Result
cat("\nSolved Coefficients (Beta):\n")
```

#block[
```

Solved Coefficients (Beta):
```

]
```r
print(t(beta_naive))
```

#block[
```
     Intercept     Size       Age     Beds   Garage    Lawn
[1,]    113186 129.3434 -1218.352 12664.16 875.1155 27.2443
```

]
]
#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Method 2: Centralized Formula
]
)
]
This method reduces multicollinearity issues. Formula: $hat(beta)_(upright("slope")) = (X_c^(') X_c)^(- 1) X_c^(') y_c$.

#block[
```r
# 1. Center the Data
y_bar <- mean(y)
X_raw <- as.matrix(df[, c("Size", "Age", "Beds", "Garage", "Lawn")])
X_means <- colMeans(X_raw)

y_c <- y - y_bar
X_c <- sweep(X_raw, 2, X_means) 

# 2. Compute Intermediate Matrices
XctXc <- t(X_c) %*% X_c
Xctyc <- t(X_c) %*% y_c

# Display Intermediate Steps
cat("Matrix X_c'X_c (Centered Sum of Squares):\n")
```

#block[
```
Matrix X_c'X_c (Centered Sum of Squares):
```

]
```r
print(round(XctXc, 0))
```

#block[
```
           Size    Age  Beds Garage     Lawn
Size   32618826 -69474  1165  -4100 -2919344
Age      -69474  16823   127    121     7093
Beds       1165    127    69      6    -2175
Garage    -4100    121     6     89     2726
Lawn   -2919344   7093 -2175   2726  4907935
```

]
```r
cat("\nMatrix X_c'y_c (Centered Cross-products):\n")
```

#block[
```

Matrix X_c'y_c (Centered Cross-products):
```

]
```r
print(round(Xctyc, 0))
```

#block[
```
             [,1]
Size   4235309234
Age     -27580376
Beds       813238
Garage    -445130
Lawn   -277680160
```

]
```r
# 3. Solve for Slope Coefficients
beta_slope <- solve(XctXc) %*% Xctyc

# 4. Recover Intercept
beta_0 <- y_bar - sum(X_means * beta_slope)
beta_central <- rbind(Intercept = beta_0, beta_slope)

# Display Result
cat("\nSolved Coefficients (Beta):\n")
```

#block[
```

Solved Coefficients (Beta):
```

]
```r
print(t(beta_central))
```

#block[
```
     Intercept     Size       Age     Beds   Garage    Lawn
[1,]    113186 129.3434 -1218.352 12664.16 875.1155 27.2443
```

]
]
#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Method 3: Using R's `lm` Function
]
)
]
This is the standard approach for practitioners.

#block[
```r
# Fit Model
model_lm <- lm(Price ~ ., data = df)
y_hat_lm <- fitted(model_lm)

# Extract Coefficients
print(summary(model_lm))
```

#block[
```

Call:
lm(formula = Price ~ ., data = df)

Residuals:
    Min      1Q  Median      3Q     Max 
-135178  -36006    1710   26401  111967 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept) 113185.971  35675.435   3.173  0.00249 ** 
Size           129.343      8.927  14.490  < 2e-16 ***
Age          -1218.352    386.414  -3.153  0.00264 ** 
Beds         12664.157   6064.435   2.088  0.04150 *  
Garage         875.115   5316.490   0.165  0.86987    
Lawn            27.244     23.243   1.172  0.24629    
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 49360 on 54 degrees of freedom
Multiple R-squared:  0.8161,    Adjusted R-squared:  0.799 
F-statistic: 47.92 on 5 and 54 DF,  p-value: < 2.2e-16
```

]
]
=== Visualization of Fitted Values vs Mean
<visualization-of-fitted-values-vs-mean>
We define $hat(y)_0$ as the vector of the mean of $y$ ($macron(y)$). We plot the actual $y$ against our fitted model $hat(y)$, using a green line to represent the "Null Model" ($hat(y)_0$).

#emph[Note: Axes have been set so that X = Predicted Value and Y = Actual Value.]

```r
# Define y_hat_0 (The Null Model) - for conceptual clarity
y_hat_0 <- rep(mean(y), length(y))

# Scatterplot (Axes reversed: x=fitted, y=actual)
plot(y_hat_lm, y,
     main = "Actual vs Fitted Prices",
     xlab = "Fitted Price (y_hat)",
     ylab = "Actual Price (y)",
     pch = 19, col = "blue")

# Add 1:1 line (Perfect fit area, remains y=x)
abline(0, 1, col = "gray", lty = 2)

# Add Mean line representing the null model
# Since y-axis is 'actual y', a horizontal line at mean(y) represents y_bar
abline(v=mean (y), h = mean(y), col = "green", lwd = 2)

legend("topleft", legend = c("Data", "Mean (y_bar)"),
       col = c("blue", "green"), pch = c(19, NA), lty = c(NA, 1))
```

#box(image("linearmodel-lli_files/figure-typst/plot-y-vs-yhat-1.png"))

#strong[Question:]

$ macron(y) = macron(hat(y)) ? $

=== Computing Sums of Squares (SSE, SST, SSR)
<computing-sums-of-squares-sse-sst-ssr>
We compare different methods to calculate the sources of variation.

==== 1. Naive Sum of Squared Errors
<naive-sum-of-squared-errors>
This uses the standard summation definitions: $sum (D i f f e r e n c e)^2$.

- #strong[SST (Total):] Variation of $y$ around $hat(y)_0$ (Mean).
- #strong[SSR (Regression):] Variation of $hat(y)$ around $hat(y)_0$ (Mean).
- #strong[SSE (Error):] Variation of $y$ around $hat(y)$ (Model).

#block[
```r
# Vectors
y_vec <- as.vector(y)
y_hat <- as.vector(y_hat_lm)
y_bar_vec <- rep(mean(y), length(y))

# Calculations
SST_naive <- sum((y_vec - y_bar_vec)^2)
SSR_naive <- sum((y_hat - y_bar_vec)^2)
SSE_naive <- sum((y_vec - y_hat)^2)

cat("Naive Calculation:\n")
```

#block[
```
Naive Calculation:
```

]
```r
cat("SST:", SST_naive, " SSR:", SSR_naive, " SSE:", SSE_naive, "\n")
```

#block[
```
SST: 715333529746  SSR: 583756306788  SSE: 131577222958 
```

]
]
==== 2. Pythagorean Shortcut (Vector Lengths)
<pythagorean-shortcut-vector-lengths>
Based on the geometry of least squares, we can treat the variables as vectors. Because the vectors are orthogonal, we can use squared lengths (dot products with themselves).

Formula: $S S R = lr(||) hat(y) lr(||)^2 - lr(||) hat(y)_0 lr(||)^2$

#block[
```r
# Function for squared Euclidean norm (length squared)
len_sq <- function(v) sum(v^2)

# SST = ||y||^2 - ||y_0||^2
SST_pyth <- len_sq(y_vec) - len_sq(y_bar_vec)

# SSR = ||y_hat||^2 - ||y_0||^2
SSR_pyth <- len_sq(y_hat) - len_sq(y_bar_vec)

# SSE = ||y||^2 - ||y_hat||^2
SSE_pyth <- len_sq(y_vec) - len_sq(y_hat)

cat("Pythagorean Calculation:\n")
```

#block[
```
Pythagorean Calculation:
```

]
```r
cat("SST:", SST_pyth, " SSR:", SSR_pyth, " SSE:", SSE_pyth, "\n")
```

#block[
```
SST: 715333529746  SSR: 583756306788  SSE: 131577222958 
```

]
]
==== Matrix Algebra Shortcuts
<matrix-algebra-shortcuts>
These formulas use the $beta$ and $X$ matrices directly. This is computationally efficient for large datasets.

- Formula A (Centered with $y_c$): $S S R = hat(beta)_c^(') X_c^(') y_c$
- Formula B (Alternative with $y$): $S S R = hat(beta)_c^(') X_c^(') y$
- Formula C (Uncentered): $S S R = hat(beta)^(') X^(') y - n macron(y)^2$

```r
n <- length(y)
term_correction <- n * mean(y)^2 

# --- SSR Calculations ---

# 1. SSR Formula A (Centered, using y_c)
SSR_centered_yc <- t(beta_slope) %*% t(X_c) %*% y_c

# 2. SSR Formula A (Alternative, using raw y)
# Since X_c is centered, X_c' * 1 = 0, so X_c'y_c is equivalent to X_c'y
SSR_centered_y <- t(beta_slope) %*% t(X_c) %*% y

# 3. SSR Formula B (Uncentered Matrix)
# beta_naive includes intercept, X_naive includes column of 1s
term_beta_X_y <- t(beta_naive) %*% t(X_naive) %*% y
SSR_uncentered <- term_beta_X_y - term_correction

# --- Equivalence Check Table ---

results_table <- data.frame(
  Metric = c("SSR (Centered $X_c,y_c$)", 
             "SSR (Centered $X_c$)", 
             "SSR (Uncentered)"),
  Formula = c("$\\hat{\\beta}_c' X_c' y_c$", 
              "$\\hat{\\beta}_c' X_c' y$", 
              "$\\hat{\\beta}' X' y - n\\bar{y}^2$"),
  Value = c(as.numeric(SSR_centered_yc), 
            as.numeric(SSR_centered_y), 
            as.numeric(SSR_uncentered))
)

# Render the table
knitr::kable(results_table, 
             digits = 4, 
             caption = "Demonstration of SSR Formula Equivalence")
```

#table(
  columns: (35.21%, 46.48%, 18.31%),
  align: (left,left,right,),
  table.header([Metric], [Formula], [Value],),
  table.hline(),
  [SSR (Centered $X_c \, y_c$)], [$hat(beta)_c' X_c' y_c$], [583756306788],
  [SSR (Centered $X_c$)], [$hat(beta)_c' X_c' y$], [583756306788],
  [SSR (Uncentered)], [$hat(beta)' X' y - n macron(y)^2$], [583756306788],
)
=== Analysis of Variance (ANOVA)
<analysis-of-variance-anova>
We now evaluate the sources of variation to test the overall model significance.

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
1. Computing Sums of Squares
]
)
]
We calculate the following components:

- Total Sum of Squares: $upright("SST") = sum (y_i - macron(y))^2$
- Regression Sum of Squares: $upright("SSR") = sum (hat(y)_i - macron(y))^2$
- Sum of Squared Errors: $upright("SSE") = sum (y_i - hat(y)_i)^2$

#block[
```r
# Vectors
y_vec <- as.vector(y)
y_hat <- as.vector(y_hat_lm)
y_bar_vec <- rep(mean(y), length(y))

# Calculations
SST_naive <- sum((y_vec - y_bar_vec)^2)
SSR_naive <- sum((y_hat - y_bar_vec)^2)
SSE_naive <- sum((y_vec - y_hat)^2)

cat("SST:", SST_naive, " SSR:", SSR_naive, " SSE:", SSE_naive, "\n")
```

#block[
```
SST: 715333529746  SSR: 583756306788  SSE: 131577222958 
```

]
]
#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
2. Manual ANOVA Construction
]
)
]
We build the table manually using the sums of squares and degrees of freedom. We calculate the Mean Squares and the F-statistic:

- $upright("MSR") = upright("SSR") \/ k$
- $upright("MSE") = upright("SSE") \/ (n - k - 1)$
- $upright("MST") = upright("SST") \/ (n - 1)$
- $F = upright("MSR") \/ upright("MSE")$

```r
# Parameters
k <- 5             # Predictors
df_e <- n - k - 1  # Error DF
df_t <- n - 1      # Total DF

# Mean Squares
MSR <- SSR_naive / k
MSE <- SSE_naive / df_e
MST <- SST_naive / df_t # Mean Square Total (Variance of Y)

# F-statistic
F_stat <- MSR / MSE

# P-value
p_val <- pf(F_stat, k, df_e, lower.tail = FALSE)

# Assemble Table
anova_manual <- data.frame(
  Source = c("Regression (Model)", "Error (Residual)", "Total"),
  DF = c(k, df_e, df_t),
  SS = c(SSR_naive, SSE_naive, SST_naive),
  MS = c(MSR, MSE, MST), # Included MST here
  F_Statistic = c(F_stat, NA, NA),
  P_Value = c(p_val, NA, NA)
)

knitr::kable(anova_manual, digits = 4, caption = "Manual ANOVA Table")
```

#table(
  columns: (27.94%, 4.41%, 19.12%, 19.12%, 17.65%, 11.76%),
  align: (left,right,right,right,right,right,),
  table.header([Source], [DF], [SS], [MS], [F\_Statistic], [P\_Value],),
  table.hline(),
  [Regression (Model)], [5], [583756306788], [116751261358], [47.9153], [0],
  [Error (Residual)], [54], [131577222958], [2436615240], [NA], [NA],
  [Total], [59], [715333529746], [12124297114], [NA], [NA],
)
#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
3. Standard R Output (`anova`)
]
)
]
We display the standard `summary()` which provides the coefficients, t-tests, and the overall F-statistic found at the bottom. We also show `anova()` which gives the sequential sum of squares.

#block[
```r
# Fit an intercept-only (null) model and compare to the fitted model
model_null <- lm(Price ~ 1, data = df)
cat("\nANOVA comparing intercept-only model to fitted model:\n")
```

#block[
```

ANOVA comparing intercept-only model to fitted model:
```

]
```r
print(anova(model_null, model_lm))
```

#block[
```
Analysis of Variance Table

Model 1: Price ~ 1
Model 2: Price ~ Size + Age + Beds + Garage + Lawn
  Res.Df        RSS Df  Sum of Sq      F    Pr(>F)    
1     59 7.1533e+11                                   
2     54 1.3158e+11  5 5.8376e+11 47.915 < 2.2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

]
```r
# One can call anova directly to model_lm
print(anova(model_lm))
```

#block[
```
Analysis of Variance Table

Response: Price
          Df     Sum Sq    Mean Sq  F value    Pr(>F)    
Size       1 5.4992e+11 5.4992e+11 225.6914 < 2.2e-16 ***
Age        1 2.0657e+10 2.0657e+10   8.4777  0.005216 ** 
Beds       1 9.5872e+09 9.5872e+09   3.9346  0.052396 .  
Garage     1 2.4151e+08 2.4151e+08   0.0991  0.754107    
Lawn       1 3.3476e+09 3.3476e+09   1.3739  0.246291    
Residuals 54 1.3158e+11 2.4366e+09                       
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

]
]
=== Coefficient of Determination and Variance Decomposition
<coefficient-of-determination-and-variance-decomposition>
We calculate $R^2$ and Adjusted $R^2$, and then present them in a #strong[Variance Decomposition Table];.

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
1. Calculation
]
)
]
We calculate the coefficients of determination:

- Standard $R^2 = 1 - upright("SSE") / upright("SST")$
- Adjusted $R_a^2 = 1 - upright("MSE") / upright("MST")$

#block[
```r
# Standard R-squared
R2 <- 1 - (SSE_naive / SST_naive)

# Adjusted R-squared
# Formula: 1 - (MSE / MST)
R2_adj <- 1 - (MSE / MST)

cat("Standard R^2:  ", round(R2, 4), "\n")
```

#block[
```
Standard R^2:   0.8161 
```

]
```r
cat("Adjusted R^2:  ", round(R2_adj, 4), "\n")
```

#block[
```
Adjusted R^2:   0.799 
```

]
]
#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
2. Variance Decomposition Table
]
)
]
This table extends standard ANOVA. While ANOVA focuses on #strong[Mean Squares (MS)] for hypothesis testing (is $M S R > M S E$?), this table focuses on #strong[Variance Components ($hat(sigma)^2$)] for estimation (how much variance is Signal vs.~Noise?). We estimate the variance components as follows:

- Signal Variance: $hat(sigma)_mu^2 = upright("MST") - upright("MSE")$

- Noise Variance: $hat(sigma)^2 = upright("MSE")$

- Total Variance: $hat(sigma)_Y^2 = upright("MST")$

- #strong[Signal Variance ($hat(sigma)_mu^2$):] Estimated by $M S T - M S E$. (Note: $M S R$ is biased and overestimates signal).

- #strong[Noise Variance ($hat(sigma)^2$):] Estimated by $M S E$.

- #strong[Total Variance ($hat(sigma)_Y^2$):] Estimated by $M S T$.

```r
# Variance Component Estimators (Method of Moments)
sigma2_noise_est  <- MSE
sigma2_total_est  <- MST
sigma2_signal_est <- MST - MSE

# Proportions
prop_signal <- sigma2_signal_est / sigma2_total_est # Equals R^2_adj
prop_noise  <- sigma2_noise_est / sigma2_total_est  # Equals 1 - R^2_adj

# Assemble Table
decomp_table <- data.frame(
  Component = c("Signal (Model)", "Noise (Error)", "Total (Y)"),
  DF = c(k, df_e, df_t),
  SS = c(SSR_naive, SSE_naive, SST_naive),
  MS = c(NA, MSE, MST),
  Estimator_Sigma2 = c(sigma2_signal_est, sigma2_noise_est, sigma2_total_est),
  Proportion = c(prop_signal, prop_noise, 1.0)
)

# Display
knitr::kable(decomp_table, 
             digits = 4, 
             col.names = c("Component", "DF", "SS", "MS", "Value ($\\hat{\\sigma}^2$)", "Proportion"),
             caption = "Variance Decomposition Table: Estimating Signal vs. Noise")
```

#table(
  columns: (18.99%, 3.8%, 16.46%, 15.19%, 31.65%, 13.92%),
  align: (left,right,right,right,right,right,),
  table.header([Component], [DF], [SS], [MS], [Value ($hat(sigma)^2$)], [Proportion],),
  table.hline(),
  [Signal (Model)], [5], [583756306788], [NA], [9687681874], [0.799],
  [Noise (Error)], [54], [131577222958], [2436615240], [2436615240], [0.201],
  [Total (Y)], [59], [715333529746], [12124297114], [12124297114], [1.000],
)
=== Confidence Interval for Population $R^2$ ($rho^2$)
<confidence-interval-for-population-r2-rho2>
We construct a 95% confidence interval for the population proportion of variance explained ($rho^2$).

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
1. Manual Inversion Method
]
)
]
We solve for the non-centrality parameters $lambda_L$ and $lambda_U$ such that our observed $F_(o b s)$ corresponds to the appropriate quantiles.

#block[
```r
# 1. Define Helper Function to Find Lambda
# We want to find lambda such that: pf(F_stat, df1, df2, ncp = lambda) = target_prob
get_lambda <- function(target_prob, F_val, df1, df2) {
  f_root <- function(lam) {
    pf(F_val, df1, df2, ncp = lam) - target_prob
  }
  tryCatch({
    res <- uniroot(f_root, interval = c(0, 1000))$root
    return(res)
  }, error = function(e) return(NA))
}

# 2. Calculate Lambda Bounds (95% CI -> alpha = 0.05)
alpha <- 0.05
# Lower Bound Lambda: F_obs is the (1 - alpha/2) quantile
lambda_Lower <- get_lambda(1 - alpha/2, F_stat, k, df_e)
# Upper Bound Lambda: F_obs is the (alpha/2) quantile
lambda_Upper <- get_lambda(alpha/2, F_stat, k, df_e)

if (is.na(lambda_Lower)) lambda_Lower <- 0

# 3. Convert Lambda to Rho^2
# Formula for Fixed Predictors: rho^2 = lambda / (lambda + n)
rho2_Lower <- lambda_Lower / (lambda_Lower + n)
rho2_Upper <- lambda_Upper / (lambda_Upper + n)

cat("Manual Calculation:\n")
```

#block[
```
Manual Calculation:
```

]
```r
cat("95% CI for Population Rho^2: [", round(rho2_Lower, 4), ", ", round(rho2_Upper, 4), "]\n")
```

#block[
```
95% CI for Population Rho^2: [ 0.6982 ,  0.8556 ]
```

]
]
#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
2. Using R Package `MBESS`
]
)
]
The `MBESS` package automates this procedure. We use `Random.Predictors = FALSE` to match the fixed-predictor assumption used in our manual calculation.

#block[
```r
if (requireNamespace("MBESS", quietly = TRUE)) {
  
  # Use N (sample size) and p (number of predictors) 
  # instead of df.1/df.2 to avoid the redundancy error.
  ci_res <- MBESS::ci.R2(F.value = F_stat, 
                         p = k,      # Number of predictors
                         N = n,      # Sample size
                         conf.level = 0.95,
                         Random.Predictors = FALSE)
  
  print(ci_res)
  
} else {
  cat("Package 'MBESS' is not installed.")
}
```

#block[
```
$Lower.Conf.Limit.R2
[1] 0.6982442

$Prob.Less.Lower
[1] 0.025

$Upper.Conf.Limit.R2
[1] 0.8555948

$Prob.Greater.Upper
[1] 0.025
```

]
]
== Underfitting and Overfitting
<underfitting-and-overfitting>
We compare the properties of two competing estimators for the mean response vector $mu = E [y]$.

=== Notation and Setup
<notation-and-setup>
We consider the general linear model: $ y = X beta + e = X_1 beta_1 + X_2 beta_2 + e $ where $X_1$ is $n times p_1$, $X_2$ is $n times p_2$, and $upright("Var") (e) = sigma^2 I$.

We distinguish between two estimation approaches based on this model:

#strong[\1. Full Model ($M_1$)] We estimate $beta$ without restrictions. The estimator projects $y$ onto the full column space $upright("Col") (X)$. $ P_1 & = X (X^T X)^(- 1) X^T & (upright("Projection onto ") upright("Col") (X))\
hat(y)_1 & = P_1 y & (upright("Unrestricted Estimator")) $

#strong[\2. Reduced Model ($M_0$)] We estimate $beta$ subject to the constraint: $ M_0 : beta_2 = 0 $ This effectively reduces the model to $y = X_1 beta_1 + e$, projecting $y$ onto the subspace $upright("Col") (X_1)$. $ P_0 & = X_1 (X_1^T X_1)^(- 1) X_1^T & (upright("Projection onto ") upright("Col") (X_1))\
hat(y)_0 & = P_0 y & (upright("Restricted Estimator")) $

#strong[Key Geometric Property:] Since the constraint $beta_2 = 0$ restricts the estimation to a subspace ($upright("Col") (X_1) subset upright("Col") (X)$), we have the nesting property: $ P_1 P_0 = P_0 quad upright("and") quad P_1 - P_0 upright(" is a projection matrix.") $

=== Case 1: Underfitting
<case-1-underfitting>
#strong[The Truth:] The Full Model ($M_1$) is correct. $ y = X_1 beta_1 + X_2 beta_2 + e \, quad beta_2 eq.not 0 $ The true mean is $mu = X_1 beta_1 + X_2 beta_2$.

We analyze the properties of the #strong[Reduced Estimator] $hat(y)_0$ (from $M_0$) compared to the correct Full Estimator $hat(y)_1$ (from $M_1$).

#theorem("Bias-Variance Tradeoff in Underfitting")[
When $M_1$ is true:

+ #strong[Bias:] The estimator $hat(y)_0$ is #strong[biased];, while $hat(y)_1$ is unbiased. $ upright("Bias") (hat(y)_0) = - (I - P_0) X_2 beta_2 $
+ #strong[Variance:] The estimator $hat(y)_0$ has #strong[smaller variance] (matrix difference is positive semidefinite). $ upright("Var") (hat(y)_1) - upright("Var") (hat(y)_0) = sigma^2 (P_1 - P_0) gt.eq 0 $

] <thm-underfitting>
#block[
#emph[Proof];. #strong[Part 1 (Bias):] $ E [hat(y)_0] & = P_0 E [y] = P_0 (X_1 beta_1 + X_2 beta_2)\
 & = X_1 beta_1 + P_0 X_2 beta_2 quad (upright("Since ") P_0 X_1 = X_1) $ The bias is: $ upright("Bias") = E [hat(y)_0] - mu = (X_1 beta_1 + P_0 X_2 beta_2) - (X_1 beta_1 + X_2 beta_2) = - (I - P_0) X_2 beta_2 $

#strong[Part 2 (Variance):] $ upright("Var") (hat(y)_1) = sigma^2 P_1 \, quad upright("Var") (hat(y)_0) = sigma^2 P_0 $ The difference is $sigma^2 (P_1 - P_0)$. Since $upright("Col") (X_1) subset upright("Col") (X)$, the difference $P_1 - P_0$ projects onto the orthogonal complement of $upright("Col") (X_1)$ within $upright("Col") (X)$. It is idempotent and positive semidefinite.

]
#strong[Remark: Scalar Variance and Coefficients]

From the matrix inequality above, we can state that for any arbitrary vector $a$, the scalar variance of the linear combination $a^T hat(y)$ is always smaller in the reduced model: $ upright("Var") (a^T hat(y)_0) lt.eq upright("Var") (a^T hat(y)_1) $

We can extend this property to the regression coefficients $hat(beta)$. Since $hat(y) = X hat(beta)$, we can recover the coefficients from the fitted values using the left pseudo-inverse:

$ (X^T X)^(- 1) X^T (X hat(beta)) & = (X^T X)^(- 1) X^T hat(y)\
underbrace((X^T X)^(- 1) (X^T X), I) hat(beta) & = (X^T X)^(- 1) X^T hat(y) $

#corollary("Variance of Coefficients")[
Because $hat(beta)$ is a linear transformation of $hat(y)$, the variance reduction in $hat(y)_0$ propagates to the coefficients.

For any specific coefficient $beta_j$ included in the reduced model (i.e., $beta_j in beta_1$), the variance of the estimator is smaller in the reduced model than in the full model: $ upright("Var") (hat(beta)_(j \, r e d u c e d)) lt.eq upright("Var") (hat(beta)_(j \, f u l l)) $

] <cor-beta-variance>
#strong[Conclusion:] Using $M_0$ when $M_1$ is true introduces bias but reduces variance for both the fitted values and the estimated coefficients.

=== Case 2: Overfitting
<case-2-overfitting>
#strong[The Truth:] The Reduced Model ($M_0$) is correct. $ y = X_1 beta_1 + e quad (upright("i.e., ") beta_2 = 0) $ The true mean is $mu = X_1 beta_1$.

We analyze the properties of the #strong[Full Estimator] $hat(y)_1$ (from $M_1$) compared to the correct Reduced Estimator $hat(y)_0$ (from $M_0$).

#theorem("Variance Inflation in Overfitting")[
When $M_0$ is true:

+ #strong[Bias:] Both estimators are #strong[unbiased];. $ E [hat(y)_1] = mu quad upright("and") quad E [hat(y)_0] = mu $
+ #strong[Variance:] The estimator $hat(y)_1$ has #strong[unnecessarily higher variance];. $ upright("Var") (hat(y)_1) gt.eq upright("Var") (hat(y)_0) $

] <thm-overfitting>
#block[
#emph[Proof];. #strong[Part 1 (Bias):] Since $mu = X_1 beta_1$: $ E [hat(y)_1] = P_1 X_1 beta_1 = X_1 beta_1 = mu quad (upright("Since ") X_1 in upright("Col") (X)) $ $ E [hat(y)_0] = P_0 X_1 beta_1 = X_1 beta_1 = mu quad (upright("Since ") X_1 in upright("Col") (X_1)) $

#strong[Part 2 (Variance):] As shown in Case 1, the difference is $sigma^2 (P_1 - P_0)$. The cost of overfitting is purely variance inflation. The total variance (trace) increases by the number of unnecessary parameters ($p_2$): $ upright("tr") (upright("Var") (hat(y)_1)) - upright("tr") (upright("Var") (hat(y)_0)) = sigma^2 (upright("tr") (P_1) - upright("tr") (P_0)) = sigma^2 (p_(f u l l) - p_(r e d u c e d)) = sigma^2 p_2 $

]
#strong[Conclusion:] Using $M_1$ when $M_0$ is true offers no benefit in bias but strictly increases estimation variance.

#pagebreak()
= Generalized Inverses
<generalized-inverses>
== Motivation
<motivation-1>
Consider the linear system $X beta = y$. In $bb(R)^2$, if $X = [x_1 \, x_2]$ is invertible, the solution is unique: $beta = X^(- 1) y$. This satisfies $X (X^(- 1) y) = y$.However, if $X$ is not square or not invertible (e.g., $X$ is $2 times 3$), $X beta = y$ does not have a unique solution. We seek a matrix $G$ such that $beta = G y$ provides a solution whenever $y in C (X)$ (the column space of X). Substituting $beta = G y$ into the equation $X beta = y$: $ X (G y) = y quad forall y in C (X) $ Since any $y in C (X)$ can be written as $X w$ for some vector $w$: $ X G X w = X w quad forall w $ This implies the defining condition: $ X G X = X $

== Definition of Generalized Inverse
<definition-of-generalized-inverse>
#definition("Generalized Inverse")[
Let $X$ be an $n times p$ matrix. A matrix $X^(-)$ of size $p times n$ is called a #strong[generalized inverse] of $X$ if it satisfies: $ X X^(-) X = X $

] <def-gen-inverse>
#example("Examples of Generalized Inverse")[
~

- #strong[Example 1: Diagonal Matrix] If $X = upright("diag") (lambda_1 \, lambda_2 \, 0 \, 0)$, we can write it in matrix form as: $ X = mat(delim: "(", lambda_1, 0, 0, 0; 0, lambda_2, 0, 0; 0, 0, 0, 0; 0, 0, 0, 0) $ A generalized inverse is obtained by inverting the non-zero elements: $ X^(-) = mat(delim: "(", lambda_1^(- 1), 0, 0, 0; 0, lambda_2^(- 1), 0, 0; 0, 0, 0, 0; 0, 0, 0, 0) $

- #strong[Example 2: Row Vector] Let $X = (1 \, 2 \, 3)$. One possible generalized inverse is a column vector where the first element is the reciprocal of the first non-zero element of $X$ (which is $1$), and others are zero: $ X^(-) = vec(1, 0, 0) $ #strong[Verification:] $ X X^(-) X = (1 \, 2 \, 3) vec(1, 0, 0) (1 \, 2 \, 3) = (1) dot.op (1 \, 2 \, 3) = (1 \, 2 \, 3) = X $ Other valid generalized inverses include $vec(0, 1 \/ 2, 0)$ or $vec(0, 0, 1 \/ 3)$.

- #strong[Example 3: Rank Deficient Matrix] Let $A = mat(delim: "(", 2, 2, 3; 1, 0, 1; 3, 2, 4)$. Note that Row 3 = Row 1 + Row 2, so Rank$(A) = 2$.

  #strong[Solution:] A generalized inverse can be found by locating a non-singular $2 times 2$ submatrix, inverting it, and padding the rest with zeros. Let's take the top-left minor $M = mat(delim: "(", 2, 2; 1, 0)$. The inverse is $M^(- 1) = frac(1, - 2) mat(delim: "(", 0, - 2; - 1, 2) = mat(delim: "(", 0, 1; 0.5, - 1)$.

  Placing this in the corresponding position in $A^(-)$ and setting the rest to 0: $ A^(-) = mat(delim: "(", 0, 1, 0; 0.5, - 1, 0; 0, 0, 0) $

  #strong[Verification ($A A^(-) A = A$):] First, compute $A A^(-)$: $ A A^(-) = mat(delim: "(", 2, 2, 3; 1, 0, 1; 3, 2, 4) mat(delim: "(", 0, 1, 0; 0.5, - 1, 0; 0, 0, 0) = mat(delim: "(", 1, 0, 0; 0, 1, 0; 1, 1, 0) $ Then multiply by $A$: $ (A A^(-)) A = mat(delim: "(", 1, 0, 0; 0, 1, 0; 1, 1, 0) mat(delim: "(", 2, 2, 3; 1, 0, 1; 3, 2, 4) = mat(delim: "(", 2, 2, 3; 1, 0, 1; 3, 2, 4) = A $

] <exm-ginverse>
== A Procedure to Find a Generalized Inverse
<a-procedure-to-find-a-generalized-inverse>
If we can partition $X$ (possibly after permuting rows/columns) such that $R_11$ is a non-singular rank $r$ submatrix:

$ X = mat(delim: "(", R_11, R_12; R_21, R_22) $

Then a generalized inverse is:

$ X^(-) = mat(delim: "(", R_11^(- 1), 0; 0, 0) $

#strong[Verification:]

$ X X^(-) X & = mat(delim: "(", R_11, R_12; R_21, R_22) mat(delim: "(", R_11^(- 1), 0; 0, 0) mat(delim: "(", R_11, R_12; R_21, R_22)\
 & = mat(delim: "(", I_r, 0; R_21 R_11^(- 1), 0) mat(delim: "(", R_11, R_12; R_21, R_22)\
 & = mat(delim: "(", R_11, R_12; R_21, R_21 R_11^(- 1) R_12) $ Note that since rank$(X) = upright("rank") (R_11)$, the rows of $[R_21 \, R_22]$ are linear combinations of $[R_11 \, R_12]$, implying $R_22 = R_21 R_11^(- 1) R_12$. Thus, $X X^(-) X = X$.

#strong[An Algorithm for Finding a Generalized Inverse]

A systematic procedure to find a generalized inverse $A^(-)$ for any matrix $A$:

+ Find any non-singular $r times r$ submatrix $C$, where $r$ is the rank of $A$. It is not necessary for the elements of $C$ to occupy adjacent rows and columns in $A$.
+ Find $C^(- 1)$ and $(C^(- 1))'$.
+ Replace the elements of $C$ in $A$ with the elements of $(C^(- 1))'$.
+ Replace all other elements in $A$ with zeros.
+ Transpose the resulting matrix.

#strong[Matrix Visual Representation] $ mat(delim: "(", times, times.circle, times, times.circle; times, times.circle, times, times.circle; times, times, times, times)_(upright("Original ") A) arrow.r_(upright("with ") (C^(- 1))')^(upright("Replace ") C) mat(delim: "(", times, triangle.stroked.t, times, triangle.stroked.t; times, triangle.stroked.t, times, triangle.stroked.t; times, times, times, times)_(upright("Intermediate")) arrow.r_(upright("Result"))^(upright("Transpose")) mat(delim: "(", times, times, times; square.stroked.tiny, square.stroked.tiny, times; times, times, times; square.stroked.tiny, square.stroked.tiny, times)_(upright("Final ") A^(-)) $

#strong[Legend:]

- $times.circle$: Elements of submatrix $C$
- $triangle.stroked.t$: Elements of $(C^(- 1))'$
- $square.stroked.tiny$: Elements of $C^(- 1)$ (after transposition)
- $times$: Other elements (replaced by 0 in the final calculation)

== Moore-Penrose Inverse
<moore-penrose-inverse>
The Moore-Penrose inverse (denoted $X^(+)$) is a unique generalized inverse defined via Singular Value Decomposition (SVD).

If $X$ has SVD: $ X = U mat(delim: "(", Lambda_r, 0; 0, 0) V' $

Then the Moore-Penrose inverse is: $ X^(+) = V mat(delim: "(", Lambda_r^(- 1), 0; 0, 0) U' $

where $Lambda_r = upright("diag") (lambda_1 \, dots.h \, lambda_r)$ contains the singular values. Unlike standard generalized inverses, $X^(+)$ is unique.

#strong[Verification:]

We verify that $X^(+)$ satisfies the condition $X X^(+) X = X$.

+ #strong[Substitute definitions:] $ X X^(+) X = [U mat(delim: "(", Lambda_r, 0; 0, 0) V '] [V mat(delim: "(", Lambda_r^(- 1), 0; 0, 0) U '] [U mat(delim: "(", Lambda_r, 0; 0, 0) V '] $

+ #strong[Apply orthogonality:] Recall that $V' V = I$ and $U' U = I$. $ = U mat(delim: "(", Lambda_r, 0; 0, 0) underbrace((V ' V), I) mat(delim: "(", Lambda_r^(- 1), 0; 0, 0) underbrace((U ' U), I) mat(delim: "(", Lambda_r, 0; 0, 0) V' $

+ #strong[Multiply diagonal matrices:] $ = U [mat(delim: "(", Lambda_r, 0; 0, 0) mat(delim: "(", Lambda_r^(- 1), 0; 0, 0) mat(delim: "(", Lambda_r, 0; 0, 0)] V' $ Since $Lambda_r Lambda_r^(- 1) Lambda_r = I dot.op Lambda_r = Lambda_r$: $ = U mat(delim: "(", Lambda_r, 0; 0, 0) V' = X $

== Solving Linear Systems with Generalized Inverse
<solving-linear-systems-with-generalized-inverse>
We apply generalized inverses to solve systems of linear equations $X beta = c$ where $X$ is $n times p$.

#definition("Consistency and Solution")[
The system $X beta = c$ is consistent if and only if $c in upright("Col") (X)$ (the column space of $X$). If consistent, $beta = X^(-) c$ is a solution.

] <def-consistency>
#strong[Proof:] If the system is consistent, there exists some $b$ such that $X b = c$. Using the definition $X X^(-) X = X$: $ X (X^(-) c) = X (X^(-) X b) = (X X^(-) X) b = X b = c $ Thus, $X^(-) c$ is a solution. Note that the solution is not unique if $X$ is not full rank.

#example("Examples of Solutions of Linear System with Generalized Inverse")[
~

- #strong[Example 1: Underdetermined System]

  Let $X = mat(delim: "(", 1, 2, 3)$ and we want to solve $X beta = 4$.

  #strong[Solution 1:] Using the generalized inverse $X^(-) = vec(1, 0, 0)$: $ beta = X^(-) dot.op 4 = vec(1, 0, 0) 4 = vec(4, 0, 0) $ #strong[Verification:] $ X beta = mat(delim: "(", 1, 2, 3) vec(4, 0, 0) = 1 (4) + 2 (0) + 3 (0) = 4 quad checkmark $

  #strong[Solution 2:] Using another generalized inverse $X^(-) = vec(0, 0, 1 \/ 3)$: $ beta = X^(-) dot.op 4 = vec(0, 0, 1 \/ 3) 4 = vec(0, 0, 4 \/ 3) $ #strong[Verification:] $ X beta = mat(delim: "(", 1, 2, 3) vec(0, 0, 4 \/ 3) = 0 + 0 + 3 (4 \/ 3) = 4 quad checkmark $

- #strong[Example 2: Overdetermined System]

  Let $X = vec(1, 2, 3)$. Solve $X beta = vec(2, 4, 6) = c$. Here $c = 2 X$, so the system is consistent. Since $X$ is a column vector, $beta$ is a scalar.

  #strong[Solution:] Using the generalized inverse $X^(-) = mat(delim: "(", 1, 0, 0)$: $ beta = X^(-) c = mat(delim: "(", 1, 0, 0) vec(2, 4, 6) = 1 (2) + 0 (4) + 0 (6) = 2 $ #strong[Verification:] $ X beta = vec(1, 2, 3) (2) = vec(2, 4, 6) = c quad checkmark $

] <exm-gi-sol-ls>
== Least Squares for Non-full-rank $X$ with Generalized Inverse
<least-squares-for-non-full-rank-x-with-generalized-inverse>
=== Projection Matrix with Generalized Inverse of $X' X$
<projection-matrix-with-generalized-inverse-of-xx>
For the normal equations $(X ' X) beta = X' y$, a solution is given by: $ hat(beta) = (X ' X)^(-) X' y $ The fitted values are $ hat(y) = X hat(beta) = X (X ' X)^(-) X' y . $ This $hat(y)$ represents the unique orthogonal projection of $y$ onto $upright("Col") (X)$.

=== Invariance and Uniqueness of "the" Projection Matrix
<invariance-and-uniqueness-of-the-projection-matrix>
#theorem("Transpose Property of Generalized Inverses")[
$(X^(-))'$ is a version of $(X ')^(-)$. That is, $(X^(-))'$ is a generalized inverse of $X'$.

] <thm-transpose>
#block[
#emph[Proof];. By definition, a generalized inverse $X^(-)$ satisfies the property: $ X X^(-) X = X $

To verify that $(X^(-))'$ is a generalized inverse of $X'$, we need to show that it satisfies the condition $A G A = A$ where $A = X'$ and $G = (X^(-))'$.

+ Start with the fundamental definition: $ X X^(-) X = X $

+ Take the transpose of both sides of the equation: $ (X X^(-) X)' = X' $

+ Apply the reverse order law for transposes, $(A B C)' = C' B' A'$: $ X' (X^(-))' X' = X' $

Since substituting $(X^(-))'$ into the generalized inverse equation for $X'$ yields $X'$, $(X^(-))'$ is a valid generalized inverse of $X'$.

]
#lemma("Invariance of Generalized Least Squares")[
For any version of the generalized inverse $(X ' X)^(-)$, the matrix $X' (X ' X)^(-) X'$ is invariant and equals $X'$. $ X' X (X ' X)^(-) X' = X' $

] <lem-invariance>
#strong[Proof (using Projection):] Let $P = X (X ' X)^(-) X'$. This is the projection matrix onto $upright("Col") (X)$. By definition of projection, $P x = x$ for any $x in upright("Col") (X)$. Since columns of $X$ are in $upright("Col") (X)$, $P X = X$. Taking the transpose: $(P X)' = X' arrow.r.double.long X' P' = X'$. Since projection matrices are symmetric ($P = P'$), $X' P = X'$. Substituting $P$: $X' X (X ' X)^(-) X' = X'$.

#strong[Proof (Direct Matrix Manipulation):] Decompose $y = X beta + e$ where $e perp upright("Col") (X)$ (i.e., $X' e = 0$). $ X' X (X ' X)^(-) X' y & = X' X (X ' X)^(-) X' (X beta + e)\
 & = X' X (X ' X)^(-) X' X beta + X' X (X ' X)^(-) X' e $ Using the property $A A^(-) A = A$ (where $A = X' X$), the first term becomes $X' X beta$. The second term is 0 because $X' e = 0$. Thus, the expression simplifies to $X' X beta = X' (X beta) = X' hat(y)_(upright("proj"))$. This implies the operator acts as $X'$.

#theorem("Properties of Projection Matrix $P$")[
Let $P = X (X ' X)^(-) X'$. This matrix has the following properties:

+ #strong[Symmetry:] $P = P'$.

+ #strong[Idempotence:] $P^2 = P$. $ P^2 = X (X ' X)^(-) X' X (X ' X)^(-) X' = X (X ' X)^(-) (X ' X (X ' X)^(-) X ') $ Using the identity from #ref(<lem-invariance>, supplement: [Lemma]) ($X' X (X ' X)^(-) X' = X'$), this simplifies to: $ X (X ' X)^(-) X' = P $

+ #strong[Uniqueness:] $P$ is unique and invariant to the choice of the generalized inverse $(X ' X)^(-)$.

] <thm-proj-properties>
#block[
#emph[Proof];. #strong[Proof of Uniqueness:]

Let $A$ and $B$ be two different generalized inverses of $X' X$. Define $P_A = X A X'$ and $P_B = X B X'$. From #ref(<lem-invariance>, supplement: [Lemma]), we know that $X' P_A = X'$ and $X' P_B = X'$.

Subtracting these two equations: $ X' (P_A - P_B) = 0 $ Taking the transpose, we get $(P_A - P_B) X = 0$. This implies that the columns of the difference matrix $D = P_A - P_B$ are orthogonal to the columns of $X$ (i.e., $D perp upright("Col") (X)$).

However, by definition, the columns of $P_A$ and $P_B$ (and thus $D$) are linear combinations of the columns of $X$ (i.e., $D in upright("Col") (X)$).

The only matrix that lies #emph[in] the column space of $X$ but is also #emph[orthogonal] to the column space of $X$ is the zero matrix. Therefore: $ P_A - P_B = 0 arrow.r.double.long P_A = P_B $

]
== The Left Inverse View: Recovering $hat(beta)$ from $hat(y)$
<the-left-inverse-view-recovering-hatbeta-from-haty>
While the geometric properties of the linear model are most naturally established via the unique orthogonal projection $hat(y)$, we require a functional mapping---a statistical "bridge"---to translate the distribution of these fitted values back into the parameter space of $hat(beta)$. This bridge is provided by the generalized left inverse.

=== The Generalized Left Inverse
<the-generalized-left-inverse>
To recover the parameter estimates directly from the fitted values, we define the generalized left inverse, denoted as $X_(upright("left"))^(-)$, such that:

$ hat(beta) = X_(upright("left"))^(-) hat(y) $

A standard choice for this operator, derived from the normal equations, is:

$ X_(upright("left"))^(-) = (X ' X)^(-) X' $

When $X$ is full-rank, the $X_(upright("left"))^(-)$ is unique, which is given by

$ X_(upright("left"))^(-) = (X ' X)^(- 1) X' $

=== Verification of the Inverse Property
<verification-of-the-inverse-property>
To verify that $X_(upright("left"))^(-)$ acts as a valid generalized inverse of $X$, it must satisfy the condition $X X_(upright("left"))^(-) X = X$. Substituting our definition:

$ X underbrace([(X ' X)^(-) X '], X_(upright("left"))^(-)) X = X (X ' X)^(-) (X ' X) $

Using the property of generalized inverses for symmetric matrices where $(X ' X) (X ' X)^(-) X' = X'$, the transpose of this identity gives $X (X ' X)^(-) (X ' X) = X$. Thus, the condition holds:

$ X X_(upright("left"))^(-) X = X $

=== Recovering the Estimator
<recovering-the-estimator>
We can now demonstrate that applying this left inverse to the fitted values $hat(y)$ yields the standard solution to the normal equations.

Substituting the projection formula $hat(y) = X (X ' X)^(-) X' y$:

$ X_(upright("left"))^(-) hat(y) & = [(X ' X)^(-) X '] [X (X ' X)^(-) X ' y]\
 & = (X ' X)^(-) underbrace((X ' X) (X ' X)^(-) (X ' X), upright("Property ") A A^(-) A = A) (X ' X)^(-) X' y $

Simplifying using the generalized inverse property $A^(-) A A^(-) = A^(-)$ (where $A = X' X$):

$ X_(upright("left"))^(-) hat(y) & = underbrace((X ' X)^(-) (X ' X) (X ' X)^(-), (X ' X)^(-)) X' y\
 & = (X ' X)^(-) X' y $

Thus, we recover the standard estimator used in the normal equations:

$ upright(bold(hat(beta) = (X ' X)^(-) X' y)) $

== Non-full-rank Least Squares with QR Decomposition
<non-full-rank-least-squares-with-qr-decomposition>
When $X$ has rank $r < p$ (where $X$ is $n times p$), we can derive the least squares estimator using partitioned matrices.

Assume the first $r$ columns of $X$ are linearly independent. We can partition $X$ as: $ X = Q (R_1 \, R_2) $ where $Q$ is an $n times r$ matrix with orthogonal columns ($Q' Q = I_r$), $R_1$ is an $r times r$ non-singular matrix, and $R_2$ is $r times (p - r)$.

The normal equations are: $ X' X beta = X' y arrow.r.double.long vec(R_1', R_2') Q' Q (R_1 \, R_2) beta = vec(R_1', R_2') Q' y $ Simplifying ($Q' Q = I_r$): $ mat(delim: "(", R_1' R_1, R_1' R_2; R_2' R_1, R_2' R_2) beta = vec(R_1' Q' y, R_2' Q' y) $

=== Constructing a Solution by Solving Normal Equations
<constructing-a-solution-by-solving-normal-equations>
One specific generalized inverse of $X' X$ can be found by focusing on the non-singular block $R_1' R_1$: $ (X ' X)^(-) = mat(delim: "(", (R_1 ' R_1)^(- 1), 0; 0, 0) $

Using this generalized inverse, the estimator $hat(beta)$ becomes: $ hat(beta) = (X ' X)^(-) X' y = mat(delim: "(", (R_1 ' R_1)^(- 1), 0; 0, 0) vec(R_1' Q' y, R_2' Q' y) $ $ hat(beta) = vec((R_1 ' R_1)^(- 1) R_1' Q' y, 0) = vec(R_1^(- 1) Q' y, 0) $

The fitted values are: $ hat(y) = X hat(beta) = Q (R_1 \, R_2) vec(R_1^(- 1) Q' y, 0) = Q R_1 R_1^(- 1) Q' y = Q Q' y $ This confirms that $hat(y)$ is the projection of $y$ onto the column space of $Q$ (which is the same as the column space of $X$).

=== Constructing a Solution by Solving Reparametrized $beta$
<constructing-a-solution-by-solving-reparametrized-beta>
We can view the model as: $ y = Q (R_1 \, R_2) beta + epsilon.alt = Q b + epsilon.alt $ where $b = R_1 beta_1 + R_2 beta_2$.

Since the columns of $Q$ are orthogonal, the least squares estimate for $b$ is simply: $ hat(b) = (Q ' Q)^(- 1) Q' y = Q' y $

To find $beta$, we solve the underdetermined system: $ R_1 beta_1 + R_2 beta_2 = hat(b) = Q' y $

#strong[Solution 1:] Set $beta_2 = 0$. Then: $ R_1 beta_1 = Q' y arrow.r.double.long hat(beta)_1 = R_1^(- 1) Q' y $ This yields the same result as the generalized inverse method above: $hat(beta) = vec(R_1^(- 1) Q' y, 0)$.

#strong[Solution 2:] Using the generalized inverse of $R = (R_1 \, R_2)$: $ R^(-) = vec(R_1^(- 1), 0) $ $ hat(beta) = R^(-) Q' y = vec(R_1^(- 1) Q' y, 0) $ This demonstrates that finding a solution to the normal equations using $(X ' X)^(-)$ is equivalent to solving the reparameterized system $b = R beta$.
