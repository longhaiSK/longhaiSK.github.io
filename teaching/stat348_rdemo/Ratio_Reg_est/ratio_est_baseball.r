source ("estimates.r")

pdf ("Ratio_Reg_est/ratio_est_baseball.pdf")
baseball <- read.csv ("data/baseball.csv", header = F)

var_int <- 20
var_aux <- 16

## look at population data
plot (baseball[, c(var_aux, var_int)])
abline (a=0, b = sum (baseball[,var_int])/sum(baseball[,var_aux]))
cor (baseball[, c(var_aux, var_int)])

# sample size
n <- 100
# population size
N <- nrow (baseball)

# unknown true values (total numbers of home runs)
tyU <- sum (baseball [, var_int]) 
ybarU <- tyU/N
# known total runs scored
txU <- sum (baseball [, var_aux]) 
xbarU <- txU/N

################### analysis of one particular srs survey data ############
# srs sampling
srs <- sample (N,n)

# survey
ydata <- baseball [srs, var_int]
xdata <- baseball [srs, var_aux]

srs_ratio_est (ydata, xdata, N) # for B
srs_ratio_est (ydata, xdata, N) * txU # for tyU
srs_ratio_est (ydata, xdata, N) * xbarU # for ybarU
srs_est (ydata, N)

################## simulation studies using repeated sampling #############
nsim <- 50000
ratio_res <- matrix (0, nsim, 4)
simpl_res <- matrix (0, nsim, 4)

for (i in 1:nsim)
{
  srs <- sample (N,n)
  ydata <- baseball[srs, var_int]
  xdata <- baseball[srs, var_aux]
  ratio_res [i, ] <- srs_ratio_est (ydata, xdata, N) * xbarU
  simpl_res [i, ] <- srs_est (ydata, N) 
}

# compare ratio and simple estimate
boxplot (data.frame(ratio = ratio_res[,1], simple = simpl_res[,1]))

# look at estimates themselve
boxplot (ratio_res[,1])
abline (h = ybarU)
qqnorm (ratio_res[,1])


# look at relative bias
boxplot( (ratio_res[,1] - ybarU ) / ybarU)
boxplot( (simpl_res[,1] - ybarU ) / ybarU)

# look at actual coverage of CI
mean (ratio_res [,3] <= ybarU & ybarU <= ratio_res[,4])

# look at actual (based on simulation) SE of ybar_r 
sd_ybar_r <- sd (ratio_res[,1])

# look at estimates of SE of ybar_r in comparison to the actual value
boxplot (ratio_res [,2])
abline (h = sd_ybar_r, col = "red") # actual value (from simulation)

boxplot((ratio_res[,2] - sd_ybar_r)/sd_ybar_r, 
        main = "Boxplot of Relative Errors in SE Estimates")
abline (h = 0, col = "red")


dev.off ()

