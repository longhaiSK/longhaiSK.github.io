source("gaussian-imps.R")
## debugging the program
x <- rnorm(50)
log_mar_gaussian_imps(x,0,1,0,5,100)
log_mar_gaussian_mc(x,0,1,0,5,10000)
x <- rnorm(10) # another debug
log_mar_gaussian_imps(x,0,1,0,5,100)
log_mar_gaussian_mc(x,0,1,0,5,10000)

## comparing importance sampling with Gaussian approximation with naive monte carlo
x <- rnorm(200)
v_log_mar_imps <- replicate(1000, log_mar_gaussian_imps(x,0,1,0,5,100))
v_log_mar_mc <- replicate(1000, log_mar_gaussian_mc(x,0,1,0,5,100))

var(v_log_mar_imps)
var(v_log_mar_mc)

postscript("comp-imps-naivemc.eps", width=10, height=4.5, horizont=FALSE)
par(mfrow=c(1,2))
xlim <- c(min(c(v_log_mar_imps,v_log_mar_mc)),max(c(v_log_mar_imps,v_log_mar_mc)))
hist(v_log_mar_imps,main="Sampling from approximate Gaussian",xlim=xlim)
hist(v_log_mar_mc,main="Sampling from the prior",xlim=xlim)
dev.off()
