library("MASS")

n<-500 #sample size
x <- runif(n,-1.5,1.5)
lambda <- x^2
y <- rnbinom(n,size = 2, mu = exp(lambda))

###########################################################
#Model fitting
###########################################################
fit.r <- glm.nb(y~lambda)  # true model (nb: x^2)
fit.w <- glm.nb(y~x)       # wrong model(nb: x)

mu.hat.r <- fitted.values(fit.r)
mu.hat.w <- fitted.values(fit.w)

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
size.hat.r <- fit.r$theta
size.hat.w <- fit.w$theta
res.quantile.r <- qnorm(pnbinom (y-1,size = size.hat.r, mu = mu.hat.r) + 
                          dnbinom (y,size = size.hat.r, mu = mu.hat.r) * runif(n))
res.quantile.w <- qnorm(pnbinom (y-1,size = size.hat.w, mu = mu.hat.w) + 
                          dnbinom (y,size = size.hat.w, mu = mu.hat.w) * runif(n))

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
