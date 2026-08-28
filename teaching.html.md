---
title: "Teaching Activities of Prof. Longhai Li"
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


## Overview

Prof. Li’s teaching integrates cutting-edge computational data science tools with practical real-world applications. He trains students in modern programming languages and reproducible reporting frameworks, utilizing dynamic simulations to make complex statistical theorems accessible. Additionally, he extends learning beyond the classroom by actively involving undergraduate students in hands-on research projects and the development of open-source statistical software.

## Textbooks

 



<!-- -->

3. [**Theory of Statistical Inference**](https://longhaisk.github.io/mathstat/); [**[PDF]**](https://longhaisk.github.io/mathstat/mathstat-LLI.pdf)


<!-- -->

2. [**Theory of Linear Models**](https://longhaisk.github.io/theorylm/); [**[PDF]**](https://longhaisk.github.io/theorylm/stat_lin_theory.pdf)


<!-- -->

1. [**Statistical Inference and Learning Methods for Research**](https://longhaisk.github.io/statmethods/); [**[PDF]**](https://longhaisk.github.io/statmethods/stat_inference_learning.pdf)

## Materials of Selected Courses

 



<!-- -->

8. [STAT 245: Introduction to Statistical Methods](teaching/stat245/)


<!-- -->

7. [STAT 342: Mathematical Statistics](teaching/stat342/)


<!-- -->

6. [STAT 345/834: Design and Analysis of Experiments](teaching/stat345/)


<!-- -->

5. [STAT 348: Sampling Techniques](teaching/stat348/)


<!-- -->

4. [STAT 812/420: Computational Statistics](teaching/stat812/)


<!-- -->

3. [STAT 845: Statistical Methods for Research](teaching/stat845/)


<!-- -->

2. [STAT 850/442: Mathematical Statistics and Statistical Inference](teaching/stat850/)


<!-- -->

1. [STAT 851/443: Linear Statistical Models](teaching/stat851/)

## List of Taught Courses


::: {.cell}
::: {.cell-output-display}

```{=html}
<div id="rczvnxtjcd" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#rczvnxtjcd table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#rczvnxtjcd thead, #rczvnxtjcd tbody, #rczvnxtjcd tfoot, #rczvnxtjcd tr, #rczvnxtjcd td, #rczvnxtjcd th {
  border-style: none;
}

#rczvnxtjcd p {
  margin: 0;
  padding: 0;
}

#rczvnxtjcd .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: 100%;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#rczvnxtjcd .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#rczvnxtjcd .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#rczvnxtjcd .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#rczvnxtjcd .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#rczvnxtjcd .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rczvnxtjcd .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#rczvnxtjcd .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: bold;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#rczvnxtjcd .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: bold;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#rczvnxtjcd .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#rczvnxtjcd .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#rczvnxtjcd .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#rczvnxtjcd .gt_spanner_row {
  border-bottom-style: hidden;
}

#rczvnxtjcd .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#rczvnxtjcd .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#rczvnxtjcd .gt_from_md > :first-child {
  margin-top: 0;
}

#rczvnxtjcd .gt_from_md > :last-child {
  margin-bottom: 0;
}

#rczvnxtjcd .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#rczvnxtjcd .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#rczvnxtjcd .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#rczvnxtjcd .gt_row_group_first td {
  border-top-width: 2px;
}

#rczvnxtjcd .gt_row_group_first th {
  border-top-width: 2px;
}

#rczvnxtjcd .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rczvnxtjcd .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#rczvnxtjcd .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#rczvnxtjcd .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rczvnxtjcd .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rczvnxtjcd .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#rczvnxtjcd .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#rczvnxtjcd .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#rczvnxtjcd .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rczvnxtjcd .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#rczvnxtjcd .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#rczvnxtjcd .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#rczvnxtjcd .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#rczvnxtjcd .gt_left {
  text-align: left;
}

#rczvnxtjcd .gt_center {
  text-align: center;
}

#rczvnxtjcd .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#rczvnxtjcd .gt_font_normal {
  font-weight: normal;
}

#rczvnxtjcd .gt_font_bold {
  font-weight: bold;
}

#rczvnxtjcd .gt_font_italic {
  font-style: italic;
}

#rczvnxtjcd .gt_super {
  font-size: 65%;
}

#rczvnxtjcd .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#rczvnxtjcd .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#rczvnxtjcd .gt_indent_1 {
  text-indent: 5px;
}

#rczvnxtjcd .gt_indent_2 {
  text-indent: 10px;
}

#rczvnxtjcd .gt_indent_3 {
  text-indent: 15px;
}

#rczvnxtjcd .gt_indent_4 {
  text-indent: 20px;
}

#rczvnxtjcd .gt_indent_5 {
  text-indent: 25px;
}

#rczvnxtjcd .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#rczvnxtjcd div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Applied_Stat">Applied Statistics</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Stat_Theory_Algorithms">Statistical Theory and Algorithms</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Applied_Stat" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgMjQ0OiBFbGVtZW50YXJ5IFN0YXRpc3RpY2FsIENvbmNlcHRzXShodHRwczovL2NhdGFsb2d1ZS51c2Fzay5jYS9TVEFULTI0NCk="><span class='gt_from_md'><a href="https://catalogue.usask.ca/STAT-244">STAT 244: Elementary Statistical Concepts</a></span></span></td>
<td headers="Stat_Theory_Algorithms" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgMjQxOiBQcm9iYWJpbGl0eSBUaGVvcnldKGh0dHBzOi8vY2F0YWxvZ3VlLnVzYXNrLmNhL1NUQVQtMjQxKQ=="><span class='gt_from_md'><a href="https://catalogue.usask.ca/STAT-241">STAT 241: Probability Theory</a></span></span></td></tr>
    <tr><td headers="Applied_Stat" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgMjQ1OiBJbnRyb2R1Y3Rpb24gdG8gU3RhdGlzdGljYWwgTWV0aG9kc10odGVhY2hpbmcvc3RhdDI0NS8p"><span class='gt_from_md'><a href="teaching/stat245/">STAT 245: Introduction to Statistical Methods</a></span></span></td>
<td headers="Stat_Theory_Algorithms" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgMjQyOiBTdGF0aXN0aWNhbCBUaGVvcnkgYW5kIE1ldGhvZG9sb2d5XShodHRwczovL2NhdGFsb2d1ZS51c2Fzay5jYS9TVEFULTI0Mik="><span class='gt_from_md'><a href="https://catalogue.usask.ca/STAT-242">STAT 242: Statistical Theory and Methodology</a></span></span></td></tr>
    <tr><td headers="Applied_Stat" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgMzQ1OiBEZXNpZ24gYW5kIEFuYWx5c2lzIG9mIEV4cGVyaW1lbnRzXSh0ZWFjaGluZy9zdGF0MzQ1Lyk="><span class='gt_from_md'><a href="teaching/stat345/">STAT 345: Design and Analysis of Experiments</a></span></span></td>
<td headers="Stat_Theory_Algorithms" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgMzQyOiBQcm9iYWJpbGl0eSBhbmQgTWF0aGVtYXRpY2FsIFN0YXRpc3RpY3NdKHRlYWNoaW5nL3N0YXQzNDIvKQ=="><span class='gt_from_md'><a href="teaching/stat342/">STAT 342: Probability and Mathematical Statistics</a></span></span></td></tr>
    <tr><td headers="Applied_Stat" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgMzQ4OiBTYW1wbGluZyBUZWNobmlxdWVzXSh0ZWFjaGluZy9zdGF0MzQ4Lyk="><span class='gt_from_md'><a href="teaching/stat348/">STAT 348: Sampling Techniques</a></span></span></td>
<td headers="Stat_Theory_Algorithms" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgNDQyLzg1MDogU3RhdGlzdGljYWwgSW5mZXJlbmNlXSh0ZWFjaGluZy9zdGF0ODUwLyk="><span class='gt_from_md'><a href="teaching/stat850/">STAT 442/850: Statistical Inference</a></span></span></td></tr>
    <tr><td headers="Applied_Stat" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgODM0OiBBZHZhbmNlZCBFeHBlcmltZW50YWwgRGVzaWduXSh0ZWFjaGluZy9zdGF0MzQ1Lyk="><span class='gt_from_md'><a href="teaching/stat345/">STAT 834: Advanced Experimental Design</a></span></span></td>
<td headers="Stat_Theory_Algorithms" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgNDQzLzg1MTogTGluZWFyIFN0YXRpc3RpY2FsIE1vZGVsc10odGVhY2hpbmcvc3RhdDg1MS8p"><span class='gt_from_md'><a href="teaching/stat851/">STAT 443/851: Linear Statistical Models</a></span></span></td></tr>
    <tr><td headers="Applied_Stat" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgODQ1OiBTdGF0aXN0aWNhbCBNZXRob2RzIGZvciBSZXNlYXJjaF0odGVhY2hpbmcvc3RhdDg0NS8p"><span class='gt_from_md'><a href="teaching/stat845/">STAT 845: Statistical Methods for Research</a></span></span></td>
<td headers="Stat_Theory_Algorithms" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgNDIwLzgxMjogQ29tcHV0YXRpb25hbCBTdGF0aXN0aWNzXSh0ZWFjaGluZy9zdGF0ODEyLyk="><span class='gt_from_md'><a href="teaching/stat812/">STAT 420/812: Computational Statistics</a></span></span></td></tr>
    <tr><td headers="Applied_Stat" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgODQ4OiBNdWx0aXZhcmlhdGUgRGF0YSBBbmFseXNpc10oaHR0cHM6Ly9jYXRhbG9ndWUudXNhc2suY2EvU1RBVC04NDgp"><span class='gt_from_md'><a href="https://catalogue.usask.ca/STAT-848">STAT 848: Multivariate Data Analysis</a></span></span></td>
<td headers="Stat_Theory_Algorithms" class="gt_row gt_left"><span data-qmd-base64="W1NUQVQgODQxOiBQcm9iYWJpbGl0eSBUaGVvcnldKGh0dHBzOi8vY2F0YWxvZ3VlLnVzYXNrLmNhLzIwMjAwMy9TVEFULTg0MSk="><span class='gt_from_md'><a href="https://catalogue.usask.ca/202003/STAT-841">STAT 841: Probability Theory</a></span></span></td></tr>
  </tbody>
  
</table>
</div>
```

:::
:::


