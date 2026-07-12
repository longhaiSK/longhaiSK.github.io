library ("R2jags")

############################# define the model for jags #######################
regmodel <- '
model{
beta0 ~ dnorm (0, 0.000001)
beta1 ~ dnorm (0, 0.000001)
beta2 ~ dnorm (0, 0.000001)
for (i in 1:n)
{
  y[i] ~ dbern (ilogit(beta0 + beta1 * x1[i] + beta2 * x2[i]))
}

}

'

write (regmodel, file = "regmodel.bug")

##################### use jags to simulate MCMC ###############################

ilogit <- function (x) 1/(1 + exp (-x))
x1 <- rnorm (100, 0, 1)
x2 <- rnorm (100, 0, 1)
y <- rbinom (100, 1, ilogit(0.5 + x1 + x2))
data <- list (x1 = x1, x2 = x2, y = y, n = 100)


# define a function to generate initial values for parameters
inits <- function ()
{
  list (beta0 = 0, beta1 = 0, beta2 = 0)
}
# call jags to simulate MCMC
fitj <- jags (model.file = "regmodel.bug",
				data = data, inits = inits, 
        parameters = c("beta0", "beta1","beta2"),
				n.chains = 4, n.thin = 1, n.burnin = 1000, 
        n.iter = 11000)
traceplot (fitj)

# summary mcmc fit 
fitj

fitj.mcmc <- as.mcmc (fitj)

fitj.matrix <- as.matrix (fitj.mcmc)

plot (fitj.matrix[1:100,2:3], type = "b")
