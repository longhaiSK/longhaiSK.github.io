######## this file demonstrates how to analyze stratified sampling data ########

## load data
library("readr")
agstrat <- read_csv("data/agstrat.csv")

####################### find point estimate and SE #############################
## read functions
source ("estimates.r")

# survey data summary in each stratum
nh <- table (agstrat[,"region"])
sh <- tapply (agstrat[, "acres92"], agstrat[,"region"], sd)
ybarh <- tapply (agstrat[, "acres92"], agstrat[,"region"], mean)

# find population size in each stratum 
# Note that, this is given external to the data set, from pg 75 of textbook
Nh <- c(1054, 220, 1382, 422) 
# one can find stratum population size from the weights column of dataset too:


## strata mean estimate
strata_mean_estimate (ybarh, sh, nh, Nh)

## strata total estimate 
strata_mean_estimate (ybarh, sh, nh, Nh) * sum (Nh)

## if we simply apply SRS estimate ignoring that the data came from stratified sampling:
# inference for mean of variable acres92
srs_mean_est (agstrat[,"acres92"], N = 3078)

# inference for mean of variable acres92
srs_mean_est (agstrat[,"acres92"], N = 3078) * 3078

################### find point estimate only with sampling weight ##############
## find population total
sum(agstrat$acres92 * agstrat$weight)

# let's compare to the true value
agpop <- read.csv ("agpop.csv")
#true mean
mean (agpop[, "acres92"])
# true total
sum (agpop[, "acres92"])

####################### using a wrapper function ###############################
strata_mean_estimate_data (agstrat, "acres92", "region", "weight")
