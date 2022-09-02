############## find normal cumulative distribution value and quantile #########

mu <- 2; sigma <- 5
x <- seq (mu - 4*sigma, mu + 4*sigma, by = 0.01)
plot (x, dnorm (x, mean = mu, sd = sigma), type = "l")
pnorm (-6, mean = mu, sd = sigma)
pnorm (-4, mean = mu, sd = sigma)
pnorm (2, mean = mu, sd = sigma)
pnorm (7, mean = mu, sd = sigma)
qnorm (0.01, mean = mu, sd = sigma)
qnorm (c(0.05, 0.1, 0.4, 0.5, 0.6, 0.9, 0.95), mean = mu, sd = sigma)


############## the following is class demonstration code ######################
############## converting non-standard normal to standard normal###############
pdf ("normal.pdf")
x <- seq (-11, 4, length = 100)
d1 <- dnorm (x)
d2 <- dnorm (x, mean = -6, sd = 2)


plot (x, d1, type = "l", main = "Two Normal Densities",xaxp = c(-11,4,15))
lines (x, d2, col = "red")

for (z in seq (-1, 1.5, length = 40))
{
    arrows (x0 = z, y0 = 0, y1 = dnorm (z), code = 0)
    arrows (x0= -6 + z * 2, y0 = 0, 
            y1 = dnorm (-6 + z * 2, mean = -6, sd = 2), 
            code = 0, col = "red")
}

abline (h = 0)        

dev.off()
############### look at approximation of binomial with normal #################

n <- 20; p <- 0.4
x <- 0:n

pdf ("binom-normal.pdf")

binom.x <- dbinom (x, size = n, p = p)
breaks <-  c(x - 0.5, n + 0.5)
hist.binom <- list (breaks = breaks, counts = binom.x) 
class (hist.binom) <- "histogram"
plot (hist.binom, main = "Binomial and Normal", xlab = "x")

x.norm <- seq (-0.5, n + 0.5, length = 200)
x.dnorm <- dnorm (x.norm, n*p, sqrt (n * p * (1-p)))
lines (x.norm, x.dnorm, col = "blue" ) 

## demonstration the approximation

n<- 12
p <- 0.3
sum(dbinom (3:3, size = n, p = p))
mu <- n * p 
sigma <- sqrt(n * p * (1-p))

pnorm (130.5, mean = mu, sd = sigma) - pnorm (114.5, mean = mu, sd = sigma)

sum(dbinom (50:65, size = 400, p = 0.34))
mu <- 400 * 0.34
sigma <- sqrt(400 * 0.34 * 0.66)

pnorm (65.5, mean = mu, sd = sigma) - pnorm (49.5, mean = mu, sd = sigma)

dev.off()