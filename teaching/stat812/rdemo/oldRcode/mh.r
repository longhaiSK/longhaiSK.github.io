met_gauss <- function (iters = 10000, log_f, stepsizes = 0.5, ini_value,
                       iters_imc = 1,  ...)
{
    state <- ini_value
    no_var <- length (state)
    logf <- log_f (ini_value,...)
    rej <- 0
    
    if (!is.finite (logf)) stop ("Initial value has 0 probability")
    
    one_mc <- function ()
    {
        new_state <- rnorm (no_var, state, stepsizes)
        new_logf <- log_f (new_state,...)
        
        if (log (runif(1)) < new_logf - logf)
        {
            state <<- new_state
            logf <<- new_logf
        }
        else rej <<- rej + 1
    }
    
    one_sup <-  function ()
    {
        replicate (iters_imc, one_mc())
        state
    }
    
    mcsample <- replicate (iters, one_sup () )
    attr (mcsample, "rej.rate") <- rej / iters_imc / iters
    mcsample
}

## this function performs MH sampling for normal data
## iters --- iterations of Gibbs sampling
## x --- data
## mu0 --- prior mean for mu parameter
## sigma0 -- prior variance for mu parameter
## alpha --- degree freedom for sigma parameter
## w --- prior mean for sigma parameter

mh_norm <- function (iters, stepsizes, x, mu0, sigma0, alpha, w)
{
  logmusigma <- function (mulogsigma)
  {
    mu <- mulogsigma[1]
    logsigma <- mulogsigma[2]
    sigma <- exp (logsigma)

    return (sum(dnorm (x, mu, sqrt(sigma), log = T)) +
    dnorm (mu, mu0, sqrt (sigma0), log = T) +
    dgamma (sigma, alpha/2, alpha * w/2, log = T) +
    logsigma )
  }

  mc_mulogsigma <- met_gauss (
  iters = iters, log_f = logmusigma, stepsizes = stepsizes, ini_value = c(0,0))
  cat ("Rejection rate is ", attr (mc_mulogsigma, "rej.rate"), "\n")

  list (mu = mc_mulogsigma[1,], sd =  exp (0.5*mc_mulogsigma[2,]))
}

pdf ("mh-plots.pdf")

x <- rnorm (50, 10, 2)


## run preliminary mcmc to determine the stepsize
mcsamples <- mh_norm (10000, c(20,20)/sqrt(length(x)),
                      x, 0, 1E10, 1E-5, 1E-5)
plot (mcsamples$mu, main = "MC trace of mu", type = "l")
acf (mcsamples$mu)
acf (mcsamples$sd)

mcsamples <- mh_norm (10000, c(10,10)/sqrt(length(x)),
              x, 0, 1E10, 1E-5, 1E-5)
plot (mcsamples$mu, main = "MC trace of mu", type = "l")
acf (mcsamples$mu)
acf (mcsamples$sd)

## 
mcsamples <- mh_norm (1000, c(4,4)/sqrt(length(x)),
                      x, 0, 1E10, 1E-5, 1E-5)
plot (mcsamples$mu, main = "MC trace of mu", type = "l")
acf (mcsamples$mu)
acf (mcsamples$sd)

## 
mcsamples <- mh_norm (1000, c(2,2)/sqrt(length(x)),
              x, 0, 1E10, 1E-5, 1E-5)
plot (mcsamples$mu, main = "MC trace of mu", type = "l")
acf (mcsamples$mu)
acf (mcsamples$sd)

## we found that using (10,10)/sqrt (n) may be the best, based on certain theory, (4,4) is better as it has rejection rate 0.725


mcsamples <- mh_norm (100000, c(10,10)/sqrt(length(x)),
              x, 0, 1E10, 1E-5, 1E-5)
plot (mcsamples$mu, main = "MC trace of mu", type = "l")
acf (mcsamples$mu[-(1:200)])
quantile (mcsamples$mu[-(1:200)], probs = c(0, 0.025, 0.5, 0.975, 1))
sd (mcsamples$mu[-(1:200)])
plot (mcsamples$sd, main = "MC trace of sd", type = "l")
quantile (mcsamples$sd[-(1:200)], probs = c(0, 0.025, 0.5, 0.975, 1))
plot (mcsamples$mu[-(1:200)], mcsamples$sd[-(1:200)])

## test 2


dev.off ()
