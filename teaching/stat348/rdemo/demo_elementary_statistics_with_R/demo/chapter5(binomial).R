
################################# find factorial #############################
factorial (10)

############ find number of combindations of choosing 40 out of 400 ##########
choose (400,40)

choose (49, 6)

############ find number of permuation of choosing 40 out of 400 #############

choose (400, 40) * factorial (40)

########### compute binomial probabilities ####################################
dbinom (3, size = 10, p = 0.03) ## find P(X=3)
pbinom (3,size = 10, p = 0.3) ## find P(X<=3)
rbinom (100, size = 10, p = 0.3) ## generate 100 random numbers

###############################################################################
#################### class demonstration code #################################
###############################################################################

################## plot binomial probability distribution #####################

n <- 12; p <- 1/6
x <- 0:n

binom.x <- dbinom (x, size = n, p = p) # compute binomial probability
breaks <-  c(x - 0.5, n + 0.5)
hist.binom <- list (breaks = breaks, counts = binom.x) 
class (hist.binom) <- "histogram"
plot (hist.binom, main = "Binomial Probabilities", xlab = "x")

################# plot binomial Cumulative Distribution Function ##############
cdf.binom <- c(0, pbinom (0:n, size = n, p = p))
plot(stepfun (0:n, cdf.binom), verticals = F, pch = 20, 
     xlab = "x", ylab = "CDF",
     main = "Binomial Cumulative Distribution Function")

