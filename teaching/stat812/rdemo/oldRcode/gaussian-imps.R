## computing the log probability density function of multivariate normal
## x     --- a vector, the p.d.f at x will be computed
## mu   --- the mean vector of multivariate normal distribution
## A     --- the inverse covariance matrix of multivariate normal distribution
log_pdf_mnormal <- function(x, mu, A)
{   0.5 * ( -length(mu)*log(2*pi) + sum(log(svd(A)$d)) - t(x-mu) %*% A %*% (x-mu) ) 

}
## the function for computing log likelihood of normal data
log_lik <- function(x,mu,w)
{   sum(dnorm(x,mu,exp(w),log=TRUE))
}

## the function for computing log prior
log_prior <- function(mu,w, mu_0,sigma_mu,w_0,sigma_w)
{   dnorm(mu,mu_0,sigma_mu,log=TRUE) + dnorm(w,w_0,sigma_w,log=TRUE)
}

## the function for computing the negative log of likelihood * prior 
neg_log_post <- function(x, theta, mu_0,sigma_mu,w_0,sigma_w)
{   - log_lik(x,theta[1], theta[2]) - 
    log_prior(theta[1],theta[2],mu_0,sigma_mu,w_0,sigma_w)
}


## computing the log marginal likelihood using importance sampling with 
## the posterior distribution approximated by the Gaussian distribution at
## its mode
log_mar_gaussian_imps <- function(x,mu_0,sigma_mu,w_0,sigma_w,iters_mc)
{   result_min <- nlm(f=neg_log_post,p=c(mean(x),log(sqrt(var(x)))), 
                      hessian=TRUE,
                      x=x,mu_0=mu_0,sigma_mu=sigma_mu,w_0=w_0,sigma_w=sigma_w)
    hessian <- result_min$hessian
    mu <- result_min$estimate
    
    ## finding the multiplier for sampling from multivariate normal
    Sigma <- t( chol(solve(hessian)) )
    ## draw samples from N(mu, Sigma %*% Sigma')
    thetas <- Sigma %*% matrix(rnorm(2*iters_mc),2,iters_mc) + mu
     
    ## values of log approximate p.d.f. at samples
    log_pdf_mnormal_thetas <- apply(thetas,2,log_pdf_mnormal,mu=mu,A=hessian)
    ## values of log true p.d.f. at samples
    log_post_thetas <- - apply(thetas,2,neg_log_post,x=x, mu_0=mu_0,
                               sigma_mu=sigma_mu,w_0=w_0,sigma_w=sigma_w)
  
    ## averaging the weights, returning its log
    log_sum_exp(log_post_thetas-log_pdf_mnormal_thetas) - log(iters_mc)
}

## a function computing the sum of numbers represented with logarithm
## lx     --- a vector of numbers, which are the log of another vector x.
## the log of sum of x is returned
log_sum_exp <- function(lx)
{   mlx <- max(lx)
    mlx + log(sum(exp(lx-mlx)))
}

## we use Monte Carlo method to debug the above function
log_mar_gaussian_mc <- function(x,mu_0,sigma_mu,w_0,sigma_w,iters_mc)
{
    ## draw samples from the priors
    mus <- rnorm(iters_mc,mu_0,sigma_mu)
    ws <- rnorm(iters_mc,w_0,sigma_w)
    one_log_lik <- function(i)
    {  log_lik(x,mus[i],ws[i])
    }
    v_log_lik <- sapply(1:iters_mc,one_log_lik)
    log_sum_exp(v_log_lik) - log(iters_mc)
}
