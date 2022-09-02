score  <- c(66, 59, 70, 83, 82, 71)

# a) 

m <- mean (score); m
S2 <- var (score); S2 # this is the sample variance of population data 
S2_alt <- sum ((score - m)^2) / 5; S2_alt #(see how it is computed)

# b)
choose (6,4)

# c)

# all 15 srs sample
allsrs <- t (combn (score, 4)); allsrs
srs_ybar <- rowMeans (allsrs); srs_ybar
# this is the probability mass distribution of ybar
srs_PMF <- rep (1/15, 15) 
## find var of ybar
srs_mean <- sum (srs_ybar * srs_PMF);srs_mean
var_ybar <- sum ((srs_ybar- srs_mean)^2 * srs_PMF ); var_ybar

## the var_yar is the same what we compute with formula taught in class
(1-4/6) * S2/4

