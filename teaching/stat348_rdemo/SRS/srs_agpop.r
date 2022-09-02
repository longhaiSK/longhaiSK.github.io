################### A Simulation Demonstration of SRS Inference ##############

# a function for doing data analysis for srs sample
# sdata -- a vector of sampling survey data
# N -- population size 
srs_mean_est <- function (sdata, N)
{
	n <- length (sdata)
	ybar <- mean (sdata)
	seybar <- sqrt((1 - n / N)) * sd (sdata) / sqrt(n)  
	mem <- qt (0.975, df = n - 1) * seybar
	c (ybar = ybar, se = seybar, ci.low = ybar - mem, ci.upp = ybar + mem)
}
# read population data 
agpop <- read.csv ("data/agpop.csv")
agpop <- agpop[agpop$acres92 != -99, ] ## remove those counties with na
# an equivalent expression
#agpop <- subset( agpop, acres92 != -99) 

###################### working with variable 'acres92' ##################
# sample size
n <- 300
# population size
N <- nrow (agpop)

# true value of population mean
ybarU <- mean (agpop[,"acres92"]); ybarU
# true value of deviation of sample mean
true.seybar <- sqrt (1- n/N) * sd (agpop[,"acres92"]) / sqrt (n); true.seybar

## one srs sampling
# srs sampling
srs <- sample (1:N,n); srs
# get data of variable "acres92"
sdata <- agpop [srs, "acres92"]; sd (sdata)
# analysis
srs_mean_est (sdata, N)

## repeated srs sampling
nres <- 5000 # number of repeated sampling
res.est <- matrix (0, nres, 4) # matrix recording repeated results

for (i in 1:nres)
{
    srs <- sample (N, n)
	sdata <- agpop [srs, "acres92"]
	res.est [i,] <- srs_mean_est (sdata, N)
}

# look at the distribution of sample mean
hist (agpop$acres92)
hist (res.est[,1])
abline (v = ybarU, col = "red")
boxplot (res.est[,1])
abline (h = ybarU, col = "red")
qqnorm (res.est[,1])
mean (res.est[,1])
ybarU
sd (res.est [,1])
true.seybar

# look at coverage rate through simulation
res.est <- cbind (res.est, (res.est[,3] < ybarU) * (ybarU < res.est[,4] ))
# actual coverage rate in the simulation
mean (res.est[,5])

# look at the distribution of estimate of se of ybar
hist (res.est[,2]^2)
abline (v = true.seybar^2, col = "red")
summary (res.est[,2]^2)
# true value of se of ybar
true.seybar^2

