library ("R2jags")
library ("MASS")

# user should provide ifold
if (!exists ("ifold")) ifold <- 1
mixmodel <- '
var
N,           # number of observations
K,           # number of components
y[N],        # observations
Z[N],        # true groups (labelled 1,2)
mu[K],       # means of two groups
tau.mu,     	 # prior precision for mu
tau[K],      # sampling precision
sigma[K],    # sampling standard deviation
P[K],        # proportion in first group
alpha[K],    # prior parameters for proportions
ind[N,K],    # indicator function for group membership
tol[K],      # total number of observations in each group
Itot[K];     # Censored indicator for tot (1 if tot[i] > 0; 0 otherwise)


model {
    for (k in 1:K){
        mu[k]  ~ dnorm(20, 1.0E-4);
        tau[k] ~ dgamma(0.01, 0.01 * 20);
        sigma[k]     <- 1/sqrt(tau[k]);
    }
    P[]    ~ ddirch (alpha[]);    # prior for mixing proportion
    for (i in 1:N){
        y[i]  ~ dnorm(mu[Z[i]],tau[Z[i]]);       
        Z[i]  ~ dcat(P[]);
        for (k in 1:K) {
            ind[i,k] <- (Z[i] == k);
        }
    }
    for (k in 1:K) {
        tot[k] <- sum(ind[,k]);
        Itot[k] ~ dinterval(tot[k], 0);
    }
    
    for (i in 1:N){
        logp.tr [i] <- log (dnorm (y[i], mu[Z[i]], tau[Z[i]]));   
    }
    
} 
'

write (mixmodel, file = "mixmodel.jags")



K <- 2 ## number of components

y <- scan ("y.txt")
N <- length (y)
Itot <- rep (1, K)
alpha <- rep (1, K)

eyesdata <- list ( y = y, K = K, N = N, Itot = Itot, alpha = alpha)

inits <- function ()
{
    list (#mu = rnorm (K, mean (y),20), 
          #tau = rep(1/var (y),K), 
          Z = sample (1:K, N, replace = T) )
}

mixmodel.jags <- jags (data = eyesdata,  inits = inits, model.file = "mixmodel.jags", 
			parameters =  c("P", "mu","sigma"),       
            n.thin = 5, n.iter = 5000, n.chain = 2)

mixmodel.mcmc <- as.mcmc (mixmodel.jags)

summary (mixmodel.mcmc)

traceplot (mixmodel.mcmc)
