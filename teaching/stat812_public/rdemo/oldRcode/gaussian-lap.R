## the generic function for finding laplace approximation of integral of 'f'
## neg_log_f    --- the negative log of the intergrand function
## p0           --- initial value in searching mode
## ...          --- other arguments needed by neg_log_f
bayes_inference_lap <- function(neg_log_f,p0,...)
{   ## looking for the mode and hessian of the log likehood function
    result_min <- nlm(f=neg_log_f,p=p0, hessian=TRUE,...)
    hessian <- result_min$hessian
    neg_log_like_mode <- result_min$minimum
    
    
    estimates <- result_min$estimate ## posterior mode
    SIGMA <- solve(result_min$hessian) ## covariance matrix of posterior mode
    sds <- sqrt (diag(SIGMA)) ## standard errors of each estimate
    log_mar_lik <- ## log marginalized likelihood
        - neg_log_like_mode + 0.5 * ( sum(log(2*pi) - log(svd(hessian)$d) ))
    
    list (estimates = estimates, sds = sds, SIGMA = SIGMA, log_mar_lik = log_mar_lik)
}

## the function for computing log likelihood of normal data
## mu is the unknown mean, and w is the log of standard deviation (sd)
log_lik <- function(x,mu,w)
{   sum(dnorm(x,mu,exp(w),log=TRUE))
}

## the function for computing log prior
log_prior <- function(mu,w, mu_0,sigma_mu,w_0,sigma_w)
{   dnorm(mu,mu_0,sigma_mu,log=TRUE) + dnorm(w,w_0,sigma_w,log=TRUE)
}

## the function for computing the negative log of likelihood * prior
neg_log_post <- function(x, theta, mu_0,sigma_mu,w_0,sigma_w)
{   - log_lik(x,theta[1], theta[2]) - log_prior(theta[1],theta[2],mu_0,sigma_mu,w_0,sigma_w)
}



## approximating the log of integral of likelihood * prior
bayes_inference_lap_gaussian <- function(x,mu_0,sigma_mu,w_0,sigma_w)
{   bayes_inference_lap(
                neg_log_post,p0=c(mean(x),log(sqrt(var(x)))),
                x=x,mu_0=mu_0,sigma_mu=sigma_mu,w_0=w_0,sigma_w=sigma_w
    )
}


source("gaussian-midpoint.R")

## test with a data set with mean 5
x <- rnorm(50, mean = 5)
bayes_inference_lap_gaussian(x,0,100,0,5)
## compare with naive Monte carlo and midpoint rule for computing log mar lik.
log_mar_gaussian_mc(x,0,100,0,5,1000000)
log_mar_gaussian_mid(x,0,100,0,5,100)


x <- rnorm(50, mean = -5)
bayes_inference_lap_gaussian(x,0,100,0,5)
log_mar_gaussian_mc(x,0,100,0,5,1000000)
log_mar_gaussian_mid(x,0,100,0,5,100)

x <- rnorm(50, mean = -50, sd = 4)
bayes_inference_lap_gaussian(x,0,100,0,5)
log_mar_gaussian_mc(x,0,100,0,5,10000000)
log_mar_gaussian_mid(x,0,100,0,5,100)

x <- rnorm(50, mean = -50, sd = 10)
bayes_inference_lap_gaussian(x,0,100,0,5)
log_mar_gaussian_mc(x,0,100,0,5,1000000)
log_mar_gaussian_mid(x,0,100,0,5,100)
## we see that mid point rule may not work well  
