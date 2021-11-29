## generating a data set with three useful features
n <- 500
K <- 1
p <- 200 ## set it 2000 for more realistic simulation

muj <- matrix (c(-0.3,  0.3,
			      0.3, -0.3,
				  1.2,  -1.2), 
				  3, 2, byrow = TRUE)

A <- diag (1,3); 
rho <- 0.85
sigma <- matrix (c(1,rho,rho,1), 2,2)
A[1:2, 1:2] <- t(chol (sigma))

## generate a multivariate normal data with 3 variables
## the first 2 are correlated and both weakly differentiated (-0.3,0.3)
## the 3rd is independent with the first 2 but more differentiated (-1,1)
data <- gendata_fam (n = n, muj = muj, A = A, sd_g = 0, stdx = TRUE)

## find true coefs of the three useful features
deltas_true <- deltas_bc (data$muj, data$SGM) 

print (deltas_true)

## visualize the three useful features

plot (data$X[,-3],col = data$y)

## generating redundant features 
g1 <- 50
g2 <- 50
g3 <- 50
g4 <- p - g1 - g2 - g3
data$X2 <- matrix (0, n, g1+g2+g3+g4)

## correlated group 1
data$X2[, 1] <- data$X[,1] 
data$X2[, 2:g1] <- data$X[,1] + matrix (rnorm (n*(g1-1)), n, g1-1)  * 1

## correlated group 2
data$X2[, g1+1] <- data$X[,2]
data$X2[, g1+(2:g2)] <- data$X[,2] + matrix (rnorm (n*(g2-1)), n, g2-1) * 1

## correlated group 3
data$X2[, g1+g2+1] <- data$X[,3]
data$X2[, g1+g2+(2:g3)] <- data$X[,3] + matrix (rnorm (n*(g3-1)), n, g3-1)  * 1 

## totally useless group 4
data$X2[, g1+g2+g3+ (1:g4)] <- rnorm (n * g4)

## creating training and test data sets
tr <- 200
X_tr <- data$X2[1:tr,]
y_tr <- data$y[1:tr]
X_ts <- data$X2[-(1:tr), ]
y_ts <- data$y[-(1:tr)]




