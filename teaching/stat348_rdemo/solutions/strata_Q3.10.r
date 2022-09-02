## the following R code was written by Kevin Hattie

## read functions
source ("estimates.r")

##### 3.10 a)
# survey data summary in each stratum
nh <- c(4, 6, 3, 5)
ybarh <- c(.44, 1.17, 3.92, 1.80)
sh <- sqrt(c(.068, .042, 2.146, .794))

# find population size in each stratum 
Area <- c(222.81, 49.61, 50.25, 197.81)
Nh <- 25.6*Area
Nh <- c(5704, 1270,1286.4, 5064)

## strata total estimate 
strata_mean_estimate (ybarh, sh, nh, Nh) * sum (Nh)

#### 3.10 b)
# survey data summary in each stratum
nh <- c(8, 5)
ybarh <- c(.63, .40)
sh <- sqrt(c(.083, .046))

# find population size in each stratum 
Area <- c(322.67, 197.81)
Nh <- 25.6*Area

## strata total estimate 
strata_mean_estimate (ybarh, sh, nh, Nh) * sum (Nh)

