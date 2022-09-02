############### look at the effect of poststratification in a biased data #######
source ("estimates.r")

library(sampling)
agpop <- read.csv ("data/agpop.csv", as.is=T)

strata_size <- c(NC = 100, W = 100, NE = 20, S = 20)[unique(agpop$region)]

id_strata <- strata (agpop, stratanames = "region", strata_size )[,2]
agstrat <- agpop[id_strata,]

## without postratification
srs_mean_est (agstrat$acres92, N=nrow (agpop))

## with post-stratification
yh <- tapply (agstrat$acres92, INDEX = agstrat$region, FUN = mean)
sh <- tapply (agstrat$acres92, INDEX = agstrat$region, FUN = sd)
agpop <- read.csv ("data/agpop.csv", as.is=T)
Nh <- table (agpop$region)  
n <- nrow (agstrat)
nh <- Nh/sum (Nh) * n
## post-stratification estimate of mean
strata_mean_estimate (yh, sh, nh, Nh)

## the correct stratification analysis
nh <- table (agstrat$region)
strata_mean_estimate (yh, sh, nh, Nh)

