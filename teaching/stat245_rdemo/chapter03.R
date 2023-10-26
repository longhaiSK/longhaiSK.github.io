#' ---
#' title: "Introduction to Statistical Methods"
#' subtitle: "Numerical Measures and Boxplots"
#' author: "Longhai Li"
#' date: "September 2023"
#' output: 
#'    html_document:
#'        toc: true
#'        number_sections: true
#'        highlight: tango
#'        fig_width: 10
#'        fig_height: 8
#' ---

#'  Researcher was interested in the side effects of radiation therapy on
#'  patents suffering cancerous lesions. In particular he was interested in the
#'  effect of radiation therapy on Mental dexterity. Each patient was scored
#'  (Pre.test) on a mental dexterity test prior to treatment. They were again
#'  scored on a similar test (Post.Test) one month after treatment began.  
#'  
#'  N1 = 16 were not given radiation and served as controls,
#'  
#'  N2 = 19 were given radiation dosage in the range 25-50, 

#'  N3 = 18 were given radiation dosage in the range 75-125, and 

#'  N4 = 21 were given radiation dosage in the range 125-250. 

#'  
#'  In the data set,
#'  
#'  Pre.test: mental dexterity score before test

#'  Post.test: mental dexterity score after test

#'  Treat: indicator of dosage level 

#' Import a dataset called "mental.csv"
mental <- read.csv ("mental.csv", stringsAsFactors = TRUE)

#' have a look at the dataset

mental
plot(mental$Pre.test, col=as.numeric(mental$Treat))
plot(mental$Post.test, col=as.numeric(mental$Treat))

#' Numerical measures 

mean (mental$Pre.test)

median (mental$Pre.test)

range (mental$Pre.test)

var (mental$Pre.test)

sd (mental$Pre.test)

IQR (mental$Pre.test)

x <- c(1,2,3,4,5)

plot (ecdf(x))

plot (ecdf (mental$Pre.test))
abline (h = seq (0,1, by = 0.05), lty = 1, col = "grey")


quantile (mental$Pre.test)

quantile (mental$Pre.test, probs = 0.34)

quantile (mental$Pre.test, probs = seq (0, 1, by = 0.1))

quantile (mental$Pre.test, probs = seq (0, 1, by = 0.01))

boxplot (mental$Post.test)

boxplot (Post.test ~ Treat, data = mental)

#' change the default order of treatment

levels(mental$Treat)
mental$Treat2 <- factor(mental$Treat, levels =  levels(mental$Treat)[c(4,1:3)])
levels(mental$Treat2)
mental[, c("Treat", "Treat2")]

# draw boxplot again
boxplot (Post.test ~ Treat2, data = mental)

# The mental dexterity may be related to the pre dexterity of each patient
plot (mental$Post.test ~ mental$Pre.test, 
      col = as.numeric(mental$Treat2), 
      pch = as.numeric(mental$Treat2))
abline(a=0,b=1)
legend("topleft",legend = levels(mental$Treat2), pch = 1:4, col = 1:4)

boxplot (Post.test - Pre.test ~ Treat2, data = mental)
