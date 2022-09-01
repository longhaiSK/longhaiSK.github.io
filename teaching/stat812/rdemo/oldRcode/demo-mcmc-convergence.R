## a function that similates a markov chain
sim_one_mc <- function (ini, iters, n = 10)
{
    forward <- function(i) 
    {  if( i == n - 1) 0 
       else i + 1
    }
    backward <- function(i)
    {  if( i == 0 ) n - 1
       else i - 1
    }
    
    mc <- rep (0, iters + 1)
    mc[1] <- ini
    for (i in 2: (iters+1))
    {
        
        u <- runif(1)
        if(u < 0.45)  mc[i] <- forward(mc[i-1])
        else if( u > 0.55 ) mc[i] <- backward(mc[i-1])
        else mc[i] <- mc[i-1]
        
    }
    mc
}

plot(one_mc <- sim_one_mc (2,100) , type = "l")
abline (h = 0:9, lty = 2)

## simulate 1000 chain
multiple_mc <- replicate (10000, sim_one_mc (2, 100))
head (multiple_mc)
matplot (multiple_mc[, 1:100], type = "l")
plot (multiple_mc[,1000],type = "b") ## look at a chain
barplot(table (multiple_mc[90,])) ## look at an iteration

## simulate a long chain
plot(one_mc <- sim_one_mc (2,1000) , type = "l")
## barplot of state distribution
barplot(table (one_mc[-(1:20)]))
## time correlation
acf (one_mc)

