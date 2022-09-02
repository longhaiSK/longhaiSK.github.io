pdf ("twosamplemeans_H1.pdf")

mu1 <- 175
mu2 <- 170

X <- rnorm (100000, mu1, 10)
Y <- rnorm (100000, mu2, 20)

xlim <- range (X,Y)

par (mfrow = c(2,1))
hist (X, main = "Population 1", xlim = xlim)
abline (v = mu1, lwd = 4)
hist (Y, main = "Population 2", xlim = xlim, col = "red")
abline (v = mu2, lwd = 4)
## sample size = 20
sample1_xbar <- replicate (500, mean(sample (X, size = 50, replace = T) ) )
sample1_ybar <- replicate (500, mean(sample (Y, size = 50, replace = T) ) )

diff_xbar_ybar <- sample1_xbar - sample1_ybar

rn <- range (sample1_xbar, sample1_ybar)
qrn <- (rn[2] - rn[1])/2

plot (sample1_xbar, 1:500, col = 1, pch = 1, xlim = 170 + 1.5*c(-qrn, qrn), xlab = "xbar",
      main = "sampling distribution of xbar_1 and xbar_2 respectively")
points (sample1_ybar, 1:500, col = 2, pch = 1)

plot (diff_xbar_ybar, 1:500, xlim = 0 + 1.5*c(-qrn, qrn), main = "sampling distribution of xbar_1 - xbar_2 when mu_1 > mu_2", xlab = "xbar_1 - xbar_2", col = "blue")

dev.off()

pdf ("twosamplemeans_H0.pdf")

mu1 <- 170
mu2 <- 170

X <- rnorm (100000, mu1, 10)
Y <- rnorm (100000, mu2, 20)

xlim <- range (X,Y)

par (mfrow = c(2,1))
hist (X, main = "Population 1", xlim = xlim)
abline (v = mu1, lwd = 4)
hist (Y, main = "Population 2", xlim = xlim, col = "red")
abline (v = mu2, lwd = 4)
## sample size = 20
sample1_xbar <- replicate (500, mean(sample (X, size = 50, replace = T) ) )
sample1_ybar <- replicate (500, mean(sample (Y, size = 50, replace = T) ) )

diff_xbar_ybar <- sample1_xbar - sample1_ybar


plot (sample1_xbar, 1:500, col = 1, pch = 4, xlim = 170 + 1.5*c(-qrn, qrn), xlab = "xbar",
      main = "sampling distribution of xbar_1 and xbar_2 respectively")
points (sample1_ybar, 1:500, col = 2, pch = 4)

plot (diff_xbar_ybar, 1:500, xlim = 0 + 1.5*c(-qrn, qrn), main = "sampling distribution of xbar_1 - xbar_2 when mu_1 = mu_2", xlab = "xbar_1 - xbar_2", col = "blue", pch = 4)

dev.off()