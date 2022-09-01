
pdf ("solutions/srs_Q2.32.pdf") # save graph output to srsQ32.pdf

# a function for doing data analysis for srs sample
# sdata -- a vector of sampling survey data
# N -- population size 
srs_estimate <- function (sdata, N)
{
	n <- length (sdata)
	ybar <- mean (sdata)
	seybar <- sqrt((1 - n / N)) * sd (sdata) / sqrt(n)  
	mem <- qt (0.975, df = n - 1) * seybar
	c (ybar = ybar, se = seybar, ci.low = ybar - mem, ci.upp = ybar + mem)
}

# read population data 
baseball <- read.csv ("data/baseball.csv", header = F, na = ".")

# sample size
n <- 150
# population size
N <- nrow (baseball)

# a) 
## one srs sampling
# srs sampling
set.seed (1986555)
srs <- sample (N, n)
write.csv (srs, file = "solutions/Q32_savedsrs.csv")
# survey data of variable 4
salary_srs <- baseball [srs, 4]

# b)

logsal <- log (salary_srs)

hist (logsal)
hist (salary_srs)

# c) 

srs_estimate  (logsal, N)

# d)

is.pitcher <- 1 * (na.omit (baseball[srs, 5]) == "P")
# if a student takes this as sample value, count it right.
# is.pitcher <- na.omit ( 1 * (baseball[srsinclude == 1, 27] > 0) )

srs_estimate (is.pitcher, N)

# e)
mean (na.omit (baseball[, 5]) == "P")

# f)


## repeated srs sampling
nres <- 2000 # number of repeated sampling
res_sal <- numeric (nres) # matrix recording repeated results

for (i in 1:nres)
{
	srs_salary <- baseball [sample(N,n), 4]
	res_sal [i] <- mean (na.omit (srs_salary))
}

hist (res_sal, main = "Histogram of 2000 Estimates of Salary Mean")
abline (v = mean (na.omit (baseball[,4])))

boxplot (res_sal, main = "Boxplot of 2000 Estimates of Salary Mean")
abline (h = mean (na.omit (baseball[,4])))

qqnorm (res_sal)

mean (res_sal)
sd (res_sal)

# true values are
ybarU <- mean (baseball[, 4])
ybarU
seybar <- sqrt (1- n/N) * sd (baseball[,4]) / sqrt (n)
seybar

dev.off () 