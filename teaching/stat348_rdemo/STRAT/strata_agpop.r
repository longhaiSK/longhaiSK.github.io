########## this file demonstrates the efficiency of stratified sampling ########

library ("sampling")
library (readr)
source ("estimates.r")

method.strata <- 1

#############################  look at population data #########################
agpop <- read.csv ("data/agpop.csv")
agpop <- agpop[agpop$acres92 != -99, ] ## remove those counties with na
plot (agpop$acres92 ~ agpop$acres82)
if (method.strata == 1)
{
    agpop$stratum <- agpop$region
} else {
    agpop$stratum <- cut(agpop$acres82,
                     breaks = quantile (agpop$acres82, c(0, 0.5,0.8,0.95,1)),
                     include.lowest =  T)
    agpop$stratum <-mapvalues(agpop$stratum, 
              from = (sort(unique (agpop$stratum))), to= c("Q1", "Q2", "Q3", "Q4"))
}

agpop <- agpop[order (agpop$stratum), ]

## have preliminary idea how much stratification can help
summary (aov (agpop$acres92~agpop$stratum))

# look at the population data by stratums
pdf ("STRAT/agpop_stratum.pdf")
boxplot (acres92 ~ stratum, data = agpop)
dev.off()

########################## do stratified sampling once #########################
### one time of stratified sampling and analysis
N <- nrow (agpop)
# doing one stratified sampling
Nh <- tapply (rep(1, N), agpop$stratum, sum) 
# find order of stratum
# unique (agpop$stratum)
nh <- round(Nh/sum (Nh)*300) ## make sure the order matches Nh

## doing stratified sampling
strsample <- strata (agpop, "stratum", size = nh,  method = "srswor")
write.csv (strsample, file= "STRAT/strsample.csv") # for pratical use
## checking sampling results
View(strsample)
table (strsample [,1]) 

# collecting data on sampled counties
agstrat <- agpop [strsample$ID_unit, ]
agstrat$weight <- 1/strsample$Prob
View (agstrat)
strata_mean_estimate_data (agstrat, "acres92", "stratum", "weight")

################################################################################
########### repeat stratified sampling with P2S allocation 2000 times ##########
################################################################################
# doing one stratified sampling
Nh <- tapply (rep(1, nrow (agpop)), agpop$stratum, sum) 
# find order of stratum
# unique (agpop$stratum)
nh <- round(Nh/sum (Nh)*300) ## make sure the order matches Nh

nres <- 2000
res_str <- matrix (0, nres, 4)
for (i in 1:nres)
{
    ## doing stratified sampling
    strsample <- strata (agpop, "stratum", size = nh,  method = "srswor")
    ## checking sampling results
    #View(strsample)
    #table (strsample [,1]) 
    
    # collecting data on sampled counties
    agstrat <- agpop [strsample$ID_unit, ]
    agstrat$weight <- 1/strsample$Prob
    # View (agstrat)
    res_str[i,] <- 
        strata_mean_estimate_data (agstrat, "acres92", "stratum", "weight")
    
}

################################################################################
########### repeat simple random sampling  2000 times ##########################
################################################################################
nres <- 2000
res_srs <- matrix (0, nres, 4)
for (i in 1:nres)
{
    ## doing stratified sampling
    srs <- sample (sum(Nh), sum (nh))
    ## checking sampling results
    #View(strsample)
    #table (strsample [,1]) 
    
    # collecting data on sampled counties
    agsrs <- agpop [srs, ]
    # View (agstrat)
    res_srs[i,] <- srs_mean_est (agsrs[, "acres92"], N= sum(Nh))
    
}
################################################################################
####### repeat stratified sampling with optimal allocation 2000 times ##########
################################################################################

Nh <- tapply (rep(1, nrow (agpop)), agpop$stratum, length) 
# find order of stratum
# unique (agpop$stratum)
Sh <- tapply (agpop$acres92, agpop$stratum, sd)
nh_opt <- round((Nh*Sh)/sum (Nh*Sh) * 300)

nres <- 2000
res_str_opt <- matrix (0, nres, 4)
for (i in 1:nres)
{
    ## doing stratified sampling
    strsample <- strata (agpop, "stratum", size = nh_opt,  method = "srswor")
    ## checking sampling results
    #View(strsample)
    #table (strsample [,1]) 
    
    # collecting data on sampled counties
    agstrat <- agpop [strsample$ID_unit, ]
    agstrat$weight <- 1/strsample$Prob
    # View (agstrat)
    res_str_opt[i,] <- 
        strata_mean_estimate_data (agstrat, "acres92", "stratum", "weight")
    
}
################################################################################
#################### compare the efficiency of different methods ###############
################################################################################

pdf ("STRAT/agpop_str_efficiency.pdf")
all.sim <- data.frame(res_srs[,1], res_str[,1], res_str_opt[,1])
boxplot (all.sim)
abline (h = mean (agpop$acres92), col = "red")
summary (all.sim)
apply (all.sim, 2, sd)
dev.off()

