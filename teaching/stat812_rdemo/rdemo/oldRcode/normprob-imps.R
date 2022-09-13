source ("ars_tnorm.R")

######################### estimate P(a < X < b) ##############################
## estimating the probability P(X in A) for X ~ N(0,1) 
## by sampling from N(0,1)
est_normprob_mc <- function(A,iters_mc)
{
     X <- rnorm(iters_mc)
     mean((X > A[1]) * (X<A[2]))
}

## estimating the probability P(X in A) for X ~ N(0,1) 
## by sampling from Unif(A[1],A[2])
est_normprob_imps <- function(A, iters_mc)
{
     X <- runif(iters_mc,A[1],A[2])
     mean(dnorm(X))*(A[2]-A[1])
}
 
A <- c(1,2)
tp <- pnorm (A[2]) - pnorm (A[1])
probs_mc <- replicate(1000,est_normprob_mc(A,100))
probs_imps <- replicate(1000,est_normprob_imps(A,100))
var(probs_mc)
var(probs_imps)

A <- c(-3,3)
tp <- pnorm (A[2]) - pnorm (A[1])

probs_mc <- replicate(1000,est_normprob_mc(A,100))
probs_imps <- replicate(1000,est_normprob_imps(A,100))
mean((probs_mc-tp)^2)
mean((probs_imps-tp)^2)

######################### Estimate E(X^2) ####################################

## compute E(a) with importance sampling
est_tnorm_imps <- function(a, A, iters_mc)
{
    X <- runif(iters_mc,A[1],A[2])
    W <- dnorm (X)
    ahat <- sum (a(X) * W) / sum (W)
    attr(ahat, "effective sample size") <- 1/sum((W/sum(W))^2)
    ahat
}

## a function computing the sum of numbers represented with logarithm
## lx     --- a vector of numbers, which are the log of another vector x.
## the log of sum of x is returned
log_sum_exp <- function(lx)
{   mlx <- max(lx)
    mlx + log(sum(exp(lx-mlx)))
}

## a generic function for approximating 1-D integral with midpoint rule
## the logarithms of the function values are passed in
## the log of the integral result is returned
## log_f  --- a function computing the logarithm of the integrant function
## range  --- the range of integral varaible, a vector of two elements
## n      --- the number of points at which the integrant is evaluated
## ...    --- other parameters needed by log_f
log_int_mid <- function(log_f, range, n,...)
{   if(range[1] >= range[2]) 
    stop("Wrong ranges")
    h <- (range[2]-range[1]) / n
    v_log_f <- sapply(range[1] + (1:n - 0.5) * h, log_f,...)
    log_sum_exp(v_log_f) + log(h)       
}

## compute E(a) with midpoint rule
est_tnorm_mid <- function (a, A, iters_mc)
{
    log_f <- function (x) dnorm (x, log = T) + log (a(x))
    exp(log_int_mid (log_f, A, iters_mc) ) / (pnorm (A[2]) - pnorm (A[1]))
}

## define the function a
a <- function (x) x^2

A <- est_tnorm_mid (a, c(1,2), 100000) ## midpoint rule

## estimate E(a) with rejection sampling
system.time(
    {
        rn_tnorm_ars <- sample_tnorm_ars (1000, 1,2) # draw samples from tnorm
        mean (a (rn_tnorm_ars)) 
    }
)

system.time(
est_tnorm_imps (a, c(1,2), 1000000) ## importance sampling
)


## simulation comparison of importance sampling and rejection sampling
times.imps <- system.time(
EA_imps <- replicate (100, est_tnorm_imps (a, c(1,2), 1000000)) 
)

times.imps

times.rej <- system.time (
EA_rej <- replicate (100,
    {   rn_tnorm_ars <- sample_tnorm_ars (1000, 1,2)
        mean (a (rn_tnorm_ars))
    }
    )
)
times.rej

par (mfrow = c(1,2))
xlim <- range (EA_imps, EA_rej)
hist (EA_imps, xlim = xlim); mean ((EA_imps-A)^2);
abline (v = A)
hist (EA_rej, xlim = xlim); mean ((EA_rej-A)^2)
abline (v = A)

save.image ("normprob.RData")

