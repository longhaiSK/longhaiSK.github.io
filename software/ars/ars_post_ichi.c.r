###################### file: ars_post_ichi.c.r ##############################
system ("R CMD SHLIB ars_post_ichi.c")
dyn.load ("ars_post_ichi.so")

## a R wrapper function to call C function R_sample_post_ichi
sample_post_ichi <- function (n, sigmasq, alpha1, alpha0, w0, dars = 0)
{
  p <- length (sigmasq)

  .C ("R_sample_post_ichi",
  n:n, p, sigmasq, alpha1, rn_s = rep (0,n), alpha0, w0, dars)$rn_s
}

## test the above sampling procedure

## generate Inverse-Chisq samples
p <- 100
alpha1 <- 0.5
w <- exp (-10)
sigmasq <- 1 / rgamma (p, alpha1/2, alpha1*w/2)

## sample from the posterior of w with ARS
n <- 1000
rn_s <- sample_post_ichi (n, sigmasq, alpha1, alpha0 = 1E-5, w0 = 1E-5, 1)

## plot the samples
postscript ("ars_post_ichi-plots.ps",
            pap = "special", wid = 10, hei = 4, horiz = FALSE)
par (mfrow = c(1,2), mar = c(4,4,3,1))
plot (rn_s, main = bquote(paste("ARS Samples of Posterior of Inv-", chi^2)),
      ylab = "log (w)")
abline (h = log(w), col = "red", lwd = 2)
hist (rn_s, main = "Histogram", xlab = "log(w)")
abline (v = log(w), col = "red", lwd = 2)
dev.off ()
