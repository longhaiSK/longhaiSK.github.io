#' ---
#' title: "Introduction to Statistical Methods"
#' subtitle: "Normal Distribution"
#' author: "Longhai Li"
#' date: "September 2019"
#' output: 
#'    html_document:
#'        toc: true
#'        number_sections: true
#'        highlight: tango
#'        fig_width: 10
#'        fig_height: 8
#' ---


#' # Find normal cumulative distribution value and quantile

mu <- 2; sigma <- 5
x <- seq (mu - 4*sigma, mu + 4*sigma, length=100)
x
y <- dnorm (x, mean = mu, sd = sigma)
y
plot (x, y, type = "l")
pnorm (-6, mean = mu, sd = sigma)
pnorm (-4, mean = mu, sd = sigma)
pnorm (2, mean = mu, sd = sigma)
pnorm (7, mean = mu, sd = sigma)
qnorm (0.01, mean = mu, sd = sigma)
qnorm (c(0.05, 0.1, 0.4, 0.5, 0.6, 0.9, 0.95), mean = mu, sd = sigma)

#' # Convert non-standard normal to normal

x <- seq (-11,4, length = 100)
d1 <- dnorm (x)
d2 <- dnorm (x, mean = -6, sd = 2)


plot (x, d1, type = "l", main = "Two Normal Densities",xaxp = c(-11,4,15))
lines (x, d2, col = "red")

for (z in seq (-1, 1.5, length = 20))
{
    arrows (x0 = z, y0 = 0, y1 = dnorm (z), code = 0)
    arrows (x0= -6 + z * 2, y0 = 0, 
            y1 = dnorm (-6 + z * 2, mean = -6, sd = 2), 
            code = 0, col = "red")
}

abline (h = 0)	    

#' look at the equivalence of these numbers
mu <- 10
sigma <- 2

x <- 13

pnorm (x, mean = mu, sd = sigma)
z <- (x-mu)/sigma
pnorm (z, mean = 0, sd = 1)


y <- 8
pnorm (y, mean = mu, sd = sigma)
z <- (y-mu)/sigma
pnorm (z, mean = 0, sd = 1)


#' # Approximation of binomial with normal 

n <- 20; p <- 0.4
x <- 0:n


binom.x <- dbinom (x, size = n, p = p)
breaks <-  c(x - 0.5, n + 0.5)
hist.binom <- list (breaks = breaks, counts = binom.x) 
class (hist.binom) <- "histogram"
plot (hist.binom, main = "Binomial and Normal", xlab = "x")

x.norm <- seq (-0.5, n + 0.5, length = 200)
x.dnorm <- dnorm (x.norm, n*p, sqrt (n * p * (1-p)))
lines (x.norm, x.dnorm, col = "red" ) 

n <- 30; p <- 0.3
x <- 0:n


binom.x <- dbinom (x, size = n, p = p)
breaks <-  c(x - 0.5, n + 0.5)
hist.binom <- list (breaks = breaks, counts = binom.x) 
class (hist.binom) <- "histogram"
plot (hist.binom, main = "Binomial and Normal", xlab = "x")

x.norm <- seq (-0.5, n + 0.5, length = 200)
x.dnorm <- dnorm (x.norm, n*p, sqrt (n * p * (1-p)))
lines (x.norm, x.dnorm, col = "red" ) 

n <- 30; p <- 0.8
x <- 0:n


binom.x <- dbinom (x, size = n, p = p)
breaks <-  c(x - 0.5, n + 0.5)
hist.binom <- list (breaks = breaks, counts = binom.x) 
class (hist.binom) <- "histogram"
plot (hist.binom, main = "Binomial and Normal", xlab = "x")

x.norm <- seq (-0.5, n + 0.5, length = 200)
x.dnorm <- dnorm (x.norm, n*p, sqrt (n * p * (1-p)))
lines (x.norm, x.dnorm, col = "red" ) 


n <- 300; p <- 0.8
x <- 0:n


binom.x <- dbinom (x, size = n, p = p)
breaks <-  c(x - 0.5, n + 0.5)
hist.binom <- list (breaks = breaks, counts = binom.x) 
class (hist.binom) <- "histogram"
plot (hist.binom, main = "Binomial and Normal", xlab = "x")
x.norm <- seq (-0.5, n + 0.5, length = 200)
x.dnorm <- dnorm (x.norm, n*p, sqrt (n * p * (1-p)))
lines (x.norm, x.dnorm, col = "red" ) 

plot (hist.binom, main = "Binomial and Normal", xlab = "x", xlim = c(200,280))
x.norm <- seq (-0.5, n + 0.5, length = 200)
x.dnorm <- dnorm (x.norm, n*p, sqrt (n * p * (1-p)))
lines (x.norm, x.dnorm, col = "red" ) 

#' # Demonstration of the normal approximation for binomial

#' ## When n is small
n<- 30
p <- 0.3
mu <- n * p 
sigma <- sqrt(n * p * (1-p))

x <- c(3,3)
sum(dbinom (x[1]:x[2], size = n, p = p))
pnorm(x[2]+0.5, mu, sigma) - pnorm (x[1]-0.5, mu,sigma)

x <- c(3,10)
sum(dbinom (x[1]:x[2], size = n, p = p))
pnorm(x[2]+0.5, mu, sigma) - pnorm (x[1]-0.5, mu,sigma)


x <- c(12,15)
sum(dbinom (x[1]:x[2], size = n, p = p))
pnorm(x[2]+0.5, mu, sigma) - pnorm (x[1]-0.5, mu,sigma)

n<- 30
p <- 0.1
mu <- n * p 
sigma <- sqrt(n * p * (1-p))

x <- c(3,3)
sum(dbinom (x[1]:x[2], size = n, p = p))
pnorm(x[2]+0.5, mu, sigma) - pnorm (x[1]-0.5, mu,sigma)

x <- c(3,10)
sum(dbinom (x[1]:x[2], size = n, p = p))
pnorm(x[2]+0.5, mu, sigma) - pnorm (x[1]-0.5, mu,sigma)


x <- c(12,15)
sum(dbinom (x[1]:x[2], size = n, p = p))
pnorm(x[2]+0.5, mu, sigma) - pnorm (x[1]-0.5, mu,sigma)


#' ## When n is large
n<- 200
p <- 0.1
mu <- n * p 
sigma <- sqrt(n * p * (1-p))

x <- c(15,15)
sum(dbinom (x[1]:x[2], size = n, p = p))
pnorm(x[2]+0.5, mu, sigma) - pnorm (x[1]-0.5, mu,sigma)

x <- c(15,25)
sum(dbinom (x[1]:x[2], size = n, p = p))
pnorm(x[2]+0.5, mu, sigma) - pnorm (x[1]-0.5, mu,sigma)


x <- c(25,26)
sum(dbinom (x[1]:x[2], size = n, p = p))
pnorm(x[2]+0.5, mu, sigma) - pnorm (x[1]-0.5, mu,sigma)

