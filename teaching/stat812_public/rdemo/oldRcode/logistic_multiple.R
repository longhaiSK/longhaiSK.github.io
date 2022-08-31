# function to compute logistic regression -log likelihood, -score and
# information. b=parameters, r=binary response, z=covariate
lik_score_info <- function(b,r,z) {
        u <- b[1]+b[2]*z
        u2 <- exp(u)
        l <- -sum(u*r-log(1+u2))
        p <- u2/(1+u2)
        s <- -c(sum(r-p),sum(z*(r-p)))
        v <- matrix(c(sum(p*(1-p)),sum(z*p*(1-p)),0,sum(z*z*p*(1-p))),2,2)
        v[1,2] <- v[2,1]
        list(neg.loglik=l,neg.score=s,inf=v)
}

neg_logp_logistic <- function (b, z, r)
{
    u <- b[1]+b[2]*z
    u2 <- exp(u)
    -sum(u*r-log(1+u2))
}

####### a function for finding MLE with newton method
mle_logistic_nr <- function(b0, no_iter, r, z, debug=FALSE)
{
    result_nr <- matrix(0,no_iter+1, 3)
    colnames(result_nr) <- c('beta0','beta1','neg_loglike')
    result_nr[1,] <- c(b0, 0)

    for( i in 1:no_iter + 1)
    {
         q <- lik_score_info(result_nr[i-1,1:2],r,z)
         result_nr[i,1:2] <-   result_nr[i-1,1:2] - solve(q$inf,q$neg.score)
         result_nr[i-1,3] <- q$neg.loglik
         if(debug) print(result_nr[i-1,])
    }
    result_nr[-(no_iter+1),]
}


## generate a data set

gen_logistic_data <- function(b,n)
{
    z <- sort(runif(n, -2,2))
    emu <- exp(b[1]+z*b[2])
    p <- emu/(1+emu)
    r <- (runif(n)<p)*1
    plot (z, p, type = "l",ylim=c(0,1))
    points (z, r, col = r+1)
    list(z=z,r=r)
}

data <- gen_logistic_data(c(0,1.5),200)

# using self-programmed newton method
mle_logistic_nr(c(0,3),15,data$r,data$z) 
mle_logistic_nr(c(0,5),15,data$r,data$z)

## look at contour of bivariate log likelihood

B0 <- seq (-2, 2, by = 0.1)
B1 <- seq (-10, 10, by = 0.1)
loglike_values <- matrix (0, length (B0), length (B1))
for (i in 1:length (B0)) {
    for (j in 1:length (B1))
    {
        loglike_values[i,j] <- 
            neg_logp_logistic (c(B0[i], B1[j]),z = data$z, r = data$r )
    }
}
contour (B0, B1, loglike_values, nlevels = 100)
points(mle_logistic_nr(c(0,3),15,data$r,data$z), col = 1, type = "b") 
points(mle_logistic_nr(c(0,5),15,data$r,data$z), col = 2, type = "b") 

###### Find MLE using nlm function
nlm (neg_logp_logistic, c(0,0), z = data$z, r = data$r, hessian = T) -> logit_nlm
nlm (neg_logp_logistic, c(0,5), z = data$z, r = data$r, hessian = T)
nlm (neg_logp_logistic, c(-10, -10), z = data$z, r = data$r, hessian = T)

# find MLE standard errors using hessian of negative log likelihood
sds <- sqrt (diag (solve(logit_nlm$hessian))); sds

###### find MLE using glm function

logitfit_glm <- glm (r ~ z, family = binomial(), data = data)
summary (logitfit_glm)

logitfit_glm <- glm (r ~ z, family = binomial(), data = data, start = c(0,0))
summary (logitfit_glm)

logitfit_glm <- glm (r ~ z, family = binomial(), data = data, start = c(0,2))
summary (logitfit_glm)

logitfit_glm <- glm (r ~ z, family = binomial(), data = data, start = c(0,3))
summary (logitfit_glm)

