if (!exists ("ifold")) ifold <- 1 ## for other purposes, ignore!

library ("R2jags")

############################# define the model for jags #######################
normmodel <- '
model{
	mu ~ dnorm (0, 0.000001)
	prec ~ dgamma (1, 0.000001)
	for (i in 1:n)
	{
		x[i] ~ dnorm(mu,prec)
	}
	sigma <- 1/sqrt(prec)
}

'

write (normmodel, file = "normmodel.bug")

##################### use jags to simulate MCMC ###############################
# give a list of names of R objects that will be fixed during MCMC sampling
data <- list (x = rnorm (100, 100, 5), n = 100)


# define a function to generate initial values for parameters
inits <- function ()
{
  list (mu = rnorm (1, 10, 0), prec = (1/10)^2)
}
# call jags to simulate MCMC
fitj <- jags (model.file = "normmodel.bug",
				data = data, inits = inits, 
        parameters = c("mu", "sigma"),
				n.chains = 4, n.thin = 1, n.burnin = 1000, n.iter = 11000)


traceplot (fitj, varname = "mu", xlim = c(1, 10))
# summary mcmc fit 
fitj

######################### using MCMC samples ################################

# plot the markov chain for the mu0 in the 1st chain 
pdf (sprintf("mctrace%d.pdf", ifold))

traceplot (fitj)

# convert to MCMC object
as.mcmc (fitj) -> fitj.mcmc

summary (fitj.mcmc)

# the first chain
fitj.chain1 <- fitj.mcmc[[1]]

# all chains
fitj.matrix <- as.matrix (fitj.mcmc)

# traceplot
traceplot (fitj.mcmc)

plot(fitj.chain1[,2:3])

# scatterplot
plot(fitj.matrix[,2:3])

dev.off ()

