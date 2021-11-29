####################### file: ars_lognorm.c.r #################################
system ("R CMD SHLIB ars_lognorm.c")
dyn.load ("ars_lognorm.so")

## this is a wrapper function for R_sample_postlogsd
sample_post_s <- function (n, x, mu, s0, sigma0_s, dars = 1)
{
  p <- length (x)

  .C ("R_sample_post_s", n:n, spl=rep(0, n), p, x, mu, s0, sigma0_s, dars)$spl
}

## test

## generate data
s <- -5
p <- 1
mu <- 0
x <- rnorm (p, mu, exp (s))

## draw posterior sample of s
n <- 1000
s_rn <- sample_post_s (n, x, mu, 0, 100, dars = 1)

postscript ("ars_lognorm-plots.ps",
            pap = "special", wid = 10, hei = 4, horiz = FALSE)
par (mfrow = c(1,2), mar = c(4,4,3,1))

plot (s_rn, main = bquote(paste("ARS Samples of ",log(sigma) )),
      ylab = bquote(log(sigma))
     )

abline (h = s, col = "red", lwd = 2)

hist (s_rn,
      main = bquote(paste("Histogram of ARS Samples of ",log(sigma) )),
      xlab = bquote(log(sigma))
     )
abline (v = s, col = "red", lwd = 2)

dev.off ()
