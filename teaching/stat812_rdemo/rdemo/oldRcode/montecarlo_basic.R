## demonstration of central limit theorem

sample_sizes <- c(4,4^2,4^3,4^4,4^5,4^6)

no_sim<- 10000

X <- rep(0,no_sim)

shape <- 10

par(mfrow=c(3,2), mar=c(4,4,3,1))
for(n in sample_sizes)
{
    for(i_sim in 1:no_sim) X[i_sim] <- mean( rgamma(n,shape=shape,scale=1) )
    
    hist(X,xlim=c(4,16),nclass=30,main=paste("n=",n))
}

#### an application of monte carlo method in estimating pi

# n is the number of samples drawn uniformly from the rectangle (-1,1)  * (-1,1)
# an estimate of pi is returned
pi_est_mc <- function(n)
{
    #X and Y are independent, each with marginal distribution unif(-1,1)
    X <- runif(n,-1,1)
    Y <- runif(n,-1,1)
    
    Z <- 4 * (X^2 + Y^2 <= 1)
    mu <- mean (Z)
    error <- 1.96 * sd (Z) /sqrt (n)
    list (pi.est = mu, error.95perc = error, ci.95perc = mu + c(-error, error))
}  

pi_est_mc (100)
pi_est_mc (10000)
pi_est_mc (100000)
pi_est_mc (10000000)
pi_est_mc (100000000) ## caution: don't increase n further, it may crash your computer
