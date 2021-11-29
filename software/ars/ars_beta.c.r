system ("R CMD SHLIB ars_beta.c")
dyn.load ("ars_beta.so")

## R wrapper function
sample_beta_ars <- function (n, alpha = 1, beta = 1,lb =0, ub = 1, dars = 0)
{
  .C ("R_sample_beta", n:n, rep (0, n), alpha, beta, lb, ub, dars)[[2]]
}

## testing the above function
postscript ("ars_beta-plots.ps",
            paper = "special", height = 4, width = 8.5, horiz = FALSE)
par (mfrow = c(1,2), mar = c(4,4,3,1))
## test with standard method
n <- 10000
arsrnbeta <- sample_beta_ars (n, 0.1, 0.1, 0, 1, dars = 1)
drnbeta <- rbeta (n, 0.1, 0.1)
qqplot (arsrnbeta, drnbeta, main = "QQ-plot of Beta Samples",
        xlab = "Quantiles of ARS Samples",
        ylab = "Quantiles of Standard Samples")

## truncated beta
arsrnbeta <- sample_beta_ars (n, 0.1, 5, 0.1, 0.5)
hist (arsrnbeta,
      main = "Histogram of Truncated Beta Samples",
      xlab = "b")

dev.off ()