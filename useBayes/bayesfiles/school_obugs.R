library(R2OpenBUGS)

if (!exists ("ifold")) ifold <- 1

#schools data in the R2OpenBUGS library
data(schools)

#prepare the data for input into OpenBUGS
J <- nrow(schools)
y <- schools$estimate
sigma.y <- schools$sd
data <- list ("J", "y", "sigma.y")

#initialization of variables
inits <- function(){
  list(theta = rnorm(J, 0, 0), mu.theta = rnorm(1, 2, 0), 
  sigma.theta = runif(1, 1, 1))}


#these are the parameters to save
parameters = c("theta", "mu.theta", "sigma.theta")

nummodel <- '
model
{
    for (j in 1:J) {
        y[j] ~ dnorm(theta[j], tau.y[j])
        theta[j] ~ dnorm(mu.theta, tau.theta)
        tau.y[j] <- pow(sigma.y[j], -2)
    }
    mu.theta ~ dnorm(0.00000E+00, 1.00000E-06)
    tau.theta <- pow(sigma.theta, -2)
    sigma.theta ~ dunif(0.00000E+00, 1000)
}
'

write (nummodel, file = "nummodel.txt")
#run the model
schools.sim <- bugs(data, inits, 
model.file = "nummodel.txt",parameters=parameters, 
n.chains = 3, n.iter = 1000,bugs.seed = 14)

cat (schools.sim$DIC, file = sprintf("DIC%d.txt", ifold))

pdf (sprintf("fitplot%d.pdf", ifold) )

plot (schools.sim)

dev.off()

