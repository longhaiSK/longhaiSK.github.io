---
title: "Research Activities of Prof. Longhai Li"
engine: knitr
format: profweb-html
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

 

## Funded Research Projects

Many granting agencies including NSERC, CFI, CANSSI, CFREF, and MITACS have supported his research; see [**his research funding history**](./CV_LLI.html#17-research-funding-history).

## Past and Current Team Members 

::: {.btn-grid}

[![](images/icons/stack.svg)<span>Post-doctoral Fellows</span>](./CV_LLI.html#10-4-supervision-of-post-doctoral-fellows-and-research-associates)

[![](images/icons/mortarboard-fill.svg)<span>Graduate Students</span>](./CV_LLI.html#10-2-graduate-student-supervision)

[![](images/icons/book-half.svg)<span>Undergraduate Students</span>](./CV_LLI.html#10-1-undergraduate-student-supervision)

:::

## Publications

::: {.btn-grid}

[![](images/icons/journal-text.svg)<span>Papers in Refereed Journals</span>](./CV_LLI.html#12-papers-in-refereed-journals)

[![](images/icons/code-square.svg)<span>Software Released Publicly</span>](./CV_LLI.html#15-1-software-released-publicly)

[![](images/icons/globe.svg)<span>Apps and Websites</span>](./CV_LLI.html#15-3-online-apps)

[![](images/icons/file-earmark-richtext.svg)<span>Refereed Conference Publications</span>](./CV_LLI.html#13-refereed-conference-publications)

[![](images/icons/easel.svg)<span>Presentations</span>](./CV_LLI.html#14-presentations)

[![](images/icons/file-earmark-text.svg)<span>Preprints</span>](./CV_LLI.html#15-2-technical-reports)

:::
