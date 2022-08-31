################# a generic function for metropolis sampling ###############
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

############## sample from truncated normal ################################
log_tnorm <- function (x, mu, sigma, lb, ub) 
{
    if (x > lb & x < ub) dnorm (x, mu, sigma, log = T)
    else -Inf
}

mean_x2_mc <- replicate (100,
{
    mcsample1 <-  met_gauss (log_f = log_tnorm, stepsizes = 0.1, iters = 10000, 
                             mu = 0, sigma = 2, lb = -4, ub = 4, ini_value = 3.3)
    attr (mcsample1, "rej.rate")
    #acf (mcsample1)
    
    mcsample2 <-  met_gauss (log_f = log_tnorm, stepsizes = 0.5,  
                             mu = 0, sigma = 2, lb = -4, ub = 4, ini_value = 3.3)
    attr (mcsample2, "rej.rate")
    #acf (mcsample2)
    
    mcsample3 <-  met_gauss (log_f = log_tnorm, stepsizes = 2,  
                             mu = 0, sigma = 2, lb = -4, ub = 4, ini_value = 3.3)
    attr (mcsample3, "rej.rate")
    #acf (mcsample3)
    
    mcsample4 <-  met_gauss (log_f = log_tnorm, stepsizes = 10,  
                             mu = 0, sigma = 2, lb = -4, ub = 4, ini_value = 3.3)
    attr (mcsample4, "rej.rate")
    #acf (mcsample4)
    
    mcsample5 <-  met_gauss (log_f = log_tnorm, stepsizes = 100,  
                             mu = 0, sigma = 2, lb = -4, ub = 4, ini_value = 3.3)
    attr (mcsample5, "rej.rate")
    
    
    c(
      mean (mcsample1^2),
      mean (mcsample2^2),
      mean (mcsample3^2),
      mean (mcsample4^2)
    )
}
)

library (truncnorm)
mean_x2 <- mean (rtruncnorm (10000000,3,6,0,2)^2)

rowMeans(abs(mean_x2_mc -mean_x2))
sqrt(rowMeans((mean_x2_mc -mean_x2)^2))

if (F) {
plot (mcsample1[1:100], type = "l")
plot (mcsample2[1:100], type = "l")
plot (mcsample3[1:100], type = "l")
plot (mcsample4[1:100], type = "l")
}

########### sample from a truncated multivariate normal ###################
log_tmnorm <- function (x, mu, sigma)
{
    if (abs(x[1]) + abs(x[2]) < 1) sum(dnorm (x, mu, sigma, log = T))
    else -Inf
}

mcmnorm1 <-  met_gauss (log_f = log_tmnorm, stepsizes = 0.1,  iters = 100000,
                         mu = c(0,0), sigma = c(2,2), ini_value = c(0,0))

plot (t(mcmnorm1))

attr (mcmnorm1, "rej.rate")

mcmnorm2 <-  met_gauss (log_f = log_tmnorm, stepsizes = 0.5,  
                        mu = c(0,0), sigma = c(2,2), ini_value = c(0,0))

plot (t(mcmnorm2))

attr (mcmnorm2, "rej.rate")

mcmnorm3 <-  met_gauss (log_f = log_tmnorm, stepsizes = 1,  
                        mu = c(0,0), sigma = c(2,2), ini_value = c(0,0))

plot (t(mcmnorm3))

attr (mcmnorm3, "rej.rate")


