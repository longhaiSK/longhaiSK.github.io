

################################################################################
#    Case study: number of hospital visits  
#
#Demand for medical care by the elderly Deb and Trivedi (1997)  
#analyze data on 4406 individuals, aged 66 and over, who are 
#covered by Medicare, a public insurance program. Originally 
#obtained from the US National Medical Expenditure Survey (NMES) 
#for 1987/88, the data are available from the data archive of 
#the Journal of Applied Econometrics at 
#http://www.econ.queensu.ca/jae/1997-v12.3/deb-trivedi/.
#
#The objective is to model the demand for medical care-as captured 
#by the number hospital stays-by the covariates available for the patients.  
# 
#Outcome: hosp (number of hospital stays)
#Covariates: 
#age:      age in years (divided by 10)
#gender:   =1 if the person is male
#numchron: number of chronic conditions (cancer, heart attack, 
#          gall bladder problems, emphysema, arthritis, diabetes, 
#          other health disease)
#health:   self-perceived health status (excellent, average and poor), 
#adldiff:  =1 if the person has a condition that limits activity of daily living     
################################################################################


library("pscl")
library("MASS")

###############################################################################
# CDF and PMF used in RPP
###############################################################################

#PDF of ZIP distribemervisitson; 
dzpois <- function(x,xbeta,p)
{
  return((1-p)*dpois(x,xbeta)+p*(x==0))
}


#CDF of ZIP distribemervisitson;
pzpois <- function(x,xbeta,p)
{
  return((1-p)*ppois(x,xbeta)+p*(x>=0))
}


#PDF of ZINB distribemervisitson; 
dznbinom <- function(x,size,mu,p) #size: dispersion parameter
{
  return((1-p)*dnbinom(x,size = size, mu = mu)+p*(x==0))
}


#CDF of ZINB distribemervisitson; 
pznbinom <- function(x,size,mu,p)
{
  return(
    (1-p)*pnbinom(x,size = size, mu = mu)+p*(x>=0)
  )
}

###############################################################################
# plotting function
###############################################################################

plotf <- function(a,b,c,y,z)
{
  plot(a, b, ylab = y, xlab = "x", main = z)
  lines(lowess(a, b),col="blue",lwd=3)
  plot(c,b, ylab = y, xlab = "Fitted Values", main = z)
  lines(lowess(c,b),col="blue",lwd=3)
}

qqplotf <- function(res,x)
{
  qqnorm (res,main = paste(x),cex.main=2, cex.lab=1.5)
  abline(a=0,b=1, lty=2)
}


###############################################################################
## data analysis
###############################################################################

### load and process data
load("DebTrivedi.rda")

dt <- DebTrivedi
attach(dt)

health_poor<-as.numeric(health=="poor")
health_average<-as.numeric(health=="average")
health_excellent<-as.numeric(health=="excellent")
gendermale<-as.numeric(gender=="male")
adldiffyes<-as.numeric(adldiff=="yes")

y<-emer
par (mfrow = c(1,1))
hist(y, xlab="Number of emergency room visits", main="", col="blue", breaks=30)

### fit Poission, NB, ZIP, ZINB models
fit.pois <-glm(y~ black+numchron+ health_excellent+health_average+adldiffyes+school, 
               data = dt, family = poisson)
summary(fit.pois) 
fit.nb <- glm.nb(y~ numchron+health_excellent+health_average+adldiffyes+school, data = dt)
summary(fit.nb)
fit.zip <- zeroinfl(y~ black+numchron+ health_excellent+health_average+adldiffyes+school|1, data = dt, dist="poisson")
summary(fit.zip)
fit.zinb <- zeroinfl(y~ numchron+ health_excellent+health_average+adldiffyes+school|1, data = dt, dist="negbin")
summary(fit.zinb)

### compute AICs 
AIC(fit.pois)
AIC(fit.nb)
AIC(fit.zip)
AIC(fit.zinb)

vuong(fit.pois, fit.nb)
vuong(fit.pois, fit.zip)
vuong(fit.nb, fit.zinb)
vuong(fit.nb, fit.zip)

### Parameter estimates and fitted values
mu.hat.pois<-fitted.values(fit.pois)
mu.hat.nb <- fitted.values(fit.nb)
mu.hat.zip<-fitted.values(fit.zip)
mu.hat.zinb<-fitted.values(fit.zinb)

p.zip <- coef(fit.zip)[8] 
p.zinb <- coef(fit.zinb)[7] 

p.hat.zip<-exp(p.zip)/(1+exp(p.zip))
p.hat.zinb<-exp(p.zinb)/(1+exp(p.zinb))

size.hat.nb<- fit.nb$theta
size.hat.zinb <- fit.zinb$theta

## define colorized representation of values in y
uy <- sort (unique(y))
col <-  rainbow(length (uy), s=1, start=0, end = 0.7)#[rm.col]
col.y <- col[match(y, uy)]


#####################################################
#
#
#   Pearson residuals
#  
#
####################################################
res.pearson.pois <- resid(fit.pois,"pearson")
res.pearson.nb <- resid(fit.nb,"pearson")
res.pearson.zip <- resid(fit.zip,"pearson")
res.pearson.zinb <- resid(fit.zinb,"pearson")


#Residuals vs. fitted values
par (mfrow = c(2,2))
plot(mu.hat.pois,res.pearson.pois,xlab="Fitted values", ylab="Pearson Residuals",main="Poisson", cex.main=2, cex.lab=1.5, log="x", col=col.y)
plot(mu.hat.nb,res.pearson.nb,xlab="Fitted values",ylab="Pearson Residuals",main="NB", cex.main=2, cex.lab=1.5, log="x", col=col.y)
plot(mu.hat.zip,res.pearson.zip,xlab="Fitted values",ylab="Pearson Residuals",main="ZIP", cex.main=2, cex.lab=1.5, log="x", col=col.y)
plot(mu.hat.zinb,res.pearson.zinb,xlab="Fitted values",ylab="Pearson Residuals",main="ZINB", cex.main=2, cex.lab=1.5, log="x", col=col.y)

#QQ plot
par (mfrow = c(2,2))
qqplotf(res.pearson.pois,"Poisson")
qqplotf(res.pearson.nb,"NB")
qqplotf(res.pearson.zip,"ZIP")
qqplotf(res.pearson.zinb,"ZINB")

#Shaprio-wilk normality test p.value 
pv_pearson.pois<-shapiro.test(res.pearson.pois)$p.value;pv_pearson.pois
pv_pearson.nb<-shapiro.test(res.pearson.nb)$p.value; pv_pearson.nb
pv_pearson.zip<-shapiro.test(res.pearson.zip)$p.value; pv_pearson.zip
pv_pearson.zinb<-shapiro.test(res.pearson.zinb)$p.value; pv_pearson.zinb

###################################################
#
#
#   Deviance residuals
#  
#
####################################################

res.deviance.pois <- resid(fit.pois,"deviance")
res.deviance.nb <- resid(fit.nb,"deviance")
res.deviance.zip <- sign(y-mu.hat.zip*(1-p.hat.zip))*sqrt(2)*sqrt(log(dpois(y,y))-log(dzpois(y,mu.hat.zip,p.hat.zip)))
res.deviance.zinb <- sign(y-mu.hat.zinb*(1-p.hat.zinb))*sqrt(2)*sqrt(log(dnbinom (y,size = size.hat.zinb, mu = y))-log(dznbinom(y,size.hat.zinb, mu.hat.zinb,p.hat.zinb)))

#Residuals vs. fitted values
par (mfrow = c(2,2))

plot(mu.hat.pois,res.deviance.pois,xlab="Fitted values", ylab="Deviance Residuals",main="Poisson", cex.main=2, cex.lab=1.5, log="x", col=col.y)
plot(mu.hat.nb,res.deviance.nb,xlab="Fitted values",ylab="Deviance Residuals",main="NB", cex.main=2, cex.lab=1.5, log="x", col=col.y)
plot(mu.hat.zip,res.deviance.zip,xlab="Fitted values",ylab="Deviance Residuals",main="ZIP", cex.main=2, cex.lab=1.5, log="x", col=col.y)
plot(mu.hat.zinb,res.deviance.zinb,xlab="Fitted values",ylab="Deviance Residuals",main="ZINB", cex.main=2, cex.lab=1.5, log="x", col=col.y)

#QQ plot
par (mfrow = c(2,2))

qqplotf(res.deviance.pois,"Poisson")
qqplotf(res.deviance.nb,"NB")
qqplotf(res.deviance.zip,"ZIP")
qqplotf(res.deviance.zinb,"ZINB")

#Shaprio-wilk normality test p.value 
pv_deviance.pois<-shapiro.test(res.deviance.pois)$p.value; pv_deviance.pois
pv_deviance.nb<-shapiro.test(res.deviance.nb)$p.value; pv_deviance.nb
pv_deviance.zip<-shapiro.test(res.deviance.zip)$p.value; pv_deviance.zip
pv_deviance.zinb<-shapiro.test(res.deviance.zinb)$p.value; pv_deviance.zinb

#####################################################
#
#
#   Randomized Quantile Residuals (NRPP)
#  
#
####################################################
set.seed(3)
#CDF
n<-length(y)
pvalue.pois <- ppois (y-1,mu.hat.pois) + dpois (y, mu.hat.pois)*runif(n)
pvalue.nb <- pnbinom (y-1,size = size.hat.nb, mu = mu.hat.nb) + 
             dnbinom (y,size = size.hat.nb, mu = mu.hat.nb) * runif(n)
pvalue.zip <- pzpois (y-1,mu.hat.zip,p.hat.zip) + 
              dzpois (y, mu.hat.zip, p.hat.zip) * runif(n)
pvalue.zinb <- pznbinom (y-1,size.hat.zinb, mu.hat.zinb, p.hat.zinb) + 
                dznbinom (y,size.hat.zinb,mu.hat.zinb,p.hat.zinb) * runif(n)
pvalue.nb_linear <- pnbinom (y-1,size = size.hat.nb, mu = mu.hat.nb) + dnbinom (y,size = size.hat.nb, mu = mu.hat.nb) * runif(n)

pvalue.pois[pvalue.pois==1]<-0.999999999   
pvalue.nb[pvalue.nb==1]<-0.999999999   
pvalue.zip[pvalue.zip==1]<-0.999999999 
pvalue.zinb[pvalue.zinb==1]<-0.999999999 
 

#randomized quantile residuals (inverse CDF)
res.new.pois <- qnorm (pvalue.pois)
res.new.nb <- qnorm (pvalue.nb)
res.new.zip <- qnorm (pvalue.zip)
res.new.zinb <- qnorm (pvalue.zinb)
res.new.nb_linear <- qnorm (pvalue.nb_linear)

#Residuals vs. fitted values
par (mfrow = c(2,2))


plot(mu.hat.pois,res.new.pois,xlab="Fitted values", ylab="NRPP",main="Poisson", cex.main=2, cex.lab=1.5,log="x",  ylim=c(-6, 6))
abline(h=c(-3, 3), lty=2, col="blue")

plot(mu.hat.nb,res.new.nb,xlab="Fitted values",ylab="NRPP",main="NB", cex.main=2, cex.lab=1.5,log="x",  ylim=c(-6, 6))
abline(h=c(-3, 3), lty=2, col="blue")

plot(mu.hat.zip,res.new.zip,xlab="Fitted values",ylab="NRPP",main="ZIP", cex.main=2, cex.lab=1.5,log="x", ylim=c(-6, 6))
abline(h=c(-3, 3), lty=2, col="blue")

plot(mu.hat.zinb,res.new.zinb,xlab="Fitted values",ylab="NRPP",main="ZINB", cex.main=2, cex.lab=1.5,log="x", ylim=c(-6, 6))
abline(h=c(-3, 3), lty=2, col="blue")

#QQ plot
par (mfrow = c(2,2))

qqplotf(res.new.pois,"Poisson")
qqplotf(res.new.nb,"NB")
qqplotf(res.new.zip,"ZIP")
qqplotf(res.new.zinb,"ZINB")

#Shaprio-wilk normality test p.value 
shapiro.test(res.new.pois)
shapiro.test(res.new.nb)
shapiro.test(res.new.zip)
shapiro.test(res.new.zinb)

################################################################################
### replicate RQR (NRPP) for R times to examine the impact of randomization on RQR
################################################################################
set.seed(1)
R <- 1000
pv.pois<-rep(NA, R)
pv.nb<-rep(NA, R)
pv.zip<-rep(NA, R)
pv.zinb<-rep(NA, R)

for (i in 1:R){ 
  #RPP
  pvalue.pois <- ppois (y-1,mu.hat.pois) + dpois (y, mu.hat.pois)*runif(n)
  pvalue.nb <- pnbinom (y-1,size = size.hat.nb, mu = mu.hat.nb) + dnbinom (y,size = size.hat.nb, mu = mu.hat.nb) * runif(n)
  pvalue.zip <- pzpois (y-1,mu.hat.zip,p.hat.zip) + dzpois (y, mu.hat.zip, p.hat.zip) * runif(n)
  pvalue.zinb <- pznbinom (y-1,size.hat.zinb,mu.hat.zinb,p.hat.zinb) + dznbinom (y,size.hat.zinb,mu.hat.zinb,p.hat.zinb) * runif(n)
  
  pvalue.pois[pvalue.pois==1]<-0.999999999   
  pvalue.nb[pvalue.nb==1]<- 0.999999999   
  pvalue.zip [pvalue.zip==1]<-0.999999999 
  pvalue.zinb [pvalue.zinb==1]<-0.999999999
  
  #randomized quantile residuals (NRPP)
  res.new.pois <- qnorm (pvalue.pois)
  res.new.nb <- qnorm (pvalue.nb)
  res.new.zip <- qnorm (pvalue.zip)
  res.new.zinb <- qnorm (pvalue.zinb)
  
  pv.pois[i]<-shapiro.test(res.new.pois)$p.value
  pv.nb[i]<-shapiro.test(res.new.nb)$p.value
  pv.zip[i]<-shapiro.test(res.new.zip)$p.value
  pv.zinb[i]<-shapiro.test(res.new.zinb)$p.value
  
}

par (mfrow = c(2,2))

hist(pv.pois, main="Poisson", xlab="SW p-value", xlim=c(0, 1))
hist(pv.nb, main="NB", xlab="SW p-value",  xlim=c(0, 1))
hist(pv.zip, main="ZIP", xlab="SW p-value",  xlim=c(0, 1))
hist(pv.zinb, main="ZINB", xlab="SW p-value", xlim=c(0, 1))

