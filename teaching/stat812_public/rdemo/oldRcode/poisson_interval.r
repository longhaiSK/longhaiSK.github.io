## a utility function to avoid over/under flow in computing log_sum_exp
log_sum_exp <- function (lx)
{
    mlx <- max (lx)
    mlx + log(sum(exp(lx - mlx)))
}

# Find the MLE for the Poisson mean parameter given data on iid values 
# specifying an interval in which each value lies (not necessarily a
# single value).
#
# Arguments:
#     low      Vector of low ends of intervals (non-negative integers)
#     high     Vector of high ends of intervals (non-negative integers)
#
# Values:  
#     MLE for the mean parameter and 
#     standard deviation.

poisson_mle <- function (low, high)
{
    if (length(low) != length(high))
        stop("low and high have different lengths")
    
    if (any(floor(low)!=low) || any(floor(high)!=high))
        stop("interval ends are not all integers")
    
    neg_log_like <-function (lambda) -poisson_log_likelihood (lambda,low,high)
    nlmfit <- nlm (neg_log_like,
                   (mean(low) + mean(high)) / 2, hessian = TRUE) 
    est <- nlmfit$estimate
    sd <- sqrt (1/nlmfit$hessian[1,1])
    CI <- est + c(-sd, sd) * 1.96
    list (est=est, sd = sd, CI = CI)
}

# Compute the log likelihood for a Poisson mean parameter given interval
# data.
#
# Arguments:
#     lambda   The Poisson mean parameter
#     low      Vector of low ends of intervals (positive integer)
#     high     Vector of high ends of intervals (positive integer)
#
# Value:  The log probability of Poisson values lying in the given
#         intervals, based on the mean parameter given.
poisson_log_likelihood <- function (lambda, low, high)
{
    ll <- 0
    for (i in 1:length(low)) {
        lp <- c()
        for (x in low[i]:high[i])
            lp <- c(lp, dpois (x, lambda, log = TRUE))
        ll <- ll + log_sum_exp (lp)
    }
    ll
}

## a test with a simulated data set

pn <- rpois (1000, lambda = 20)
low <- pmax(pn - 1, 0)
high <- pn + 4
poisson_mle (low, high)
# from the result, we have also found that the sd estimation is not accurate. 
# this is reasonable because the sd estimate is only justified "asymptotically". 

## test with another data set
pn2 <- rpois (1000, lambda = 20)
low2 <- pmax(pn2 - 50, 0)
high2 <- pn2 + 5
poisson_mle (low2, high2)


# plot log like
lambdas <- seq (0, 50, by = 0.5)
nl <- length (lambdas)
logp_lmd <- rep (0, nl)
for (i in 1:nl)
{
    logp_lmd [i] <- poisson_log_likelihood (lambdas[i], low2, high2)
}

## the reason that the estimate of sd is very bad is that 
## the log likelihood at MLE is very flat

plot (lambdas, logp_lmd, type = "l")


# plot log like of the first data set
lambdas <- seq (0, 50, by = 0.5)
nl <- length (lambdas)
logp_lmd <- rep (0, nl)
for (i in 1:nl)
{
    logp_lmd [i] <- poisson_log_likelihood (lambdas[i], low, high)
}
plot (lambdas, logp_lmd, type = "l")

