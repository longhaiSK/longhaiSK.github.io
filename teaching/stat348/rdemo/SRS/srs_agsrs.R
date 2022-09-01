## step by step calculation without using a function 

## read survey data
agsrs <- read.csv ("data/agsrs.csv")

## extract the variable of interest
sdata <- agsrs$acres92
N <- 3078

## do calculation
n <- length (sdata)
ybar <- mean (sdata)
se.ybar <- sqrt((1 - n / N)) * sd (sdata) / sqrt(n)  
mem <- qt (0.975, df = n - 1) * se.ybar
## return estimate vector for pop mean
c (Est. = ybar, S.E. = se.ybar, ci.low = ybar - mem, ci.upp = ybar + mem)

## return estimate vector for pop total
c (Est. = ybar, S.E. = se.ybar, ci.low = ybar - mem, ci.upp = ybar + mem) * N

############################# inference with SRS sample ########################
## sdata --- a vector of original survey data
## N --- population size
## to find total, multiply N to the estimate returned by this function
srs_mean_est <- function (sdata, N = Inf)
{
    n <- length (sdata)
    ybar <- mean (sdata)
    se.ybar <- sqrt((1 - n / N)) * sd (sdata) / sqrt(n)  
    mem <- qt (0.975, df = n - 1) * se.ybar
    c (Est. = ybar, S.E. = se.ybar, ci.low = ybar - mem, ci.upp = ybar + mem)
}

agsrs <- read.csv ("data/agsrs.csv")

# inference for mean of variable acres92
srs_mean_est (agsrs[,"acres92"], N = 3078)

# inference for total of variable acres92
srs_mean_est (agsrs[,"acres92"], N = 3078) * 3078

# inference for proportion of counties with fewer than 200K acres for farming in 1992
acres92.is.fewer.200k <- as.numeric (agsrs[,"acres92"] < 200000)
srs_mean_est (acres92.is.fewer.200k, N = 3078) 
# inference for total number of counties with fewer than 200K acres for farming in 1992
srs_mean_est (acres92.is.fewer.200k, N = 3078) * 3078

####################### compare with true value ################################
agpop <- read.csv ("data/agpop.csv", na = "-99")
#true mean
mean (agpop[, "acres92"], na.rm = T)
# true total
sum (agpop[, "acres92"], na.rm = T)

# true proportion of counties with less than 200K acres for farming
mean (agpop[, "acres92"] < 200000, na.rm = T)
# true number of counties with less than 200K acres for farming
sum (agpop[, "acres92"] < 200000, na.rm = T)


