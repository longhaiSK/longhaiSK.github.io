# create data frame (it can be read from files too)
issu <- data.frame (
		  driving = c(5, 2, 12, 9, 15, 6, 25, 16),
		  premium = c(64, 87, 50, 71, 44, 56, 42, 60)
		)
		
#fit linear model
lmfit_issu <- lm (premium ~ driving, data = issu)
#inference for coefficients
summary (lmfit_issu)

#plot to look at the fit
plot (premium ~ driving, data = issu)
abline (lmfit_issu)


#prediction of the mean of y at x = 3
predict (lmfit_issu, newdata = data.frame (driving = 3), interval = "confidence")
#prediction of y at x = 3
predict (lmfit_issu, newdata = data.frame (driving = 3), interval = "prediction")
