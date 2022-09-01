## this function performs Gibbs sampling for normal data
## iters --- iterations of Gibbs sampling
## x --- data
## mu0 --- prior mean for mu parameter
## sigma0 -- prior variance for mu parameter
## alpha --- degree freedom for sigma parameter
## w --- prior mean for sigma parameter
gibbs_norm <- function (iters, x, mu0, sigma0, alpha, w)
{
  sumx <- sum (x)
  n <- length (x)

  ## set and initial Markov chain state
  mu <- 0
  sigma <- 1

  one_gibbs <- function ()
  {
    ## update mu
    post_var_mu <- 1 / (n/sigma + 1/sigma0)
    mu <<- rnorm (1, (sumx / sigma + mu0 / sigma0) * post_var_mu,
                 sqrt (post_var_mu))
    sigma <<- 1/rgamma (1, (alpha + n)/2, (alpha * w + sum ((x-mu)^2))/2 )
    c(mu, sigma)
  }
  mc_musigma <- replicate (iters, one_gibbs ())
  list (mu = mc_musigma[1,], sd = sqrt (mc_musigma[2,]) )
}

## a simple test

pdf ("gibbs_norm-plots.pdf")

## test 1

x <- rnorm (50)

mcsamples <- gibbs_norm (10000, x, 0, 1E10, 1E-5, 1E-5)
plot (mcsamples$mu, main = "MC trace of mu", type = "l")
plot (density (mcsamples$mu))
acf (mcsamples$mu)
quantile (mcsamples$mu, probs = c(0, 0.025, 0.5, 0.975, 1))
mean (mcsamples$mu)
sd (mcsamples$mu)
plot (mcsamples$sd, main = "MC trace of sd", type = "l")
plot (density ((mcsamples$sd)))

quantile (mcsamples$sd, probs = c(0, 0.025, 0.5, 0.975, 1))

plot (mcsamples$mu, mcsamples$sd)

## test 2
x <- rnorm (50, 10, 2)

mcsamples <- gibbs_norm (10000, x, 0, 1E10, 1E-5, 1E-5)
plot (mcsamples$mu, main = "MC trace of mu", type = "l")
plot (density (mcsamples$mu))
acf (mcsamples$mu)
quantile (mcsamples$mu, probs = c(0, 0.025, 0.5, 0.975, 1))
mean (mcsamples$mu)
sd (mcsamples$mu)
plot (mcsamples$sd, main = "MC trace of sd", type = "l")
plot (density ((mcsamples$sd)))

quantile (mcsamples$sd, probs = c(0, 0.025, 0.5, 0.975, 1))

plot (mcsamples$mu, mcsamples$sd)

## test 3
x <- rnorm (5000, 10, 2)


mcsamples <- gibbs_norm (10000, x, 0, 1E10, 1E-5, 1E-5)
plot (mcsamples$mu, main = "MC trace of mu", type = "l")
plot (density (mcsamples$mu))
acf (mcsamples$mu)
quantile (mcsamples$mu, probs = c(0, 0.025, 0.5, 0.975, 1))
mean (mcsamples$mu)
sd (mcsamples$mu)
plot (mcsamples$sd, main = "MC trace of sd", type = "l")
plot (density ((mcsamples$sd)))

quantile (mcsamples$sd, probs = c(0, 0.025, 0.5, 0.975, 1))

plot (mcsamples$mu, mcsamples$sd)

dev.off ()

