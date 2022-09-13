# Example of fitting a non-linear model with several parameters by 
# maximum likelihood, using "nlm".
#
# The model is for the data on sunspot counts supplied with R.  We
# hypothesize that the counts (actually integers, but modelled as
# non-negative continuous values) come from taking the absolute value
# of a normal variate whose mean varies with time according to a sine 
# wave.  The model parameters are a, b, f, and M, which define the
# sine wave, as M*(a+sin(b+f*t), and the log of the standard deviation
# of the observation, lsigma.
#
# We use "nlm" to find the maximum likelihood estimates

logl <- function (p, x, t)
{
    a <- p[1]
    b <- p[2]
    f <- p[3]
    M <- p[4]
    lsigma <- p[5]
    - sum(log(dnorm ( x, M*(a+sin(b+f*t)), exp (lsigma)) + 
              dnorm (-x, M*(a+sin(b+f*t)), exp (lsigma))
      )) 
}


## get the data.

x <- sunspots [1:500]
t <- 1:length(x)

# Estimation, from a carefully chosen starting point.

est <- nlm (logl, 
            p = c(a= 0, b = -1, f = 2*pi/200, M=80,lsigma = 4), 
            x = x, t = t, hessian = T)
print(est)

mle <- est$estimate
sds <- sqrt(diag(solve(est$hessian)))

# Plot the mean from the model with the MLE parameter estimates together
# with the data points.

a <- mle[1]
b <- mle[2]
f <- mle[3]
M <- mle[4]

plot(t,x,pch=20)
lines(t,abs(M*(a+sin(b+f*t))),col="red")

