\name{d4:analyzefit}

\alias{bcbcsf_sumfit}

\alias{reload_fit_bcbcsf}

\alias{bcbcsf_plotsumfit}

\title{Functions for analyzing and visualizing a BCBCSF fitting result}

\description{
These functions are used to look at the fitting results, especially plot the gene signals. 
}

\usage{

reload_fit_bcbcsf (fit_bcbcsf_afile)

bcbcsf_sumfit (fit_bcbcsf = NULL, fit_bcbcsf_afile = NULL, 
               burn = NULL,  thin = 1)

bcbcsf_plotsumfit (sum_fit)
 
}

\arguments{

\item{fit_bcbcsf_afile}{a string of name of a file saving a Markov chain fitting result; it can be found from the value \code{fitfiles} of function \code{bcbcsf_fitpred}.}

\item{fit_bcbcsf}{a list of Markov chain fitting result, returned by function \code{reload_fit_bcbcsf} and \code{\link{bcbcsf_fitpred}}; if it is NULL, it will be retrieved by running \code{reload_fit_bcbcsf} with value in \code{fit_bcbcsf_afile}.}

\item{burn, thin}{\code{burn} of Markov chain (super)iterations will be discarded (burned) for evaluation, and only every \code{thin}th are used; by default, 20\% of (super)iterations are burned, and \code{thin}=1.}

\item{sum_fit}{a list returned by function \code{bcbcsf_sumfit}}

}

\value{ 

\code{reload_fit_bcbcsf} returns a list of Markov chain fitting results, including how to do feature selection and data preprocessing. 

\code{bcbcsf_sumfit} returns a list of point estimates of means and variances. 

\code{bcbcsf_plotsumfit} returns nothing; it plots the normalized means (for each gene, original expression means substracted by their means and divided by the common standard deviation), and overall signals (Euclid distance of normalized means) for the selected features. 
}


