
# generate a dataset
n <- 1000
x <- seq (0, 2*pi, length = n)
mu <- exp (-1 + 2*sin(2*x))
y <- rpois(length (x), mu)
uy <- sort(unique(y)) ## unique values in y

# define col representation for different values of y
col <-  rainbow(length (uy), s=1, start=0, end = 0.7)

# fit the true model
fit.r <- glm(y~sin(2*x), family = "poisson") 
mu.r <- fit.r$fitted.values
# fit a wrong model
fit.w <- glm(y~x, family = "poisson") 
mu.w <- fit.w$fitted.values

#draw plots
#pdf("rainbowplot1.pdf", width=7, height=9)

par(mfrow = c(4,2),mar=c(4.5, 4.5, 2, 1))

#=============================================
# RPP
#=============================================

## RPP for the true model: 
RPP <- ppois(y-1, lambda = mu.r)+runif(n)*dpois(y, lambda = mu.r)

plot (x,rep (0.5, length (x)), ylim = c(0, 1), 
      type = "n", 
      ylab="RPP", xlab="x")

title("RPP, True Model")
k <- length (uy)
upper <- matrix (0,k, n)

for (i in 1:length (uy))
{
  upper[i,] <- ppois(uy[i], lambda = mu.r)
  lines(x, upper[i,], lty = 1, lwd=1,col = "black" )
}
points(x, RPP, col = col[match (y, uy)], pch = 20, cex=0.6)

#RPP for the wrong model
RPP <- ppois(y-1, lambda = mu.w)+runif(n)*dpois(y, lambda = mu.w)


plot (x, rep (0.5, length (x)), ylim = c(0, 1), 
      type="n",  ylab="RPP", xlab="x")

title("RPP, Wrong Model")
k <- length (uy)
upper <- matrix (0,k, n)

for (i in 1:length (uy))
{
  upper[i,] <-  ppois(uy[i], lambda = mu.w) 
  lines(x, upper[i,], lty = 1, col = "black" )


}
points (x, RPP, col = col[match (y, uy)], pch = 20, cex=0.6)


#=============================================
# MQR 
#=============================================

### MQR for the True model: 
MPP <- ppois(y-1, lambda = mu.r)+0.5*dpois(y, lambda = mu.r)

plot (x,rep (0.5, length (x)), ylim = c(0, 1), type = "n", 
       ylab="MPP", xlab="x" )
title("MPP, True Model")
k <- length (uy)
upper <- matrix (0,k, n)
 
for (i in 1:length (uy))
{
  upper[i,] <- ppois(uy[i], lambda = mu.r)
  lines(x, upper[i,], lty = 1, col = "black" )

}
points(x, MPP, col = col[match (y, uy)], pch = 20, cex=0.6)

### MQR for the Wrong model: 

MPP<- ppois(y-1, lambda = mu.w)+0.5*dpois(y, lambda = mu.w)
plot (x, rep (0.5, length (x)), 
      ylim = c(0, 1), 
      type="n",  ylab="MPP", xlab="x")
title("MPP, Wrong Model")
k <- length (uy)
upper <- matrix (0,k, n)

for (i in 1:length (uy))
{
  upper[i,] <-  ppois(uy[i], lambda = mu.w) 
  lines(x, upper[i,], lty = 1, col = "black" )
}
points (x, MPP, col = col[match (y, uy)], pch = 20, cex=0.6)

#=============================================
# Deviance 
#=============================================
res.deviance.r <- resid(fit.r,"deviance")
res.deviance.w <- resid(fit.w,"deviance")

plot (x, res.deviance.r, ylim = range (res.deviance.r), 
      col = col[match (y, uy)], pch = 20, ylab="Deviance", 
      main="Deviance, True Model", cex=0.6)

plot (x, res.deviance.w, ylim = range (res.deviance.w), 
      col = col[match (y, uy)], pch = 20, ylab="Deviance", 
      main="Deviance, Wrong Model", cex=0.6)

#=============================================
# Pearson for true model 
#=============================================
res.pearson.r <- resid(fit.r,"pearson")
res.pearson.w <- resid(fit.w,"pearson")

plot (x, res.pearson.r, ylim = range (res.pearson.r), 
      col = col[match (y, uy)], pch = 20, ylab="Pearson", 
      main="Pearson, True Model", cex=0.6)
#=============================================
# Pearson for wrong model 
#=============================================
plot (x, res.pearson.w, ylim = range (res.pearson.w), 
      col = col[match (y, uy)], pch = 20, ylab="Pearson", 
      main="Pearson, Wrong Model", cex=0.6)

#dev.off()


