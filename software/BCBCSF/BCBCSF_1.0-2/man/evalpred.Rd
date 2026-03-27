\name{d3:evalpred}

\alias{eval_pred}

\title{A function for evaluating arrays of predictive probabilities with the true class labels of test cases}

\description{
This function is used to find error rate, amlp, loss and predictive probabilities at true labels.
}
\usage{
eval_pred (out_pred, y_ts, Mloss = NULL)
}

\arguments{

\item{out_pred}{a list returned by function \code{bcbcsf_fitpred} with \code{X_ts} given, or \code{bcbcsf_pred}, or by \code{cross_vld}.}

\item{y_ts}{a vector of true class labels.}

\item{Mloss}{a matrix indicting loss function, with element \eqn{m_{ij}} saving the losss from predicting class \eqn{i} with class label \eqn{j}}; by default, it is NULL. 
}

\value{

\item{probs_at_truelabels}{a matrix of predictive probabilities at true labels, with rows for cases, and columns for different numbers of retained features}

\item{summary}{a data frame, with rows for different numbers of retained features, and columns: \code{Error.Rate}: fraction of cases misclassified with fair threshold, and \code{AMLP}: minus average log probabilities at true labels, often called "deviation",  and \code{Loss} (if \code{Mloss} is given): average loss.
}
}

\keyword{classif}

