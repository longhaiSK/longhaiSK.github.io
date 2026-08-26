---
title: "STAT 812/420 Computational Statistics"
subtitle: "Univ. of Saskatchewan, 2026-09"
engine: knitr
format: 
  profweb-html: default
  profweb-typst: default
  

---

## Description

This course covers the fundamental concepts in computational methods used the areas of statistics, machine learning, and data sciences. The topics include Introduction to R programming; Computer Arithmetics (Overflow, Underflow, Rounding Error); Monte Carlo Methods (RNG, Inverting CDF Sampling, Simulation for Estimation and Testing); Maximum Likelihood Estimation (Univariate Optimization, Multivariate Optimization, EM Algorithm); and Bayesian Inference & MCMC (Intro to Bayesian Inference, Numerical Quadrature, Laplace Approximation, Rejection Sampling, Importance Sampling, Convergence, Gibbs Sampling, Metropolis-Hastings Sampling, General-purpose Samplers like JAGS and STAN). After learning this course, students are expected to gain an understanding of the algorithms behind these statistical inferential methods, be able to develop new statistical methods, use computers to investigate the properties of statistical methods, and implement a combination of standard statistical toolkits for analyzing real data sets.

## Prerequisites

* Multivariate calculus (MATH 225)
* Linear algebra (MATH 164)
* Calculus-based Probability (eg. STAT 342 or STAT 241)
* Multiple Linear Regression (eg. STAT 344)

## Instructor
* [Longhai Li](https://longhaisk.github.io), Professor
* Department of Mathematics and Statistics, University of Saskatchewan
* Email: longhai.li@usask.ca.

## Times and Places
* **Lectures:** TTH 10:00-11:20, MCLN 42.1
* **Office Hours:** TBA with Students
* **No lab**

## Textbook and Course Materials

* [The course page](index.html) contains the links to my lecture notes and assingments.

* **Recommended Text:** [My own lecture note](index.html).

## Tentative Schedule / List of Topics


::: {.cell}
::: {.cell-output-display}

```{=html}
<div id="trntqpbgfu" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#trntqpbgfu table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#trntqpbgfu thead, #trntqpbgfu tbody, #trntqpbgfu tfoot, #trntqpbgfu tr, #trntqpbgfu td, #trntqpbgfu th {
  border-style: none;
}

#trntqpbgfu p {
  margin: 0;
  padding: 0;
}

#trntqpbgfu .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 13px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
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

#trntqpbgfu .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#trntqpbgfu .gt_title {
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

#trntqpbgfu .gt_subtitle {
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

#trntqpbgfu .gt_heading {
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

#trntqpbgfu .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#trntqpbgfu .gt_col_headings {
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

#trntqpbgfu .gt_col_heading {
  color: #333333;
  background-color: #F0F0F0;
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

#trntqpbgfu .gt_column_spanner_outer {
  color: #333333;
  background-color: #F0F0F0;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#trntqpbgfu .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#trntqpbgfu .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#trntqpbgfu .gt_column_spanner {
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

#trntqpbgfu .gt_spanner_row {
  border-bottom-style: hidden;
}

#trntqpbgfu .gt_group_heading {
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

#trntqpbgfu .gt_empty_group_heading {
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

#trntqpbgfu .gt_from_md > :first-child {
  margin-top: 0;
}

#trntqpbgfu .gt_from_md > :last-child {
  margin-bottom: 0;
}

#trntqpbgfu .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #E0E0E0;
  border-left-style: solid;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: solid;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#trntqpbgfu .gt_stub {
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

#trntqpbgfu .gt_stub_row_group {
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

#trntqpbgfu .gt_row_group_first td {
  border-top-width: 2px;
}

#trntqpbgfu .gt_row_group_first th {
  border-top-width: 2px;
}

#trntqpbgfu .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#trntqpbgfu .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#trntqpbgfu .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#trntqpbgfu .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#trntqpbgfu .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#trntqpbgfu .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#trntqpbgfu .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#trntqpbgfu .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#trntqpbgfu .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#trntqpbgfu .gt_footnotes {
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

#trntqpbgfu .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#trntqpbgfu .gt_sourcenotes {
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

#trntqpbgfu .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#trntqpbgfu .gt_left {
  text-align: left;
}

#trntqpbgfu .gt_center {
  text-align: center;
}

#trntqpbgfu .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#trntqpbgfu .gt_font_normal {
  font-weight: normal;
}

#trntqpbgfu .gt_font_bold {
  font-weight: bold;
}

#trntqpbgfu .gt_font_italic {
  font-style: italic;
}

#trntqpbgfu .gt_super {
  font-size: 65%;
}

#trntqpbgfu .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#trntqpbgfu .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#trntqpbgfu .gt_indent_1 {
  text-indent: 5px;
}

#trntqpbgfu .gt_indent_2 {
  text-indent: 10px;
}

#trntqpbgfu .gt_indent_3 {
  text-indent: 15px;
}

#trntqpbgfu .gt_indent_4 {
  text-indent: 20px;
}

#trntqpbgfu .gt_indent_5 {
  text-indent: 25px;
}

#trntqpbgfu .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#trntqpbgfu div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" style="table-layout:fixed;width:100%;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <colgroup>
    <col style="width:10%;"/>
    <col style="width:10%;"/>
    <col style="width:55%;"/>
    <col style="width:25%;"/>
  </colgroup>
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Date"><span data-qmd-base64="KipEYXRlKio="><span class='gt_from_md'><strong>Date</strong></span></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Acad_Week"><span data-qmd-base64="KipBY2FkLiBXZWVrKio="><span class='gt_from_md'><strong>Acad. Week</strong></span></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Topic"><span data-qmd-base64="KipUb3BpYyoq"><span class='gt_from_md'><strong>Topic</strong></span></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Task"><span data-qmd-base64="KipSZW1hcmsqKg=="><span class='gt_from_md'><strong>Remark</strong></span></span></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Date" class="gt_row gt_left">Sep 07</td>
<td headers="Acad_Week" class="gt_row gt_center">1</td>
<td headers="Topic" class="gt_row gt_left">1 Introduction: Stat. Inference, R, R Studio, Quarto</td>
<td headers="Task" class="gt_row gt_left"><span data-qmd-base64="KipDb3Vyc2UgU3RhcnRzIChTZXAgMDgpKio="><span class='gt_from_md'><strong>Course Starts (Sep 08)</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Sep 14</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">2</td>
<td headers="Topic" class="gt_row gt_left gt_striped">2 Computer Arithmetics: Overflow, Underflow, Rounding Error</td>
<td headers="Task" class="gt_row gt_left gt_striped"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Sep 21</td>
<td headers="Acad_Week" class="gt_row gt_center">3</td>
<td headers="Topic" class="gt_row gt_left">3 Monte Carlo Methods: RNG, Inverting CDF Sampling</td>
<td headers="Task" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Sep 28</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">4</td>
<td headers="Topic" class="gt_row gt_left gt_striped">3 Monte Carlo Methods: Simulation for Estimation and Testing</td>
<td headers="Task" class="gt_row gt_left gt_striped"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Oct 05</td>
<td headers="Acad_Week" class="gt_row gt_center">5</td>
<td headers="Topic" class="gt_row gt_left">4 Maximum Likelihood Estimation: Univariate Optimization</td>
<td headers="Task" class="gt_row gt_left"><span data-qmd-base64="KipBc3NpZ25tZW50IDEgZHVlKio="><span class='gt_from_md'><strong>Assignment 1 due</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Oct 12</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">6</td>
<td headers="Topic" class="gt_row gt_left gt_striped">4 Maximum Likelihood Estimation: Multivariate Optimization</td>
<td headers="Task" class="gt_row gt_left gt_striped"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Oct 19</td>
<td headers="Acad_Week" class="gt_row gt_center">7</td>
<td headers="Topic" class="gt_row gt_left">4 Maximum Likelihood Estimation: EM Algorithm</td>
<td headers="Task" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Oct 26</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">8</td>
<td headers="Topic" class="gt_row gt_left gt_striped">5 Bayesian Inference &amp; MCMC: Intro Bayesian Inference and Numerical Quadrature</td>
<td headers="Task" class="gt_row gt_left gt_striped"><span data-qmd-base64="KipBc3NpZ25tZW50IDIgZHVlKio="><span class='gt_from_md'><strong>Assignment 2 due</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Nov 02</td>
<td headers="Acad_Week" class="gt_row gt_center">9</td>
<td headers="Topic" class="gt_row gt_left">5 Bayesian Inference &amp; MCMC: Laplace Approx, Rejection Sampling</td>
<td headers="Task" class="gt_row gt_left"><span data-qmd-base64="KipNaWR0ZXJtIChkdXJpbmcgY2xhc3MpKio="><span class='gt_from_md'><strong>Midterm (during class)</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped" style="background-color: #D1E7DD; font-style: italic; font-weight: bold;">Nov 09</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped" style="background-color: #D1E7DD; font-style: italic; font-weight: bold;">N/A</td>
<td headers="Topic" class="gt_row gt_left gt_striped" style="background-color: #D1E7DD; font-style: italic; font-weight: bold;">—</td>
<td headers="Task" class="gt_row gt_left gt_striped" style="background-color: #D1E7DD; font-style: italic; font-weight: bold;"><span data-qmd-base64="KipSZWFkaW5nIFdlZWsg4oCTIE5vIGNsYXNzZXMqKg=="><span class='gt_from_md'><strong>Reading Week – No classes</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Nov 16</td>
<td headers="Acad_Week" class="gt_row gt_center">10</td>
<td headers="Topic" class="gt_row gt_left">5 Bayesian Inference &amp; MCMC: Importance Sampling</td>
<td headers="Task" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Nov 23</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">11</td>
<td headers="Topic" class="gt_row gt_left gt_striped">5 Bayesian Inference &amp; MCMC: Convergence, Gibbs Sampling</td>
<td headers="Task" class="gt_row gt_left gt_striped"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Nov 30</td>
<td headers="Acad_Week" class="gt_row gt_center">12</td>
<td headers="Topic" class="gt_row gt_left">5 Bayesian Inference &amp; MCMC: Metropolis-Hastings Sampling</td>
<td headers="Task" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Dec 07</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">13</td>
<td headers="Topic" class="gt_row gt_left gt_striped">5 Bayesian Inference &amp; MCMC: General-purpose Samplers (JAGS, STAN)</td>
<td headers="Task" class="gt_row gt_left gt_striped"><span data-qmd-base64="KipBc3NpZ25tZW50IDMgZHVlKio8YnI+KipDb3Vyc2UgRW5kcyAoRGVjIDA3KSoq"><span class='gt_from_md'><strong>Assignment 3 due</strong><br><strong>Course Ends (Dec 07)</strong></span></span></td></tr>
  </tbody>
  
</table>
</div>
```

:::
:::


:::{.callout-important}
The schedule may change depending on the course pace. The exact assignment and test dates are given on Canvas. 
:::

## Learning Outcomes 

After completing this course, students are expected to grasp the following knowledges and skills:


::: {.cell}
::: {.cell-output-display}

```{=html}
<div id="skwvsrvsds" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#skwvsrvsds table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#skwvsrvsds thead, #skwvsrvsds tbody, #skwvsrvsds tfoot, #skwvsrvsds tr, #skwvsrvsds td, #skwvsrvsds th {
  border-style: none;
}

#skwvsrvsds p {
  margin: 0;
  padding: 0;
}

#skwvsrvsds .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 12px;
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

#skwvsrvsds .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#skwvsrvsds .gt_title {
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

#skwvsrvsds .gt_subtitle {
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

#skwvsrvsds .gt_heading {
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

#skwvsrvsds .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#skwvsrvsds .gt_col_headings {
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

#skwvsrvsds .gt_col_heading {
  color: #333333;
  background-color: #E0E0E0;
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

#skwvsrvsds .gt_column_spanner_outer {
  color: #333333;
  background-color: #E0E0E0;
  font-size: 100%;
  font-weight: bold;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#skwvsrvsds .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#skwvsrvsds .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#skwvsrvsds .gt_column_spanner {
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

#skwvsrvsds .gt_spanner_row {
  border-bottom-style: hidden;
}

#skwvsrvsds .gt_group_heading {
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

#skwvsrvsds .gt_empty_group_heading {
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

#skwvsrvsds .gt_from_md > :first-child {
  margin-top: 0;
}

#skwvsrvsds .gt_from_md > :last-child {
  margin-bottom: 0;
}

#skwvsrvsds .gt_row {
  padding-top: 5px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #B0B0B0;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#skwvsrvsds .gt_stub {
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

#skwvsrvsds .gt_stub_row_group {
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

#skwvsrvsds .gt_row_group_first td {
  border-top-width: 2px;
}

#skwvsrvsds .gt_row_group_first th {
  border-top-width: 2px;
}

#skwvsrvsds .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#skwvsrvsds .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#skwvsrvsds .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#skwvsrvsds .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#skwvsrvsds .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#skwvsrvsds .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#skwvsrvsds .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#skwvsrvsds .gt_striped {
  background-color: #F5F5F5;
}

#skwvsrvsds .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#skwvsrvsds .gt_footnotes {
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

#skwvsrvsds .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#skwvsrvsds .gt_sourcenotes {
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

#skwvsrvsds .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#skwvsrvsds .gt_left {
  text-align: left;
}

#skwvsrvsds .gt_center {
  text-align: center;
}

#skwvsrvsds .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#skwvsrvsds .gt_font_normal {
  font-weight: normal;
}

#skwvsrvsds .gt_font_bold {
  font-weight: bold;
}

#skwvsrvsds .gt_font_italic {
  font-style: italic;
}

#skwvsrvsds .gt_super {
  font-size: 65%;
}

#skwvsrvsds .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#skwvsrvsds .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#skwvsrvsds .gt_indent_1 {
  text-indent: 5px;
}

#skwvsrvsds .gt_indent_2 {
  text-indent: 10px;
}

#skwvsrvsds .gt_indent_3 {
  text-indent: 15px;
}

#skwvsrvsds .gt_indent_4 {
  text-indent: 20px;
}

#skwvsrvsds .gt_indent_5 {
  text-indent: 25px;
}

#skwvsrvsds .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#skwvsrvsds div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" style="table-layout:fixed;width:100%;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <colgroup>
    <col style="width:15%;"/>
    <col style="width:35%;"/>
    <col style="width:40%;"/>
    <col style="width:10%;"/>
  </colgroup>
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Topic"><span data-qmd-base64="KipUb3BpYyoq"><span class='gt_from_md'><strong>Topic</strong></span></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Knowledge"><span data-qmd-base64="KipLbm93bGVkZ2UqKg=="><span class='gt_from_md'><strong>Knowledge</strong></span></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Skills"><span data-qmd-base64="KipTa2lsbHMqKg=="><span class='gt_from_md'><strong>Skills</strong></span></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Percentages"><span data-qmd-base64="KipQZXJjKio="><span class='gt_from_md'><strong>Perc</strong></span></span></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Intro &amp; Arithmetic</td>
<td headers="Knowledge" class="gt_row gt_left">Understand R fundamentals, computer arithmetic limits, overflow/underflow, and numerical rounding errors.</td>
<td headers="Skills" class="gt_row gt_left">Write modular R code and diagnose numerical stability issues in statistical computations.</td>
<td headers="Percentages" class="gt_row gt_right">10%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left gt_striped" style="font-weight: bold;">Monte Carlo Methods</td>
<td headers="Knowledge" class="gt_row gt_left gt_striped">Understand random number generation, the inverse CDF method, and simulation strategies for evaluating statistical methods.</td>
<td headers="Skills" class="gt_row gt_left gt_striped">Implement sampling algorithms from scratch and design simulation studies for point estimation and hypothesis testing.</td>
<td headers="Percentages" class="gt_row gt_right gt_striped">20%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Optimization &amp; MLE</td>
<td headers="Knowledge" class="gt_row gt_left">Understand the mathematical principles of univariate and multivariate optimization techniques for likelihood functions.</td>
<td headers="Skills" class="gt_row gt_left">Apply Newton-Raphson and other multivariate optimization techniques computationally to find Maximum Likelihood Estimates.</td>
<td headers="Percentages" class="gt_row gt_right">25%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left gt_striped" style="font-weight: bold;">EM Algorithm</td>
<td headers="Knowledge" class="gt_row gt_left gt_striped">Understand the theoretical framework of the Expectation-Maximization algorithm for latent variable models.</td>
<td headers="Skills" class="gt_row gt_left gt_striped">Implement the EM algorithm to solve problems involving missing data or hidden states.</td>
<td headers="Percentages" class="gt_row gt_right gt_striped">15%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Bayesian &amp; MCMC</td>
<td headers="Knowledge" class="gt_row gt_left">Grasp the concepts of numerical quadrature, rejection/importance sampling, and MCMC theory (Gibbs, Metropolis-Hastings).</td>
<td headers="Skills" class="gt_row gt_left">Simulate from complex posterior distributions using custom MCMC algorithms and general-purpose samplers like JAGS and STAN.</td>
<td headers="Percentages" class="gt_row gt_right">30%</td></tr>
  </tbody>
  
</table>
</div>
```

:::
:::


## Computing

We will use RStudio and R for this course. 

* **Personal Computer:** Download R, RStudio/Positron/VS-code to your local machine.

* **USASK vlab:** If you don't have a personal computer, you can use the USask remote desktop, the browser-based vlab ([https://vlab.usask.ca/](https://vlab.usask.ca/)), 

* **Posit Cloud:** ([https://posit.cloud/](https://posit.cloud/)).

* **GitHub Codespaces:** You can also run R and RStudio in the cloud with a GitHub Codespace, without installing anything locally. See [https://github.com/codespaces](https://github.com/features/codespaces).

* **Google Colab:** You can also run R in the cloud using Google Colaboratory. To open a notebook with R pre-configured, use this direct link: [https://colab.research.google.com/#create=true&language=r](https://colab.research.google.com/#create=true&language=r). Alternatively, you can create a new notebook in Colab and change the runtime type to R (Runtime > Change runtime type > R).

## Evaluation

### Grading Scheme

**3 Assignments: 3 x 10%, 1 Term Test: 20%, 1 Final Exam: 50%.**

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

* **AI for Learning vs. Assessment**. Students are free (and **encouraged**) to use Generative AI tools as a study aid to understand course concepts, debug code, or explain complex theorems. However, **all submitted work for assignments must be your own.** You must write your own solutions. Directly copying text, derivations, or code from an AI tool and submitting it as your own may receive a **severe penalty** (up to receiving a 0% on the assignment).
* **Electronic Devices**. All term tests and the final exam are **Open Book**, meaning you may bring printed notes, textbooks, and lecture slides.
  * **No Electronic Devices:** You are **NOT allowed** to use laptops, tablets, smartwatches, or any other electronic devices during the exam.
  * **Phone Exception:** You are permitted to bring a smartphone, but it must remain stowed away during the writing period. It may **only** be used at the very end of the exam for the specific purpose of taking photos of your answer sheets for submission (if required). Using the phone for any other reason during the exam will be treated as academic misconduct.

