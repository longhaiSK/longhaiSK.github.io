log_AD_gamma <- function(x, alpha)
{
    if (x < 1)  
}

## look at the approximating functionn
xvec <- seq (0, 1, by = 0.0001)
alpha <- 1.1
log_g_gamma_val <- log_g_gamma(xvec, alpha = alpha)
log_gamma_val <- dgamma (xvec, shape = alpha, log =T)
ylim <- range (log_g_gamma_val, log_gamma_val, finite = T)
plot (xvec, log_g_gamma_val, col = "black", type = "l", ylim = ylim )
points (xvec,log_gamma_val, col = "red",type = "l")
## we see that g isn't above dgamma all the time when alpha < 2

#sampling from Gamma distribution with rejection sampling
sample_gamma_rej <- function(n,alpha)
{  sample_gamma <- rep(0,n)
no.draw <- 0  
for(i in 1:n)
{   rejected <- TRUE

while(rejected)
{  sample_gamma[i] <- rcauchy(1) * sqrt(2*alpha-1) + (alpha -1)
no.draw <- no.draw + 1
U <- runif(1)
rejected <- (log(U) > dgamma(sample_gamma[i],shape=alpha,log=TRUE) - 
                 log_g_gamma(sample_gamma[i],alpha) )
}
}
attr(sample_gamma, "accept.rate") <- n/no.draw
sample_gamma
}


# a test
alpha <- 2.1
gammarn <- sample_gamma_rej (2000,alpha); attr (gammarn, "accept.rate")
hist (gammarn)
qqplot(gammarn, rgamma (2000, alpha))
