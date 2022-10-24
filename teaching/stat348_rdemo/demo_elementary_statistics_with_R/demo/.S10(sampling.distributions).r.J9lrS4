X <- rgamma (100000, 2, .2)

mean (X)
sd (X)

sample1_xbar <- replicate (5000, mean(sample (X, size = 10) ) )
sample2_xbar <- replicate (5000, mean(sample (X, size = 30) ) )
sample3_xbar <- replicate (5000, mean(sample (X, size = 1000) ) )

pdf ("S10.pdf") # open plot device

hist (X, 
	  main = "Population Distribution")

qqnorm (X)

hist (sample1_xbar,   
	  main = "Sampling Distribution of xbar with n = 10" )

qqnorm (sample1_xbar)

hist (sample2_xbar,   
	  main = "Sampling Distribution of xbar with n = 30" )

qqnorm (sample2_xbar)

hist (sample3_xbar, nclass = 20,
	  main = "Sampling Distribution of xbar with n = 1000" )

qqnorm (sample3_xbar)

dev.off () # close the plot device

allxbar <- data.frame (sample1_xbar, sample2_xbar, sample3_xbar)
# find mean of sample means
sapply (allxbar, mean)
# look at actual population mean
mean (X)
# find sd of sample means
sapply (allxbar, sd)
# look at values given by formula:
sd (X) /sqrt (c(10,30,1000))
