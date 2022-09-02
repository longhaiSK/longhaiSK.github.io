
#### the following is only for class demonstration 

pdf ("practical-significance.pdf", width = 11, height = 8)

mu0 <- 180

X <- rnorm (100000, 180, 10)

xlim <- range (X)

hist (X, main = sprintf( "Population Distribution when H0: mu = %d is true", mu0), 
      xlim = xlim)
abline (v = mu0, lwd = 4)

## sample size = 20
nset <- c(5, 20, 50, 100, 500, 1000)
sample1_xbar <- list (nset)
for (i in 1:length (nset))
{
    sample1_xbar[[i]] <- replicate (500, mean(sample (X, size = nset[i], replace = T) ) )    
}

xlim <- range (sample1_xbar)

par (mfrow = c(3, 1))
for (i in 1:length (nset))
{
    plot (sample1_xbar[[i]],1:500,  pch = 4, xlim = xlim, 
          main = sprintf("Distribution of xbar of n = %d observations given H0: mu = %.2f", 
                         nset[i], mu0
                  ),
          xlab = "xbar", ylab = "Sample ID"
    )
    abline (v = mu0, lwd = 4)
    abline (v = mu0 - 1.645 * 10/sqrt (nset[i]), col = "green", lwd = 3)
    
    
}



dev.off()

