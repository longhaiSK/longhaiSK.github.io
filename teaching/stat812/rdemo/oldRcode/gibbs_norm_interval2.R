library (truncnorm)
## this function performs Gibbs sampling for normal data
## iters --- iterations of Gibbs sampling
## y --- data, the observed lower limits 
## l the length of interval
## mu0 --- prior mean for mu parameter
## sigma0 -- prior variance for mu parameter
## alpha --- degree freedom for sigma parameter
## w --- prior mean for sigma parameter
gibbs_norm_interval <- function (iters, y, mu0, sigma0, alpha, w, l = 1)
{
    n <- length (y)
    
    ## set and initial Markov chain state
    mu <- 0
    sigma <- 1
    x <- rep (0, n)
    one_gibbs <- function ()
    {
        for (i in 1:n)
            x[i] <<- rtruncnorm (1, a = y[i], b = y[i] + l, 
                                 mean = mu, sd = sqrt(sigma))
        sumx <- sum (x)
        ## update mu
        post_var_mu <- 1 / (n/sigma + 1/sigma0)
        post_mean_mu <- (sumx / sigma + mu0 / sigma0) * post_var_mu
        mu <<- rnorm (1,post_mean_mu, sqrt (post_var_mu))
        sigma <<- 1/rgamma (1, (alpha + n)/2, (alpha * w + sum ((x-mu)^2))/2 )
        
        
        return(c(mu, sigma, x))
    }
    mc_musigma <- replicate (iters, one_gibbs ())
    
    list (mu = mc_musigma[1,], sd = sqrt (mc_musigma[2,]), 
          x = mc_musigma[-(1:2),] )
}

## a simple test

x <- rnorm (100, 3, 10); 
y <- floor (x); mean (y); sd (y)

mcsamples <- gibbs_norm_interval (10000, y, 0, 1E10, 1E-5, 1E-5, 1)

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

plot (mcsamples$mu[1:100], mcsamples$sd[1:100], type = "b")
plot (mcsamples$x[1, 1:100], type = "l")
hist (mcsamples$x[1,])

## another test


y2 <- floor (x*10)/10
mcsamples2 <- gibbs_norm_interval (10000, y2, 0, 1E10, 1E-5, 1E-5, 0.1)

plot (mcsamples2$mu[1:100], main = "MC trace of mu", type = "l")
acf (mcsamples2$mu)
quantile (mcsamples2$mu[-(1:100)], probs = c(0, 0.025, 0.5, 0.975, 1))
sd (mcsamples2$mu)
plot (mcsamples2$sd[1:100], main = "MC trace of sd", type = "l")
quantile (mcsamples2$sd[-(1:100)], probs = c(0, 0.025, 0.5, 0.975, 1))

plot (mcsamples2$mu[-(1:100)], mcsamples2$sd[-(1:100)], type = "l")

## compare inference results for two data sets
boxplot (data.frame(mcsamples$mu[-(1:100)], mcsamples2$mu[-(1:100)]))
boxplot (data.frame(mcsamples$sd[-(1:100)], mcsamples2$sd[-(1:100)]))

