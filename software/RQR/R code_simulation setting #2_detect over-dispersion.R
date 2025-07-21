
 

library("MASS")

n<-100 #sample size
beta0 <- 1
beta1 <- 2

x <- runif(n,-1,2)
y <- rnbinom(n,size = 2, mu = exp(beta0+beta1*x))

###########################################################
#Model fitting
###########################################################
fit.r <- glm.nb(y~x)
fit.w <- glm(y~x, family = "poisson")
mu.hat.r <- fitted.values(fit.r)
mu.hat.w <- fitted.values(fit.w)
size.hat.r <- fit.r$theta


#############################################################
#Residuals
#############################################################

### deviance residual
res.deviance.r <- resid(fit.r,"deviance")
res.deviance.w <- resid(fit.w,"deviance")

### Pearson residual
res.pearson.r <- resid(fit.r,"pearson")
res.pearson.w <- resid(fit.w,"pearson")

### Randomized quantile residual
res.quantile.r <- qnorm(pnbinom (y-1,size = size.hat.r, mu = mu.hat.r) + dnbinom (y,size = size.hat.r, mu = mu.hat.r) * runif(n))
pvalue.w <- ppois (y-1,mu.hat.w) + dpois (y, mu.hat.w) * runif(n)
pvalue.w[pvalue.w==1] <- .999999999
res.quantile.w <- qnorm(pvalue.w)

############################################################# 
### residual analysis with RQR (NRPP)
#############################################################
par (mfcol=c(2,2))

plot(x,res.quantile.r)
plot(x,res.quantile.w)

qqnorm(res.quantile.r);abline(a=0,b=1)
qqnorm(res.quantile.w);abline(a=0,b=1)

shapiro.test(res.quantile.r)
shapiro.test(res.quantile.w)
