
#' ---
#' title: "Introduction to Statistical Methods"
#' subtitle: "Confidence Interval"
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

#' # Generate a population data
#'
X <- rgamma (1000000, 10, .08)
# use another sample
# X <- rbinom (100000, 1, 0.3)

mu <- mean (X) # population mean
mu
sigma <- sd (X) # population sd
sigma
hist (X, main = "Population Distribution")

#' # Draw sample of sample mean
#' 
n <- 30
n_rep <- 2000
CI_rep <- matrix (0, n_rep, 3) 

xbar <- replicate (n_rep, mean(sample (X, size = n, replace = T) ) )
data.frame(xbar = xbar[1:50])

#' Look at the distribution of sample mean in comparison with the population
#' 

xbar.hist <- hist (xbar, nclass=20, xlim = range (X))

#' # Find 95% confidence intervals for each sample mean 

# find margin error (me)
alpha <- 0.05
z <- - qnorm (alpha/2) # or using z <- qnorm (alpha/2, lower = F)
me <- z * sigma/sqrt (n)

# find a CI with the first sample
ci <- c(xbar[1] - me, xbar[1] + me)
mu.is.covered <- ci[1] < mu & mu < ci[2] 

# repeat n_rep times
for (i in 1:n_rep)
{
    CI_rep [i,1:2] <- c(xbar[i] - me, xbar[i] + me)
    CI_rep [i, 3] <- CI_rep [i,1] < mu & mu < CI_rep [i,2] 
}

data.frame("true mean"= mu,
           "sample mean"=xbar[1:50], 
           "lower bound" = CI_rep[1:50,1],
           "upper bound" = CI_rep[1:50,2],
           "true mean covered"=CI_rep[1:50,3])

#' # Plot CI 
#' 
n_plot <- 50
rns <- sample (n_rep)
plot (0,0,type = "n", ylab = "Replication ID", xlab = "x",  
      xlim = c(90, 160), #xlim = range (CI_rep[,1:2]),
      ylim = c(0,n_plot+1))
title (main = "Illustration of Confidence Intervals")
abline (v = mu, col = "green", lwd = 3)
abline (v = mu + c(-me, +me), col = "green")
for (i in 1:n_plot)
{
    lines (CI_rep[rns[i],1:2], c(i,i), col =  2 - CI_rep[rns[i], 3] )
    points (xbar[rns[i]], i, pch = 4, col = 2 - CI_rep[rns[i],3])
}

## actual cover rate
mean (CI_rep [,3])

#' # Margin Errors of Proportions
#' 
#' 

p<- seq (0,1, by=0.05)

n<- 1200

data.frame(p=p, me=sqrt(p*(1-p)/n)*1.96)

n<- 2070

data.frame(p=p, me=sqrt(p*(1-p)/n)*1.96)
