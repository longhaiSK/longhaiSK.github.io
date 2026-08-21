---
title: "CURRICULUM VITAE of LONGHAI LI (Aug 21, 2026)"
engine: knitr
format:
  profweb-html: default
  profweb-typst: default
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


## 1. PERSONAL

  * Official webpage: [https://artsandscience.usask.ca/profile/LLi](https://artsandscience.usask.ca/profile/LLi) 
  * Professional web site: [https://longhaisk.github.io](https://longhaisk.github.io) 
  * Phone: +1 (306) 966-6095 
  * Email: [longhai.li@usask.ca](mailto:longhai.li@usask.ca)
  * Address:\
    Department of Mathematics & Statistics \
    University of Saskatchewan\
    106 Wiggins RD\
    Saskatoon, SK, S7W0G8 CANADA

## 2. DEGREES

  * Ph.D.,  University of Toronto, 2007, Statistics \
    Supervisor: [Radford M. Neal](https://glizen.com/radfordneal/)\
    **Thesis**: Bayesian Classification and Regression with High Dimensional Features
  * M.Sc., University of Toronto, 2003, Statistics
  * B.Sc.,  University of Science and Technology of China, 2002, Statistics.

## 4. Employment History

  * Full Professor, July 1st, 2018, Dept. of Math & Stat., Univ. of Saskatchewan, SK, Canada
  * Associate Professor, July 1st, 2012, Dept. of Math & Stat., Univ. of Saskatchewan, SK, Canada
  * Assistant Professor, July 1st, 2007, Dept. of Math & Stat., Univ. of Saskatchewan, SK, Canada
  * Research Intern, Nov. 2006 to Feb. 2007, Microsoft Research, Redmond, WA, USA
  * Sessional Instructor, 2006-2007, University of Toronto, Toronto, ON, Canada

## 7. LEAVES

  * Sabbatical Leave, Jan. 1st, 2025 to June 30th, 2025.
  * Sabbatical Leave, July 1st, 2020 to June 30th, 2021.
  * Parental Leave, Jan. 1st, 2019 to June 30th, 2019.
  * Sabbatical Leave, July 1st, 2013 to June 30th, 2014.

## 9. TEACHING ACTIVITIES

### 9.1 Scheduled Instructional Activity

```{=html}
<details class="course-details" style="margin-bottom: 1.5rem;">
<summary style="background-color: #e0e0e0; color: #333333; padding: 0px 5px; cursor: pointer; border-radius: 4px; font-weight: bold; display: inline-block; user-select: none; border: 1px solid #cccccc;">
  &#9662;
</summary>

```

::: {.course-tables}


**2025-2026**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 851 | T2 | Linear Statistical Models | LEC | 4 | 39 | 156 |
| STAT 443 | T2 | Linear Models | LEC | 3 | 39 | 117 |
| STAT 442 | T2 | Statistical Inference | LEC | 3 | 39 | 117 |
| STAT 850 | T2 | Mathematical Statistics and Inference | LEC | 1 | 39 | 39 |
| STAT 845 | T1 | Statistical Methods for Research | LEC | 10 | 39 | 390 |
| MATH 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 1 | | |

**2024-2025**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 348 | T1 | Sampling Techniques | LEC | 15 | 39 | 585 |
| STAT 812 | T1 | Computational Statistics | LEC | 5 | 39 | 195 |
| STAT 420 | T1 | Topics in Computational Statistics | LEC | 1 | 39 | 39 |
| BIOS 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |
| BIOS 996 | T1T2 | Research Supervision (M.Sc.) | RES | 1 | | |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 1 | | |

**2023-2024**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 245 | T1 | Introduction to Statistical Methods | LEC | 91 | 39 | 3549 |
| STAT 812 | T1 | Computational Statistics | LEC | 5 | 39 | 195 |
| STAT 420 | T1 | Topics in Computational Statistics | LEC | 1 | 39 | 39 |
| STAT 443 | T2 | Linear Statistical Models | LEC | 4 | 39 | 156 |
| STAT 851 | T2 | Linear Models | LEC | 4 | 39 | 156 |
| BIOS 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |
| BIOS 996 | T1T2 | Research Supervision (M.Sc.) | RES | 1 | | |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 1 | | |

**2022-2023**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 348 | T1 | Sampling Techniques | LEC | 35 | 39 | 1365 |
| STAT 812 | T1 | Computational Statistics | LEC | 3 | 39 | 117 |
| STAT 420 | T1 | Topics in Computational Statistics | LEC | 1 | 39 | 39 |
| STAT 443 | T2 | Linear Statistical Models | LEC | 1 | 39 | 39 |
| STAT 851 | T2 | Linear Models | LEC | 1 | 39 | 39 |
| BIOS 996 | T1T2 | Research Supervision (M.Sc.) | RES | 1 | | |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 1 | | |
| BIOS 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |

**2021-2022**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 244 | T2 | Elementary Statistical Concepts | LEC | 72 | 39 | 2808 |
| STAT 342 | T1 | Mathematical Statistics | LEC | 8 | 39 | 312 |
| STAT 443 | T2 | Linear Statistical Models | LEC | 3 | 39 | 117 |
| STAT 851 | T2 | Linear Models | LEC | 5 | 39 | 195 |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 2 | | |
| MATH 994 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |
| BIOS 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |
| ENGR 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |

**2020-2021**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 3 | | |
| BIOS 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |
| ENGR 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |

**2019-2020**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 245 | T1 | Introduction to Statistical Methods | LEC | 128 | 39 | 4992 |
| STAT 345 | T2 | Design and Analysis of Experiments | LEC | 27 | 39 | 1053 |
| STAT 834 | T2 | Advanced Experimental Design | LEC | 1 | 39 | 39 |
| STAT 812 | T1 | Computational Statistics | LEC | 5 | 39 | 195 |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 1 | | |
| BIOS 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |
| ENGR 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |

**2018-2019**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 812 | T1 | Computational Statistics | LEC | 11 | 39 | 429 |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 2 | | |
| BIOS 994 | T1T2 | Research Supervision (M.Sc.) | RES | 2 | | |
| BIOS 994 | T2 | Research Supervision (Ph.D.) | RES | 1 | | |
| MATH 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |

**2017-2018**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 241 | T1 | Probability Theory | LEC | 70 | 39 | 2730 |
| STAT 345 | T2 | Design and Analysis of Experiments | LEC | 25 | 39 | 975 |
| STAT 834 | T2 | Advanced Experimental Design | LEC | 9 | 39 | 351 |
| STAT 841 | T2 | Probability Theory | LEC | 5 | 39 | 195 |
| MATH 994 | T1T2 | M.Sc. Research Supervision | RES | 5 | | |

**2016-2017**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 812 | T1 | Computational Statistics | LEC | 12 | 39 | 468 |
| STAT 348 | T2 | Sampling Techniques | LEC | 33 | 39 | 1287 |
| STAT 442 | T2 | Statistical Inference | LEC | 1 | 39 | 39 |
| STAT 846 | T2 | Sp. Topics (Statistical Inference) | LEC | 8 | 39 | 312 |
| MATH 994 | T1T2 | M.Sc. Research Supervision | RES | 6 | | |

**2015-2016**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 245 | T1 | Intro. to Stat. Methods | LEC | 157 | 39 | 6123 |
| STAT 342 | T1 | Mathematical Statistics | LEC | 7 | 39 | 273 |
| STAT 242 | T2 | Stat. Theory & Methodology | LEC | 11 | 39 | 429 |
| STAT 245 | Summer | Intro to Statistical Methods | LEC | 30 | 39 | 1170 | 
| MATH 994 | T1T2 | M.Sc. Research Supervision | RES | 5 | | |
| MATH 996 | T1T2 | Ph.D. Research Supervision | RES | 1 | | |

**2014-2015**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 342 | T1 | Mathematical Statistics | LEC | 9 | 39 | 351 |
| STAT 812 | T1 | Computational Statistics | LEC | 10 | 39 | 390 |
| STAT 348 | T2 | Sampling Techniques | LEC | 21 | 39 | 819 |
| STAT 442 | T2 | Statistical Inference | LEC | 5 | 39 | 195 |
| STAT 846 | T2 | Sp. Topics (Statistical Inference) | LEC | 8 | 39 | 312 |
| STAT 244 | T2 | Elementary Statistical Concepts | LEC | 14 | 39 | 546 |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 4 | | |
| MATH 996 | T1 | Research Supervision (Ph.D.) | RES | 2 | | |

**2012-2013**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 241 | T1 | Probability Theory | LEC | 51 | 39 | 1989 |
| STAT 348 | T2 | Sampling Techniques | LEC | 15 | 39 | 585 |
| STAT 245 | T2 | Intro to Statistical Methods | LEC | 135 | 39 | 5265 |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 2 | | |
| MATH 996 | T1T2 | Research Supervision (Ph.D.) | RES | 2 | | |

**2011-2012**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 241 | T1 | Probability Theory | LEC | 43 | 39 | 1677 |
| STAT 342 | T1 | Mathematical Statistics | LEC | 3 | 39 | 117 |
| STAT 841 | T1 | Probability Theory | LEC | 10 | 39 | 390 |
| STAT 245 | T2 | Intro to Statistical Methods | LEC | 138 | 39 | 5382 |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 2 | | |

**2010-2011**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 241 | T1 | Probability Theory | LEC | 42 | 39 | 1638 |
| STAT 846 | T1 | Computational Statistics | LEC | 8 | 39 | 195 |
| STAT 242 | T2 | Stat. Theory & Methodology | LEC | 13 | 39 | 507 |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 2 | | |
| MATH 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |

**2009-2010**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 342 | T1 | Mathematical Statistics | LEC | 4 | 39 | 156 |
| STAT 841 | T1 | Probability Theory | LEC | 6 | 39 | 234 |
| STAT 241 | T2 | Probability Theory | LEC | 28 | 39 | 1092 |
| STAT 244 | T2 | Elem. Stat. Concepts | LEC | 83 | 39 | 3237 |
| STAT 848 | T2 | Multivariate Data Analysis | READ | 2 | 39 | 78 |
| MATH 994 | T1T2 | Research Supervision (M.Sc.) | RES | 2 | | |
| MATH 996 | T1T2 | Research Supervision (Ph.D.) | RES | 1 | | |

**2008-2009**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 342 | T1 | Mathematical Statistics | LEC | 19 | 39 | 741 |
| STAT 848 | T2 | Multivariate Data Analysis | LEC | 6 | 39 | 234 |

**2007-2008**

| COURSE | TERM | TITLE | TYPE | ENRL | YIH | YCSH |
|-----|--|-----------|--|--|--|--|
| STAT 342 | T1 | Mathematical Statistics | LEC | 7 | 39 | 273 |
| STAT 846 | T2 | Computational Statistics | LEC | 5 | 39 | 195 |

:::

```{=html}
</details>
```
### 9.2 Unscheduled Instructional Activity

  * Creating and assessing PhD qualifying exam on Mathematical Statistics, July 2021.
  * Creating and assessing PhD qualifying exam on Mathematical Statistics, May 2021.

### 9.3 Course and Program Development

**2022-2023**





<!-- -->

3. Renewal of the University of Saskatchewan Courses for SSC Accreditation.


<!-- -->

2. Participated in creating new M.Sc. and Ph.D. programs in Statistics, approved on May 18, 2023.

**2020-2021**



<!-- -->

1. Participation in creating Certificate in Statistical Methods, 2021.

### 9.4 Teaching Materials



**2025-2026**





<!-- -->

4. STAT 442/850: a textbook entitled "[Theory of Statistical Inference](teaching/stat850/mathstat/index.html)" in PDF ($\ge$ 200 pages) and HTML.


<!-- -->

3.  STAT 845: a textbook entitled "[Statistical Inference and Learning Methods for Research](teaching/stat845_rdemo/book/index.html)" in PDF ($\ge$ 200 pages) and HTML


<!-- -->

2.  STAT 443/851: a textbook entitled "[Theory of Linear Model](teaching/stat851/theorylm/index.html)" in PDF ($\approx$ 200 pages) and HTML.

**2024-2025**



<!-- -->

1. STAT 443/851: 273 pages of handwritten lecture notes were developed and posted to students.

### 9.5 Other Teaching-Related Activities



**2025-2026**





<!-- -->

10. Peer evaluation for Matthew Schmirler, Mar. 2026.

**2023-2024**



<!-- -->

9. Data Science Bootcamp, a case study, June 19, 2023.

**2022-2023**



<!-- -->

8. Peer evaluation for Raj Srinivasan, April 2023.


<!-- -->

7. Peer evaluation for Saima Khosa, Dec. 2022.

**2021-2022**



<!-- -->

6. Peer Teaching Evaluation for Shahedul Khan, Nov. 2021.


<!-- -->

5. Peer Teaching Evaluation for Li Xing, Nov. 2021.

**2020-2021**



<!-- -->

4. Peer Teaching Evaluation for Shahedul Khan, STAT 812, Nov. 12, 2020.

**2019-2020**



<!-- -->

3. Peer Teaching Evaluation for Annalizer McGillvray, Nov. 29, 2019.

**2017-2018**



<!-- -->

2. Peer Teaching Evaluation for Shahedul Khan, 2017-2018.


<!-- -->

1. Peer Teaching Evaluation for Lawrence Chang, 2017-2018.

## 10. SUPERVISION AND ADVISORY ACTIVITIES

### 10.1 Undergraduate Student Supervision



**2025-2026**



<!-- -->

16. George Chen, B.Sc., Computer Science, Simon Fraser University, June 1, 2025 -- Aug. 31, 2025, Supervised.


<!-- -->

15. Shruti Kaur, B.Sc., Computer Science and Statistics, May -- Aug., 2025, Supervised.

**2023-2024**



<!-- -->

14. George Chen, B.Sc., Computer Science, Simon Fraser University, May 7, 2023 -- Aug. 25, 2023, Supervised.

**2022-2023**



<!-- -->

13. Noah Little, B.Sc., Anatomy and Cell Biology, April 2022 -- Aug. 31, 2022, Supervised.

**2020-2021**



<!-- -->

12. Noah Little, B.Sc., Anatomy and Cell Biology, Aug. 2020 -- Feb. 2021, Supervised.


<!-- -->

11. Lifang Lei, B.Sc., Mechanical Engineering, Oct. 2020 -- March 2021, Supervised.


<!-- -->

10. Yanping Li, B.Sc., Business, Edward Business School, Feb. 2021 -- June 2021, Supervised.


<!-- -->

9. Lina Li, B.Sc., Statistics, May 2020 -- June 2020, Summer Research Assistant, Supervised.

**2019-2020**



<!-- -->

8. Hao Hu, B.Sc., Statistics, 2019--2020, Undergraduate Thesis Supervision, Supervised.



<!-- -->

7. Steven Liu, B.Sc., Computer Science, July 2019 -- Oct. 2020, Summer Research Assistant, Supervised.
    
    * Project title: Development of an R package for Bayesian Hyper-LASSO Logistic Regression

    * Software: HTLR: [Bayesian Logistic Regression with Heavy-Tailed Priors](/software/BLRHL/index.html), [**[CRAN page]**](https://cran.r-project.org/web/packages/HTLR/index.html), [**[Github page]**](https://longhaisk.github.io/HTLR). HTLR was listed in [the top 40 new packages in October 2019](https://rviews.rstudio.com/2019/11/18/october-2019-top-40-new-r-packages/?mkt_tok=eyJpIjoiT1RabU5tVTFaR0ptTlRCbCIsInQiOiJXWFlONVZhcm44V1wvR25pNmJUb3BrU3h2NmxMN0pPZW9tdVZSelc2ZDRnUWxrbGcrUmcyRnhJdnAraXJCaUVhdkVvbFNRU1hLUEJCTXk1ZHJFSDBFNTBDXC9qZkxSYTdGcWNlclZjYndQdElINnRNRVNWeDZrMU55clQ2Q2dEOU9IIn0%3D) by R views of Rstudio.



<!-- -->

6. Steven Liu, B.Sc., Computer Science, June 17, 2019 -- Aug. 31, 2019, Supervised.

**2018-2019**



<!-- -->

5. Jian Su, B.Sc., Computer Science, May 1, 2018 -- Aug. 31, 2018, Supervised.

**2016-2017**



<!-- -->

4. Jiaqi Xiao, B.Sc., Economics, Research Assistant, May 2016 -- Aug. 2016, Supervised.

**2015-2016**



<!-- -->

3. Jiaqi Xiao, B.Sc., Economics, May 2015 -- Aug. 2015, Supervised.

**2014-2015**



<!-- -->

2. Zhouji Zhang, B.Sc., Mathematics, June 1, 2014 -- June 30, 2014, Supervised.

**2013-2014**



<!-- -->

1. Bei Zhang, B.Sc., Statistics, May 1, 2013 -- Aug. 31, 2013, Supervised.

### 10.2 Graduate Student Supervision



**Ph.D. Students**



<!-- -->

4. **Jing Wang**, Ph.D., Biostatistics, School of Public Health, Co-supervised with Prof. Li Xing, 2023–2026 (Transferred to other supervisor)




<!-- -->

3. **Wutao Yin**, Ph.D., Biomedical Engineering, Co-supervised with Prof. FangXiang Wu, 2019–2021 (Defended: Dec. 17, 2021)

    * **Thesis:** [Artificial Intelligence Based Methods for Autism Spectrum Disorder Diagnosis from fMRI Data](https://harvest.usask.ca/handle/10388/13732)

    * **Employment:** Associate Professor, Ocean Institute, Northwestern Polytechnical University, Taicang Jiangsu, China




<!-- -->

2. **Tingxuan Wu**, Ph.D., Biostatistics, School of Public Health, Co-supervised with Prof. Cindy Feng, 2018–2023 (Defended: May 24, 2023)

    * **Thesis:** [Residual Diagnostics and Statistical Inference for Shared Frailty Models](https://harvest.usask.ca/handle/10388/14727)
    * **Employment:** Forestry Statistical Analyst, Ministry of Environment, Government of Saskatchewan



<!-- -->

1. **Lai Jiang**, Ph.D., Statistics, Math & Stat, Supervised, 2009–2015 (Defended: Sept. 14, 2015)

    * **Thesis:** [Fully Bayesian T-probit Regression with Heavy-tailed Priors for Selection in High-Dimensional Features with Grouping Structure](https://www.google.com/search?q=/researchteam/theses/Jiang,Lai_PhD_thesis_Sep_2015.pdf)
    * **Employment:** Postdoctoral fellow at Lady Davis Institute, Jewish General Hospital, McGill University in Montreal



**Master's Students**






<!-- -->

18. **Dananji Egodage (Shashiprabha)**, M.Sc., Statistics, Math & Stat, Co-supervised with Prof. Cindy Feng, 2023–2025 (Defended: Aug. 30, 2025)

    * **Thesis:** [Component-wise Z-residual Diagnosis for Bayesian Hurdle Models](https://harvest.usask.ca/items/02bfcf7a-e2c5-4edb-baf1-1812bd60fb5f)

    * **Employment:** Applied Researcher at Southeast College Saskatchewan




<!-- -->

17. **Wuqian Effie Gao**, M.Sc., Biostatistics, School of Public Health, Co-supervised with Prof. Cindy Feng, 2022–2024 (Defended: Aug. 30, 2024)

    * **Thesis:** [Z-residuals for Checking Bayesian Hurdle Models](https://harvest.usask.ca/items/ea0c9479-9914-4139-8027-9145190056c6)

    * **Employment:** Senior Data and Forecasting Analyst, Health Ministry, Government of Saskatchewan



<!-- -->

16. **Lina Li**, M.Sc., Statistics, Math & Stat, MITACS Project supervisor, Supervised, 2022–2022 (Completed: August 2022)



<!-- -->

15. **Hao Hu**, M.Sc., Statistics, Math & Stat, Co-supervised with Prof. Li Xing, 2021–2022 (Defended: Sept. 15, 2022)

    * **Thesis:** [Identifying Risk Factors for Cognitive Decline Using Statistical Learning Techniques and Functional Data Analysis](https://harvest.usask.ca/bitstream/handle/10388/14244/HU-THESIS-2022.pdf?sequence=1&isAllowed=y)

    * **Employment:** Senior Statistician in Health Ministry in a Chinese government



<!-- -->

14. **Man Chen**, M.Sc., Statistics, Math & Stat, Supervised, 2019–2021 (Defended: April 30, 2021)

    * **Thesis:** [Association between Gut Microbiome and Parkinson's Disease Revealed by Sparse Learning](https://harvest.usask.ca/bitstream/handle/10388/13403/CHEN-THESIS-2021.pdf?sequence=1&isAllowed=y)

    * **Employment:** AI Engineer at [Super GeoAI Technology Inc.](https://sga.ai)



<!-- -->

13. **Mei Dong**, M.Sc., Statistics, Math & Stat, Co-supervised with Prof. Lloyd Balbuena, 2017–2019 (Defended: May 23, 2019)

    * **Thesis:** [Feature Selection Bias in Assessing the Predictivity of SNPs for Alzheimer's Disease](https://www.google.com/search?q=/researchteam/theses/DONG-THESIS-2019.pdf)

    * **Employment:** Senior Research Analyst at the University of Toronto



<!-- -->

12. **Tingxuan Wu**, M.Sc., Biostatistics, School of Public Health, Co-supervised with Prof. Cindy Feng, 2017–2018 (Defended: Dec. 4, 2018)

    * **Thesis:** [Randomized Survival Probability Residuals for Assessing Parametric Survival Models](https://www.google.com/search?q=/researchteam/theses/WU-THESIS-2018.pdf)

    * **Employment:** PhD student at the University of Saskatchewan



<!-- -->

11. **Xiaoying Wang**, M.Sc., Statistics, Math & Stat, Supervised, 2016–2019 (Defended: March 12, 2019)

    * **Thesis:** [Comparison of Statistical Testing and Predictive Analysis Methods for Feature Selection in Zero-inflated Microbiome Data](https://www.google.com/search?q=/researchteam/theses/WANG-THESIS-2019.pdf)



<!-- -->

10. **Wei Bai**, M.Sc., Statistics, Math & Stat, Co-supervised with Prof. Cindy Feng, 2016–2018 (Defended: July 12, 2018)

    * **Thesis:** [Randomized Quantile Residual for Assessing Generalized Linear Mixed Models with Application to Zero-Inflated Microbiome Data](https://www.google.com/search?q=/researchteam/theses/BAI-THESIS-2018.pdf)

    * **Employment:** Lead Statistical Analyst, Bayer Pharmaceuticals, Ontario, Canada (First Employment: Statistical Programmer, Everest Clinical Research, Markham, Ontario)



<!-- -->

9. **Arash Shamloo**, M.MATH., Statistics, Math & Stat, Supervised, 2016–2017 (Project Completed: August 31, 2017)

    * **Project:** Randomized quantile residuals for accelerated failure time models

    * **Employment:** Research assistant, College of Pharmacy and Nutrition, University of Saskatchewan



<!-- -->

8. **Alireza Sadeghpour**, M.Sc., Statistics, Math & Stat, Co-supervised with Prof. Cindy Feng, 2016–2017 (Defended: Sept. 19, 2017)

    * **Thesis:** [Empirical Investigation of Randomized Quantile Residuals for Diagnosis of Non-Normal Regression Models](https://www.google.com/search?q=/researchteam/theses/alithesis.pdf)

    * **Employment:** Statistician at Health Canada, Ottawa



<!-- -->

7. **Yunyang Wang**, M.Sc., Statistics, Math & Stat, Supervised, 2014–2017 (Defended: Nov. 18, 2017)

    * **Thesis:** [Comparison of Stochastic Volatility Models Using Integrated Information Criteria](https://www.google.com/search?q=/researchteam/theses/WANG-THESIS-2016.pdf)

    * **Employment:** Statistician at Montreal office of [Evidera](http://www.evidera.com/) (a PPD company), Montreal, QC (First Employment: Intern at the PathWise Solutions, AON Securities, Toronto)



<!-- -->

6. **Naorin Islam**, M.Sc., Statistics, Math & Stat, Co-supervised with Prof. Shahedul Khan, 2014–2017 (Defended: Nov. 28, 2017)

    * **Thesis:** [Substance Abuse and Health: A Structural Equation Modeling Approach to Assess Latent Health Effects](https://www.google.com/search?q=/researchteam/theses/ISLAM-THESIS-2016.pdf)

    * **Employment:** Senior Researcher and Statistical Analyst at Ministry of Health, Government of Saskatchewan. **First Employment**: Research assistant, College of Pharmacy and Nutrition, University of Saskatchewan



<!-- -->

5. **Setu Chandra Kar**, M.Sc., Statistics, Math & Stat, Supervised, 2014–2016 (Defended: 2016)



<!-- -->

4. **Shi Qiu**, M.Sc., Statistics, Math & Stat, Co-supervised with Prof. Cindy Feng, 2012–2015 (Defended: March 26, 2015)

    * **Thesis:** [Cross-validatory Model Comparison and Divergent Regions Detection using iIS and iWAIC for Disease Mapping](https://www.google.com/search?q=/researchteam/theses/QIU-THESIS.pdf)

    * **Employment:** Statistician, Mabwell Therapeutics, Inc., Shanghai, China (First Employment: Data Service Specialist at [IRD Inc.](http://www.irdinc.com/))



<!-- -->

3. **Masud Rana**, M.Sc., Statistics, Math & Stats, Co-supervised with Prof. Shahedul Khan, 2010–2012 (Defended: Sept. 2012)

    * **Thesis:** [Spatial-Longitudinal Bent-Cable Model with an Application to Atmospheric CFC Data](https://www.google.com/search?q=/researchteam/theses/Thesis_mdr091.pdf)

    * **Employment:** Biostatistician at Clinical Research Support Unit, College of Medicine, University of Saskatchewan



<!-- -->

2. **Lai Jiang**, M.Sc., Statistics, Math & Stats, Supervised, 2008–2009 (Transferred to Ph.D.; M.Sc. supervision ended)



<!-- -->

1. **Zhengrong Li**, M.Sc., Statistics, Math & Stats, Supervised, 2007–2012 (Defended: May 2012)

    * **Thesis:** [A Non-MCMC Procedure for Fitting Dirichlet Process Mixture Models](https://www.google.com/search?q=/researchteam/theses/zhli_thesis.pdf)

    * **Employment:** Data Service Specialist at [IRD Inc.](http://www.irdinc.com/)

### 10.3 Graduate Theses Supervised





**2025-2026**



<!-- -->

17. Dananji Egodage, 2025, Component-wise Z-residuals for Checking Bayesian Hurdle Models, M.Sc., defended on Aug. 30, 2025.

**2024-2025**



<!-- -->

16. Effie Wuqian Gao, 2024, Z-residuals for Checking Bayesian Hurdle Models, M.Sc., defended on Aug. 30, 2024.

**2023-2024**



<!-- -->

15. Tingxuan Wu, 2023, Residual Diagnostics and Statistical Inference for Shared Frailty Models, Ph.D., defended on May 24, 2023.

**2022-2023**



<!-- -->

14. Hao Hu, 2022, Identifying Risk Factors for Cognitive Decline using Statistical Learning Techniques and Functional Data Analysis, M.Sc., defended on Sept. 15, 2022.

**2021-2022**



<!-- -->

13. Wutao Yin, 2021, Artificial Intelligence Based Methods for Autism Spectrum Disorder Diagnosis from fMRI Data, Ph.D., defended on Dec. 17, 2021.


<!-- -->

12. Man Chen, 2021, Association Between Gut Microbiome and Parkinson's Disease Revealed by Sparse Learning, M.Sc., defended on April 30, 2021.

**2019-2020**



<!-- -->

11. Dong Mei, 2019, Feature Selection Bias in Assessing the Predictivity of SNPs for Alzheimer's Disease, M.Sc., defended on May 23, 2019.


<!-- -->

10. Xiaoying Wang, 2019, Comparison of Statistical Testing and Predictive Analysis Methods for Feature Selection in Zero-inflated Microbiome Data, M.Sc., defended on March 12, 2019.

**2018-2019**



<!-- -->

9. Tingxuan Wu, 2018, Randomized Survival Probability Residuals for Assessing Parametric Survival Models, M.Sc., defended on Dec. 4, 2018.


<!-- -->

8. Wei Bai, 2018, Randomized Quantile Residual for Assessing Generalized Linear Mixed Models with Application to Zero-Inflated Microbiome Data, M.Sc., defended on July 12, 2018.

**2016-2017**



<!-- -->

7. Yunyang Wang, 2016, Comparison of Stochastic Volatility Models Using Integrated Information Criteria, M.Sc., defended on Nov. 18, 2016.


<!-- -->

6. Alireza Sadeghpour, 2016, Empirical Investigation of Randomized Quantile Residuals for Diagnosis of Non-Normal Regression Models, M.Sc., defended on Sept. 19, 2016.


<!-- -->

5. Naorin Islam, 2016, Substance Abuse and Health: A Structural Equation Modeling Approach to Assess Latent Health Effects, M.Sc., defended on Nov. 28, 2016.

**2015-2016**



<!-- -->

4. Lai Jiang, 2015, Fully Bayesian T-probit Regression with Heavy-tailed Priors for Selection in High-Dimensional Features with Grouping Structure, Ph.D., defended on Sept. 14, 2015.
   
**2014-2015**



<!-- -->

3. Shi Qiu, 2015, Cross-validatory Model Comparison and Divergent Regions Detection using iIS and iWAIC for Disease Mapping, M.Sc., defended on March 26, 2015.

**2012-2013**



<!-- -->

2. Masud Rana, 2012, Spatial-Longitudinal Bent-Cable Model with An Application to Atmospheric CFC Data, M.Sc., defended in Sept. 2012.


<!-- -->

1. Zhengrong Li, 2012, A Non-MCMC Procedure for Fitting Dirichlet Process Mixture Models, M.Sc., defended in May 2012.

### 10.4 Supervision of Post-Doctoral Fellows and Research Associates





<!-- -->

4. Tingxuan Wu, University of Saskatchewan, Postdoc Research Associate,  Jan. 2025 – July 2026.


<!-- -->

3. Tingxuan Wu, University of Saskatchewan, Postdoc Fellow, June 2023 – April 2024.


<!-- -->

2. Ming Ming Zhang, MITACS Postdoc, 2022-2025.


<!-- -->

1. Jinhong Shi, team-supervised for CFREF projects, Sept. 2016 - Aug. 2019.

### 10.5 Staff Supervision





<!-- -->

1. Saima Khosa, faculty mentoring, Sept. 2022- Dec. 2022.

### 10.6 Thesis Committee Memberships

```{=html}
<details class="course-details" style="margin-bottom: 1.5rem;">
<summary style="background-color: #e0e0e0; color: #333333; padding: 0px 5px; cursor: pointer; border-radius: 4px; font-weight: bold; display: inline-block; user-select: none; border: 1px solid #cccccc;">
  &#9662;
</summary>
```


::: {.cell}
::: {.cell-output-display}

```{=html}
<div id="qwbfxgnnsz" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#qwbfxgnnsz table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#qwbfxgnnsz thead, #qwbfxgnnsz tbody, #qwbfxgnnsz tfoot, #qwbfxgnnsz tr, #qwbfxgnnsz td, #qwbfxgnnsz th {
  border-style: none;
}

#qwbfxgnnsz p {
  margin: 0;
  padding: 0;
}

#qwbfxgnnsz .gt_table {
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
  border-top-style: hidden;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: hidden;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#qwbfxgnnsz .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#qwbfxgnnsz .gt_title {
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

#qwbfxgnnsz .gt_subtitle {
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

#qwbfxgnnsz .gt_heading {
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

#qwbfxgnnsz .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qwbfxgnnsz .gt_col_headings {
  border-top-style: hidden;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: hidden;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#qwbfxgnnsz .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
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

#qwbfxgnnsz .gt_column_spanner_outer {
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

#qwbfxgnnsz .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#qwbfxgnnsz .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#qwbfxgnnsz .gt_column_spanner {
  border-bottom-style: hidden;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#qwbfxgnnsz .gt_spanner_row {
  border-bottom-style: hidden;
}

#qwbfxgnnsz .gt_group_heading {
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

#qwbfxgnnsz .gt_empty_group_heading {
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

#qwbfxgnnsz .gt_from_md > :first-child {
  margin-top: 0;
}

#qwbfxgnnsz .gt_from_md > :last-child {
  margin-bottom: 0;
}

#qwbfxgnnsz .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: none;
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

#qwbfxgnnsz .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: hidden;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#qwbfxgnnsz .gt_stub_row_group {
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

#qwbfxgnnsz .gt_row_group_first td {
  border-top-width: 2px;
}

#qwbfxgnnsz .gt_row_group_first th {
  border-top-width: 2px;
}

#qwbfxgnnsz .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#qwbfxgnnsz .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#qwbfxgnnsz .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#qwbfxgnnsz .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qwbfxgnnsz .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#qwbfxgnnsz .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#qwbfxgnnsz .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#qwbfxgnnsz .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#qwbfxgnnsz .gt_table_body {
  border-top-style: hidden;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: hidden;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qwbfxgnnsz .gt_footnotes {
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

#qwbfxgnnsz .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#qwbfxgnnsz .gt_sourcenotes {
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

#qwbfxgnnsz .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#qwbfxgnnsz .gt_left {
  text-align: left;
}

#qwbfxgnnsz .gt_center {
  text-align: center;
}

#qwbfxgnnsz .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#qwbfxgnnsz .gt_font_normal {
  font-weight: normal;
}

#qwbfxgnnsz .gt_font_bold {
  font-weight: bold;
}

#qwbfxgnnsz .gt_font_italic {
  font-style: italic;
}

#qwbfxgnnsz .gt_super {
  font-size: 65%;
}

#qwbfxgnnsz .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#qwbfxgnnsz .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#qwbfxgnnsz .gt_indent_1 {
  text-indent: 5px;
}

#qwbfxgnnsz .gt_indent_2 {
  text-indent: 10px;
}

#qwbfxgnnsz .gt_indent_3 {
  text-indent: 15px;
}

#qwbfxgnnsz .gt_indent_4 {
  text-indent: 20px;
}

#qwbfxgnnsz .gt_indent_5 {
  text-indent: 25px;
}

#qwbfxgnnsz .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#qwbfxgnnsz div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" style="table-layout:fixed;width:100%;" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <colgroup>
    <col style="width:5%;"/>
    <col style="width:25%;"/>
    <col style="width:5%;"/>
    <col style="width:20%;"/>
    <col style="width:30%;"/>
    <col style="width:10%;"/>
  </colgroup>
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="background-color: #D9D9D9; font-weight: bold;" scope="col" id="a#">#</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="background-color: #D9D9D9; font-weight: bold;" scope="col" id="NAME">NAME</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="background-color: #D9D9D9; font-weight: bold;" scope="col" id="DEG">DEG</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="background-color: #D9D9D9; font-weight: bold;" scope="col" id="PROGRAM">PROGRAM</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="background-color: #D9D9D9; font-weight: bold;" scope="col" id="TIME-FRAME">TIME FRAME</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="background-color: #D9D9D9; font-weight: bold;" scope="col" id="ROLE">ROLE</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="#" class="gt_row gt_center">31</td>
<td headers="NAME" class="gt_row gt_left">Tiansui Wu</td>
<td headers="DEG" class="gt_row gt_center">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left">Biostatistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2025--Present</td>
<td headers="ROLE" class="gt_row gt_center">Chair</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">30</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Prabhawi Kahatapitiye</td>
<td headers="DEG" class="gt_row gt_center gt_striped">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2025--Present</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">29</td>
<td headers="NAME" class="gt_row gt_left">Rasel Kabir</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Biostatistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2025--Present</td>
<td headers="ROLE" class="gt_row gt_center">Chair</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">28</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Mohammad Toranjsimin</td>
<td headers="DEG" class="gt_row gt_center gt_striped">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Biostatistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2023--2025 (Def. 09/2025)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">27</td>
<td headers="NAME" class="gt_row gt_left">Lina Li</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Biostatistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2023--Present</td>
<td headers="ROLE" class="gt_row gt_center">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">26</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Kyle Gardiner</td>
<td headers="DEG" class="gt_row gt_center gt_striped">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2023--2024 (Def. 09/2024)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">25</td>
<td headers="NAME" class="gt_row gt_left">Mangladeep Bhullar</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Physics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2023--2025 (Def. 11/2025)</td>
<td headers="ROLE" class="gt_row gt_center">Cognate</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">24</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Hammed Jimoh</td>
<td headers="DEG" class="gt_row gt_center gt_striped">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2022--2023</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">23</td>
<td headers="NAME" class="gt_row gt_left">Qi Zhang</td>
<td headers="DEG" class="gt_row gt_center">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left">Sociology</td>
<td headers="TIME FRAME" class="gt_row gt_left">2021--2022</td>
<td headers="ROLE" class="gt_row gt_center">External</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">22</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Han Wang</td>
<td headers="DEG" class="gt_row gt_center gt_striped">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Sociology</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2020--Present</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Cognate</td></tr>
    <tr><td headers="#" class="gt_row gt_center">21</td>
<td headers="NAME" class="gt_row gt_left">Yanzhao Cheng</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Biostatistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2020--2022 (Def. 10/2021)</td>
<td headers="ROLE" class="gt_row gt_center">Chair</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">20</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Naeima Ashleik</td>
<td headers="DEG" class="gt_row gt_center gt_striped">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2017--2018 (Def. 03/2018)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">19</td>
<td headers="NAME" class="gt_row gt_left">Mehdi Rostami</td>
<td headers="DEG" class="gt_row gt_center">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left">Biostatistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2014--2016 (Def. 06/2016)</td>
<td headers="ROLE" class="gt_row gt_center">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">18</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Sanjeev Rijal</td>
<td headers="DEG" class="gt_row gt_center gt_striped">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2014--2018 (Def. 07/2017)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">17</td>
<td headers="NAME" class="gt_row gt_left">Farhad Maleki</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Bioinformatics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2014--2019</td>
<td headers="ROLE" class="gt_row gt_center">Cognate</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">16</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Saima Khan Khosa</td>
<td headers="DEG" class="gt_row gt_center gt_striped">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2014--2017</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">15</td>
<td headers="NAME" class="gt_row gt_left">Yue Dong</td>
<td headers="DEG" class="gt_row gt_center">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2014--2016 (Def. 06/2016)</td>
<td headers="ROLE" class="gt_row gt_center">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">14</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Temitope Adesina</td>
<td headers="DEG" class="gt_row gt_center gt_striped">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Biostatistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2014--2015</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Chair</td></tr>
    <tr><td headers="#" class="gt_row gt_center">13</td>
<td headers="NAME" class="gt_row gt_left">Sudhakar Achath</td>
<td headers="DEG" class="gt_row gt_center">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2014--2017 (Def. 05/2017)</td>
<td headers="ROLE" class="gt_row gt_center">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">12</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Xiaolei Yu</td>
<td headers="DEG" class="gt_row gt_center gt_striped">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Geography</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2012--2022 (Def. 06/2022)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Cognate</td></tr>
    <tr><td headers="#" class="gt_row gt_center">11</td>
<td headers="NAME" class="gt_row gt_left">Matthew Schmirler</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2012--2022 (Def. 07/2022)</td>
<td headers="ROLE" class="gt_row gt_center">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">10</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Masha Naseri</td>
<td headers="DEG" class="gt_row gt_center gt_striped">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Computer Sci.</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2012--2014 (Def. 02/2014)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Cognate</td></tr>
    <tr><td headers="#" class="gt_row gt_center">9</td>
<td headers="NAME" class="gt_row gt_left">Chel Hee Lee</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2012--2013</td>
<td headers="ROLE" class="gt_row gt_center">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">8</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Weiwei Fan</td>
<td headers="DEG" class="gt_row gt_center gt_striped">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Bioinformatics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2012--2014 (Def. 01/2014)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">7</td>
<td headers="NAME" class="gt_row gt_left">Zhaoqin Li</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Geography</td>
<td headers="TIME FRAME" class="gt_row gt_left">2011--2017 (Def. 04/2017)</td>
<td headers="ROLE" class="gt_row gt_center">Cognate</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">6</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Courtney Kendall</td>
<td headers="DEG" class="gt_row gt_center gt_striped">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2011--2014 (Def. 08/2014)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">5</td>
<td headers="NAME" class="gt_row gt_left">Michael Janzen</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Computer Sci.</td>
<td headers="TIME FRAME" class="gt_row gt_left">2011--2012 (Def. 03/2012)</td>
<td headers="ROLE" class="gt_row gt_center">Cognate</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">4</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Matthew Schmirler</td>
<td headers="DEG" class="gt_row gt_center gt_striped">M.Sc.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2010--2013 (Def. 09/2012)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center">3</td>
<td headers="NAME" class="gt_row gt_left">Mohammed Obeidat</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Statistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2010--2014 (Def. 07/2014)</td>
<td headers="ROLE" class="gt_row gt_center">Member</td></tr>
    <tr><td headers="#" class="gt_row gt_center gt_striped">2</td>
<td headers="NAME" class="gt_row gt_left gt_striped">Lingling Jin</td>
<td headers="DEG" class="gt_row gt_center gt_striped">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left gt_striped">Bioinformatics</td>
<td headers="TIME FRAME" class="gt_row gt_left gt_striped">2010--2018 (Def. 08/2017)</td>
<td headers="ROLE" class="gt_row gt_center gt_striped">Cognate</td></tr>
    <tr><td headers="#" class="gt_row gt_center">1</td>
<td headers="NAME" class="gt_row gt_left">Tolulope Sajobi</td>
<td headers="DEG" class="gt_row gt_center">Ph.D.</td>
<td headers="PROGRAM" class="gt_row gt_left">Biostatistics</td>
<td headers="TIME FRAME" class="gt_row gt_left">2008--2012 (Def. 03/2012)</td>
<td headers="ROLE" class="gt_row gt_center">Member</td></tr>
  </tbody>
  
</table>
</div>
```

:::
:::


```{=html}
</details>
```

## 11. BOOKS AND CHAPTERS IN BOOKS

### 11.1 Authored Books





<!-- -->

2. Soltanifar, M., Li, L., and Rosenthal, J., 2010. A Collection of Exercises in Advanced Probability Theory - the solutions manual of all even-numbered exercises from “A First Look at Rigorous Probability Theory”, World Scientific Publishing, (Second Edition, 2006), Singapore.


<!-- -->

1. Li, L., 2007. Bayesian Classification and Regression with High Dimensional Features. (Ph.D. Thesis), Toronto: University of Toronto.

### 11.3 Chapters in Books





<!-- -->

1. Feng, C. X. and  Li, L ., 2016. Modeling Zero Inflation and Overdispersion in the Length of Hospital Stay for Patients with Ischaemic Heart Disease, in the book Advanced Statistical Methods in Big-Data Sciences, edited by D. Chen, J. Chen, X. Lu, G. Yi and H. Yu, Springer, Chapter 3, pp. 35-53.

## 12. PAPERS IN REFEREED JOURNALS


**2026-2027**



<!-- -->

34. Wu, T., Gao, WE, Feng, C., and Li, L., Z-residuals for Diagnosing Bayesian Models, *Journal of American Statistical Association*, under revision. [[**Slides**](https://zresidual-slides-jasa-r1.longhai-li.workers.dev/)]

**2025-2026**
 


<!-- -->

33. Wu, T., Li, L., and Feng, C., $Z$-residuals Diagnostics for Cox Proportional Hazards Models: Distinguishing Functional Form Misspecification from Nonproportional Hazards, with an Application to Biliary Cirrhosis Survival Times, *Canadian Journal of Statistics*, Accepted on June 5, 2026.


<!-- -->

32. Nolan, J., Su, C., Li, L., 2025. Evaluating Railroad Duopoly Behavior: A Market Level Analysis. *Review of Network Economics* 24, 87–111. [https://doi.org/10.1515/rne-2025-0034](https://doi.org/10.1515/rne-2025-0034)
                   
**2024-2025**



<!-- -->

31. Wu, T., Feng, C., Li, L., 2025. Cross-validatory Z-Residual for Diagnosing Shared Frailty Models. *The American Statistician*, 79(2), 198–211. [https://doi.org/10.1080/00031305.2024.2421370](https://doi.org/10.1080/00031305.2024.2421370) [[**PDF**](/doc/cv_zresidual_final.pdf)]; [[**Free Reprints**](https://www.tandfonline.com/eprint/9CQD3QCVP56MCVKFZWEY/full?target=10.1080/00031305.2024.2421370)]; [[**slides**](https://api.zotero.org/users/1693946/publications/items/7FZTDQ3Z/file/view)]; [[**Z-residual on Github**](https://tiw150.github.io/Zresidual/index.html)]; [[**Demo**](https://tiw150.github.io/CV_Zresidual_demo.html)]


<!-- -->

30. Wu, T., Li, L., Feng, C., 2025. Z-residual diagnostic tool for assessing covariate functional form in shared frailty models. *Journal of Applied Statistics*, 52(1), 28–58. [https://doi.org/10.1080/02664763.2024.2355551](https://doi.org/10.1080/02664763.2024.2355551) [[**PDF**](/doc/jas_z_residual_nolinear.pdf)]; [[**Z-residual on Github**](https://tiw150.github.io/Zresidual/index.html)]; [[**Demo**](https://tiw150.github.io/Zresidual_demo.html)] [[**slides**](https://api.zotero.org/users/1693946/publications/items/WRQUGMIR/file/view)]


<!-- -->

29. Wu, T., Feng, C., Li, L., 2025. A Comparison of Estimation Methods for Shared Gamma Frailty Models. *Statistics in Biosciences*, Volume 17, pages 791–812. [https://doi.org/10.1007/s12561-024-09444-7](https://doi.org/10.1007/s12561-024-09444-7) [[**PDF**](/doc/sib_compfrailty.pdf)]
  
**2023-2024**



<!-- -->

28. Feng, C., Li, L., Xu, C., 2023. Advancements in predicting and modeling rare event outcomes for enhanced decision-making. *BMC Medical Research Methodology* 23, Article 243 (pp. 1-3). [https://doi.org/10.1186/s12874-023-02060-x](https://doi.org/10.1186/s12874-023-02060-x)

**2021-2022**



<!-- -->

27. Yin, W., Li, L., Wu, F.-X., 2022. A semi-supervised autoencoder for autism disease diagnosis. *Neurocomputing*, 483, 140–147. [https://doi.org/10.1016/j.neucom.2022.02.017](https://doi.org/10.1016/j.neucom.2022.02.017)


<!-- -->

26. Cheng, H., Wang, W., Li, L., 2022. Determinants of Citizen Acceptance of White-Collar Crime in China. *Journal of Asian and African Studies*, 59(3), 826-843. [https://doi.org/10.1177/00219096221123742](https://doi.org/10.1177/00219096221123742) (Published OnlineFirst; final pagination may vary.)


<!-- -->

25. Yin, W., Li, L., Wu, F.-X., 2022. Corrigendum to “Deep learning for brain disorder diagnosis based on fMRI images, Neurocomputing 469 (2022) 332–345”. *Neurocomputing* 509, 271. [https://doi.org/10.1016/j.neucom.2022.08.074](https://doi.org/10.1016/j.neucom.2022.08.074)


<!-- -->

24. Yin, W., Li, L., Wu, F.-X., 2022. Deep learning for brain disorder diagnosis based on fMRI images. *Neurocomputing* 469, 332–345. [https://doi.org/10.1016/j.neucom.2020.05.113](https://doi.org/10.1016/j.neucom.2020.05.113)

**2020-2021**



<!-- -->

23. Bai, W., Dong, M., Li, L., Feng, C., Xu, W., 2021. Randomized quantile residuals for diagnosing zero-inflated generalized linear mixed models with applications to microbiome count data. *BMC Bioinformatics* 22, Article 564 (pp. 1-17). [https://doi.org/10.1186/s12859-021-04371-6](https://doi.org/10.1186/s12859-021-04371-6) [[**slides**](/doc/talks/rqr_glmm_ssc2022.pdf)].


<!-- -->

22. Li, L., Wu, T., Feng, C., 2021. Model Diagnostics for Censored Regression via Randomized Survival Probabilities. *Statistics in Medicine* 40(6), 1482–1497. [https://doi.org/10.1002/sim.8852](https://doi.org/10.1002/sim.8852) [[**PDF**](/doc/1911.00198v4.pdf)]; [[**R Functions and Demonstration**](./software/NRSP)]; [[**slides**](https://api.zotero.org/users/1693946/publications/items/Z7WFLYHB/file/view)];


<!-- -->

21. Dagasso, G., Yan, Y., Wang, L., Li, L., Kutcher, R., Zhang, W., Jin, L., 2021. Leveraging Machine Learning to Advance Genome-Wide Association Studies. *International Journal of Data Mining and Bioinformatics*, 25(1/2), 17–36. [https://doi.org/10.1504/ijdmb.2021.116881](https://doi.org/10.1504/ijdmb.2021.116881)

**2019-2020**



<!-- -->

20. Dong, M., Li, L., Chen, M., Kusalik, A., Xu, W., 2020. Predictive analysis methods for human microbiome data with application to Parkinson’s disease. *PLOS ONE* 15(8), e0237779 (pp. 1-20). [https://doi.org/10.1371/journal.pone.0237779](https://doi.org/10.1371/journal.pone.0237779)


<!-- -->

19. Feng, C., Li, L., Sadeghpour, A., 2020. A comparison of residual diagnosis tools for diagnosing regression models for count data. *BMC Medical Research Methodology* 20, Article 175 (pp. 1-11). [https://doi.org/10.1186/s12874-020-01055-2](https://doi.org/10.1186/s12874-020-01055-2) [[**R code used in this paper**](https://github.com/longhaiSK/longhaiSK.github.io/tree/main/software/RQR)]


<!-- -->

18. Jiang, L., Greenwood, C.M.T., Yao, W., Li, L., 2020. Bayesian Hyper-LASSO Classification for Feature Selection with Application to Endometrial Cancer RNA-seq Data. *Scientific Reports* 10, Article 9747 (pp. 1-12). [https://doi.org/10.1038/s41598-020-66466-z](https://doi.org/10.1038/s41598-020-66466-z)


<!-- -->

17. Soltanifar, M., Li, L., and Rosenthal, J. S., 2010. A Collection of Exercises in Advanced Probability Theory, World Scientific Publishing, Singapore. [[**PDF**](http://www.worldscientific.com/doi/suppl/10.1142/6300/suppl_file/6300-solutionsmanual_free.pdf)].

**2018-2019**



<!-- -->

16. Shi, J., Yan, Y., Links, M.G., Li, L., Dillon, J.-A.R., Horsch, M., Kusalik, A., 2019. Antimicrobial resistance genetic factor identification from whole-genome sequence data using deep feature selection. *BMC Bioinformatics* 20, Article 535 (pp. 1-14). [https://doi.org/10.1186/s12859-019-3054-4](https://doi.org/10.1186/s12859-019-3054-4)

**2017-2018**



<!-- -->

15. Essien, S. K., Feng, C., Sun, W., Farag, M., Li, L., Gao, Y., 2018. Sleep duration and sleep disturbances in association with falls among the middle-aged and older adults in China: a population-based nationwide study. *BMC Geriatrics* 18, Article 196 (pp. 1-9). [https://doi.org/10.1186/s12877-018-0889-x](https://doi.org/10.1186/s12877-018-0889-x)


<!-- -->

14. Li, L., Yao, W., 2018. Fully Bayesian Logistic Regression with Hyper-Lasso Priors for High-dimensional Feature Selection. *Journal of Statistical Computation and Simulation*, 88(14), 2827–2851. [https://doi.org/10.1080/00949655.2018.1490418](https://doi.org/10.1080/00949655.2018.1490418) [[**PDF**](http://arxiv.org/abs/1405.3319)]; [[**software**](/software/BLRHL/index.html)]; [[**slides**](/doc/bplr/bplrslides-mgill.pdf)].

**2016-2017**



<!-- -->

13. Jin, L., McQuillan, I., Li, L., 2017. Computational Identification of Harmful Mutation Regions to the Activity of Transposable Elements. *BMC Genomics* 18, Article 862 (pp. 1-10). [https://doi.org/10.1186/s12864-017-4227-z](https://doi.org/10.1186/s12864-017-4227-z)


<!-- -->

12. Li, L., Feng, C.X., Qiu, S., 2017. Estimating Cross-validatory Predictive P-values with Integrated Importance Sampling for Disease Mapping Models. *Statistics in Medicine*, 36(14), 2220–2236. [https://doi.org/10.1002/sim.7278](https://doi.org/10.1002/sim.7278) [[**PDF**](http://arxiv.org/abs/1603.07668)]; [[**slides**](/doc/talks/dmpvalues_ssc.pdf)]; [[**R Functions**](/software/dmpvalues/dmpvalues-larynx.R)].


<!-- -->

11. Feng, C. X., Rostami, M., Li, L., 2017. Impact of Misspecified Residual Correlation Structure on the Parameter Estimates in a Shared Spatial Frailty Model. *Journal of Statistical Computation and Simulation*, 87(12), 2384–2410. [https://doi.org/10.1080/00949655.2017.1332196](https://doi.org/10.1080/00949655.2017.1332196)

**2015-2016**



<!-- -->

10. Li, L., Qiu, S., Zhang, B., Feng, C.X., 2016. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC. *Statistics and Computing*, 26(4), 881–897. [https://doi.org/10.1007/s11222-015-9577-2](https://doi.org/10.1007/s11222-015-9577-2) [[**PDF**](http://arxiv.org/abs/1404.2918)]; [[**slides**](/doc/iis/iisslides-manitoba.pdf)].

**2013-2014**



<!-- -->

9. Yao, W., Li, L., 2014. A New Regression Model: Modal Linear Regression. *Scandinavian Journal of Statistics*, 41(3), 656–671. [https://doi.org/10.1111/sjos.12054](https://doi.org/10.1111/sjos.12054) [[**PDF**](/doc/others/modlin.pdf)].


<!-- -->

8. Yao, W., Li, L., 2014. Bayesian Mixture Labeling by Minimizing Deviance of Classification Probabilities to Reference Labels. *Journal of Statistical Computation and Simulation*, 84(2), 310–323.

**2011-2012**



<!-- -->

7. Khan, S. A., Rana, M., Li, L., Dubin, J. A., 2012. A Comparative Case Study to Monitor and Understand Atmospheric CFC Decline with the Spatial-Longitudinal Bent-Cable Model. *International Journal of Statistics and Probability*, 1(2), 56–68.


<!-- -->

6. Li, L., 2012. Bias-corrected Hierarchical Bayesian Classification with a Selected Subset of High-dimensional Features. *Journal of American Statistical Association*, 107(497), 120–134. [https://doi.org/10.1198/JASA.2011.AP10446](https://doi.org/10.1198/JASA.2011.AP10446) [[**PDF**](/doc/bcbcsf/jasapaper.pdf)]; [[**software**](/software/BCBCSF)]; [[**slides**](/doc/bcbcsf/shanghaistat2015_calgary_longhai_li.pdf)].


<!-- -->

5. Sajobi, T.T., Lix, L. M., Dansu, B. M., Laverty, W., Li, L., 2012. Robust Descriptive Discriminant Analysis for Repeated Measures Data. *Computational Statistics & Data Analysis*, 56(9), 2782–2794. [https://doi.org/10.1016/j.csda.2012.02.029](https://doi.org/10.1016/j.csda.2012.02.029)

**2010-2011**



<!-- -->

4. Sajobi, T. T., Lix, L., Li, L., Laverty, W., 2011. Discriminant Analysis for Repeated Measures Data: Effects of Mean and Covariance Misspecification on Bias and Error in Discriminant Function Coefficients. *Journal of Modern Applied Statistical Methods*, 10(2), 571–582. [https://doi.org/10.22237/jmasm/1320120840](https://doi.org/10.22237/jmasm/1320120840)

**2009-2010**



<!-- -->

3. Li, L., 2010. Are Bayesian Inferences Weak for Wasserman’s Example? *Communications in Statistics – Simulation and Computation*, 39(4), 655–667. [https://doi.org/10.1080/03610910903576540](https://doi.org/10.1080/03610910903576540) [[**PDF**](/doc/wman/wman-r1-online.pdf)]; [[**slides**](/doc/wman/ssc10talk.pdf)].

**2007-2008**



<!-- -->

2. Li, L., Zhang, J., Neal, R.M., 2008. A method for avoiding bias from features selection with application to naive Bayes classification models. *Bayesian Analysis*, 3(1), 171–196. [https://doi.org/10.1214/08-BA307](https://doi.org/10.1214/08-BA307) [[**PDF**](/doc/naivebayes/naivebayes.pdf)]; [[**slides**](/doc/naivebayes/uktalk.pdf)]; [[**software**](/software/predbayescor/release.html)].


<!-- -->

1. Li, L., Neal, R.M., 2008. Compressing Parameters in Bayesian High-order Models with Application to Logistic Sequence Models. *Bayesian Analysis*, 3(4), 793–822. [https://doi.org/10.1214/08-BA330](https://doi.org/10.1214/08-BA330) [[**PDF**](/doc/seqpred/seqpred.pdf)]; [[**slides**](/doc/seqpred/seqpred-ssc.pdf)]; [[**software**](/software/BPHO/release.html)].

## 13. REFEREED CONFERENCE PUBLICATIONS





<!-- -->

3. Yin, W., Li, L., Wu, F.-X., 2021. A Graph Attention Neural Network for Diagnosing ASD with fMRI Data, in: 2021 IEEE International Conference on Bioinformatics and Biomedicine (BIBM). pp. 1131–1136. [https://doi.org/10.1109/BIBM52615.2021.9669849](https://doi.org/10.1109/BIBM52615.2021.9669849)


<!-- -->

2. Dagasso, G., Yan, Y., Wang, L., Li, L., Kutcher, R., Zhang, W., Jin, L., 2020. Comprehensive-GWAS: a pipeline for genome-wide association studies utilizing cross-validation to assess the predictivity of genetic variations, in: 2020 IEEE International Conference on Bioinformatics and Biomedicine (BIBM). Presented at the 2020 IEEE International Conference on Bioinformatics and Biomedicine (BIBM), pp. 1361–1367. [https://doi.org/10.1109/BIBM49941.2020.9313355](https://doi.org/10.1109/BIBM49941.2020.9313355)


<!-- -->

1. Jin, L., McQuillan, I., and Li, L., 2016, Computational Identification of Regions that Influence Activity of Transposable Elements in the Human Genome. Proceeding of 2016 IEEE International Conference on Bioinformatics and Biomedicine, pp. 592-599.

## 14. PRESENTATIONS

### 14.1 Invited Presentations





**2026-2027**



<!-- -->

34. Z-residuals for diagnosing Bayesian Models. Presented at: University of Toronto, Biostatistics Seminar, 1 September, 2026 




**2025-2026**





<!-- -->

33. Z-residuals for Checking Bayesian Models. Presented at: University of Calgary, Calgary, AB, Canada; July 28, 2025



<!-- -->

32. Sparse Learning for Assessing the Association Between Gut Microbiome and Parkinson’s Disease. Presented at: The 3rd JCSDS, Hangzhou, China, July 13, 2025.

**2024-2025**



<!-- -->

31. Z-residuals for Checking Bayesian Models. Presented at: International Conference on Statistics and Data Science, Vancouver, BC, Canada; June 24, 2025


<!-- -->

30. Z-residuals for Checking Bayesian Hurdle Models. Presented at: EcoStat 2024; July 17, 2024; Beijing, China.

**2023-2024**



<!-- -->

29. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, ICSA Canada Chapter Symp., June 9, 2024, Niagara Falls, Canada


<!-- -->

28. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, Annual Meeting of SSC, St John’s, Canada, June 2, 2024


<!-- -->

27. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, Dept. Seminar, Texas State University, USA, March 8, 2024


<!-- -->

26. Z-residual Diagnostic Tool for Assessing Covariate Functional Form in Proportional Hazards Models with Shared Frailty, Dept. Seminar, Sun Yat-sen University, China, Jan. 4, 2024

**2022-2023**



<!-- -->

25. Cross-validatory Residual Diagnostics for Bayesian Spatial Models, Annual Meeting of SSC, Ottawa, May 29, 2023


<!-- -->

24. Model Diagnostics for Censored Regression via Randomized Survival Probabilities, the 5th ICSA Canada Symposium, 9 July 2022, Banff, AB, Canada


<!-- -->

23. Model Diagnostics for Censored Regression via Randomized Survival Probabilities, 17 Aug. 2022, Statistics Conference in Genomics, Pharmaceutical Science, and Health Data Science, University of Victoria, Victoria, BC, Canada

**2021-2022**



<!-- -->

22. Randomized quantile residuals for diagnosing zero-inflated generalized linear mixed models with applications to microbiome count data, SSC Annual Meeting (virtual), May 2022.


<!-- -->

21. Model Diagnostics for Censored Regression via Randomized Survival Probabilities, The 6th Canadian Conference in Applied Statistics, Hosted by Concordia University (virtual), 16 July 2021.

**2019-2020**



<!-- -->

20. Estimating Cross-validatory Predictive P-values with Integrated Importance Sampling for Disease Mapping Models, Aug. 2019, the 4th ICSA-Canada Symposium held at Queen’s University.

**2018-2019**



<!-- -->

19. Feature Selection Bias in Assessing the Predictivity of SNPs for Alzheimer's Disease, June 2019, Seminar talk, University of Manitoba, Canada

**2017-2018**



<!-- -->

18. Randomized Quantile Residuals for Checking GLMM with Application to Zero-inflated Microbiome Data, June 2018, Annual Meeting of Statistical Society of Canada, McGill University, Canada.


<!-- -->

17. Fully Bayesian Classification with Heavy-tailed Priors for Selection in High-Dimensional Features with Grouping Structure, Aug. 2017, the 3rd ICSA-Canada Symposium held at Vancouver.

**2016-2017**



<!-- -->

16. Randomized Quantile Residuals: an Omnibus Model Diagnostic Tool with Unified Reference Distribution, June 2017, Seminar talk, School of Mathematical Sciences, Xiamen University, China.


<!-- -->

15. Fully Bayesian Classification with Heavy-tailed Priors for Selection in High-Dimensional Features with Grouping Structure, June 2017, Seminar talk, School of Mathematical Sciences, Xiamen University, China.


<!-- -->

14. Randomized Quantile Residuals: an Omnibus Model Diagnostic Tool with Unified Reference Distribution, June 2017, Seminar talk, Department of Biostatistics, Southern Medical University, Guangzhou, China.


<!-- -->

13. Estimating Cross-validatory Predictive P-values with Integrated Importance Sampling for Disease Mapping Models, June 2017, Annual Meeting of Statistical Society of Canada, University of Manitoba, Canada.


<!-- -->

12. Fully Bayesian Classification with Heavy-tailed Priors for Selection in High-Dimensional Features with Grouping Structure, Dec., 2016, Wuhan University, China.

**2015-2016**



<!-- -->

11. Cross-validatory Model Comparison and Divergent Regions Detection using iIS for Disease Mapping, Seminar of Dept of Math & Stat, University of Calgary, April 2016, Calgary, AB.


<!-- -->

10. Cross-validatory Model Comparison and Divergent Regions Detection using iIS for Disease Mapping, Seminar of Dept of Math & Stat, University of Alberta, Edmonton, AB.


<!-- -->

9. Cross-validatory Model Comparison and Divergent Regions Detection using iIS for Disease Mapping, Seminar of Department of Statistics, University of Manitoba, Jan. 2016, Winnipeg, MB.


<!-- -->

8. Bias-corrected Hierarchical Bayesian Classification with a Selected Subset of High-dimensional Features, ICSA Canada Chapter Annual Meeting, University of Calgary, Aug. 2015, Calgary, AB.

**2014-2015**



<!-- -->

7. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC, Dec. 2014, Tongji University, Shanghai, China.


<!-- -->

6. An Introduction to Microarray Data. Workshop on “Statistical Issues in Biomarker and Drug Co-development”, Nov. 2014, Fields Institute, Toronto, ON, Canada.

**2013-2014**



<!-- -->

5. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC. Statistics Seminar, April, Kansas State University, Manhattan, Kansas, USA.

**2011-2012**



<!-- -->

4. High-dimensional Feature Selection Using Hierarchical Bayesian Logistic Regression with Heavy-tailed Priors. CRM-ISM-GERAD Colloque de Statistique, April, McGill University, Montreal, Quebec, Canada.

**2010-2011**



<!-- -->

3. High-dimensional Classification using Hierarchical Bayesian Polychotomous Logistic Regression Models. Colloquia talk, Jan., The University of Western Ontario, London, ON, Canada.


<!-- -->

2. High-dimensional Classification using Hierarchical Bayesian Polychotomous Logistic Regression Models. Colloquia talk, Sept., Penn State University, University Park, PA, USA.

**2007-2008**



<!-- -->

1. Avoiding Bias from Feature Selection. CRISM 'workshop on Bayesian Analysis of High-dimensional Data, April, University of Warwick, Coventry, UK.

### 14.2 Contributed Presentations



**2013-2014**





<!-- -->

10. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC. Annual Meeting of Statistical Society of Canada, May 27, 2014, Toronto, ON, Canada.

**2010-2011**



<!-- -->

9. High-dimensional Classification using Hierarchical Bayesian Polychotomous Logistic Regression Models. The 8th ICSA International Conference, Dec. 20, 2010, Guangzhou, China.

**2009-2010**



<!-- -->

8. Sajobi, T., Lix, L., Laverty, W., and Li, L., 2010. Discriminant Analysis for Repeated Measures Data: Effects of Covariance Structure on Bias and Error in Discriminant Function Coefficients. Annual Meeting of Statistical Society of Canada, May 24, 2010, Quebec City, QC, Canada.


<!-- -->

7. Are Bayesian Inferences Weak for Wasserman’s Example? Annual Meeting of Statistical Society of Canada, May 25, 2010, Quebec City, QC, Canada.

**2008-2009**



<!-- -->

6. Calibrating Predictions Based on a Selected Subset of Features from Bayesian Gaussian Classification Models. Annual meeting of Statistical Society of Canada, January, Vancouver, BC, Canada.


<!-- -->

5. Calibrating Predictions Based on a Selected Subset of Features from Bayesian Gaussian Classification Models. Bayesian Biostatistics Conference, January, Houston, TX, USA.

**2007-2008**



<!-- -->

4. Compressing Parameters in Bayesian High-order Models. Annual Meeting of Statistical Society of Canada, May, Ottawa, ON, Canada.

**2006-2007**



<!-- -->

3. Compressing Parameters in Bayesian Models with High-order Interactions. The 3rd Monte Carlo Workshop, Harvard University, May, Cambridge, MA, USA.

**2005-2006**



<!-- -->

2. Avoiding Bias from Feature Selection in Regression and Classification Models. Joint Statistical Meeting, August, Seattle, WA, USA.


<!-- -->

1. Analysis of Obstructive Sleep Apnea Data with Bayesian Neural Network. Annual Meeting of Statistical Society of Canada, June, London, ON, Canada.

## 15. REPORTS AND OTHER OUTPUTS

### 15.1 Software Released Publicly {#research-software}





<!-- -->

11. Wu, T. and Li, L., 2026. `Zresidual`: Computing and Diagnosing Gaussian-like Residuals. [[pkgdown site]](https://tiw150.github.io/Zresidual/index.html). Version 0.1-0 on Github (April 2026); Version 0.2-0 on Github (August 2026). 


<!-- -->

10. Li, L., 2026. R Functions for Computing Z-residuals for `survreg` and `coxph` Objects. [[URL]](https://longhaisk.github.io/software/NRSP/index.html).


<!-- -->

9. Li, L., et al., 2021. Real-time estimates of $R_t$ for Covid-19 in Canada. [[URL]](https://longhaisk.github.io/CanadaCovidRt/). 


<!-- -->

8. Li, L. and Liu, S., 2019--2026. `HTLR`: Bayesian Logistic Regression with Hyper-LASSO priors. DOI: 10.32614/CRAN.package.HTLR. [[CRAN]](https://cran.r-project.org/web/packages/HTLR/index.html) [[Github]](https://longhaisk.github.io/HTLR) [[URL]](https://longhaisk.github.io/software/BLRHL/index.html). Version 0.4 (2019), version 0.4-1 (2019), version 0.4-2 (2020), version 0.4-3 (2020), version 0.4-4 (2022), version 1.0 (2026).


<!-- -->

7. Li, L., 2011--2026. `BCBCSF`: Bias-corrected Bayesian Classification with Selected Features. DOI: 10.32614/CRAN.package.BCBCSF.  [[CRAN]](https://cran.r-project.org/web/packages/BCBCSF/index.html) [[URL]](https://longhaisk.github.io/software/BCBCSF/index.html). Version 0.0-0 (2011), version 0.0-1 (2011), version 0.0-2 (2012), version 1.0-0 (2013), version 1.0-1 (2015), updated to version 1.0-2 (2026).


<!-- -->

6. Li, L., 2018. `HTLR`: Bayesian Logistic Regression with Hyper-LASSO priors. [[URL]](https://longhaisk.github.io/software/BLRHL/index.html). Pre-CRAN version (2018).


<!-- -->

5. Li, L., 2016. `iIS`: R code for computing predictive p-values in disease mapping models. [[URL]](https://longhaisk.github.io/software/dmpvalues/dmpvalues-larynx.R). 


<!-- -->

4. Li, L., 2008. `gibbs.met`: Naive Gibbs Sampling with Metropolis Steps. [[CRAN]](https://cran.r-project.org/web/packages/gibbs.met/index.html) [[URL]](https://longhaisk.github.io/software/gibbs.met/release.html).


<!-- -->

3. Li, L., 2008. `BPHO`: Bayesian Prediction with High-order Interactions. [[CRAN]](https://cran.r-project.org/web/packages/BPHO/index.html) [[URL]](https://longhaisk.github.io/software/BPHO/release.html).


<!-- -->

2. Li, L., 2007. `predmixcor`: Classification rule based on Bayesian mixture models with feature selection bias corrected. [[CRAN]](https://cran.r-project.org/web/packages/predmixcor/index.html) [[URL]](https://longhaisk.github.io/software/predmixcor/release.html). 


<!-- -->

1. Li, L., 2007. `predbayescor`: Classification Rule Based on Bayesian Naive Bayes Models with Features Selection Bias Corrected. [[CRAN]](https://cran.r-project.org/web/packages/predbayescor/index.html) [[URL]](https://longhaisk.github.io/software/predbayescor/release.html). 

### 15.2 Technical Reports {#techical-reports}




<!-- -->

13. Li, L., 2026. An entropy-based coefficient of determination with adjustment of optimization bias. [arXiv preprint arXiv:2608.06624](https://doi.org/10.48550/arXiv.2608.06624). August 2026. 



<!-- -->

12. Wu, T., Feng, C. and Li, L., 2023. Cross-validatory Z-Residual for Diagnosing Shared Frailty Models. [https://doi.org/10.48550/arXiv.2303.09616](https://doi.org/10.48550/arXiv.2303.09616). 32 pages, 14 figures.


<!-- -->

11. Wu, T., Li, L. and Feng, C., 2023. Z-residual diagnostics for detecting misspecification of the functional form of covariates for shared frailty models. [https://doi.org/10.48550/arXiv.2302.09106](https://doi.org/10.48550/arXiv.2302.09106). 21 pages, 7 figures.


<!-- -->

10. Li, L., Wu, T. and Feng, C., 2019. Model diagnostics for censored regression via randomized survival probabilities. [https://doi.org/10.48550/arXiv.1911.00198](https://doi.org/10.48550/arXiv.1911.00198). 12 pages. (Journal-ref: Statistics in Medicine, 2021, 40(6), 1482-1497).


<!-- -->

9. Feng, C., Sadeghpour, A. and Li, L., 2017. Randomized Predictive P-values: A Versatile Model Diagnostic Tool with Unified Reference Distribution. [https://doi.org/10.48550/arXiv.1708.08527](https://doi.org/10.48550/arXiv.1708.08527). 26 pages. (Journal-ref: BMC Medical Research Methodology, 2020, 20(175)).


<!-- -->

8. Jiang, L., Li, L. and Yao, W., 2016. Fully Bayesian Classification with Heavy-tailed Priors for Selection in High-dimensional Features with Grouping Structure. [https://doi.org/10.48550/arXiv.1607.00098](https://doi.org/10.48550/arXiv.1607.00098). 31 pages. (Journal-ref: Sci Rep, 2020, 10(9747)).


<!-- -->

7. Li, L., Feng, C.X. and Qiu, S., 2016. Estimating Cross-validatory Predictive P-values with Integrated Importance Sampling for Disease Mapping Models. [https://doi.org/10.48550/arXiv.1603.07668](https://doi.org/10.48550/arXiv.1603.07668). 18 pages. (Journal-ref: Statistics in Medicine, 2017, 36(14), 2220-2236).


<!-- -->

6. Li, L. and Yao, W., 2014. Fully Bayesian Logistic Regression with Hyper-Lasso Priors for High-dimensional Feature Selection. [https://doi.org/10.48550/arXiv.1405.3319](https://doi.org/10.48550/arXiv.1405.3319). 33 pages. (Journal-ref: Journal of Statistical Computation and Simulation, 2018, 88(14), 2827-2851).


<!-- -->

5. Li, L., Qiu, S., Zhang, B. and Feng, C.X., 2014. Approximating Cross-validatory Predictive Evaluation in Bayesian Latent Variables Models with Integrated IS and WAIC. [https://doi.org/10.48550/arXiv.1404.2918](https://doi.org/10.48550/arXiv.1404.2918). 38 pages. (Journal-ref: Statistics and Computing, 2016, 26(4), 881-897).


<!-- -->

4. Li, L. and Yao, W., 2013. High-dimensional Feature Selection Using Hierarchical Bayesian Logistic Regression with Heavy-tailed Priors. [https://doi.org/10.48550/arXiv.1308.4690](https://doi.org/10.48550/arXiv.1308.4690). (Earlier version of arXiv:1405.3319).


<!-- -->

3. Li, L. and Neal, R.M., 2007. A Method for Compressing Parameters in Bayesian Models with Application to Logistic Sequence Prediction Models. [https://doi.org/10.48550/arXiv.0711.4983](https://doi.org/10.48550/arXiv.0711.4983). 29 pages. (Journal-ref: Bayesian Analysis, 2008, 3(4), 793-822).


<!-- -->

2. Li, L., 2007. Bayesian Classification and Regression with High Dimensional Features. [https://doi.org/10.48550/arXiv.0709.2936](https://doi.org/10.48550/arXiv.0709.2936). PhD Thesis Submitted to University of Toronto, 129 pages.


<!-- -->

1. Li, L., Zhang, J. and Neal, R.M., 2007. A method for avoiding bias from features selection with application to naive Bayes classification models. Technical Report No 0705, Department of Statistics, University of Toronto.

### 15.3 Online Apps {#online-apps}





<!-- -->

5. **Students' Grade Calculator:** A Shinylive app that can [calculate students' grades](./software/calcmark_shiny/) with fine-grained controls and output.


<!-- -->

4. **Animation of Finding $\sqrt{S}$:** [A Shinylive App for Finding Square Root using Newton Method](./software/sqrt/)


<!-- -->

3. **Abbreviation Extractor for Documents with Latex Equations:** A shinylive  app that can [extract abbreviations](software/abbr/extract_abbr.html) in the source text with latex equations.


<!-- -->

2. [Real-time estimates of the reproduction rate ($R_t$) of Canada and its provinces](./CanadaCovidRt/), a website maintained until Feb 2022.


<!-- -->

1. [Projections of Canada's COVID-19 Cases (up to 2020-06-30)](covid-canada.html)



## 17. RESEARCH FUNDING HISTORY






**2025-2026**



<!-- -->

17. **NSERC Individual Discovery Grant (No. 2026-07053)** – *Prediction-based Methods for Statistical Learning and Inference in Biosciences and Epidemiology*, $185,000 (37K per year), 2026-2031, PI.



<!-- -->

16. **CANSSI** – *Statistical Methodologies and Computational Tools to Identify Microbial Correlates of Canadian Bee Gut Health*, [Collaborative Research Team Projects – Project 29](https://canssi.ca/story/crt-29/), 2025-2028, Co-PI.

**2021-2022**



<!-- -->

15. **MITACS Accelerate Grant** – *Geospatial Artificial Intelligence Algorithms for Automating Manual Observation Associated with Wheat Production*, $280,000, 2021-2025, PI.

**2020-2021**



<!-- -->

14. **MITACS Accelerate Grant** – *Develop a web-based geospatial artificial intelligence framework to track, visualize, analyze, model, and predict infectious disease spread in real-time*, $105,000, 2020-2021, PI.

**2019-2020**



<!-- -->

13. **NSERC Individual Discovery Grant** – *[Predictive Methods for Analyzing High-throughput and Spatial-temporal Data](https://cognit.ca/en/project/207670)*, $140,000 (20K per year), 2019-2026, PI.

**2017-2018**



<!-- -->

12. **The Western Canadian Universities Collaborative Project Seed Funding** – *Genome-wide diet-gene interaction analysis for risk of psychiatric comorbidity in inflammatory bowel disease*, $20,000, 2017-2019, Co-PI.

**2016-2017**



<!-- -->

11. **Canada First Research Excellence Fund (CFREF)** - *Designing Crops for Global Food Security, Genotype & Environment to Phenotype*, $756,918, 2016-2019, Co-Investigator (PI: Prof. Kusalik).



<!-- -->

10. **MITACS Accelerate Internship** – *Applications of Neural Network Curve Fitting Methods for Least-squares Monte Carlo Simulations in Financial Risk Management*, $15,000, 2016, PI.

**2014-2015**



<!-- -->

9. **NSERC Individual Discovery Grant** – *[Bayesian Methods for High-dimensional and Correlated Data](https://cognit.ca/en/project/13450)*, $70,000, 2014-2019, PI.

**2011-2012**



<!-- -->

8. **NSERC Individual Discovery Grant ECR Supplement** – *Efficient Bayesian Analysis for Complex Models*, $5,000/year, 2011-2014, PI.

**2009-2010**



<!-- -->

7. **NSERC Individual Discovery Grant** – *[Efficient Bayesian Analysis for Complex Models](https://www.nserc-crsng.gc.ca/ase-oro/Details-Detailles_eng.asp?id=527993)*, $80,000, 2009-2014, PI.


<!-- -->

6. **CFI Leaders Opportunity Funds** – *A Computer Cluster for Research on Efficient Bayesian Statistical Methods*, $160,000, 2009, PI.

**2008-2009**



<!-- -->

5. **MITACS Accelerate Internship** – *Clustering Analysis for Detecting the Types of Vehicles*, $15,000, 2008, Co-PI with Prof. Laverty.


<!-- -->

4. **University of Saskatchewan President's Award**, $5,000, 2008, PI.


<!-- -->

3. **College of Graduate Studies and Research at the University of Saskatchewan Award**, $15,000, 2008, PI.


<!-- -->

2. **College of Arts and Science at the University of Saskatchewan – Supplemental start-up operating grant**, $15,000, 2008, PI.

**2007-2008**



<!-- -->

1. **University of Saskatchewan – Start-up operating grant**, $5,000, 2007, PI.

## 18. PRACTICE OF PROFESSIONAL SKILLS

### 18.1 Journal Refereeing



**2026-2027**


<!-- -->

44. Refereeing for *Biometrical Journal*, August 2026


<!-- -->

43. Refereeing for *Journal of Computational and Graphical Statistics*, July 2026


<!-- -->

42. Refereeing for *Bioinformatics*, July, 2026

**2025-2026**


<!-- -->

41. Refereeing for *Journal of Statistical Computation and Simulation*, June, 2026


<!-- -->

40. Refereeing for *Journal of Statistical Computation and Simulation*, April, 2026


<!-- -->

39. Refereeing for *Journal of the Royal Statistical Society: Series C*, April 2026


<!-- -->

38. Refereeing for *Bioinformatics*, March 2026


<!-- -->

37. Refereeing for *Journal of Computational and Graphical Statistics*, March 2026


<!-- -->

36. Refereeing for *Journal of Statistical Computation and Simulation*, Dec. 2025


<!-- -->

35. Refereeing for *Journal of Computational and Graphical Statistics*, Sept. 2025


<!-- -->

34. Refereeing for *Journal of the Royal Statistical Society: Series C*, August 2025


<!-- -->

33. Refereeing for *Journal of Applied Statistics*, August 2025

**2023-2024**



<!-- -->

32. Refereeing for *Journal of Computational and Graphical Statistics*, Sept. 2024


<!-- -->

31. Refereeing for *Journal of Applied Statistics*, Jan. 2024

**2022-2023**



<!-- -->

30. Refereeing for *Statistical Methods in Medical Research*, April 2023


<!-- -->

29. Refereeing for *Statistical Methods in Medical Research*, Jan. 2023


<!-- -->

28. Refereeing for *Journal of Computational and Graphical Statistics*, Jan. 2023


<!-- -->

27. Refereeing for *Statistical Methods in Medical Research*, Aug. 2022


<!-- -->

26. Refereeing for *Canadian Journal of Statistics*, July 2022

**2021-2022**



<!-- -->

25. Refereeing for *Statistical Methods in Medical Research*


<!-- -->

24. Refereeing for *Journal of Statistical Computation and Simulation*


<!-- -->

23. Refereeing for *BMC Cancer*


<!-- -->

22. Refereeing for *Journal of Computational and Graphical Statistics*


<!-- -->

21. Refereeing for *Canadian Journal of Statistics*


<!-- -->

20. Refereeing for *IEEE Transactions on Neural Networks and Learning Systems*

**2020-2021**



<!-- -->

19. Refereeing for *Statistics in Medicine*


<!-- -->

18. Refereeing for *Computational Statistics and Data Analysis*


<!-- -->

17. Refereeing for *Frontiers in Genetics*


<!-- -->

16. Refereeing for *Statistical Methods for Medical Research*


<!-- -->

15. Refereeing for *Journal of Statistical Computation and Simulation*


<!-- -->

14. Refereeing for *BMC Cancer*

**2019-2020**



<!-- -->

13. Refereeing for *Computational Statistics and Data Analysis*


<!-- -->

12. Refereeing for *Frontiers in Genetics*


<!-- -->

11. Refereeing for *Communications in Statistics - Simulation and Computation*

**2017-2018**



<!-- -->

10. Refereeing for *Canadian Journal of Statistics*


<!-- -->

9. Refereeing for *Journal of Royal Statistical Society (C)*

**2016-2017**



<!-- -->

8. Refereeing for *Statistics in Medicine*


<!-- -->

7. Refereeing for *Statistics and Computing*


<!-- -->

6. Refereeing for *PLOS ONE*

**2013-2014**



<!-- -->

5. Refereeing for *Biometrika*


<!-- -->

4. Refereeing for *Statistics In Medicine*


<!-- -->

3. Refereeing for *Statistical Papers*


<!-- -->

2. Refereeing for *Computational Statistics*


<!-- -->

1. Refereeing for *Statistica Sinica*

### 18.2 Institutional Review



**2025-2026**



<!-- -->

10. External Referee for a Tenure and Promotion Case, Simon Fraser University, Dec. 2025


<!-- -->

9. External Examiner for the doctoral thesis by Xiaoqing Zhang, University of Regina, Dec. 8, 2025


<!-- -->

8. External Examiner for the doctoral thesis by Na Zhang, University of Alberta, August 28, 2025

**2023-2024**



<!-- -->

7. External Examiner for the doctoral thesis by Yuping Yang, Simon Fraser University, June 25, 2024

**2022-2023**



<!-- -->

6. External Examiner for the M.Sc. thesis by Xiangling Ji, University of Victoria, July 27, 2022

**2021-2022**



<!-- -->

5. External Reviewer for a Canada Research Chair Position application


<!-- -->

4. External Examiner for the M.Sc. thesis by Zhongyuan Zhang, University of Toronto

**2020-2021**



<!-- -->

3. External Examiner for the doctoral thesis, University of Montreal, May 2021

**2019-2020**



<!-- -->

2. External Examiner for the doctoral thesis by Shijia Wang, Simon Fraser University


<!-- -->

1. External Examiner for the doctoral thesis by Kexin Luo, Western University

### 18.3 Grant Refereeing



**2023-2024**



<!-- -->

12. Refereeing for a MITACS Accelerate Grant application, Dec. 2023

**2021-2022**



<!-- -->

11. Refereeing for a NSERC IDG application


<!-- -->

10. Refereeing for a NSERC IDG application


<!-- -->

9. Refereeing for a MITACS Accelerate Grant application

**2020-2021**



<!-- -->

8. Refereeing for a MITACS Accelerate Grant application, May 2021


<!-- -->

7. Refereeing for a NSERC IDG application, Jan. 2021

**2019-2020**



<!-- -->

6. Refereeing for a MITACS Grant application


<!-- -->

5. Refereeing for a NSERC IDG application

**2017-2018**



<!-- -->

4. Refereeing for a NSERC Discovery Grant application

**2016-2017**



<!-- -->

3. Refereeing for two MITACS Accelerate Grant applications

**2015-2016**



<!-- -->

2. Refereeing for a NSERC Discovery Grant application, 2015

**2011-2012**



<!-- -->

1. Refereeing for a NSERC Discovery Grant application, 2011

### 18.4 Conference/Session Organizing



**2024-2025**



<!-- -->

4. Organizing an invited Session for the 7th Symposium of ICSA Canada Chapter, McGill University, August 2026


<!-- -->

3. Organizing an invited Session for 2025 SSC Annual Meeting, Saskatoon, SK, Canada, June 2025

**2021-2022**



<!-- -->

2. Organizer of an invited session for ICSA Canada Symposium 2022, Banff, AB, Canada, July 2022

**2015-2016**



<!-- -->

1. Organizer, Invited session “Recent Advances in Statistical Inference Methods in Regression Models for Complex and Big Data”, China Statistics Conference, June 2016, Qingdao, China

## 19. ADMINISTRATIVE SERVICE

### 19.1 University Committees



**2026-2027**



<!-- -->

11. Chair, Collaborative Biostatistics Program, University of Saskatchewan.



**2025-2026**



<!-- -->

10. Chair, Collaborative Biostatistics Program, University of Saskatchewan.


<!-- -->

9. USASK NSERC Discovery Grant (DG), Internal Reviewer.

**2020-2021**



<!-- -->

8. USASK NSERC Discovery Grant (DG), Internal Reviewer.

**2019-2020**



<!-- -->

7. Chair, Collaborative Biostatistics Program, University of Saskatchewan.

**2018-2019**



<!-- -->

6. Member, Academic Programming Committee, University of Saskatchewan.

**2017-2018**



<!-- -->

5. Member, Academic Programming Committee, University of Saskatchewan.

**2016-2017**



<!-- -->

4. Member, Academic Programming Committee, University of Saskatchewan.


<!-- -->

3. Member, University of Saskatchewan Bioinformatics Program Committee.

**2015-2016**



<!-- -->

2. Member, University of Saskatchewan Bioinformatics Program Committee.

**2013-2014**



<!-- -->

1. Dean's Designate for the Ph.D. Defense of Rui Zhang, Department of Veterinary Microbiology, June 12, 2014.

### 19.2 College and Departmental Committees



**2025-2026**



<!-- -->

45. Member, Budgeting and Planning Committee, Dept of Math & Stat


<!-- -->

44. Co-Chair, Undergraduate Committee (Statistics), Dept of Math & Stat


<!-- -->

43. Member, Graduate Program Committee in Statistics, Dept of Math & Stat

**2024-2025**



<!-- -->

42. Member, Graduate Program Committee in Statistics, Dept of Math & Stat


<!-- -->

41. Search subcommittee for a faculty position in statistics

**2023-2024**



<!-- -->

40. Member, Graduate Program Committee in Statistics, Dept of Math & Stat


<!-- -->

39. Member, Sub Search Committee, 4-Year Lecturer Position

**2022-2023**



<!-- -->

38. Statistics Advisor (credit transferring for the whole university)


<!-- -->

37. Member, Department Promotion (Associate) Committee (1-Case), Dept of Math & Stat


<!-- -->

36. Member, Department Renewals and Tenure Committee (1-Case: Tenure), Dept of Math & Stat


<!-- -->

35. Member, Department Promotion (Full) Committee (1-Case), Dept of Math & Stat

**2021-2022**



<!-- -->

34. Statistics Advisor (credit transferring for the whole university)


<!-- -->

33. Member, Department Renewals and Tenure Committee (1-Case), Dept of Math & Stat


<!-- -->

32. Member, Department Promotion (Full) Committee (1-Case), Dept of Math & Stat


<!-- -->

31. Search subcommittee for a 4-year term lecturer position (two rounds of searching, Jan 2022--June 2022)

**2019-2020**



<!-- -->

30. Member, Tenure Committee (1 case), Dept of Math & Stat


<!-- -->

29. Member, Promotion Committee (1 case), Dept of Math & Stat


<!-- -->

28. Member, Renewal of Probation Committee (1 case), Dept of Math & Stat


<!-- -->

27. Member, Graduate Committee, Dept of Math & Stat


<!-- -->

26. Organizer, Team discussion towards renovating undergraduate statistics program, Dept of Math & Stat

**2018-2019**



<!-- -->

25. Committee Member, Data Science Boot Camp, University of Saskatchewan (June 10–21, 2019)


<!-- -->

24. Member, Curriculum Renewal Committee, Dept of Math & Stat, Term 1


<!-- -->

23. Member, Undergraduate Committee, Dept of Math & Stat, Term 1

**2017-2018**



<!-- -->

22. Member, Salary Review Committee, Dept of Math & Stat, University of Saskatchewan


<!-- -->

21. Member, Search Committee, Dept of Math & Stat, University of Saskatchewan

**2016-2017**



<!-- -->

20. Member, Sub Search Committee for a joint position in ``data science/big data'', College of Arts and Science, University of Saskatchewan.


<!-- -->

19. Member, Graduate Committee, Dept of Math & Stat


<!-- -->

18. Member, Sub Search Committee, APA position, Dept of Math & Stat, University of Saskatchewan


<!-- -->

17. Member, Sub Search Committee, 4 lecturer positions, Dept of Math & Stat, University of Saskatchewan


<!-- -->

16. Organizer, Statistics and Probability Alumni Networking Day (Nov. 2016)


<!-- -->

15. Organizer, Qualifying Exams for Trisha Lawrence (Nov. 2016)

**2015-2016**



<!-- -->

14. Member, Graduate Committee, Dept of Math & Stat


<!-- -->

13. Organizer, Student Seminar Day, Dept of Math & Stat (May 2016)


<!-- -->

12. Team leader, submission of U of S courses for accreditation by the Statistical Society of Canada (May 2016)


<!-- -->

11. Organizer, Qualifying Exams for Trisha Lawrence (May 2016)

**2014-2015**



<!-- -->

10. Member, Academic Program Committee, College of Arts and Science.


<!-- -->

9. Member, Graduate Committee, Dept of Math & Stat


<!-- -->

8. Organizer, Seminar Series, Dept of Math & Stat

**2012-2013**



<!-- -->

7. Member, Curriculum Renewal Committee, Dept of Math & Stat


<!-- -->

6. Member, Budget Planning Committee, Dept of Math & Stat


<!-- -->

5. Member, Colloquium Committee, Dept of Math & Stat

**2011-2012**



<!-- -->

4. Member, Salary Review Committee, Dept of Math & Stat, University of Saskatchewan


<!-- -->

3. Organizer, Seminar Series, Dept of Math & Stat


<!-- -->

2. Member, Colloquium Committee, Dept of Math & Stat

**2009-2010**



<!-- -->

1. Member, Sub Search Committee, Dept of Math & Stat

## 20. PROFESSIONAL OR ASSOCIATION OFFICES AND COMMITTEE ACTIVITY





**2024-2025**



<!-- -->

9. Member of NSERC Discovery Grant EG 1508 Committee


<!-- -->

8. Local Organizing Committee, 2025 Annual Meeting of the Statistical Society of Canada held at the U of S

**2023-2024**



<!-- -->

7. Member of NSERC Discovery Grant EG 1508 Committee

**2022-2023**



<!-- -->

6. Member of NSERC Discovery Grant EG 1508 Committee


<!-- -->

5. Co-editor for a special issue "Prediction Methods for Rare Diseases or Outcomes" in the journal *BMC Medical Research Methodology*

**2021-2022**



<!-- -->

4. Member, CANSSI-SK Health Research Collaborating Center. Participate Substantially in organizing a semester-long seminar series

**2019-2020**



<!-- -->

3. Program Committee Member for the 4th ICSA-Canada Symposium, Queens University (Aug. 2019)

**2017-2018**



<!-- -->

2. Co-chair of the scientific program, the 3rd ICSA Canada Chapter Symposium held in Vancouver (Aug. 2017)

**2016-2017**



<!-- -->

1. Judge for case study competition, Annual Meeting of Statistical Society of Canada (June 2017)

```{=html}
<footer>
Last updated on August 21, 2026.
</footer>
```
