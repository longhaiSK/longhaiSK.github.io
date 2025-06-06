#' ---
#' title: "Introduction to Statistical Methods"
#' subtitle: "t test"
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

#' # Unpaired t-test
path_data <- "~/OneDrive - University of Saskatchewan/teaching/stat245_1909/rdemo/data"
addpath <- function (x) file.path(path_data,x)
survey <-  read.csv (addpath("survey.csv"))

t.test (survey$Age, mu = 23, altern = "less") 

#'# Paired t-test
#'

mental <- read.csv (addpath("mental.csv") )

sub <- mental$Treat=="025-050R"
#' scatterplot
matplot(mental[sub,1:2], pch=c(1,2), xlab = "Patient Index")
#' Unpaired t-test
t.test(mental[sub,1], mental[sub,2], alternative = "greater")
#' Paired t-test
t.test(mental[sub,1], mental[sub,2], alternative = "greater", paired = TRUE)

sub <- mental$Treat=="075-125R"
#' scatterplot
matplot(mental[sub,1:2], pch=c(1,2), xlab = "Patient Index")
#' Unpaired t-test
t.test(mental[sub,1], mental[sub,2], alternative = "greater")
#' Paired t-test
t.test(mental[sub,1], mental[sub,2], alternative = "greater", paired = TRUE)



sub <- mental$Treat=="125-250R"
#' scatterplot
matplot(mental[sub,1:2], pch=c(1,2), xlab = "Patient Index")
#' Unpaired t-test
t.test(mental[sub,1], mental[sub,2], alternative = "greater")
#' Paired t-test
t.test(mental[sub,1], mental[sub,2], alternative = "greater", paired = TRUE)

