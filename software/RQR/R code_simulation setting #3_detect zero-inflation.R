 
library("pscl")

dzpois <- function(x,lambda,p)
{
  return((1-p)*dpois(x,lambda)+p*(x==0))
}

pzpois <- function(x,lambda,p)
{
  return((1-p)*ppois(x,lambda)+p*(x>=0))
}

 
n<-100 #sample size
beta0 <- 1
beta1 <- 2
p <- .3

x <- runif(n,-1,2)
mu <- exp(beta0+beta1*x)
y <- rpois(n,mu)*rbinom(n,1,1-p)

###########################################################
#Model fitting
###########################################################
fit.r <- zeroinfl(y~x|1,dist="poisson")
fit.w1 <- glm(y~x,family="poisson")

mu.hat.r <- exp(coef(fit.r)[1]+coef(fit.r)[2]*x)
mu.hat.w1 <- fitted.values(fit.w1)

p.hat.r <- exp(coef(fit.r)[3])/(1+exp(coef(fit.r)[3]))

#############################################################
#Residuals
#############################################################

#deviance Residuals
res.deviance.r <- sign(y-mu.hat.r*(1-p.hat.r))*sqrt(2)*sqrt(log(dpois(y,y))-log(dzpois(y,mu.hat.r,p.hat.r)))
res.deviance.w1 <- resid(fit.w1,"deviance")

#Pearson residuals
res.pearson.r <- resid(fit.r,"pearson")
res.pearson.w1 <- resid(fit.w1,"pearson")
 
### Randomized quantile residual
pvalue.r <- pzpois (y-1,mu.hat.r,p.hat.r) + dzpois (y, mu.hat.r,p.hat.r) * runif(n)
pvalue.w1 <- ppois (y-1,mu.hat.w1) + dpois (y, mu.hat.w1) * runif(n)
 
pvalue.r[pvalue.r==1] <- .999999999
pvalue.w1[pvalue.w1==1] <- .999999999
 
res.quantile.r <- qnorm(pvalue.r)
res.quantile.w1 <- qnorm(pvalue.w1)
 
 
############################################################# 
### residual analysis with RQR (NRPP)
#############################################################
par (mfcol=c(2,2))

plot(x,res.quantile.r)
plot(x,res.quantile.w1)

qqnorm(res.quantile.r);abline(a=0,b=1)
qqnorm(res.quantile.w1);abline(a=0,b=1)

shapiro.test(res.quantile.r)
shapiro.test(res.quantile.w1)
