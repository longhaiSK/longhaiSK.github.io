\name{d1:bcbcsfexamples}

\alias{bcbcsfexamples}

\title{Examples of fitting models, predicting class labels, evaluating
prediction, and analyzing fitting results}

\description{These examples demonstrate how to use BCBCSF package. They use
all prior and Markov chain sampling settings by default (except
\code{no_rmc} as noted below). The methods for setting others can be found
from documents for specific functions. However, the default settings may
work well for a wide range of gene expression data.}

\seealso{\code{\link{bcbcsf_fitpred}}, \code{\link{bcbcsf_pred}},
\code{\link{cross_vld}}, \code{\link{eval_pred}},  
\code{\link{reload_fit_bcbcsf}}, \code{\link{bcbcsf_sumfit}},
\code{\link{bcbcsf_plotsumfit}}}

\examples{

##\dontrun{
## load lymphoma microarray data
data (lymphoma)

## select some cases as testing data set
ts <- c (sort(sample (1:42,5)), 43:44, 61:62)

## training data
X_tr <- lymph.X[-ts,] 
y_tr <- lymph.y[-ts]
## test data 
X_ts <- lymph.X[ts,] 
y_ts <- lymph.y[ts] 

##########################################################################
######################## training and prediction #########################
##########################################################################

## To comply with CRAN policies, we use R's temporary directory for saving files
my_prefix <- file.path(tempdir(), "bcbcsf_")

## fitting training data with top features selected by F-statistic 
out_fit <- bcbcsf_fitpred (X_tr = X_tr, y_tr = y_tr, nos_fsel = c(20, 50),
                           no_rmc = 10, fit_bcbcsf_filepre = my_prefix)
## note 1: if 'X_ts' is given above, prediction is made after fitting
## note 2: no_rmc = 100 is too small, omit it and use the default

## predicting class labels of test cases 
out_pred <- bcbcsf_pred (X_ts = X_ts, out_fit = out_fit)

## evaluate prediction given true labels
eval_pred (out_pred = out_pred, y_ts = y_ts)

##########################################################################
####################### visualizing prediction results ###################
##########################################################################
## reload one bcbcsf fit result from hardrive
fit_bcbcsf <- reload_fit_bcbcsf (out_fit$fitfiles[1])
## the fitting result for no_fsel = 50 can be retrieved directly from
## out_fit:
fit_bcbcsf_fsel50 <- out_fit$fit_bcbcsf
## summarize the fitting result
sum_fit <- bcbcsf_sumfit (fit_bcbcsf)

## visualize fitting result
bcbcsf_plotsumfit (sum_fit)

##########################################################################
############################ cross validation ############################
##########################################################################

cv_prefix <- file.path(tempdir(), "cv_bcbcsf_")

## doing cross validation with bcbcsf_fitpred on lymphoma data 
cv_pred <- cross_vld (
       ##################### classifier, data, and fold ###################
       fitpred_func = bcbcsf_fitpred, X = lymph.X, y = lymph.y, nfold = 2,
       ################ all other arguments passed classifier ############
       nos_fsel = c(10,12), no_rmc = 20, fit_bcbcsf_filepre = cv_prefix)
## note: no_rmc = 100 is too small, omit it and use the default in practice

## evaluate prediction given true labels            
eval_pred (out_pred = cv_pred, y_ts = lymph.y)   

## warning: this function is slow if nfold is large; if you have a 
## computer cluster, you better parallel the cross validation folds.
##}
}

\references{
Li, L. (2012), Bias-corrected Hierarchical Bayesian Classification
with a Selected Subset of High-dimensional Features, \emph{Journal of
American Statistical Association},107:497,120-134
}
