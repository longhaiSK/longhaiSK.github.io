## read functions for analyzing data
source ("estimates.r")


######## this file demonstrates how to analyze stratified sampling data ########

## load data
seals <- read.csv("data/seals.csv")

################## find point estimate and SE step-by-step #####################
# survey data summary in each stratum
nh <- table (seals[,"zone"])
sh <- tapply (seals[, "holes"], seals[,"zone"], sd)
ybarh <- tapply (seals[, "holes"], seals[,"zone"], mean)

# find population size in each stratum 
# create a vector with external information
# Nh <- c(NC = 1054, NE = 220, S= 1382, W = 422)
# Or, find stratum size from 'weight' column of stratified sample dataset
Nh <- c(68,84,48)


N <- sum (Nh)
Wh <- Nh/N
ybar <- sum(ybarh * Wh)
seybar <- sqrt(sum((1-nh/Nh)*Wh^2*sh^2/nh))
mem <- 1.96 * seybar
c(Est. = ybar, S.E. = seybar, ci.low = ybar - mem, ci.upp = ybar + mem)

# b)
## assuming the cost of surving each zone is the same
Ch <- rep (1, 3)
Sh <- sh ## estimate Sh with sh
NhShDCh <- Nh * Sh / sqrt (Ch)

## the optimal allocation scheme for estimating the total holes:
Lh <- NhShDCh / sum (NhShDCh);Lh

## if the goal in the density of holes (mean of holes per plot) we would like 
## SE of each mean estimate is the same for all stratum.
## therefore, we want to n_i proportional to Sh^2

Lh2 <- Sh^2/sum (Sh^2); Lh2
