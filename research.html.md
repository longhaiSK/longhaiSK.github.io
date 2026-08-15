---
title: "Research Activities of Prof. Longhai Li"
engine: knitr
format: html
metadata-files:
  - _website.yaml
---



```{=typst}
// ====================================================================
// TYPST RULES FOR REVERSE LISTS 
// ====================================================================
#show figure: set block(breakable: true)

// 1. Global spacing and indents
#set enum(indent: 1em, body-indent: 0.75em)
#set list(indent: 2em, body-indent: 0.75em)

// 2. Nested bullet list rule
#show list: it => { 
  set list(indent: 1em)
  it 
}

// 3. The Numbering Enforcer (with recursion safety)
#show enum: it => { 
  set list(indent: 1em)
  
  // If it already has the right numbering, return it as-is to break the loop
  if it.numbering == "[1]" {
    it
  } else {
    // Otherwise, rebuild the list to strip Pandoc's formatting
    enum(
      numbering: "[1]",
      start: it.start,    // Keeps your reverse number
      ..it.children       // Keeps all the actual items and sublists
    )
  }
}
```


## Overview

Prof. Li develops computationally intensive tools for bioinformatics and epidemiology to solve complex health science problems. His focus on Predictive Methods for Model Validation bridges a critical gap by providing novel residual diagnostic tools to evaluate intricate Bayesian and non-Bayesian structures for highly correlated data. Additionally, his work in Statistical Machine Learning improves phenotype modeling by designing robust methods to accurately identify and measure truly predictive features. Ultimately, he applies these advanced computational techniques to uncover the underlying molecular mechanisms driving complex conditions like Alzheimer’s and Parkinson’s diseases. 

## Funded Research Projects

Many granting agencies including NSERC, CFI, CANSSI, CFREF, and MITACS have supported his research; see [**his research funding history**](./longhailiCV-2026.html#17-research-funding-history).

## Past and Current Team Members 

* [**Post-doctoral Fellows**](./longhailiCV-2026.html#10-4-supervision-of-post-doctoral-fellows-and-research-associates)
* [**Graduate Students**](./longhailiCV-2026.html#10-2-graduate-student-supervision)
* [**Undergraduate Students**](./longhailiCV-2026.html#10-1-undergraduate-student-supervision)

## Publications

* [**Papers in refereed Journals**](./longhailiCV-2026.html#12-papers-in-refereed-journals)
* [**Software Released Publicly**](./longhailiCV-2026.html#15-1-software-released-publicly)
* [**Online Apps/Websites**](./longhailiCV-2026.html#15-3-online-apps)
* [**Refereed Conference Publications**](./longhailiCV-2026.html#13-refereed-conference-publications)
* [**Presentations**](./longhailiCV-2026.html#14-presentations)
* [**Preprints**](./longhailiCV-2026.html#15-2-technical-reports)

<footer>
Last updated on August 14, 2026.
</footer>