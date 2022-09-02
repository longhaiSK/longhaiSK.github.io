################################################################################
##The following functions were written for STAT 348 Sampling Techniques taught##
##at the University of Saskatchewan by Longhai Li###############################
################################################################################

## data --- original data frame for holding data
## cname --- variable recording cluster (psu) identity
## csize --- variable recording cluster (psu) population size (not sample size)
## cpik --- sampling probability for each cluster
## yvar --- variable of interest
## N --- total number of clusters (psus)

cluster_upswo_ratio_est <- function (data, cname, csize, cpik, yvar)
{
  clust <- data[,cname]
  ydata <- data [, yvar]  
  
  ## cluster-wise summary
  ybari <- tapply (ydata, clust, mean)
  Mi <- tapply (data [,csize], clust, function (x) x[1])
  pik <- tapply (data [,cpik], clust, function (x) x[1])
  ## the same as total in cluster if Mi = mi
  t_hat_cls <- ybari * Mi 
  
  ## apply ratio estimate to t_hat_cls and Mi
  srs_ratio_est (t_hat_cls/pik, Mi/pik)
}

## data --- original data frame for holding data
## sid --- variable recording sample id of psu, note that, 
## sid must be different when the same psu is surveyed multiple times
## csize --- variable recording cluster (psu) population size (not sample size)
## cpik --- sampling probability for each cluster
## yvar --- variable of interest
## N --- total number of clusters (psus)

cluster_upswr_ratio_est <- function (data, sid, csize, cpik, yvar)
{
    clust <- data[, sid]
    ydata <- data [, yvar]  
    
    ## cluster-wise summary
    ybari <- tapply (ydata, clust, mean)
    Mi <- tapply (data [,csize], clust, function (x) x[1])
    pik <- tapply (data [,cpik], clust, function (x) x[1])
    ## the same as total in cluster if Mi = mi
    t_hat_cls <- ybari * Mi 
    
    ## apply ratio estimate to t_hat_cls and Mi
    srs_ratio_est (t_hat_cls/pik, Mi/pik)
}

upswr_total_est <- function (total, psi, N = Inf)
{	
  srs_mean_est (total/psi, N = N)
}

upswr_ratio_est <- function (total, M, psi, N = Inf)
{
  srs_ratio_est (total/psi, M/psi, N = N)
}

## data --- original data frame for holding data
## cname --- variable recording cluster (psu) identity
## csize --- variable recording cluster (psu) population size (not sample size)
## yvar --- variable of interest
## N --- total number of clusters (psus)
cluster_ratio_est <- function (data, cname, csize, yvar, N = Inf)
{
  clust <- data[,cname]
  ydata <- data [, yvar]  
  
  ## cluster-wise summary
  ybari <- tapply (ydata, clust, mean)
  Mi <- tapply (data [,csize], clust, function (x) x[1])
  ## the same as total in cluster if Mi = mi
  t_hat_cls <- ybari * Mi 
  
  print (data.frame (Mi=Mi, yhari=ybari, ti = t_hat_cls))
  ## apply ratio estimate to t_hat_cls and Mi
  srs_ratio_est (t_hat_cls, Mi, N = N)
}

## ydata --- observations of the variable of interest
## xdata --- observations of the auxilliary variable
## N --- population size
## xbarU --- population mean of auxilliary variable
srs_reg_est_mean <- function (ydata, xdata, xbarU, N = Inf)
{
  n <- length (ydata)
  lmfit <- lm (ydata ~ xdata)
  Bhat <- lmfit$coefficients
  efit <- lmfit$residuals
  SSe <- sum (efit^2) / (n - 2) 
  yhat_reg <- Bhat[1] + Bhat[2] * xbarU
  se_yhat_reg <- sqrt ((1-n/N) * SSe / n)
  mem <- qt (0.975, df = n - 2) * se_yhat_reg
  output <- c(yhat_reg, se_yhat_reg, yhat_reg - mem, yhat_reg + mem)
  names (output) <- c("Est.", "S.E.", "ci.low", "ci.upp" )
  output
}
srs_reg_est <- srs_reg_est_mean

## ydata --- observations of the variable of interest
## xdata --- observations of the auxilliary variable
## N --- population size
srs_ratio_est <- function (ydata, xdata, N = Inf)
{	
  n <- length (xdata)
  xbar <- mean (xdata)
  ybar <- mean (ydata)
  B_hat <- ybar / xbar
  d <- ydata - B_hat * xdata
  var_d <- sum (d^2) / (n - 1)
  sd_B_hat <- sqrt ((1 - n/N) * var_d / n) / xbar
  mem <- qt (0.975, df = n - 1) * sd_B_hat
  output <- c (B_hat, sd_B_hat, B_hat - mem, B_hat + mem )
  names (output) <- c("Est.", "S.E.", "ci.low", "ci.upp" )
  output
}

strata_samplesize <- function (e, Lh, Nh, Sh)
{
  N <- sum (Nh)
  nu <- sum ((Nh/N)^2 * Sh^2 / Lh) 
  # necessiry sample size 
  n <- nu * qnorm (0.975)^2 / e^2

  nh <- n * Lh
  
  list (n = n, nh = nh)
}

## this function finds statistical estimates given a dataset with sampling weight
# stratdata --- data.frame containing stratified sample
# y --- name of variable for which we want to estiamte population mean
# stratum --- name of variable that will be used as stratum variable
# weight --- name of variable indicating sampling weight
# note: from weights we can find Nh (see the code for formula)
strata_mean_estimate_data <- function (stratdata, y, stratum, weight, post=FALSE)
{
    ## compute stratum-wise data
    n <- nrow (stratdata)
    sh <- tapply (stratdata[, y], stratdata[,stratum], sd)
    ybarh <- tapply (stratdata[, y], stratdata[,stratum], mean)
    ## find population stratum size using sampling weight included in the data set
    Nh <- tapply (stratdata[, weight], stratdata[,stratum], sum)
    if (!post)    
        nh <- table (stratdata[,stratum])
    else 
        nh <- n * Nh/sum (Nh)
    
    ## find mean estimates
    N <- sum (Nh)
    Wh <- Nh/N
    ybar <- sum(ybarh * Wh)
    seybar <- sqrt(sum((1-nh/Nh)*Wh^2*sh^2/nh))
    mem <- 1.96 * seybar
    c(Est. = ybar, S.E. = seybar, ci.low = ybar - mem, ci.upp = ybar + mem)
    
}


## to find total, multiply N to the estimate returned by this function
## for poststratification, use nh = n * Nh/N
strata_mean_estimate <- function (ybarh, sh, nh, Nh)
{
    N <- sum (Nh)
    Wh <- Nh/N
    ybar <- sum(ybarh * Wh)
    seybar <- sqrt(sum((1-nh/Nh)*Wh^2*sh^2/nh))
    mem <- 1.96 * seybar
    c(Est. = ybar, S.E. = seybar, ci.low = ybar - mem, ci.upp = ybar + mem)
}



## sdata --- a vector of original survey data
## N --- population size
## to find total, multiply N to the estimate returned by this function

srs_mean_est <- function (sdata, N = Inf)
{
	n <- length (sdata)
	ybar <- mean (sdata)
	se.ybar <- sqrt((1 - n / N)) * sd (sdata) / sqrt(n)  
	mem <- qt (0.975, df = n - 1) * se.ybar
	c (Est. = ybar, S.E. = se.ybar, ci.low = ybar - mem, ci.upp = ybar + mem)
}

## create another function that is exactly equal to srs_mean_est. 
## make this alias only because sometimes I used srs_est instead of srs_mean_est
srs_est <- srs_mean_est
