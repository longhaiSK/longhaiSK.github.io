
# generate data on two variables
x1 <- rnorm (60, 20, 10)
x2 <- rnorm (60, 20, 30)
par (mfrow = c(1,2))
plot (x1, ylim = range (x1,x2))
plot (x2, ylim = range (x1,x2))
# draw boxplot separately, with ylim controling the y scale
boxplot (x1, ylim = range (x1,x2))
boxplot (x2, ylim = range (x1,x2))
# draw two variables in a single plot for comparison
adata <- data.frame (x1,x2)
boxplot (adata)


# read data
mental <- read.csv ("mental.csv") 
mean (mental$Pre.test)
median (mental$Pre.test)
range (mental$Pre.test)
var (mental$Pre.test)
sd (mental$Pre.test)
IQR (mental$Pre.test)

boxplot (mental$Post.test)
## draw comparison boxplot 
boxplot (Post.test ~ Treat, data = mental)
boxplot (Post.test - Pre.test ~ Treat, data = mental)


## quantiles for a toy dataset
x <- 1:5
x
plot (ecdf(x))
abline (h = seq (0,1, by = 0.05), lty = 1, col = "grey")
quantile (x)
quantile (x, seq (0,1,by = 0.05))
## draw quantiles with ecdf
points (quantile (x, seq (0,1,by = 0.05)), seq (0,1,by = 0.05), type = "b", col = "red")


## quantile for the dataset used in slides
y <- scan(text = "7  8  9 10 11 12 13 13 14 17 17 45")
quantile (y, probs = seq (0,1,by = 0.05))
# compare to the quantiles returned with the textbook formula
y[round(12*0.42,0)]
y[round(12*0.80,0)]
y[round(12*0.85,0)]
y[round(12*0.90,0)]

## quantile for a real dataset
plot (ecdf (mental$Pre.test))
abline (h = seq (0,1, by = 0.05), lty = 1, col = "grey")
rug (mental$Pre.test)

quantile (mental$Pre.test)
quantile (mental$Pre.test, probs = 0.05)
quantile (mental$Pre.test, probs = seq (0, 1, by = 0.1))
quantile (mental$Pre.test, probs = seq (0, 1, by = 0.01))
## draw quantiles with ecdf
points (quantile (mental$Pre.test, seq (0,1,by = 0.05)), seq (0,1,by = 0.05), type = "b", col = "red")
