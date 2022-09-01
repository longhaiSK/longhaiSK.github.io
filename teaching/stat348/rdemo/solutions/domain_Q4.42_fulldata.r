
source ("estimates.r")


## analysis with data in the whole US

trucks <- read.csv ("data/vius.csv", header = T, na = ".")
################# a) Find total miles per business type ###################
## summing the sampling weights gives N
## note that we should do this before removing NA
N <- sum(trucks [, 5]); N

## remove rows with NA in miles_annl or business type
sel <- !is.na(trucks[,27]) & !is.na (trucks[, 10]) 
trucks_sel <- trucks [sel, ]

## create a data frame to save the results
mean_miles_2002 <- data.frame (matrix (0, 14, 5))
names (mean_miles_2002) <- c("BType", "Est", "SE", "ci.low", "ci.upp" )

mean_miles_2002 [,1] <- 1:14
total_miles_2002 <- mean_miles_2002

for (i in 1:14)
{
  ## define a domain as business == i
  busi <- 1 * (trucks_sel[,27] == i) 
  mean_miles_2002[i, 2:5] <- 
	srs_ratio_est (trucks_sel[,10] * busi, busi, N = N) 
  total_miles_2002[i, 2:5] <- 
	srs_mean_est (trucks_sel[,10] * busi, N = N) * N 
		
}

mean_miles_2002

total_miles_2002

################# b) Find mean MPG per Tranmission type ###################

sel <- !is.na(trucks[, 19]) & !is.na (trucks[, 12])
trucks_sel <- trucks [sel, ]

## create a data frame to save the results
mean_MPG <- data.frame (matrix (0, 4, 5))
names (mean_MPG) <- c("TransType", "Est.", "S.E.", "ci.low", "ci.upp" )
mean_MPG[,1] <- 1:4

for (i in 1:4)
{
  trans <- 1 * (trucks_sel[, 19] == i) 
  mean_MPG [i, 2:5] <- 
	srs_ratio_est (trucks_sel[,12] * trans, trans, N = N) 		
}

mean_MPG


############ c) Find mean miles in 2002/life time miles ###################
sel <- !is.na(trucks[, 10]) & !is.na (trucks[, 11])
trucks_sel <- trucks [sel, ]

## Find ratio of miles driven in 2002 to miles driven in life time
srs_ratio_est (trucks_sel [,10], trucks_sel [,11], N = N)

######################## final note ######################## ##################
## The answers given by the above R code are different from what's provided by 
## the SAS code. The difference may be in the procedure of handling missing data. 
## The solution didn't say clearly how they handle missing data. 
