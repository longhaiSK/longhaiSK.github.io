# Fit of the multiple linear regression
##########################################
# Wire bond strength data
# Read data. Change the path as necessary.
bond.data<-read.csv("V:/Teaching/STAT845/2023-2024-T1/lecturers/CH03/wire-bond.csv")

# Scatter plots
par(mfrow=c(1,2))
plot(bond.data$length,bond.data$strength,
  xlab="Wire Length",ylab="Pull strength")
plot(bond.data$height,bond.data$strength,
  xlab="Die height",ylab="Pull strength")

# Fit
fit<-lm(strength~length+height,data=bond.data)
summary(fit)

# Note the ANOVA F test for overall significant,
# R^2, adjusted R^2, and t test.

# Confidence intervals for the indivudal 
# regression coefficients.
confint(fit)

# Fitted values and ordinary residuals
pred<-fitted.values(fit)
e<-resid(fit)
cbind(y=bond.data$strength,y.hat=pred,e=e)

# Extract covariance matrix from the fit
cov.mat<-vcov(fit)
cov.mat

# Note: The diagonal elements of this matrix
# are the variances of the estimators of the
# regression coefficients. If you take square
# root, you will get the standard errors.

sqrt(diag(cov.mat))

# Same as given in the summary fit.

########################
########################
# Partial F test and t test
########################
########################

# Data: Weight, height and age of children
# See lecture notes for the problems 1-4.
wgt<-c(64,71,53,67,55,58,77,57,56,51,76,68)
hgt<-c(57,59,49,62,51,50,55,48,42,42,61,57)
age<-c(8,10,6,11,8,7,10,9,10,6,12,9)

# Problem 1
fit11<-lm(wgt~hgt)
summary(fit11)

# Problem 2
fit21<-lm(wgt~hgt+age)
summary(fit21)
#anova(fit21)

fit22<-lm(wgt~hgt)
#anova(fit22)
anova(fit22,fit21)

# Problem 3
fit31<-lm(wgt~hgt+age+I(age^2))
summary(fit31)
fit32<-lm(wgt~hgt+age)
anova(fit32,fit31)

# Problem 4
fit41<-lm(wgt~hgt+age+I(age^2))
fit42<-lm(wgt~hgt)
anova(fit42,fit41)

########################
########################
# Mean response and prediction
########################
########################

# Wire bond strength

# Construct a 95% CI on the mean pull strength 
# for a wire bond with 
# wire length = 8 and die height =275.

fit<-lm(strength~length+height,data=bond.data)
predict(fit,newdata=data.frame(length=8,height=275),
    interval="confidence",level=0.95)

# Construct a 95% PI on the mean pull strength 
# for a wire bond with 
# wire length = 8 and die height =275.

predict(fit,newdata=data.frame(length=8,height=275),
    interval="prediction",level=0.95)


########################
########################
# Model diagnostics
########################
########################

# Wire bond strength

# Hat values h_ii
hatvalues(fit) 

# Ordinary residuals
resid(fit) 

# Standardized residuals
resid(fit)/sigma(fit)

# Studentized residuals (internal)
rstandard(fit) 

# Studentized residuals (external)
rstudent(fit) 

# Residual analysis using studentized residuals (internal)
n<-nrow(bond.data)
r<-rstandard(fit) # Internally studentized residuals
y.hat<-fitted.values(fit)
par(mfrow=c(2,3))
qqnorm(r)
qqline(r)
plot(y.hat,r,xlab="Fitted values",ylab="Studentized Residuals")
abline(h=0)
plot(1:n,r,xlab="Observation Number",ylab="Studentized Residuals")
abline(h=0)
plot(bond.data$length,r,xlab="Wire Length",ylab="Studentized Residuals")
abline(h=0)
plot(bond.data$height,r,xlab="Die Height",ylab="Studentized Residuals")
abline(h=0)


########################
########################
# Influential observations
########################
########################

# Find DFFITS, DFBETAS and Cook's D for the wire bond data.
cbind(dffits=dffits(fit),cook.D=cooks.distance(fit),dfbetas(fit))

# We will use the contributed package "olsrr" for plots.

# What is a contributed package?
# Packages are collections of R functions, data, and compiled code 
# in a well-defined format. The directory where packages are stored 
# is called the library. R comes with a standard set of packages. 
# Others are available for download and installation. 
# Once installed, they have to be loaded into the session to be used.

# To install, use the function install.packages().
# To load the package, use the function library().

#install.packages("olsrr")
library(olsrr)

# Note: You do not need to install everytime you use a contributed package.
# Install only once. However, you will have to load the package
# using the library() function if you want to use it.

# Plot for Cook's D
ols_plot_cooksd_chart(fit) 

# Plot for DFFITS
ols_plot_dffits(fit) 

# Plot for DFBETAS
ols_plot_dfbetas(fit) 


########################
########################
# Polynomial regression
########################
########################

# Data: Cost and production lot size of 
# sidewall panels for the interior of an airplane

y<-c(1.81,1.70,1.65,1.55,1.48,1.40,1.30,1.26,1.24,1.21,1.20,1.18)
x<-c(20,25,30,35,40,50,60,65,70,75,80,90)
fit<-lm(y~x+I(x^2))
summary(fit)

# Note the ANOVA F test for overall significance.

plot(x,y,xlab="Lot size, x",ylab="Average cost per unit, y")
lines(x,predict(fit,newdata=data.frame(x=x)),type="l")

# Does the addition of x^2 significantly contribute to the 
# prediction of y after we account for the contribution of x?
# Partial F test

fit1<-lm(y~x)
anova(fit1,fit)


########################
########################
# Indicator variables
########################
########################

# SBP Data
sbpdata<-read.csv("V:/Teaching/STAT845/2023-2024-T1/lecturers/CH03/sbpdata.csv")

# Fit the full model
fit.full<-lm(sbp~age+sex+age:sex,data=sbpdata)
summary(fit.full)

# Test of Coincidence. H0: beta2=beta3=0
fit.coin<-lm(sbp~age,data=sbpdata)
anova(fit.coin,fit.full)

# Test of Parallelism. H0: beta3=0
fit.para<-lm(sbp~age+sex,data=sbpdata)
anova(fit.para,fit.full)

# Test for Equal Intercepts.
fit1.inter<-lm(sbp~age+sex,data=sbpdata)
fit2.inter<-lm(sbp~age,data=sbpdata)
anova(fit2.inter,fit1.inter)

# Plot of fitted models

# Define color for males and females.
colors<-ifelse(sbpdata$sex==1,"black","gray")
# Scatter plot
plot(sbpdata$age,sbpdata$sbp,xlab="Age",ylab="SBP",col=colors)
# The design matrix is cbind(1,sbpdata$age,1,sbpdata$age) for sex = 1,
# and cbind(1,sbpdata$age,0,0) for sex = 0.
# Add the fitted lines for males and females
lines(sbpdata$age,cbind(1,sbpdata$age,1,sbpdata$age)%*%coef(fit.full),col="black")
lines(sbpdata$age,cbind(1,sbpdata$age,0,0)%*%coef(fit.full),col="gray")
# Add legend
legend("topleft",legend=c("sex = 1","sex = 0"),lty=c(1,1),col=c("black","gray"))


########################
########################
# Model building
########################
########################
# We will use the contributed package olsrr
# Data: Wine quality 

library(olsrr)
wine<-read.csv("V:/Teaching/STAT845/2023-2024-T1/lecturers/CH03/wine.csv")

# Fit the model.
# A dot in the lm function means:
# use all other variables (except the dependent variable) 
# as independent variables in the model.
# Alternative, you could specify these manually.

model<-lm(quality ~ .,data=wine)

# All possible regression
ols_step_best_subset(model)


# Backward Elimination and Forward Selection
# Note:
# p_val: alpha_out for Backward and alpha_in for Forward(see lecture)
# progress: if TRUE, will display variable selection progress; default is FALSE.

# Backward Elimination
ols_step_backward_p(model,p_val=0.1)

# Forward selection
ols_step_forward_p(model,p_val=0.1)

# Stepwise
# p_enter: alpha_in
# p_remove: alpha_out

ols_step_both_p(model,p_enter=0.1,p_remove=0.1)


########################
########################
# Multicollinearity
########################
########################
y<-c(19,20,37,39,36,38)
x1<-c(4,4,7,7,7.1,7.1)
x2<-c(16,16,49,49,50.4,50.4)
cor(x1,x2)
fit<-lm(y~x1+x2)
summary(fit)

fit1<-lm(y~x1)
summary(fit1)

# Wine quality data

wine.x<-wine[,-6]
cor(wine.x)

model<-lm(quality ~ .,data=wine)

# Find VIF's. We need the olsrr package.
# Make sure that you have loaded the package earlier.

ols_vif_tol(model)




