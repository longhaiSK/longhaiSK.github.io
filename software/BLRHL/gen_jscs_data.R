
#source ("genedata.R")
## The description of the dataset generating scheme is found from 
## Li, L. & Yao, W. Fully Bayesian logistic regression with hyper-LASSO priors for high-dimensional feature selection. Journal of Statistical Computation and Simulation 88, 2827–2851 (2018).
## There are 4 groups of features:
##  feature #1: marginally related feature
##  feature #2: marginally unrelated feature, but feature #2 is correlated with feature #1
##  feature #3-10: marginally related features and also internally correlated
##  feature #11-2000: noise features without relationship with the y.
n <- 2100
p <- 1000

means <- rbind(
    c (0,1,0),
    c (0,0,0),
    c (0,0,1),
    c (0,0,1),
    c (0,0,1),
    c (0,0,1),
    c (0,0,1),            
    c (0,0,1),            
    c (0,0,1),            
    c (0,0,1)
) * 2

means <- rbind (means, matrix (0, p-10,3))

A <- diag (1, p)

A [1:10,1:3] <- 
    rbind( 
        c (1,0,0),
        c (2,1,0),
        c (0,0,1),
        c (0,0,1),
        c (0,0,1),
        c (0,0,1),
        c (0,0,1),
        c (0,0,1),
        c (0,0,1),
        c (0,0,1)
    )

data <- gendata_fam (n, means, A, sd_g = 0.5, stdx = TRUE)

## spliting into training and testing

## feature labels
flabel <- rep (20, p)
flabel [1] <- 8
flabel [2] <- 3
flabel [3:10] <- 4


