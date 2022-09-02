## the following R code was written by Kevin Hattie

## load data
agsrs <- read.csv ("data/agsrs.csv")

## read functions
source ("estimates.r")

##### 2.15 a)

hist(agsrs$acres87)

srs_mean_est (agsrs[,"acres87"], N = 3078)

##### 2.15 b)

hist(agsrs$farms92)

srs_mean_est (agsrs[,"farms92"], N = 3078)

##### 2.15 c)

hist(agsrs$largef92)

srs_mean_est (agsrs[,"largef92"], N = 3078)

##### 2.15 d)

hist(agsrs$smallf92)

srs_mean_est (agsrs[,"smallf92"], N = 3078)
