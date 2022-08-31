# MAXIMUM LIKELIHOOD ESTIMATION FOR POISSON DATA WITH ZEROS UNOBSERVED.
#
# For all three functions,
# the arguments are the vector of observations, the number of iterations to
# do, and the initial guess (defaulting to the sample mean). The result is
# a data frame with one row for each iteration (including the initial guess),
# with the columns being the estimate for lambda at that iteration and the
# log likelihood for that value of lambda (minus the factorial terms that
# don’t involve lambda).
# COMPUTE LOG LIKELIHOOD. The arguments are the data vector and a value for
# lambda (or vector of values). The result is the log probability of the data
# given that value for lambda, omitting the factorial terms (or a vector of
# log probabilities if lambda is a vector).
nzp.log.likelihood <- function (n, lambda)
{
    sum(n) * log(lambda) - length(n) * (lambda + log(1-exp(-lambda)))
}
# FIND MLE BY SIMPLE ITERATION.
nzp.simple.iteration <- function (n, r, lambda0=mean(n))
{
    mean.n <- mean(n)
    lambda <- rep(0,r+1)
    lambda[1] <- lambda0
    for (i in 1:r)
    { lambda[i+1] <- mean.n * (1 - exp(-lambda[i]))
    }
    data.frame (lambda=lambda, log.lik=nzp.log.likelihood(n,lambda))
}

# FIND MLE BY NEWTON-RAPHSON ITERATION.
nzp.newton.raphson <- function (n, r, lambda0=mean(n))
{
    mean.n <- mean(n)
    lambda <- rep(0,r+1)
    lambda[1] <- lambda0
    for (i in 1:r)
    { e <- exp(-lambda[i])
    lambda[i+1] <- lambda[i] -
        (mean.n/lambda[i] - 1/(1-e)) / (e/(1-e)^2 - mean.n/lambda[i]^2)
    }
    data.frame (lambda=lambda, log.lik=nzp.log.likelihood(n,lambda))
}
# FIND MLE BY THE METHOD OF SCORING.
nzp.method.of.scoring <- function (n, r, lambda0=mean(n))
{
    mean.n <- mean(n)
    lambda <- rep(0,r+1)
    lambda[1] <- lambda0
    for (i in 1:r)
    { e <- exp(-lambda[i])
    lambda[i+1] <- lambda[i] -
        (mean.n/lambda[i] - 1/(1-e)) / ((e/(1-e) - 1/lambda[i]) / (1-e))
    }
    data.frame (lambda=lambda, log.lik=nzp.log.likelihood(n,lambda))
}

## test with generated datasets
n<-rpois (10, lambda = 1.5)
n <- n[n>0]

nzp.simple.iteration(n,15, mean (n))
nzp.simple.iteration(n,15,0.1)
nzp.simple.iteration(n,15,100)
nzp.newton.raphson(n,15, mean (n))
nzp.newton.raphson(n,15,0.1)

nzp.newton.raphson(n,15,2.8)

nzp.method.of.scoring(n,15, mean (n))
nzp.method.of.scoring(n,15,0.1)
nzp.method.of.scoring(n,15,100)

## test with another dataset
n<-c(1,2,1,1,1)
nzp.newton.raphson(n,15)
nzp.method.of.scoring(n,15,10)
nzp.method.of.scoring(n,15,100)

########################## golden section method ##############################
### used for the function without smooth 1st order derivative

golden <- function(f,brack.int,eps=1e-4,...) {
    g <- (3-sqrt(5))/2
    xl <- min(brack.int)
    xu <- max(brack.int)
    tmp <- g*(xu-xl)
    xmu <- xu-tmp
    xml <- xl+tmp
    fl <- f(xml,...)
    fu <- f(xmu,...)
    while(abs(xu-xl)>(1.e-5+abs(xl))*eps) {
        if (fl<fu) {
            xu <- xmu
            xmu <- xml
            fu <- fl
            xml <- xl+g*(xu-xl)
            fl <- f(xml,...)
        } else {
            xl <- xml
            xml <- xmu
            fl <- fu
            xmu <- xu-g*(xu-xl)
            fu <- f(xmu,...)
        }
    }
    if (fl<fu) xml else xmu
}

## a test
f1 <- function(theta) -1997*log(2+theta)-1810*log(1-theta)-32*log(theta)
plot (f1, xlim = c(0.001,0.999))
golden(f1,c(.001,.999))

f2 <- function(x) abs(x-10)
plot (f2, xlim = c(0,20))
golden(f2,c(0,20))
