library("MASS")


#---------------------------------------------------------------------------------------------------------------------------------- 
# Test for equal variances of RQR against groups of x
# for continuous x...we devide x into m groups
# for cateogrical x..we keep x's levels as they are 
# 
#  n: sample size 
#  y: residuals
#  x: covariate 
#  m: groups (split sample into m groups)
#---------------------------------------------------------------------------------------------------------------------------------- 

equavarance.test<-function(n, y, x, m){
  y.ordered<-y[order(x)] #order RQR by the covaraite x
  test.eqvan.p<-bartlett.test(y.ordered~as.factor(rep(1:(n/m), each=m)))$p.value
  return(test.eqvan.p)
}


n<-1000 #sample size
x <- runif(n,0,pi)
xsq<- sin(5*x)
beta0 <- 0
beta1 <- 2
xbeta <- beta0+beta1*xsq
prob <- exp(xbeta)/(1+exp(xbeta))
y <- rbinom(n, 1,prob=prob)

###########################################################
#Model fitting
###########################################################
fit.r <- glm(y~xsq, family = "binomial")
fit.w <- glm(y~x, family ="binomial")


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

### NMPP

mpvalue.r <- pbinom (y-1, 1, prob = mu.hat.r) + dbinom (y, 1, prob  = mu.hat.r) * 0.5
mpvalue.w <- pbinom (y-1, 1, prob = mu.hat.w) + dbinom (y, 1, prob  = mu.hat.w) * 0.5
res.mquantile.r<- qnorm (mpvalue.r)
res.mquantile.w<- qnorm (mpvalue.w)

### NRPP

pvalue.r <- pbinom (y-1, 1, prob = mu.hat.r) + dbinom (y, 1, prob  = mu.hat.r) * runif(n)
pvalue.w <- pbinom (y-1, 1, prob = mu.hat.w) + dbinom (y, 1, prob  = mu.hat.w) * runif(n)
res.quantile.r<- qnorm (pvalue.r)
res.quantile.w<- qnorm (pvalue.w)

############################################################# 
### residual analysis with RQR (NRPP)
#############################################################
par (mfrow=c(2,4))


plot(x,res.quantile.r, main="NRPPs, True Model", col = y+1)
plot(x,res.quantile.w, main="NRPPs, Wrong Model", col = y+1)
plot(x,res.mquantile.r, main="NMPPs, True Model", col = y+1)
plot(x,res.mquantile.w, main="NMPPs, Wrong Model", col = y+1)


qqnorm(res.quantile.r, main="QQplot, NRPP, True Model");abline(a=0,b=1)
qqnorm(res.quantile.w, main="QQplot, NRPP, Wrong Model");abline(a=0,b=1)
qqnorm(res.mquantile.r, main="QQplot, NMPP, True Model");abline(a=0,b=1)
qqnorm(res.mquantile.w, main="QQplot, NMPP, Wrong Model");abline(a=0,b=1)


shapiro.test(res.quantile.r)
shapiro.test(res.quantile.w)
shapiro.test(res.mquantile.r)
shapiro.test(res.mquantile.w)

equavarance.test(n, res.quantile.r, x, m=20)
equavarance.test(n, res.quantile.w, x, m=20)


##############################################
## Replicate RQR for R times (power analysis)
##############################################
 
R<-500
pv.sw.r<-rep(NA, R)
pv.sw.w<-rep(NA, R)

pv.bartlett.r<-rep(NA, R)
pv.bartlett.w<-rep(NA, R)


for(r in 1:R){

  n<-1000 #sample size
  x <- runif(n,0,pi)
  xsq<- sin(5*x)
  beta0 <- 0
  beta1 <- 2
  xbeta <- beta0+beta1*xsq
  prob <- exp(xbeta)/(1+exp(xbeta))
  y <- rbinom(n, 1,prob=prob)
  
  ###########################################################
  #Model fitting
  ###########################################################
  fit.r <- glm(y~xsq, family = "binomial")
  fit.w <- glm(y~x, family ="binomial")
  
 
  mu.hat.r <- fitted.values(fit.r)
  mu.hat.w <- fitted.values(fit.w)
 
  
  pvalue.r <- pbinom (y-1, 1, prob = mu.hat.r) + dbinom (y, 1, prob  = mu.hat.r) * runif(n)
  pvalue.w <- pbinom (y-1, 1, prob = mu.hat.w) + dbinom (y, 1, prob  = mu.hat.w) * runif(n)
  res.quantile.r<- qnorm (pvalue.r)
  res.quantile.w<- qnorm (pvalue.w)
  
  pv.sw.r[r]<-shapiro.test(res.quantile.r)$p.value
  pv.sw.w[r]<-shapiro.test(res.quantile.w)$p.value
  pv.bartlett.r[r]<-equavarance.test(n, res.quantile.r, x, m=20)
  pv.bartlett.w[r]<-equavarance.test(n, res.quantile.w, x, m=20)
  

}

par(mfcol = c(2,2))

hist(pv.sw.r, main = "SW pvalues,NRPP,True Model")
hist(pv.sw.w, main = "SW pvalues,NRPP,Wrong Model")
hist(pv.bartlett.r,main = "Bartlett pvalues,NRPP,True Model")
hist(pv.bartlett.w,main = "Bartlett pvalues,NRPP,Wrong Model", nclass=20,xlim=c(0,1))

mean (pv.bartlett.w<=0.05)
mean (pv.bartlett.r<=0.05)
mean (pv.sw.w<=0.05)
mean (pv.sw.r<=0.05)




