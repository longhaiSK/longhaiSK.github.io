system ("rm leapfro.o leapfrog.so")
system ("R CMD SHLIB leapfrog.c")
dyn.load ("leapfrog.so")

A <- matrix (runif(12), 3,4)
.C ("colSums", 1:1, 4:4,3:3, A, rep (0, 3))

apply (A, 1, mean)

A <- runif (5)
.C ("log_sum_exp", 5:5, A, 1)

log (sum(exp (A)))

lv <- matrix (- runif(20) * 100, 4,5)

lv

lv - apply (lv,1, function (a) log (sum(exp(a))))

nlv <- t(.C("norm_lv", 4:4, 5:5, t(lv))[[3]])

nlv

apply (exp(nlv), 1, sum) 

system ("rm samplew.o samplew.so")
system ("R CMD SHLIB samplew.c")
dyn.load ("samplew.so")

deltas <- rt (200, df = 0.5) * sqrt (2) * exp (-5)

vardeltas <- deltas^2/2

smp_logw <- rep (0, 2)
for (j in 1:2)
{
  smp_logw[j] <- 
  .C("samplew", 0.0, 1:1, length (vardeltas),vardeltas, 0.5,-20, 1000)[[1]]
}

plot (smp_logw)



rpkg <- "~/work/bplr/rcodes/BPLR_2.0-0"
rfiles <- system (sprintf("ls %s/R/*.r",rpkg), intern = TRUE) 
for (i in 1: length(rfiles) ) source (rfiles[i]) 

set.seed (1)
lrdata <- bplr_gendata (100, 100, NC = 3, nu = 1, w = exp(-10))
bplr_train (lrdata$y, lrdata$X, initial_state = lrdata$deltas)


rpkg <- "~/work/bplr/rcodes/BPLR_3.0-0"
rfiles <- system (sprintf("ls %s/R/*.r",rpkg), intern = TRUE) 
for (i in 1: length(rfiles) ) source (rfiles[i]) 

set.seed (1)
lrdata <- bplr_gendata (500, 1000, NC = 3, nu = 1, w = exp (-10))
tsdd <- comp_sdd (lrdata$deltas)
lrdata$X <- lrdata$X[,order(-tsdd)]
tsdd <- tsdd[order(-tsdd)]

fitbplr <- bplr_fitpred (
              y_tr = lrdata$y[1:200], X_tr = lrdata$X[1:200,], 
              X_ts = lrdata$X[-(1:200),], 
              iters_h = 0, iters_rmc = 1000, thin = 10,  leap_L = 10, 
              hmc_sgmcut = 0.01, leap_step = 0.25 )

bsdd <- bplr_mcdeltas (fitbplr, showsdd = T)
plot (bsdd, log = "xy")

mean (-log (probs_attrue (fitbplr$probs_pred, lrdata$y[-(1:200)])))

deltas <- bplr_mcdeltas (fitbplr, showmean = T)

plot (fitbplr$mcdeltas[1,1,])

plot (fitbplr$mcvardeltas[20,], log = "y")
plot ( abs( c(deltas) ),  abs(c(lrdata$deltas)), log = "xy" )

