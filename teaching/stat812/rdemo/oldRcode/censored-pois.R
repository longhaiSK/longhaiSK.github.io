# AN EM ALGORITHM FOR FINDING THE MLE FOR A CENSORED POISSON MODEL.
#
# The data consists of n observed counts, whose mean is m, plus c counts
# that are observed to be less than 2 (ie, 0 or 1), but whose exact value
# is not known.  The counts are assumed to be Poisson distributed with 
# unknown mean, lambda.  
#
# The function below finds the maximum likelihood estimate for lambda given
# the data, using the EM algorithm started from the specified guess at lambda
# (default being the mean count with censored counts set to 1), run for the
# specified number of iterations (default 20).  The log likelihood is printed 
# at each iteration.  It should never decrease.

#n is the number of observed poisson counts
#c is the number of missed poisson counts
#y_bar is is the mean of observed poisson counts
EM.censored.poisson <- function (n, y_bar, c, lambda0=(n*y_bar+c)/(n+c),
iterations=20)
{
  # Set initial guess, and print it and its log likelihood.

  lambda <- lambda0

  cat (0, lambda, log.likelihood(n,y_bar,c,lambda), "\n")

  # Do EM iterations.

  for (i in 1:iterations)
  {
    # The E step: Figure out the distribution of the unobserved data.  For 
    # this model, we need the probability that an unobserved count that is 
    # either 0 or 1 is actually equal to 1, which is p1 below.

    y_mis <- lambda / (1+lambda)
    
    # The M step: Find the lambda that maximizes the expected log likelihood
    # with unobserved data filled in according to the distribution found in
    # the E step.

    lambda <- (n*y_bar + c*y_mis) / (n+c)

    # Print the new guess for lambda and its log likelihood.

    cat (i, lambda, log.likelihood_obs(n,y_bar,c,lambda), "\n")
  }

  # Return the value for lambda from the final EM iteration.

  lambda
}

log.likelihood_obs <- function (n, y_bar, c, lambda)
{
  n*y_bar*log(lambda) - (n+c)*lambda + c*log(1+lambda)
}

y <- rpois(200,3)

c<- sum(y < 2)
y_bar <- mean(y[y >=2])

EM.censored.poisson(length(y),y_bar,c)
