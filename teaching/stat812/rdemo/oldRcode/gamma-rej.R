# Note: this is only a toy example demonstrating how to program rejection sampling
# this is not a good sampling scheme for gamma distribution. 
# Do not use it for serious applications that demand high efficiency. 


#log of a function which is always above the Gamma density function  
# alpha must be > 2
log_g_gamma <- function(x, alpha)
{
   (alpha-1) * (log(alpha-1) - 1) - log( 1 + (x-(alpha-1))^2 / (2*alpha-1) )  
}

## look at the approximating functionn
xvec <- seq (0, 3, by = 0.0001)
alpha <- 2.1
log_g_gamma_val <- log_g_gamma(xvec, alpha = alpha)
log_gamma_val <- dgamma (xvec, shape = alpha, log =T)
ylim <- range (log_g_gamma_val, log_gamma_val, finite = T)
plot (xvec, log_g_gamma_val, col = "black", type = "l", ylim = ylim )
points (xvec,log_gamma_val, col = "red",type = "l")
## note that we see that g isn't above dgamma all the time when alpha < 2

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
alpha <- 4.3
gammarn <- sample_gamma_rej (2000,alpha); attr (gammarn, "accept.rate")
hist (gammarn)
qqplot(gammarn, rgamma (2000, alpha))
## we see that when alpha is larger than 2, the overall acceptance rate is very low


## if you requires highly efficient gamma random numbers generators, 
## read a paper in Computational Statistics and Data Analysis (2007)
## http://www.sciencedirect.com/science/article/pii/S0167947306003616 

## or type ?rgamma in R to see which generator R uses. 


