## read functions for analyzing data
source ("estimates.r")


######## this file demonstrates how to analyze stratified sampling data ########

## load data

agstrat <- read.csv("data/agstrat.csv")

################## find point estimate and SE step-by-step #####################

# survey data summary in each stratum
nh <- tapply (rep (1, nrow (agstrat)), agstrat[,"region"], sum)
sh <- tapply (agstrat[, "acres92"], agstrat[,"region"], sd)
ybarh <- tapply (agstrat[, "acres92"], agstrat[,"region"], mean)

# find population size in each stratum 
# create a vector with external information
# Nh <- c(NC = 1054, NE = 220, S= 1382, W = 422)
# Or, find stratum size from 'weight' column of stratified sample dataset
Nh <- tapply (agstrat$weight, agstrat$region, sum)


N <- sum (Nh)
Wh <- Nh/N
ybar <- sum(ybarh * Wh)
seybar <- sqrt(sum((1-nh/Nh)*Wh^2*sh^2/nh))
mem <- 1.96 * seybar
c(Est. = ybar, S.E. = seybar, ci.low = ybar - mem, ci.upp = ybar + mem)

#################### find point estimate with a function ######################

## strata mean estimate
strata_mean_estimate (ybarh, sh, nh, Nh)

## strata total estimate 
strata_mean_estimate (ybarh, sh, nh, Nh) * sum (Nh)



################### find point estimate only with sampling weight ##############
## find population total
sum(agstrat$acres92 * agstrat$weight)

# let's compare to the true value
agpop <- read.csv ("agpop.csv")
#true mean
mean (agpop[, "acres92"])
# true total
sum (agpop[, "acres92"])

####################### using a higher-level function ##########################
strata_mean_estimate_data (agstrat, "acres92", "region", "weight")


