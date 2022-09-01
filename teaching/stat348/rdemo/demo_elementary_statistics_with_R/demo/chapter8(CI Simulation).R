pdf ("simulatedCI.pdf")

############## generate a population data ###################################

X <- rgamma (100000, 15, .08)
# use another sample
# X <- rbinom (100000, 1, 0.3)

me <- sd (X)/sqrt(10)*4
xlim <- mean (X) + c(-me, me)
mu <- mean (X) # population mean
sigma <- sd (X) # population sd
#hist (X, main = "Population Distribution")

############# draw sample of sample mean ####################################
for (n in c(10,50,100))
{
    
    n_rep <- 10000
    CI_rep <- matrix (0, n_rep, 3) 
    xbar <- replicate (n_rep, mean(sample (X, size = n, replace = T) ) )
    
    ############ find 95% confidence intervals for each sample mean #########
    
    # find margin error (me)
    alpha <- 0.05
    z <- - qnorm (alpha/2) # or using z <- qnorm (alpha/2, lower = F)
    me <- z * sigma/sqrt (n)
    
    # find a CI with the first sample
    ci <- c(xbar[2] - me, xbar[2] + me)
    mu.is.covered <- ci[1] < mu & mu < ci[2] 
    
    # repeat n_rep times
    for (i in 1:n_rep)
    {
        CI_rep [i,1:2] <- c(xbar[i] - me, xbar[i] + me)
        CI_rep [i, 3] <- CI_rep [i,1] < mu & mu < CI_rep [i,2] 
    }
    
    
    ############################ plot CI ########################################
    n_plot <- 50
    rns <- sample (n_rep)
    plot (0,0,type = "n", ylab = "Replication ID", xlab = "x",  
          xlim = xlim, #xlim = range (CI_rep[,1:2]),
          ylim = c(0,n_plot+1))
    title (main = paste("Illustration of Confidence Intervals, n = ",n))
    abline (v = mu, col = "green", lwd = 3)
    abline (v = mu + c(-me, +me), col = "green")
    for (i in 1:n_plot)
    {
        lines (CI_rep[rns[i],1:2], c(i,i), col =  2 - CI_rep[rns[i], 3] )
        points (xbar[rns[i]], i, pch = 4, col = 2 - CI_rep[rns[i],3])
    }
    hist (xbar,xlim=xlim)
    abline (v = mu, col = "green", lwd = 3)
    abline (v = mu + c(-me, +me), col = "green")
    ## actual cover rate
    mean (CI_rep [,3])
    
}

dev.off()
