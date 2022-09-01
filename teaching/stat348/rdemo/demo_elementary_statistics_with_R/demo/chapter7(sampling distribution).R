#################### Demonstration of Central Limit Theorem #################
pdf ("sampling.pdf")
## population distributions 

## generate a population data
X <- rgamma (100000, 3, .2)

mean (X)
sd (X)
hist (X, main = "Population Distribution")
abline (v = mean (X), col = "red")
## sampling distributions 

## sample size = 10
sample1_xbar <- replicate (10000, mean(sample (X, size = 10, replace = T) ) )
mean (sample1_xbar)
mean (X)
sd (sample1_xbar)
sd (X)
sd (X)/sqrt(10)

xlim <- range (sample1_xbar)
plot (sample1_xbar[1:500],1:500,  pch = 4, xlim = xlim, main = "n = 10")
abline (v = mean (X), col = "red")

hist (sample1_xbar, main = "n = 10", xlim = xlim,
      probability = TRUE, nclass =20)
x <- seq (min (sample1_xbar), max(sample1_xbar), length = 100)
lines (x, dnorm (x, mean = mean (X), sd = sd (X)/sqrt(10)))
abline (v = mean (X), col = "red")

## sample size = 30
sample2_xbar <- replicate (10000, mean(sample (X, size = 30, replace = T) ) )

plot (sample2_xbar[1:500],1:500,  pch = 4, xlim = xlim, main = "n = 30")
abline (v = mean (X), col = "red")

hist (sample2_xbar, main = "n = 30", xlim = xlim,
      probability = TRUE, nclass = 20 )
x <- seq (min (sample2_xbar), max(sample2_xbar), length = 100)
lines (x, dnorm (x, mean = mean (X), sd = sd (X)/sqrt(30)))
abline (v = mean (X), col = "red")

## sample size = 100
sample3_xbar <- replicate (10000, mean(sample (X, size = 100, replace = T) ) )

plot (sample3_xbar[1:500],1:500,  pch = 4, xlim = xlim, main = "n = 100")
abline (v = mean (X), col = "red")


hist (sample3_xbar, main = "n = 100", xlim = xlim,
      probability = TRUE, nclass = 20 )
x <- seq (min (sample3_xbar), max(sample3_xbar), length = 100)
lines (x, dnorm (x, mean = mean (X), sd = sd (X)/sqrt(100)))
abline (v = mean (X), col = "red")

## plot comparison boxplot of sample means
allxbar <- data.frame (sample1_xbar, sample2_xbar, sample3_xbar)
colnames (allxbar) <- c("n = 10", "n = 30","n = 100" )
boxplot (allxbar,horizontal=T)
abline (v = mean (X), col = "red")

dev.off()
