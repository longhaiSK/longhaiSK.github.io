pdf ("reg-inference.pdf",width  = 10)

beta <- 1.5

x <- runif (1000,110,130)
y <- 10 + beta * x + rnorm (1000,0,10)

plot (x, y, cex = 1.5, main = "population with true B = 1.5", col = "grey" )
abline (a = 10, b = beta, lwd = 4, col = "grey" )

replicate (5,
{
    plot (x, y, cex = 1.5, main = "population with true B = 1.5" , col = "grey" )
    abline (a = 10, b = beta, lwd = 4, col = "grey" )
    
    id.sample <- sample (1:1000, 30)

    points (x[id.sample], y[id.sample], pch = 4, col = "red", cex = 1.5 ) 
    abline (lm (y[id.sample] ~ x[id.sample]), col = "red", lwd = 4)

    summary (lm (y[id.sample] ~ x[id.sample]))
}
)


beta <- 0

x <- runif (1000,110,130)
y <- 10 + beta * x + rnorm (1000,0,10)

plot (x, y, cex = 1.5, main = "population with true B = 0", col = "grey"  )
abline (a = 10, b = beta, lwd = 4, col = "grey" )

replicate (5,
{
    plot (x, y, cex = 1.5, main = "population with true B = 0" , col = "grey" )
    abline (a = 10, b = beta, lwd = 4, col = "grey" )
    
    id.sample <- sample (1:1000, 30)
    
    points (x[id.sample], y[id.sample], pch = 4, col = "red", cex = 1.5 ) 
    abline (lm (y[id.sample] ~ x[id.sample]), col = "red", lwd = 4)
    
    summary (lm (y[id.sample] ~ x[id.sample]))
}
)

dev.off()

