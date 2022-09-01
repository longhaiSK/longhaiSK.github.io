## the following R code was written by Kevin Hattie

## load data
agstrat <- read.csv("data/agstrat.csv")

## read functions
source ("estimates.r")

##### 3.9 a)


hist(agstrat$acres87)

# survey data summary in each stratum
nh <- table (agstrat[,"region"])
ybarh <- tapply (agstrat[, "acres87"], agstrat[,"region"], mean)
sh <- tapply (agstrat[, "acres87"], agstrat[,"region"], sd)

# find population size in each stratum 
# Note that, this is given external to the data set, from pg 75 of textbook
Nh <- c(1054, 220, 1382, 422)

## strata mean estimate
strata_mean_estimate (ybarh, sh, nh, Nh)

##### 3.9 b)

hist(agstrat$farms92)

# survey data summary in each stratum
nh <- table (agstrat[,"region"])
ybarh <- tapply (agstrat[, "farms92"], agstrat[,"region"], mean)
sh <- tapply (agstrat[, "farms92"], agstrat[,"region"], sd)

# find population size in each stratum 
# Note that, this is given external to the data set, from pg 75 of textbook
Nh <- c(1054, 220, 1382, 422)

## strata mean estimate
strata_mean_estimate (ybarh, sh, nh, Nh)

##### 3.9 c)

hist(agstrat$largef92)

# survey data summary in each stratum
nh <- table (agstrat[,"region"])
ybarh <- tapply (agstrat[, "largef92"], agstrat[,"region"], mean)
sh <- tapply (agstrat[, "largef92"], agstrat[,"region"], sd)

# find population size in each stratum 
# Note that, this is given external to the data set, from pg 75 of textbook
Nh <- c(1054, 220, 1382, 422)

## strata mean estimate
strata_mean_estimate (ybarh, sh, nh, Nh)

##### 3.9 d)

hist(agstrat$smallf92)

# survey data summary in each stratum
nh <- table (agstrat[,"region"])
ybarh <- tapply (agstrat[, "smallf92"], agstrat[,"region"], mean)
sh <- tapply (agstrat[, "smallf92"], agstrat[,"region"], sd)

# find population size in each stratum 
# Note that, this is given external to the data set, from pg 75 of textbook
Nh <- c(1054, 220, 1382, 422)

## strata mean estimate
strata_mean_estimate (ybarh, sh, nh, Nh)
