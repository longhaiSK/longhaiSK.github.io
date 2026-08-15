---
title: "STAT 443/851 Theory of Linear Models (University of Saskatchewan, 2026-01)"
engine: knitr
format: profweb-html
---
<!-- ```{r setup, include=FALSE}
library(knitr)
# This tells knitr to use webshot2 to take a screenshot of HTML widgets
options(knitr.table.format = "typst") 
opts_chunk$set(screenshot.force = FALSE)
``` -->

## Description
This course is a rigorous examination of the general linear models using vector space theory, in particular the approach of regarding least square as projection. The topics includes: vector space; projection; matrix algebra; generalized inverses;  quadratic forms; theory for point estimation; theory for hypothesis test; theory for non-full-rank models. 

**Prerequisite(s):** MATH 164 (formerly MATH 264) or MATH 266, STAT 342, and STAT 344 or 345.

## Instructor
[Longhai Li](https://longhaisk.github.io/), Professor, <br>
Department of Mathematics and Statistics, University of Saskatchewan<br>
Email: longhai.li@usask.ca.

## Times and Places
Lecture Classroom: MCLN 242.1, MWF 9:30-10:20; Office hour: TBA; Lab: no lab.


## Course Materials

* See [the course page](.), which is the primary source for learning.
* Recommended reading: LINEAR MODELS IN STATISTICS, Second Edition, by Alvin C. Rencher and G. Bruce Schaalje, ISBN 978-0-471-75498-5 (cloth). *The book is not required but it is good to have it.*

## Learning Outcomes 

After completing this course, students are expected to grasp the following knowledges and skills:


::: {.cell}
::: {.cell-output .cell-output-stderr}

```
Warning: package 'gt' was built under R version 4.5.2
```


:::

::: {.cell-output .cell-output-stderr}

```
Warning: package 'dplyr' was built under R version 4.5.2
```


:::

::: {.cell-output-display}

```{=html}
<div id="qlpajvrmdx" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#qlpajvrmdx table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#qlpajvrmdx thead, #qlpajvrmdx tbody, #qlpajvrmdx tfoot, #qlpajvrmdx tr, #qlpajvrmdx td, #qlpajvrmdx th {
  border-style: none;
}

#qlpajvrmdx p {
  margin: 0;
  padding: 0;
}

#qlpajvrmdx .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 14px;
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

#qlpajvrmdx .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#qlpajvrmdx .gt_title {
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

#qlpajvrmdx .gt_subtitle {
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

#qlpajvrmdx .gt_heading {
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

#qlpajvrmdx .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qlpajvrmdx .gt_col_headings {
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

#qlpajvrmdx .gt_col_heading {
  color: #333333;
  background-color: #E0E0E0;
  font-size: 100%;
  font-weight: normal;
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

#qlpajvrmdx .gt_column_spanner_outer {
  color: #333333;
  background-color: #E0E0E0;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#qlpajvrmdx .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#qlpajvrmdx .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#qlpajvrmdx .gt_column_spanner {
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

#qlpajvrmdx .gt_spanner_row {
  border-bottom-style: hidden;
}

#qlpajvrmdx .gt_group_heading {
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

#qlpajvrmdx .gt_empty_group_heading {
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

#qlpajvrmdx .gt_from_md > :first-child {
  margin-top: 0;
}

#qlpajvrmdx .gt_from_md > :last-child {
  margin-bottom: 0;
}

#qlpajvrmdx .gt_row {
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

#qlpajvrmdx .gt_stub {
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

#qlpajvrmdx .gt_stub_row_group {
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

#qlpajvrmdx .gt_row_group_first td {
  border-top-width: 2px;
}

#qlpajvrmdx .gt_row_group_first th {
  border-top-width: 2px;
}

#qlpajvrmdx .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#qlpajvrmdx .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#qlpajvrmdx .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#qlpajvrmdx .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qlpajvrmdx .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#qlpajvrmdx .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#qlpajvrmdx .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#qlpajvrmdx .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#qlpajvrmdx .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qlpajvrmdx .gt_footnotes {
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

#qlpajvrmdx .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#qlpajvrmdx .gt_sourcenotes {
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

#qlpajvrmdx .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#qlpajvrmdx .gt_left {
  text-align: left;
}

#qlpajvrmdx .gt_center {
  text-align: center;
}

#qlpajvrmdx .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#qlpajvrmdx .gt_font_normal {
  font-weight: normal;
}

#qlpajvrmdx .gt_font_bold {
  font-weight: bold;
}

#qlpajvrmdx .gt_font_italic {
  font-style: italic;
}

#qlpajvrmdx .gt_super {
  font-size: 65%;
}

#qlpajvrmdx .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#qlpajvrmdx .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#qlpajvrmdx .gt_indent_1 {
  text-indent: 5px;
}

#qlpajvrmdx .gt_indent_2 {
  text-indent: 10px;
}

#qlpajvrmdx .gt_indent_3 {
  text-indent: 15px;
}

#qlpajvrmdx .gt_indent_4 {
  text-indent: 20px;
}

#qlpajvrmdx .gt_indent_5 {
  text-indent: 25px;
}

#qlpajvrmdx .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#qlpajvrmdx div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" style="table-layout:fixed;width:100%;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <colgroup>
    <col style="width:30%;"/>
    <col style="width:60%;"/>
    <col style="width:10%;"/>
  </colgroup>
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Topic">Topic</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Competencies">Learning Outcomes (Knowledge &amp; Skills)</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Percentages">Perc</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Vector Spaces</td>
<td headers="Competencies" class="gt_row gt_left"><span data-qmd-base64="PGI+VW5kZXJzdGFuZGluZzwvYj4gdGhlIGdlb21ldHJpYyBpbnRlcnByZXRhdGlvbiBvZiBzdWJzcGFjZXMsIG9ydGhvZ29uYWwgcHJvamVjdGlvbnMgd2l0aCB0aGUgSGF0IG1hdHJpeCAoSCkgYW5kIHRoZSBQYXJ0aWFsIFJlc2lkdWFsIG1hdHJpeC4gPGI+TnVtZXJpY2FsbHkgYW5kIHN5bWJvbGljYWxseSBjYWxjdWxhdGluZzwvYj4gb3J0aG9nb25hbCBwcm9qZWN0aW9ucyBvbnRvIHRoZXNlIHNwYWNlcyB1c2luZyB2YXJpb3VzIGFwcHJvYWNoZXM="><span class='gt_from_md'><b>Understanding</b> the geometric interpretation of subspaces, orthogonal projections with the Hat matrix (H) and the Partial Residual matrix. <b>Numerically and symbolically calculating</b> orthogonal projections onto these spaces using various approaches</span></span></td>
<td headers="Percentages" class="gt_row gt_left">15%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Matrix Algebra</td>
<td headers="Competencies" class="gt_row gt_left"><span data-qmd-base64="PGI+VW5kZXJzdGFuZGluZzwvYj4gYWR2YW5jZWQgbWF0cml4IHRoZW9yeSwgaW5jbHVkaW5nIHNwZWN0cmFsIGRlY29tcG9zaXRpb24gYW5kIGlkZW1wb3RlbnQgcHJvcGVydGllcy4gPGI+RGVyaXZpbmc8L2I+IHByb3BlcnRpZXMgb2YgcHJvamVjdGlvbiBtYXRyaWNlcywgPGI+c3ltYm9saWNhbGx5PC9iPiBtYW5pcHVsYXRpbmcgbWF0cmljZXMsIGluY2x1ZGluZyAgPGI+Y2FsY3VsYXRpbmc8L2I+IGdlbmVyYWxpemVkIGludmVyc2VzLg=="><span class='gt_from_md'><b>Understanding</b> advanced matrix theory, including spectral decomposition and idempotent properties. <b>Deriving</b> properties of projection matrices, <b>symbolically</b> manipulating matrices, including  <b>calculating</b> generalized inverses.</span></span></td>
<td headers="Percentages" class="gt_row gt_left">10%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Multivariate Normal</td>
<td headers="Competencies" class="gt_row gt_left"><span data-qmd-base64="PGI+VW5kZXJzdGFuZGluZzwvYj4gdGhlIHByb3BlcnRpZXMgb2YgbXVsdGl2YXJpYXRlIG5vcm1hbCB2ZWN0b3JzIGFuZCBtdWx0aXBsZSBjb3JyZWxhdGlvbiBjb2VmZmljaWVudHMuIDxiPkRlcml2aW5nPC9iPiB0aGUgbWVhbiBhbmQgY292YXJpYW5jZSBvZiB0cmFuc2Zvcm1lZCBub3JtYWwgdmVjdG9ycyBhbmQgPGI+Y2FsY3VsYXRpbmc8L2I+IGNvbmRpdGlvbmFsIGFuZCBtYXJnaW5hbCBkaXN0cmlidXRpb24gb2YgTVZOLg=="><span class='gt_from_md'><b>Understanding</b> the properties of multivariate normal vectors and multiple correlation coefficients. <b>Deriving</b> the mean and covariance of transformed normal vectors and <b>calculating</b> conditional and marginal distribution of MVN.</span></span></td>
<td headers="Percentages" class="gt_row gt_left">10%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Quadratic Forms</td>
<td headers="Competencies" class="gt_row gt_left"><span data-qmd-base64="PGI+VW5kZXJzdGFuZGluZzwvYj4gdGhlIGRpc3RyaWJ1dGlvbnMgb2YgcXVhZHJhdGljIGZvcm1zLiA8Yj5WZXJpZnlpbmc8L2I+IHRoZSBpbmRlcGVuZGVuY2Ugb2YgcXVhZHJhdGljIGZvcm1zIGFuZCA8Yj5hcHBseWluZzwvYj4gQ29jaHJhbidzIFRoZW9yZW0gdG8gZGVyaXZlIHRoZSBkaXN0cmlidXRpb25zIGFuZCBkZWdyZWVzIG9mIGZyZWVkb20gZm9yIHN1bXMgb2Ygc3F1YXJlcy4="><span class='gt_from_md'><b>Understanding</b> the distributions of quadratic forms. <b>Verifying</b> the independence of quadratic forms and <b>applying</b> Cochran’s Theorem to derive the distributions and degrees of freedom for sums of squares.</span></span></td>
<td headers="Percentages" class="gt_row gt_left">10%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Multiple Regression</td>
<td headers="Competencies" class="gt_row gt_left"><span data-qmd-base64="PGI+VW5kZXJzdGFuZGluZzwvYj4gdGhlIGdlbmVyYWwgbGluZWFyIGh5cG90aGVzaXMgYW5kIHRoZSByZWxhdGlvbnNoaXAgYmV0d2VlbiBSU1MsIFNTSCwgYW5kIFNTRS4gPGI+Q2FsY3VsYXRpbmc8L2I+IExTIGVzdGltYXRvcnMsIGVycm9yIHZhcmlhbmNlLCBhbmQgYWRqdXN0ZWQgJFJeMiQgd2l0aCBDSS4gPGI+SW1wbGVtZW50aW5nPC9iPiBGLXRlc3RzIGFuZCB0LXRlc3RzOyA8Yj5jb25zdHJ1Y3Rpbmc8L2I+IGNvbmZpZGVuY2UvcHJlZGljdGlvbiByZWdpb25zOyBhbmQgPGI+c3ltYm9saWNhbGx5IGRlcml2aW5nPC9iPiBTU0gsIFNTRSwgYW5kIHRoZSBGLWRpc3RyaWJ1dGlvbi4="><span class='gt_from_md'><b>Understanding</b> the general linear hypothesis and the relationship between RSS, SSH, and SSE. <b>Calculating</b> LS estimators, error variance, and adjusted \(R^2\) with CI. <b>Implementing</b> F-tests and t-tests; <b>constructing</b> confidence/prediction regions; and <b>symbolically deriving</b> SSH, SSE, and the F-distribution.</span></span></td>
<td headers="Percentages" class="gt_row gt_left">40%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Non-full-rank Models</td>
<td headers="Competencies" class="gt_row gt_left"><span data-qmd-base64="PGI+VW5kZXJzdGFuZGluZzwvYj4gaWRlbnRpZmlhYmlsaXR5IGFuZCBlc3RpbWFibGUgZnVuY3Rpb25zIGluIG92ZXItcGFyYW1ldGVyaXplZCBtb2RlbHMuIDxiPklkZW50aWZ5aW5nPC9iPiBlc3RpbWFibGUgbGluZWFyIGNvbWJpbmF0aW9ucyBhbmQgPGI+Y29uZHVjdGluZzwvYj4gaHlwb3RoZXNpcyB0ZXN0cyBhbmQgZXN0aW1hdGlvbiBmb3Igbm9uLWZ1bGwgcmFuayBsaW5lYXIgbW9kZWxz"><span class='gt_from_md'><b>Understanding</b> identifiability and estimable functions in over-parameterized models. <b>Identifying</b> estimable linear combinations and <b>conducting</b> hypothesis tests and estimation for non-full rank linear models</span></span></td>
<td headers="Percentages" class="gt_row gt_left">15%</td></tr>
  </tbody>
  
</table>
</div>
```

:::
:::


## Tentative Schedule

::: {.cell}
::: {.cell-output-display}

```{=html}
<div id="uslblpqhcm" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#uslblpqhcm table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#uslblpqhcm thead, #uslblpqhcm tbody, #uslblpqhcm tfoot, #uslblpqhcm tr, #uslblpqhcm td, #uslblpqhcm th {
  border-style: none;
}

#uslblpqhcm p {
  margin: 0;
  padding: 0;
}

#uslblpqhcm .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 14px;
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

#uslblpqhcm .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#uslblpqhcm .gt_title {
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

#uslblpqhcm .gt_subtitle {
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

#uslblpqhcm .gt_heading {
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

#uslblpqhcm .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#uslblpqhcm .gt_col_headings {
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

#uslblpqhcm .gt_col_heading {
  color: #333333;
  background-color: #E0E0E0;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: solid;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: solid;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#uslblpqhcm .gt_column_spanner_outer {
  color: #333333;
  background-color: #E0E0E0;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#uslblpqhcm .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#uslblpqhcm .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#uslblpqhcm .gt_column_spanner {
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

#uslblpqhcm .gt_spanner_row {
  border-bottom-style: hidden;
}

#uslblpqhcm .gt_group_heading {
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

#uslblpqhcm .gt_empty_group_heading {
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

#uslblpqhcm .gt_from_md > :first-child {
  margin-top: 0;
}

#uslblpqhcm .gt_from_md > :last-child {
  margin-bottom: 0;
}

#uslblpqhcm .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: solid;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: solid;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#uslblpqhcm .gt_stub {
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

#uslblpqhcm .gt_stub_row_group {
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

#uslblpqhcm .gt_row_group_first td {
  border-top-width: 2px;
}

#uslblpqhcm .gt_row_group_first th {
  border-top-width: 2px;
}

#uslblpqhcm .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#uslblpqhcm .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#uslblpqhcm .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#uslblpqhcm .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#uslblpqhcm .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#uslblpqhcm .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#uslblpqhcm .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#uslblpqhcm .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#uslblpqhcm .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#uslblpqhcm .gt_footnotes {
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

#uslblpqhcm .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#uslblpqhcm .gt_sourcenotes {
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

#uslblpqhcm .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#uslblpqhcm .gt_left {
  text-align: left;
}

#uslblpqhcm .gt_center {
  text-align: center;
}

#uslblpqhcm .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#uslblpqhcm .gt_font_normal {
  font-weight: normal;
}

#uslblpqhcm .gt_font_bold {
  font-weight: bold;
}

#uslblpqhcm .gt_font_italic {
  font-style: italic;
}

#uslblpqhcm .gt_super {
  font-size: 65%;
}

#uslblpqhcm .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#uslblpqhcm .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#uslblpqhcm .gt_indent_1 {
  text-indent: 5px;
}

#uslblpqhcm .gt_indent_2 {
  text-indent: 10px;
}

#uslblpqhcm .gt_indent_3 {
  text-indent: 15px;
}

#uslblpqhcm .gt_indent_4 {
  text-indent: 20px;
}

#uslblpqhcm .gt_indent_5 {
  text-indent: 25px;
}

#uslblpqhcm .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#uslblpqhcm div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" style="table-layout:fixed;width:100%;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <colgroup>
    <col style="width:12%;"/>
    <col style="width:8%;"/>
    <col style="width:45%;"/>
    <col style="width:35%;"/>
  </colgroup>
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Date">Date (Mon)</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Acad_Week">Week</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Topic">Lecture Topic</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Remarks">Tests &amp; Notes</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Date" class="gt_row gt_left">Jan 05</td>
<td headers="Acad_Week" class="gt_row gt_center">1</td>
<td headers="Topic" class="gt_row gt_left">1. Vector Space and Projection</td>
<td headers="Remarks" class="gt_row gt_left"><span data-qmd-base64="SmFuIDA3OiBGaXJzdCBkYXkgb2YgY2xhc3M="><span class='gt_from_md'>Jan 07: First day of class</span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Jan 12</td>
<td headers="Acad_Week" class="gt_row gt_center">2</td>
<td headers="Topic" class="gt_row gt_left">1. Vector Space and Projection </td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Jan 19</td>
<td headers="Acad_Week" class="gt_row gt_center">3</td>
<td headers="Topic" class="gt_row gt_left">2. Matrix Algebra</td>
<td headers="Remarks" class="gt_row gt_left"><span data-qmd-base64="PGI+SmFuIDI1OiBBc3NpZ25tZW50IDEgZHVlPC9iPg=="><span class='gt_from_md'><b>Jan 25: Assignment 1 due</b></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Jan 26</td>
<td headers="Acad_Week" class="gt_row gt_center">4</td>
<td headers="Topic" class="gt_row gt_left">2. Matrix Algebra </td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Feb 02</td>
<td headers="Acad_Week" class="gt_row gt_center">5</td>
<td headers="Topic" class="gt_row gt_left">3. Distribution of Multivariate Normal</td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Feb 09</td>
<td headers="Acad_Week" class="gt_row gt_center">6</td>
<td headers="Topic" class="gt_row gt_left">4. Distribution of Quadratic Forms</td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left" style="background-color: #D1E7DD; font-weight: bold;">Feb 16</td>
<td headers="Acad_Week" class="gt_row gt_center" style="background-color: #D1E7DD; font-weight: bold;">N/A</td>
<td headers="Topic" class="gt_row gt_left" style="background-color: #D1E7DD; font-weight: bold;">—</td>
<td headers="Remarks" class="gt_row gt_left" style="background-color: #D1E7DD; font-weight: bold;"><span data-qmd-base64="PGI+UmVhZGluZyBXZWVrIOKAkyBObyBjbGFzc2VzPC9iPg=="><span class='gt_from_md'><b>Reading Week – No classes</b></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Feb 23</td>
<td headers="Acad_Week" class="gt_row gt_center">7</td>
<td headers="Topic" class="gt_row gt_left">4. Distribution of Quadratic Forms </td>
<td headers="Remarks" class="gt_row gt_left"><span data-qmd-base64="PGI+TWFyIDAxOiBBc3NpZ25tZW50IDIgZHVlPC9iPg=="><span class='gt_from_md'><b>Mar 01: Assignment 2 due</b></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Mar 02</td>
<td headers="Acad_Week" class="gt_row gt_center">8</td>
<td headers="Topic" class="gt_row gt_left">5. Theory for Multiple Regression</td>
<td headers="Remarks" class="gt_row gt_left"><span data-qmd-base64="PGI+TWFyIDA2OiBNaWR0ZXJtIChkdXJpbmcgY2xhc3MpPC9iPg=="><span class='gt_from_md'><b>Mar 06: Midterm (during class)</b></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Mar 09</td>
<td headers="Acad_Week" class="gt_row gt_center">9</td>
<td headers="Topic" class="gt_row gt_left">5. Theory for Multiple Regression </td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Mar 16</td>
<td headers="Acad_Week" class="gt_row gt_center">10</td>
<td headers="Topic" class="gt_row gt_left">5. Theory for Multiple Regression </td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Mar 23</td>
<td headers="Acad_Week" class="gt_row gt_center">11</td>
<td headers="Topic" class="gt_row gt_left">6. Non-full-rank Models</td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Mar 30</td>
<td headers="Acad_Week" class="gt_row gt_center">12</td>
<td headers="Topic" class="gt_row gt_left">6. Non-full-rank Models </td>
<td headers="Remarks" class="gt_row gt_left"><span data-qmd-base64="PGI+QXByIDA1OiBBc3NpZ25tZW50IDMgZHVlPC9iPg=="><span class='gt_from_md'><b>Apr 05: Assignment 3 due</b></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Apr 06</td>
<td headers="Acad_Week" class="gt_row gt_center">13</td>
<td headers="Topic" class="gt_row gt_left">Review</td>
<td headers="Remarks" class="gt_row gt_left"><span data-qmd-base64="QXByIDA2OiBMYXN0IGxlY3R1cmU="><span class='gt_from_md'>Apr 06: Last lecture</span></span></td></tr>
  </tbody>
  
</table>
</div>
```

:::
:::

::: {.callout-important}
The schedule may change depending on the course pace. The exact assignment and test dates are given on Canvas. 
:::

## Evaluation

### Grading Scheme
**3 assignments: 3x10% = 30%,  1 term test:  20%,  final exam: 50%.**

### Assignments and Tests
**Assignment questions are released in the one-drive folder**. You will submit your solutions via Canvas. **If you miss an assignment without proper excuse, the weight will NOT be shifted to the final.** Undergraduate students will be assigned with different assignments and tests.

### Assignments

* I will accept late assignments only for three (3) days beyond the due date. The penalty for your delay is 10 percentage points per day of lateness from the value of the assignment (including weekends). **Extensions are only granted in rare instances (notably as a result of family or medical emergencies) and upon receipt of adequate documentation/proof.**
* Answer the questions in the order they appear in the assignment. Neatness is important.
* Solutions to problems are to be included. Hence, simple answers without work will receive few (or no!) marks.
* Most problems in statistics have a “real-life” basis. Hence, solutions should include not only numerical solutions but also a statement as to what the numbers say about the problem.
* The work handed in must not be an exact duplicate of others.
* Submitting Assignments: The assignment can be typed and/or handwritten. Save your assignment as **one PDF file** (for handwritten assignments, feel free to take a picture/scan of your work and save it as one PDF file). Upload the **PDF file** as an assignment submission in Canvas.
* More details will be provided ahead of each assignment.
* Due Date: See Course Schedule.

### Midterm
* The midterm is given in class period.
* Midterms must be written on the dates scheduled. Students must do midterms completely on their own. More details (including syllabus) will be provided ahead of each midterm.
* Type: Short-answer questions, problem-solving, open-book.
* Calculator: A scientific calculator is allowed.
* Make-up exam will not be given. If you miss an exam for a legitimate reason (e.g., illness, emergency) and notify me within 48 hours of the scheduled exam, the weight of the missed exam will be transferred to the final exam.

### Final Exam
* Scheduling: Final examinations may be scheduled at any time during the examination period; students should therefore avoid making prior travel, employment, or other commitments for this period. If a student is unable to write an exam through no fault of their own for medical or other valid reasons, documentation must be provided and an opportunity to write the missed exam may be given. Students are encouraged to review all examination policies and procedures: [http://students.usask.ca/academics/exams.php](http://students.usask.ca/academics/exams.php).
* The final exam will cover material of the entire course. More details will be provided ahead of the exam.
* Length: 3-hour in-person exam.
* Type: Short-answer questions, problem-solving, open-book.

### Criteria That Must Be Met to Pass
The **final exam is a required component of the course**. Students must complete the final exam in order to be eligible to receive a passing grade in this class.

## Attendance Expectation
Attendance is highly correlated with student performance. While a syllabus and suggested readings are provided, it is not an adequate substitute for attending class. Your **attendance is highly recommended** but not required, and you will not be graded on your attendance.

## Recording of the Course
Recording of the lectures will only be allowed in certain circumstances. Please see the instructor for information on how to receive approval. In general, there will be no videos available for in-person lectures. Therefore, **attendance is strongly recommended**.

## Use of Generative AI and Electronic Devices

1. AI for Learning vs. Assessment. Students are free (and encouraged) to use Generative AI tools as a study aid to understand course concepts, debug code, or explain complex theorems. However, **all submitted work for assignments must be your own.** You must write your own solutions. Directly copying text, derivations, or code from an AI tool and submitting it as your own may receive a **severe penalty** (up to receiving a 0% on the assignment.
  
2. Electronic Devices During Tests. All term tests and the final exam are **Open Book**, meaning you may bring printed notes, textbooks, and lecture slides.
  
   * **No Electronic Devices:** You are **NOT allowed** to use laptops, tablets, smartwatches, or any other electronic devices during the exam.
    
   * **Phone Exception:** You are permitted to bring a smartphone, but it must remain stowed away during the writing period. It may **only** be used at the very end of the exam for the specific purpose of taking photos of your answer sheets for submission (if required). Using the phone for any other reason during the exam will be treated as academic misconduct.

