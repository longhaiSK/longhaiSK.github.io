

## the function for computing log likelihood of normal data
log_lik <- function(x,mu,w)
{   sum(dnorm(x,mu,exp(w),log=TRUE))
}

## the function for computing log prior
log_prior <- function(mu,w, mu_0,sigma_mu,w_0,sigma_w)
{   dnorm(mu,mu_0,sigma_mu,log=TRUE) + dnorm(w,w_0,sigma_w,log=TRUE)
}

## the function for computing the unormalized log posterior 
## given transformed mu and w 
log_post_tran <- function(x, mu_t, w_t, mu_0,sigma_mu,w_0,sigma_w)
{
    #log likelihood
    log_lik(x,logi(mu_t), logi(w_t)) +
    #log prior 
    log_prior(logi(mu_t), logi(w_t), mu_0,sigma_mu,w_0,sigma_w) + 
    #log derivative of transformation
    log_der_logi(mu_t) + log_der_logi(w_t)
}

## the logistic function for transforming (0,1) value to (-inf,+inf)
logi <- function(x)
{  log(x) - log(1-x)
}

## the log derivative of logistic function 
log_der_logi <- function(x)
{  -log(x) - log(1-x)
}

## the generic function for approximating 1-D integral with midpoint rule
## the logarithms of the function values are passed in
## the log of the integral result is returned

## log_f  --- a function computing the logarithm of the integrant function
## range  --- the range of integral varaible, a vector of two elements
## n      --- the number of points at which the integrant is evaluated
## ...    --- other parameters needed by log_f
log_int_mid <- function(log_f, range, n,...)
{   if(range[1] >= range[2]) 
        stop("Wrong ranges")
    h <- (range[2]-range[1]) / n
    v_log_f <- sapply(range[1] + (1:n - 0.5) * h, log_f,...)
    log_sum_exp(v_log_f) + log(h)       
}

## a function computing the sum of numbers represented with logarithm
## lx     --- a vector of numbers, which are the log of another vector x.
## the log of sum of x is returned
log_sum_exp <- function(lx)
{   mlx <- max(lx)
    mlx + log(sum(exp(lx-mlx)))
}

## a function computing the normalization constant
log_mar_gaussian_mid <- function(x,mu_0,sigma_mu,w_0,sigma_w,n)
{
    ## function computing the normalization constant of with mu_t fixed
    log_int_gaussian_mu <- function(mu_t)
    {   log_int_mid(log_f=log_post_tran,range=c(0,1),n=n,
                    x=x,mu_t=mu_t,mu_0=mu_0,sigma_mu=sigma_mu,
                    w_0=w_0,sigma_w=sigma_w)
    }
    
    log_int_mid(log_f=log_int_gaussian_mu,range=c(0,1), n=n)
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

############ some tests ###################################################
x <- rnorm(50)
log_mar_gaussian_mid(x,0,1,0,1,100)
log_mar_gaussian_mc(x,0,1,0,1,100000)
x <- rnorm(10) # another debug
log_mar_gaussian_mid(x,0,1,0,1,100)
log_mar_gaussian_mc(x,0,1,0,1,100000)

## looking at the convergence
x <- rnorm(100)
for(i in seq(10,90,by=10))
{ cat("n = ",i,",")
    cat(" Estimated Log Marginal Likelihood =", 
        log_mar_gaussian_mid(x,0,1,0,1,i),"\n")
}

## looking at the log marginal likelihood of different models
x <- rnorm(100)
log_mar_gaussian_mid(x,mu_0=0,sigma_mu=1,w_0=0,sigma_w=1,100)
log_mar_gaussian_mid(x,mu_0=-5,sigma_mu=10,w_0=0,sigma_w=1,100)
log_mar_gaussian_mid(x,mu_0=-5,sigma_mu=1,w_0=0,sigma_w=1,100)
