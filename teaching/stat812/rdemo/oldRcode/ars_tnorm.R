#install.packages ("ars") 

library (ars) 

## a direct rejection sampling for truncated normal
sample_tnorm_drs <- function (n, lb = -Inf, ub = Inf)
{
    x <- rep (0, n)
    for (i in 1:n)
    {
        rej <- TRUE
        while (rej)
        {
            x[i] <- rnorm (1)
            if (x[i] >= lb & x[i] <= ub) rej <- FALSE
        }
    }
    x
}

## sample from truncated normal using ars package
sample_tnorm_ars <- function (n, lb, ub)
{
    logf <- function (x) dnorm (x, log = TRUE) ## define log density
    fprima <- function (x) -x ## define derivative of log density
    
    ars (10000, f = logf, fprima = fprima, 
         x = c(lb, (lb + ub )/2, ub), # starting points
         lb = TRUE, ub = TRUE, xlb = lb, xub = ub) # boundary of log density
}
n <- 1000
system.time (
    rn_tnorm_ars <- sample_tnorm_ars (n, -50, -49)
)

# system.time(
# rn_tnorm_rej <- sample_tnorm_drs (n, -5, -4)
# )

#par (mfrow = c(1,3))
hist (rn_tnorm_ars, main = "ars")
# hist (rn_tnorm_rej, main = "naive rejection")
#qqplot (rn_tnorm_ars, rn_tnorm_rej)

## remark: a C implementation of ars by L. Li can be found from 
## http://math.usask.ca/~longhai/software/ars/ars.html
