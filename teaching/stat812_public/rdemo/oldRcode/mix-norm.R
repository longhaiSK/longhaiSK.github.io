log_like_obs <- function(theta,Y)
{
    sum( log( theta[1] * dnorm(Y,theta[2],1) + 
                  (1 - theta[1]) * dnorm(Y,theta[3],1)
    )
    )
}


em_mixnorm <- function(theta0,Y,no_iters)
{
    result <- matrix(0,no_iters + 1,4)
    colnames(result) <- c("p","u1","u0","log_lik")
    result[1,1:3] <- theta0
    result[1,4] <- log_like_obs(theta0,Y)
    for(i in 1:no_iters + 1) {
        like1_weighted <- dnorm(Y,result[i-1,2],1) * result[i-1,1]
        like0_weighted <- dnorm(Y,result[i-1,3],1) * (1-result[i-1,1])
        weighs <-   like1_weighted / (like1_weighted + like0_weighted)
        #update p
        result[i,1] <- mean(weighs)
        #update u1
        result[i,2] <- sum(Y*weighs)/sum(weighs)
        result[i,3] <- sum(Y*(1-weighs))/sum(1-weighs)
        result[i,4] <- log_like_obs(result[i,1:3],Y)
    }
    result
}

gen_mixnorm <- function(theta,n)
{
    Z <- 1*(runif(n) < theta[1])
    Y <- rep(0,n)
    for(i in 1:n){
        if(Z[i]==1) Y[i] <- rnorm(1,theta[2],1)
        else Y[i] <- rnorm(1,theta[3],1)
    }
    plot (Y, Z, col = Z+1)
    Y
}

data <- gen_mixnorm(c(0.3,0,3),200)
em_mixnorm(c(0.5,-20,10),data,25)

em_mixnorm(c(0.5,0.1,0.2),data,25)

## try this and think what caused the NaN
em_mixnorm(c(0.5,50, 60),data,25)


## compare with nlm
nlm (log_like_obs, p = c(0.3,0,3), Y = data)
nlm (log_like_obs, p = c(0.3,0,2.8), Y = data)

## we see that nlm doesn't work at all in this naive implementation
