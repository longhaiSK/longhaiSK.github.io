
#### the following is only for class demonstration 

pdf ("hypothesistesting.pdf", width = 11, height = 9)
X <- rnorm (100000, 170, 10)
Y <- rnorm (100000, 175, 10)
xlim <- range (X,Y)

par (mfrow = c(2,1))
hist (X, main = "Population Distribution when H0: mu = 170 is true", xlim = xlim)
abline (v = 170, lwd = 4)
hist (Y, main = "Population Distribution when H1: mu = 175 is true", xlim = xlim, col = "red")
abline (v = 175, lwd = 4, col = "red")

## sample size = 20
sample1_xbar <- replicate (500, mean(sample (X, size = 20, replace = T) ) )
sample1_ybar <- replicate (500, mean(sample (Y, size = 20, replace = T) ) )

xlim <- range (sample1_xbar, sample1_ybar)
plot (sample1_xbar,1:500,  pch = 4, xlim = xlim, main = "Distribution of xbar of n = 20 observations given H0: mu = 170")
abline (v = 170, lwd = 4)

plot (sample1_ybar,1:500,  pch = 4, xlim = xlim, main = "Distribution of xbar of n = 20 observations given H1: mu = 175", col = "red")
abline (v = 175, lwd = 4, col = "red")

## add rejection region
xlim <- range (sample1_xbar, sample1_ybar)
plot (sample1_xbar,1:500,  pch = 4, xlim = xlim, main = "Distribution of xbar of n = 20 observations  given H0: mu = 170")
abline (v = 170 + 1.645 * 10/sqrt (20), col = "green", lwd = 3)
text (178, 200, "Rejection Region: the right to green line ")
plot (sample1_ybar,1:500,  pch = 4, xlim = xlim, main = "Distribution of xbarof n = 20 observations given H1: mu = 175", col = "red")
abline (v = 170 + 1.645 * 10/sqrt (20), col = "green", lwd = 3)

## sample size = 20
sample2_xbar <- replicate (500, mean(sample (X, size = 50, replace = T) ) )
sample2_ybar <- replicate (500, mean(sample (Y, size = 50, replace = T) ) )


## add rejection region
plot (sample2_xbar,1:500,  pch = 4, xlim = xlim, main = "Distribution of xbar of n = 50 observations   given H0: mu = 170")
abline (v = 170 + 1.645 * 10/sqrt (50), col = "green", lwd = 3)
text (178, 200, "Rejection Region: the right to green line")
plot (sample2_ybar,1:500,  pch = 4, xlim = xlim, main = "Distribution of xbar of n = 50 observations  given H1: mu = 175", col = "red")
abline (v = 170 + 1.645 * 10/sqrt (50), col = "green", lwd = 3)

dev.off()

