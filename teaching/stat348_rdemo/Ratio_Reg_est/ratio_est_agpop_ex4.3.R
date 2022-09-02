source ("estimates.r")

agpop <- read.csv ("agpop.csv")
# population size
N <- nrow (agpop)

######################## ratio estimate for an SRS data set #################
agsrs <- read.csv ("agsrs.csv")
ydata <- agsrs [, "acres92"]
xdata <- agsrs [, "acres87"]

# suppose known for ratio estimate
txU <- sum (agpop [,"acres87"]) 
xbarU <- txU/N

srs_ratio_est (ydata, xdata, N) # for B
srs_ratio_est (ydata, xdata, N) * txU # for total
srs_ratio_est (ydata, xdata, N) * xbarU # for mean
srs_mean_est (ydata, N)

###################### look at the repeated sampling  ########################
# true values that we want to estimate
tyU <- sum (agpop [,"acres92"])
ybarU <- tyU/N

n <- 300

ratio_res <- srs_res <- matrix (0, 10000, 4)

for (i in 1:10000)
{
  srs <- sample (N,n)
  ydata <- agpop [srs, "acres92"]
  xdata <- agpop [srs, "acres87"]
  ratio_res [i, ] <- srs_ratio_est (ydata, xdata, N) * xbarU
  srs_res [i,] <- srs_mean_est (ydata, N)
}

pdf ("ratio_est_agpop.pdf")


# look at estimates themselve
boxplot (data.frame(ratio_res[,1], srs_res[,1]))
abline (h = ybarU)
qqnorm (ratio_res[,1])

# relative efficiency by looking at variance
var (ratio_res[,1])/var (srs_res[,1])

# look at actual coverage of CI
mean (ratio_res [,3] < ybarU & ybarU < ratio_res[,4])
mean (srs_res [,3] < ybarU & ybarU < srs_res[,4])


dev.off ()