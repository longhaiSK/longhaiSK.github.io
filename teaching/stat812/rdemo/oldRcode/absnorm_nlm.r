# Demonstration of using nlm and deriv to find the MLE for data that
# is normally distributed but with only the absolute value observed.

# Some artificial data to try it out on.

set.seed(1)
x <- abs(rnorm(1000,2.2,1.3))

# The function to compute the log probability density for each data point
# and its first and second derivatives.  Looks at data in "x".

logp <- 
  deriv (quote (
    -lsigma + log (dnorm((x-mu)/exp(lsigma))
                    + dnorm((-x-mu)/exp(lsigma)))),
    c("mu","lsigma"), fun=TRUE, hessian=TRUE)

# Minus log likelihood function, for data in "x".

logl <- function (p) {
    lp <- logp(p[1],p[2])
    ll <- -sum(lp)
    attr(ll,"gradient") <- -colSums(attr(lp,"gradient"))
    attr(ll,"hessian") <- -colSums(attr(lp,"hessian"))
    ll
}

# Estimates found from two starting points.

cat("estimate starting at 0,0:\n\n")
print (nlm (logl, c(0,0)))

cat("\nestimate starting at 0.1,0:\n\n")
print (nlm (logl, c(0.1,0)))
