#' ---
#' title: "Introduction to Statistical Methods"
#' subtitle: "Analysis of Variance"
#' author: "Longhai Li"
#' date: "September 2019"
#' output: 
#'    html_document:
#'        toc: true
#'        number_sections: true
#'        highlight: tango
#'        fig_width: 10
#'        fig_height: 8
#' ---



arith <- read.csv ("arith.csv", header = T, stringsAsFactors = TRUE) 

# have a look at the data
arith

plot (arith$scores, col = arith$methods)
# do anova
arith.aov <- aov ( scores ~ methods, data = arith)
# look at the result
summary (arith.aov) 
