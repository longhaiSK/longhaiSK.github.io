#author: Longhai Li (https://math.usask.ca/~longhai/software/BLRHL/index.html)
#email: longhai@math.usask.ca

# recompile source codes (for developing code only)
developing <- FALSE
if (developing){
    system ("source ~/.bash_profile \n cd ~/work/bplr/rcodes\n R CMD build HTLR_3.1-1")
    system ("source ~/.bash_profile \n cd ~/work/bplr/rcodes\n installR HTLR_3.1-1")
    if (any(search () == "package:HTLR")) detach ("package:HTLR", unload=TRUE)
}


# load library
library (HTLR, lib.loc = "~/Rdev/HTLR_3.1-1") 

################################################################################
######################### create/load datasets #################################
################################################################################

## generate a dataset with grouping structure
## to analyze read data, replace the following objects with your data matrix/vector
source ("gen_jscs_data.R") 
## split into training and testing datasets
ntr <- 100
X_tr <- data$X[1:ntr, ]
y_tr <- data$y[1:ntr]
X_ts <- data$X[-(1:ntr), ]
y_ts <- data$y[-(1:ntr)]


################################################################################
######################### Model fitting and feature selection ##################
################################################################################

######################## Fit and Prediction with LASSO  ########################

## fit lasso and make predictions on test cases
lfit <- lasso_fitpred (X_tr, y_tr, X_ts) 
## looking at coefficients and feature selection
sdb.lfit <- comp_sdb (lfit$deltas, normalize = F)
## draw lasso coefficients for visualization
plot_fscore (sdb.lfit, log = "x", main = "LASSO")  
sel.lfit <- which(sdb.lfit > 0.1 * max (sdb.lfit)); sel.lfit
length (sel.lfit)

################### Fit and Prediction using HTLR with t prior ################
tfit <- htlr_fit (
    y_tr = y_tr, X_tr = X_tr, X_ts = X_ts, stdzx = T, fsel = 1:ncol(X_tr),## data
    pty = "t", alpha = 1, s = -10, eta = 0,  ## alpha = df and s= log (w) 
    iters_h = 100, iters_rmc = 1000, thin = 1, ## mcmc iteration settings, 
    leap_L_h = 5, leap_L = 50, leap_step = 0.3, hmc_sgmcut = 0.05, ## hmc settings 
    initial_state = "bcbcsfrda", silence = F)  ## initial state settings

## looking at coefficients and feature selection
sdb.tfit <- htlr_sdb(tfit)
plot_fscore (sdb.tfit, log = "x", main = "t")

sel.tfit <- which(sdb.tfit > 0.1*max(sdb.tfit)); sel.tfit
length (sel.tfit)

################### Fit and Prediction using HTLR with horseshoe prior ########

hfit <- htlr_fit (
    y_tr = y_tr, X_tr = X_tr, X_ts = X_ts, stdzx = T, fsel = 1:ncol(X_tr),##  data
    pty = "ghs", alpha = 1, s = -10, eta = 0,  ## alpha = df and s= log (w) 
    iters_h = 100, iters_rmc = 1000, thin = 1, ## mcmc iteration settings, 
    leap_L_h = 5, leap_L = 50, leap_step = 0.3, hmc_sgmcut = 0.05, ## hmc settings 
    initial_state = "bcbcsfrda", silence = F)  ## initial state

## looking at coefficients and feature selection
sdb.hfit <- htlr_sdb(hfit)
plot_fscore (sdb.hfit, log = "x", main = "Horseshoe")

sel.hfit <- which(sdb.hfit > 0.1*max(sdb.hfit)); sel.hfit
length (sel.hfit)

################### Fit and Prediction using HTLR with NEG prior ###############

nfit <- htlr_fit (
    y_tr = y_tr, X_tr = X_tr, X_ts = X_ts, stdzx = T, fsel = 1:ncol(X_tr),  ##  data
    pty = "neg", alpha = 1, s = -10,  ## alpha = df and s= log (w) 
    iters_h = 100, iters_rmc = 1000, thin = 1, ## mcmc iteration settings, 
    leap_L_h = 5, leap_L = 50, leap_step = 0.5, hmc_sgmcut = 0.05, ## hmc settings 
    initial_state = "bcbcsfrda", silence = F)  ## initial state

## looking at coefficients and feature selection
sdb.nfit <- htlr_sdb(nfit)
plot_fscore (sdb.nfit, log = "x", main = "NEG")

sel.nfit <- which(sdb.nfit > 0.1*max(sdb.nfit)); sel.nfit
length (sel.nfit)

################################################################################
##################### Comparison of Out-of-sample Prediction  ##################
################################################################################

#Note: predictions have been produced in fitting functions

## evaluate predictions on test cases (out-of-sample testing) by lasso
lpred <- lfit$probs_pred ## prediction results on test cases
## evaluate lasso predictions with ER and AMLP
evaluate_pred (lpred, y_ts, method = "LASSO") -> lpred.eval

## evaluate tprior predictions with ER and AMLP
bpred <- tfit$probs_pred
evaluate_pred (bpred, y_ts, method = "t") -> bpred.eval
## evaluate horseshoe predictions with ER and AMLP
hpred <- hfit$probs_pred
evaluate_pred (hpred, y_ts, method = "Horseshoe") -> hpred.eval
## evaluateneg predictions with ER and AMLP
npred <- nfit$probs_pred
evaluate_pred (npred, y_ts,method = "NEG") -> npred.eval

