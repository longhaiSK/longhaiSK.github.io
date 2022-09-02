
# illustration of the concept of variance
# ignore this part if you don't want to learn
# generate data on two variables
pdf ("variance.pdf")

x1 <- rnorm (60, 20, 10)
x2 <- rnorm (60, 20, 30)

par (mfrow = c(1,2))
plot (x1, ylim = range (x1,x2))
abline (h = mean(x1))
for (i in 1:length (x1)) lines (c(i,i), c(mean(x1), x1[i]))
plot (x2, ylim = range (x1,x2))
abline (h = mean(x2))
for (i in 1:length (x2)) lines (c(i,i), c(mean(x2), x2[i]))

dev.off()
