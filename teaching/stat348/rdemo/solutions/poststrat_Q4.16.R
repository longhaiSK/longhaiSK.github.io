source ("estimates.r")

agsrs <- read.csv("data/agsrs.csv", as.is = T)

################# poststratification estimation #########################
yh <- tapply (agsrs$acres92, INDEX = agsrs$region, FUN = mean)
sh <- tapply (agsrs$acres92, INDEX = agsrs$region, FUN = sd)
agpop <- read.csv ("data/agpop.csv", as.is=T)
Nh <- table (agpop$region)  

## for poststratification, we use nh proportional to Nh, NOT the actual nh
n <- nrow (agsrs)
nh <- Nh/sum (Nh) * n

## post-stratification estimation of mean
strata_mean_estimate (yh, sh, nh, Nh)

## without postratification
srs_mean_est (agsrs$acres92, N=sum(Nh))

## true mean 
mean (agpop$acres92)

## comparison result: for this data set, we've found that poststratification
## provides a closer answer to the true value although it is not much because there is not a serious selection bias in the SRS data

## look at "post-strata-agpop.R" in rdemo/ for a comparison with a biased dataset

