################################################
# Example: CHD data
################################################
# chd = 1 if a person has the disease, 0 if not 
# smk = 1 if yes, 0 if no
# cat = 1 if catecholamine level is high, 0 if catecholamine level is low
# sbp = a measure of systolic blood pressure
# age
# chl = a measure of cholesterol level
# ecg = 1 if electrocardiogram status is abnormal, 
#       0 if electrocardiogram status is normal
# hpt = 1 if high blood pressure, 0 if normal blood pressure
#------------------------------------
# The data is in .dat format. Use the read.table() function
# to read the data.
CHD.data<-read.table("V:/evans.dat",header=TRUE)
CHD.data
# Use glm() to fit the model.
fit1<-glm(chd~smk+cat+sbp+age+chl+ecg+hpt,data=CHD.data,
   family=binomial(link="logit"))
summary(fit1)
# smk, age and chl are significant at 5% level, and 
# cat and hpt are significant at 10% level.

# For CI, use the function confint()
ci<-confint(fit1,level=0.95)
ci

# How to extract the covariance matrix?
cov.mat<-vcov(fit1)
cov.mat
# Find SEs
sqrt(diag(cov.mat))
# These are the same as given in summary

# Find the adjusted OR for smk
OR.smk<-exp(coef(fit1)[2])
OR.smk
# CI for OR.smk:
exp(ci[2,])

# Find the adjusted OR for sbp comparing values 160 vs 120
A.sbp<-40*coef(fit1)[4]
OR.sbp<-exp(A.sbp)
OR.sbp
# Find 95% CI
var.A.sbp<-40^2*cov.mat[4,4]
ci.sbpA<-c(A.sbp-qnorm(0.975)*sqrt(var.A.sbp),A.sbp+qnorm(0.975)*sqrt(var.A.sbp))
exp(ci.sbpA)

# Find the adjusted OR to compare 
# group 1: (smk = 1, cat, sbp, age = 50, chl, ecg, hpt)
# group 1: (smk = 0, cat, sbp, age = 30, chl, ecg, hpt)
# A = beta1 + 30*beta5

a<-50-30
A.smk<-coef(fit1)[2]+a*coef(fit1)[5]
OR.smk<-exp(A.smk)
OR.smk

var.A.smk<-cov.mat[2,2]+a^2*cov.mat[5,5]+2*a*cov.mat[2,5]
ci.smkA<-c(A.smk-qnorm(0.975)*sqrt(var.A.smk),A.smk+qnorm(0.975)*sqrt(var.A.smk))
exp(ci.smkA)

# What happens if the age difference is 10? 5?

# Carry out an analysis for the data on launch temperature 
# and O-ring failure for the 24 Space Shuttle launches prior 
# to the Challenger disaster of January 1986.
# First you will have enter data, for example, as follows:
# y<-c(...)
# x<-c(...)
# dat<-data.frame(y=y, x=x)
# Use the glm() funtion, find the OR, test for significance, concludion.




