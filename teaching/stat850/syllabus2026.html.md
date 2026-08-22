---
title: "STAT 850/442 Statistical Inference (Univ. of Saskatchewan, 2026-01)"
engine: knitr
format: profweb-html
---


## Description

This course presents a rigorous theoretical treatment of statistical inference, offering a comparative analysis of frequentist and Bayesian paradigms. The curriculum explores several core areas of statistical theory, beginning with foundational concepts in Decision theory (Risk Function, Minimaxity Theorem) before moving into a comprehensive treatment of Bayesian inference (Posterior, Bayes Rules, Bayes Risk, Minimax Rules, James-Stein Estimator, Empirical Bayes, Hierarchical Bayesian, MCMC, Case Study). The course then transitions to focus heavily on Likelihood theory (Sufficient Statistic, Bartlett's Identities, Cramér-Rao Lower Bound, Exponential Families) and the mechanics of MLE (Score, Fisher Information, Newton-Raphson Methods, Asymptotics of Maximum Likelihood Estimators, Alkeike Information Criteria, Deep Learning). Finally, we cover hypothesis testing and optimal point estimation through the lens of the Likelihood ratio test (Neyman-Pearson Lemma, Monotone Likelihood Test, Likelihood-based Tests) and UMVUE (Complete Statistic, Uniformly Minimum Variance Unbiased Estimators/Tests).

**Prerequisite(s):** STAT 342. 

This course requires a strong command of multivariate calculus, alongside a rigorous foundation in intermediate probability theory including asymptotic theorey for probability. Students should also possess prior exposure to applied statistical methods and familiar with basic statistical concepts such as standard error, p-value, and confidence internal.

## Instructor
* [Longhai Li](https://longhaisk.github.io), Professor
* Department of Mathematics and Statistics, University of Saskatchewan
* Email: longhai.li@usask.ca.

## Times and Places
* **Lectures:** TTH 11:30-12:20, MCLN 242.1
* **Office Hours:** TBA
* **No lab**

## Textbook and Course Materials

* [The course page](https://longhaisk.github.io/teaching/stat850/) contains the links to my lecture notes and assingments.

* **Recommended Text:** 

  Young G. A. & R. L. Smith, *Essentials of Statistical Inference*, Cambridge University Press, 2005. 



## Tentative Schedule


::: {.cell}

:::



::: {.cell}
::: {.cell-output-display}

```{=html}
<div id="velghkmjgu" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#velghkmjgu table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#velghkmjgu thead, #velghkmjgu tbody, #velghkmjgu tfoot, #velghkmjgu tr, #velghkmjgu td, #velghkmjgu th {
  border-style: none;
}

#velghkmjgu p {
  margin: 0;
  padding: 0;
}

#velghkmjgu .gt_table {
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

#velghkmjgu .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#velghkmjgu .gt_title {
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

#velghkmjgu .gt_subtitle {
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

#velghkmjgu .gt_heading {
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

#velghkmjgu .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#velghkmjgu .gt_col_headings {
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

#velghkmjgu .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
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

#velghkmjgu .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#velghkmjgu .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#velghkmjgu .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#velghkmjgu .gt_column_spanner {
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

#velghkmjgu .gt_spanner_row {
  border-bottom-style: hidden;
}

#velghkmjgu .gt_group_heading {
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

#velghkmjgu .gt_empty_group_heading {
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

#velghkmjgu .gt_from_md > :first-child {
  margin-top: 0;
}

#velghkmjgu .gt_from_md > :last-child {
  margin-bottom: 0;
}

#velghkmjgu .gt_row {
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

#velghkmjgu .gt_stub {
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

#velghkmjgu .gt_stub_row_group {
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

#velghkmjgu .gt_row_group_first td {
  border-top-width: 2px;
}

#velghkmjgu .gt_row_group_first th {
  border-top-width: 2px;
}

#velghkmjgu .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#velghkmjgu .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#velghkmjgu .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#velghkmjgu .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#velghkmjgu .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#velghkmjgu .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#velghkmjgu .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#velghkmjgu .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#velghkmjgu .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#velghkmjgu .gt_footnotes {
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

#velghkmjgu .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#velghkmjgu .gt_sourcenotes {
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

#velghkmjgu .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#velghkmjgu .gt_left {
  text-align: left;
}

#velghkmjgu .gt_center {
  text-align: center;
}

#velghkmjgu .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#velghkmjgu .gt_font_normal {
  font-weight: normal;
}

#velghkmjgu .gt_font_bold {
  font-weight: bold;
}

#velghkmjgu .gt_font_italic {
  font-style: italic;
}

#velghkmjgu .gt_super {
  font-size: 65%;
}

#velghkmjgu .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#velghkmjgu .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#velghkmjgu .gt_indent_1 {
  text-indent: 5px;
}

#velghkmjgu .gt_indent_2 {
  text-indent: 10px;
}

#velghkmjgu .gt_indent_3 {
  text-indent: 15px;
}

#velghkmjgu .gt_indent_4 {
  text-indent: 20px;
}

#velghkmjgu .gt_indent_5 {
  text-indent: 25px;
}

#velghkmjgu .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#velghkmjgu div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" style="table-layout:fixed;width:100%;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <colgroup>
    <col style="width:15%;"/>
    <col style="width:10%;"/>
    <col style="width:50%;"/>
    <col style="width:25%;"/>
  </colgroup>
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Date">Date</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Acad_Week">Acad_Week</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Topic">Topic</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Remarks">Remarks</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Date" class="gt_row gt_left">Jan 05</td>
<td headers="Acad_Week" class="gt_row gt_center">1</td>
<td headers="Topic" class="gt_row gt_left">1. Introduction, Likelihood Function, and MLE</td>
<td headers="Remarks" class="gt_row gt_left"><span data-qmd-base64="SmFuIDA2OiBGaXJzdCBMZWN0dXJl"><span class='gt_from_md'>Jan 06: First Lecture</span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Jan 12</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">2</td>
<td headers="Topic" class="gt_row gt_left gt_striped">2. Decision Theory: Risk, Minimaxity Theorem</td>
<td headers="Remarks" class="gt_row gt_left gt_striped"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Jan 19</td>
<td headers="Acad_Week" class="gt_row gt_center">3</td>
<td headers="Topic" class="gt_row gt_left">3. Bayesian Inference: Posterior, Bayes Rules, Bayes Risk</td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Jan 26</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">4</td>
<td headers="Topic" class="gt_row gt_left gt_striped">3. Bayesian Inference: Minimax Rules, Jame-Stein Estimator</td>
<td headers="Remarks" class="gt_row gt_left gt_striped"><span data-qmd-base64="KipGZWIgMDE6IEFzc2lnbm1lbnQgMSBkdWUqKg=="><span class='gt_from_md'><strong>Feb 01: Assignment 1 due</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Feb 02</td>
<td headers="Acad_Week" class="gt_row gt_center">5</td>
<td headers="Topic" class="gt_row gt_left">3. Bayesian Inference: Empirical Bayes, Hierachical Bayesian, MCMC, Case Study</td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Feb 09</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">6</td>
<td headers="Topic" class="gt_row gt_left gt_striped">4. Likelihood Theory: Sufficient Statistic</td>
<td headers="Remarks" class="gt_row gt_left gt_striped"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left" style="background-color: #D1E7DD; font-weight: bold;">Feb 16</td>
<td headers="Acad_Week" class="gt_row gt_center" style="background-color: #D1E7DD; font-weight: bold;">N/A</td>
<td headers="Topic" class="gt_row gt_left" style="background-color: #D1E7DD; font-weight: bold;">—</td>
<td headers="Remarks" class="gt_row gt_left" style="background-color: #D1E7DD; font-weight: bold;"><span data-qmd-base64="KipSZWFkaW5nIFdlZWsg4oCTIE5vIGNsYXNzZXMqKg=="><span class='gt_from_md'><strong>Reading Week – No classes</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Feb 23</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">7</td>
<td headers="Topic" class="gt_row gt_left gt_striped">5. Likelihood Theory: Bartlett's Identities, CR Lower Bound</td>
<td headers="Remarks" class="gt_row gt_left gt_striped"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Mar 02</td>
<td headers="Acad_Week" class="gt_row gt_center">8</td>
<td headers="Topic" class="gt_row gt_left">5. Likelihood Theory: Exponential Families</td>
<td headers="Remarks" class="gt_row gt_left"><span data-qmd-base64="KipNYXIgMDM6IE1pZHRlcm0gKGR1cmluZyBjbGFzcykqKg=="><span class='gt_from_md'><strong>Mar 03: Midterm (during class)</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Mar 09</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">9</td>
<td headers="Topic" class="gt_row gt_left gt_striped">6. Maximum Likelihood Estimation: Score, Fisher Information, New-Raphson Methods</td>
<td headers="Remarks" class="gt_row gt_left gt_striped"><span data-qmd-base64="KipNYXIgMTU6IEFzc2lnbm1lbnQgMiBkdWUqKg=="><span class='gt_from_md'><strong>Mar 15: Assignment 2 due</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Mar 16</td>
<td headers="Acad_Week" class="gt_row gt_center">10</td>
<td headers="Topic" class="gt_row gt_left">6. Maximum Likelihood Estimation: Asympotics of MLE, AIC, Deep Learning</td>
<td headers="Remarks" class="gt_row gt_left"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Mar 23</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">11</td>
<td headers="Topic" class="gt_row gt_left gt_striped">7. Hypothesis Testing: NP Lemma, Monotone Likelihood Test, Likelihood-based Tests</td>
<td headers="Remarks" class="gt_row gt_left gt_striped"></td></tr>
    <tr><td headers="Date" class="gt_row gt_left">Mar 30</td>
<td headers="Acad_Week" class="gt_row gt_center">12</td>
<td headers="Topic" class="gt_row gt_left">8. Uniformly Minimum Variance Unbiased Tests: Complete Statistic, UMVUE</td>
<td headers="Remarks" class="gt_row gt_left"><span data-qmd-base64="KipBcHIgMDU6IEFzc2lnbm1lbnQgMyBkdWUqKg=="><span class='gt_from_md'><strong>Apr 05: Assignment 3 due</strong></span></span></td></tr>
    <tr><td headers="Date" class="gt_row gt_left gt_striped">Apr 06</td>
<td headers="Acad_Week" class="gt_row gt_center gt_striped">13</td>
<td headers="Topic" class="gt_row gt_left gt_striped">Review</td>
<td headers="Remarks" class="gt_row gt_left gt_striped"><span data-qmd-base64="QXByIDA3OiBMYXN0IGxlY3R1cmU="><span class='gt_from_md'>Apr 07: Last lecture</span></span></td></tr>
  </tbody>
  
</table>
</div>
```

:::
:::


:::{.callout-important}
The schedule may change depending on the course pace. The exact assignment and test dates  are given on Canvas. 
:::


## Learning Outcomes 

After completing this course, students are expected to grasp the following knowledges and skills:


::: {.cell}
::: {.cell-output-display}

```{=html}
<div id="nhgppesfjt" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#nhgppesfjt table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#nhgppesfjt thead, #nhgppesfjt tbody, #nhgppesfjt tfoot, #nhgppesfjt tr, #nhgppesfjt td, #nhgppesfjt th {
  border-style: none;
}

#nhgppesfjt p {
  margin: 0;
  padding: 0;
}

#nhgppesfjt .gt_table {
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

#nhgppesfjt .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#nhgppesfjt .gt_title {
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

#nhgppesfjt .gt_subtitle {
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

#nhgppesfjt .gt_heading {
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

#nhgppesfjt .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#nhgppesfjt .gt_col_headings {
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

#nhgppesfjt .gt_col_heading {
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

#nhgppesfjt .gt_column_spanner_outer {
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

#nhgppesfjt .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#nhgppesfjt .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#nhgppesfjt .gt_column_spanner {
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

#nhgppesfjt .gt_spanner_row {
  border-bottom-style: hidden;
}

#nhgppesfjt .gt_group_heading {
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

#nhgppesfjt .gt_empty_group_heading {
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

#nhgppesfjt .gt_from_md > :first-child {
  margin-top: 0;
}

#nhgppesfjt .gt_from_md > :last-child {
  margin-bottom: 0;
}

#nhgppesfjt .gt_row {
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

#nhgppesfjt .gt_stub {
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

#nhgppesfjt .gt_stub_row_group {
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

#nhgppesfjt .gt_row_group_first td {
  border-top-width: 2px;
}

#nhgppesfjt .gt_row_group_first th {
  border-top-width: 2px;
}

#nhgppesfjt .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#nhgppesfjt .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#nhgppesfjt .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#nhgppesfjt .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#nhgppesfjt .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#nhgppesfjt .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#nhgppesfjt .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#nhgppesfjt .gt_striped {
  background-color: #F5F5F5;
}

#nhgppesfjt .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#nhgppesfjt .gt_footnotes {
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

#nhgppesfjt .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#nhgppesfjt .gt_sourcenotes {
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

#nhgppesfjt .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#nhgppesfjt .gt_left {
  text-align: left;
}

#nhgppesfjt .gt_center {
  text-align: center;
}

#nhgppesfjt .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#nhgppesfjt .gt_font_normal {
  font-weight: normal;
}

#nhgppesfjt .gt_font_bold {
  font-weight: bold;
}

#nhgppesfjt .gt_font_italic {
  font-style: italic;
}

#nhgppesfjt .gt_super {
  font-size: 65%;
}

#nhgppesfjt .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#nhgppesfjt .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#nhgppesfjt .gt_indent_1 {
  text-indent: 5px;
}

#nhgppesfjt .gt_indent_2 {
  text-indent: 10px;
}

#nhgppesfjt .gt_indent_3 {
  text-indent: 15px;
}

#nhgppesfjt .gt_indent_4 {
  text-indent: 20px;
}

#nhgppesfjt .gt_indent_5 {
  text-indent: 25px;
}

#nhgppesfjt .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#nhgppesfjt div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Decision Theory</td>
<td headers="Knowledge" class="gt_row gt_left">Understand risk functions, admissibility, and the theoretical foundation of decision rules.</td>
<td headers="Skills" class="gt_row gt_left">Calculate frequentist risk function for given estimators and evaluate admissibility under simple loss functions.</td>
<td headers="Percentages" class="gt_row gt_right">10%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left gt_striped" style="font-weight: bold;">Bayesian Inference</td>
<td headers="Knowledge" class="gt_row gt_left gt_striped">Define prior/posterior distributions and Bayes risk. Understand shrinkage via the James-Stein estimator, Empirical Bayes, hierarchical models, and MCMC principles.</td>
<td headers="Skills" class="gt_row gt_left gt_striped">Derive posterior distributions, find Bayes estimators, calculate Bayes risk, and find minimax rules.</td>
<td headers="Percentages" class="gt_row gt_right gt_striped">20%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Likelihood Theory</td>
<td headers="Knowledge" class="gt_row gt_left">Define minimal sufficient statistic. Understand Bartlett's Identities, the Cramér-Rao Lower Bound (CRLB), and the mathematical properties of Exponential Families.</td>
<td headers="Skills" class="gt_row gt_left">Identify minimal sufficient statistic, compute Fisher Information matrices, Bartlett Identities, verify CRLB attainment,  identify natural parameters and calculate moments of suff. statistics in Exponential Families</td>
<td headers="Percentages" class="gt_row gt_right">10%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left gt_striped" style="font-weight: bold;">Maximum Likelihood Estimation</td>
<td headers="Knowledge" class="gt_row gt_left gt_striped">Define the score function and Fisher Information. Understand the Newton-Raphson algorithm, MLE asymptotic normality, and information criteria (AIC).</td>
<td headers="Skills" class="gt_row gt_left gt_striped">Derive MLEs analytically, calculate asymptotic variances using Fisher information, find the asymptotic distributions of estimators, compute AIC. </td>
<td headers="Percentages" class="gt_row gt_right gt_striped">30%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left" style="font-weight: bold;">Hypothesis Testing</td>
<td headers="Knowledge" class="gt_row gt_left">Grasp the size, power,  Neyman-Pearson Lemma, Monotone Likelihood Ratios (MLR), and the theoretical logic of likelihood-based testing.</td>
<td headers="Skills" class="gt_row gt_left">Construct UMP tests using MLR, derive Likelihood Ratio tests, Score tests, and Wald tests with specified rejection regions.</td>
<td headers="Percentages" class="gt_row gt_right">20%</td></tr>
    <tr><td headers="Topic" class="gt_row gt_left gt_striped" style="font-weight: bold;">UMVUE</td>
<td headers="Knowledge" class="gt_row gt_left gt_striped">Understand completeness, the Lehmann-Scheffé theorem, and Rao-Blackwell Theorem.</td>
<td headers="Skills" class="gt_row gt_left gt_striped">Derive UMVUE in exponential families.</td>
<td headers="Percentages" class="gt_row gt_right gt_striped">10%</td></tr>
  </tbody>
  
</table>
</div>
```

:::
:::


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

1. AI for Learning vs. Assessment. Students are free (and encouraged) to use Generative AI tools as a study aid to understand course concepts, debug code, or explain complex theorems. However, **all submitted work for assignments must be your own.** You must write your own solutions. Directly copying text, derivations, or code from an AI tool and submitting it as your own may receive a **severe penalty** (up to receiving a 0% on the assignment.
  
2. Electronic Devices During Tests. All term tests and the final exam are **Open Book**, meaning you may bring printed notes, textbooks, and lecture slides.
  
   - **No Electronic Devices:** You are **NOT allowed** to use laptops, tablets, smartwatches, or any other electronic devices during the exam.
    
   - **Phone Exception:** You are permitted to bring a smartphone, but it must remain stowed away during the writing period. It may **only** be used at the very end of the exam for the specific purpose of taking photos of your answer sheets for submission (if required). Using the phone for any other reason during the exam will be treated as academic misconduct.


    