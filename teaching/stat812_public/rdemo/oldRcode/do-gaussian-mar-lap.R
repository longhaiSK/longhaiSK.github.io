source("gaussian-lap.R")
source("gaussian-midpoint.R")

x <- rnorm(50, mean = 5)
log_mar_gaussian_mc(x,0,100,0,5,100000)
log_mar_gaussian_mid(x,0,100,0,5,100)
log_mar_gaussian_lap(x,0,100,0,5)


x <- rnorm(500, mean = 5)
log_mar_gaussian_mc(x,0,10,0,5,100000)
log_mar_gaussian_mid(x,0,10,0,5,100)
log_mar_gaussian_lap(x,0,10,0,5)

