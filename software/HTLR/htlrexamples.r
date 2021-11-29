
library (HTLR)

## generate data
source ("gendata.r")

## fit htlr models
fithtlr <- htlr_fitpred (
    y_tr = y_tr, X_tr = X_tr, ##  data
    alpha = 1, s = -15,  ## alpha = df and s= log (w)
    iters_h = 1000, iters_rmc = 1000, thin = 50, ## mcmc iterations
    silence = F)  ## silence = F for looking at mcmc iterations info

## analyze mcmc samples by dividing into feature subsets
fsshtlr <- htlr_fss (fithtlr)

## draw averaged sdbs in all feature subsets
plot_fscore (fsshtlr$wsdbs)

## draw sdbs (feature importance) for top 1 feature subset
plot_fscore (fsshtlr$sdbs[[1]])

## looking at MCMC sample directly

# 1) in all mcmc iterations (maybe see multimodes)
htlr_mccoef (fithtlr, features = c(1,51))

# 2) in only mcmc iterations for feature subset 1
htlr_mccoef (fithtlr, features = c(1,51), usedmc = fsshtlr$mcids[[1]])

## make prediction on test cases
out_pred <- htlr_predict (X_ts = X_ts, fithtlr = fithtlr)

## report detailed prediction results with true response
pred_table <- tabulate_pred (out_pred$probs_pred, y_ts)

## evaluate prediction performance using error rate and amlp
evaluate_pred (pred_table)

