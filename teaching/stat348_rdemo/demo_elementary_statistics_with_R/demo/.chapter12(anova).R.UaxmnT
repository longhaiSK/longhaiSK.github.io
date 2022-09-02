## the code is for class demonstration only

oneway.anova <- function (m.i, v.i, n.i)
{
    n <- sum (n.i)
    df1 <- length (m.i) - 1
    df2 <- n - length (m.i)
    xbar <- sum(m.i * n.i)/n
    SSB <- sum (n.i*(m.i-xbar)^2)
    SSW <- sum ((n.i-1)*v.i)
    MSB <- SSB/df1
    MSW <- SSW/df2
    f <- MSB/MSW
    pv <- pf (f, df1,df2, lower = FALSE)
    
    list (
        xbar = xbar,
        SSB = SSB,
        SSW = SSW,
        MSB = MSB,
        MSW = MSW,
        df = c(df1,df2),
        F=f,
        p_value = pv
    )
}

m.v.n <- function (x) c(mean (x), var (x), length (x))

pdf ("anova.pdf", width = 10, height = 10)

## when three means are unequal
mu1 <- 170
mu2 <- 175
mu3 <- 180

X <- rnorm (100000, mu1, 10)
Y <- rnorm (100000, mu2, 10)
Z <- rnorm (100000, mu3, 10)

plim <- range (X,Y)

par (mfrow = c(3,1))
hist (X, main = "Population 1", xlim = plim)
abline (v = mu1, lwd = 4)
hist (Y, main = "Population 2", xlim = plim, col = "red")
abline (v = mu2, lwd = 4)
hist (Z, main = "Population 3", xlim = plim, col = "green")
abline (v = mu3, lwd = 4)

## sample size = 20
m.v.n_x <- replicate (500, m.v.n(sample (X, size = 20, replace = T) ) )
m.v.n_y <- replicate (500, m.v.n(sample (Y, size = 20, replace = T) ) )
m.v.n_z <- replicate (500, m.v.n(sample (Z, size = 20, replace = T) ) )

par (mfrow = c(1,1))

xlim <- range (m.v.n_x[1,], m.v.n_y[1,],m.v.n_z[1,])

plot (m.v.n_x[1,], 1:500, col = 1, pch = 1, xlim = xlim, xlab = "xbar",
      main = "sampling distribution of three sample means when some pop means unequal (H_1)")
points (m.v.n_y[1,], 1:500, col = 2, pch = 1)

points (m.v.n_z[1,], 1:500, col = 3, pch = 1)

m.v.n_xyz <- abind (m.v.n_x, m.v.n_y, m.v.n_z, along = 3)

Fvalues_H1 <- rep (0, 500)
for (i in 1:500) Fvalues_H1[i] <- oneway.anova (m.v.n_xyz[1,i,],m.v.n_xyz[2,i,],m.v.n_xyz[3,i,])$F






## when three means are equal
mu1 <- 175
mu2 <- 175
mu3 <- 175

X <- rnorm (100000, mu1, 10)
Y <- rnorm (100000, mu2, 10)
Z <- rnorm (100000, mu3, 10)

plim <- range (X,Y)

par (mfrow = c(3,1))
hist (X, main = "Population 1", xlim = plim)
abline (v = mu1, lwd = 4)
hist (Y, main = "Population 2", xlim = plim, col = "red")
abline (v = mu2, lwd = 4)
hist (Z, main = "Population 3", xlim = plim, col = "blue")
abline (v = mu3, lwd = 4)

## sample size = 20
m.v.n_x <- replicate (500, m.v.n(sample (X, size = 20, replace = T) ) )
m.v.n_y <- replicate (500, m.v.n(sample (Y, size = 20, replace = T) ) )
m.v.n_z <- replicate (500, m.v.n(sample (Z, size = 20, replace = T) ) )

par (mfrow = c(1,1))


plot (m.v.n_x[1,], 1:500, col = 1, pch = 4, xlim = xlim, xlab = "xbar",
      main = "sampling distribution of three sample means when all pop means equal (H_0)")
points (m.v.n_y[1,], 1:500, col = 2, pch = 4)

points (m.v.n_z[1,], 1:500, col = 3, pch = 4)

m.v.n_xyz <- abind (m.v.n_x, m.v.n_y, m.v.n_z, along = 3)

Fvalues_H0 <- rep (0, 500)
for (i in 1:500) Fvalues_H0[i] <- oneway.anova (m.v.n_xyz[1,i,],m.v.n_xyz[2,i,],m.v.n_xyz[3,i,])$F

flim <- range (Fvalues_H0, Fvalues_H1)
par (mfcol=c(2,1))
plot (Fvalues_H0, 1:500, pch = 4, xlim = flim, main = "Distribution of F when H_0 is true" )
plot (Fvalues_H1, 1:500, pch = 1, xlim = flim, main = "Distribution of F when H_1 is true" )

par (mfcol=c(2,1))
plot (density(Fvalues_H0), pch = 4, xlim = flim, main = "Distribution of F when H_0 is true" )
plot (density(Fvalues_H1), pch = 1, xlim = flim, main = "Distribution of F when H_1 is true")

dev.off()