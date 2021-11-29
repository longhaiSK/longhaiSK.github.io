## authors: Longhai Li, Shi Qiu, Cindy Feng, 2016
## accompanying publication: Longhai Li, Cindy X. Feng, and Shi Qiu*, (2017+), Estimating Cross-validatory Predictive P-values with Integrated Importance Sampling for Disease Mapping Models. arXiv:1603.07668, Statistics in Medicine, available from the following URL:
## http://onlinelibrary.wiley.com/doi/10.1002/sim.7278/full


## load R package "R2OpenBUGS"
library("R2OpenBUGS")

##################################################################################
################### OpenBUGS fitting for Germany larynx data #####################
##################################################################################

## Load data for MCMC simulation
##################################################################################
## Germany dataset is available from 
## http://math.usask.ca/longhai/software/dmpvalues/larynxdata.zip
## download the above zip file and unzip them into directory called larynxdata. 
##################################################################################

O = dget ("larynxdata/Y.txt")
E = dget ("larynxdata/E.txt")
X= dget ("larynxdata/X.txt")
adj = dget ("larynxdata/adj.txt")
num = dget("larynxdata/num.txt")
N <- length (O)
sumNumNeigh <- sum (num)

data <- list(N=N,sumNumNeigh=sumNumNeigh,O=O,E=E,X=X,adj=adj,num=num)


## define BUGS model
## alpha --- intercept.
## prec ---  a scalar, inverse variance,ie, 1/tau^2 in the paper
## beta --- a latent variable for linear effect with covariate X.
## theta --- the linear predictor
## gamma --- spatial strength, ie, phi in the paper
model <- '
model {
    for(i in 1 : N)  m[i] <- 1/E[i] 
    cumsum[1] <- 0
    for(i in 2:(N+1)) cumsum[i] <- sum(num[1:(i-1)])
    
    for(k in 1 : sumNumNeigh) {
        for(i in 1:N) {
            pick[k,i] <- step(k - cumsum[i] - epsilon) * step(cumsum[i+1] - k)
        }
        C[k] <- sqrt(E[adj[k]] / inprod(E[], pick[k,]))
    }
    epsilon <- 0.0001
    for (i in 1 : N) {
        O[i] ~ dpois(mu[i])
        log(mu[i]) <- log(E[i]) + S[i]
        RR[i] <- exp(S[i])
        theta[i] <- alpha + beta*X[i]/100
    }
    # Proper CAR prior distribution for spatial random effects:
    S[1:N] ~ car.proper(theta[], C[], adj[], num[], m[], prec, gamma)
    # Other priors:
    alpha ~ dnorm(0, 0.0001)
    beta ~ dnorm(0, 0.001)
    prec ~ dgamma(0.5, 0.0005)
    v <- 1/prec
    sigma <- sqrt(1 / prec)
    gamma.min <- min.bound(C[], adj[], num[], m[])
    gamma.max <- max.bound(C[], adj[], num[], m[])
    gamma ~ dunif(gamma.min, gamma.max)
}'
write(model, "model_propcar_full.txt")

inits <- function() {
    list(alpha = rnorm(1,0,2), prec = runif(1,0.1,2), gamma =0,S = rep(0,N), 
         beta=rnorm(1,5,5))
}

parameters<-c("alpha","S","sigma","prec","gamma" ,"beta","theta")

## nIter --- number of iterations for each chain of MCMC simulation
## nBur --- number of iterations for burning
nIter <- 3000
nBur <- 500

## fit data with openbugs
fit<-bugs(data,inits,parameters, n.iter = nIter, 
          model.file='model_propcar_full.txt',
          n.chains=2, n.thin=10, n.burnin = nBur, DIC=TRUE, 
          bugs.seed = sample(1:14,1))
## save MCMC samples for future use
save.image (file = "propcar_larynx.RData") 

##################################################################################
###################### Compute predictive p-values ###############################
##################################################################################

library("R2OpenBUGS")

## load MCMC samples and original data
load ("propcar_larynx.RData") 

## attach names in 'data' for directly access
attach(data)

## extract MCMC samples of different variables
mcmc<-fit$sims.matrix 
Sims <- nrow (mcmc) ## number of MCMC samples
alpha_hat<-mcmc[,"alpha"]
beta_hat<-mcmc[,"beta"]
gamma_hat<-mcmc[,"gamma"]
prec_hat<-mcmc[,"prec"]
sigma_hat<-mcmc[,"sigma"]
S_hat<-mcmc[,sprintf("S[%d]",c(1:N))]
theta_hat<-mcmc[,sprintf("theta[%d]",c(1:N))]

## define vectors to store predictive pvalues
p_ghost <- p_iis <-p_nis <- p_post <- rep(0,N)


# compute iIS predictive p_value ------------------------------------------


## define C matrix representing spatial dependency
C <- table(adj,rep(1:N,num))
for(i in 1:N){
    for(j in 1:N){
        C[i,j]<-sqrt(C[i,j]*E[j]/E[i])
    }
}


## number of re-sampling (replicated) latent variables in iIS
R <- 50 
for( i in 1:N )
{
    Iweight_rep <- rep(0,Sims) ## a vector holding integrated importance weights 
    Ip_value_rep <- rep(0,Sims) ## a vector holding integrated p-values 
    
    for(k in 1:Sims) 
    {
        ## the mean of the conditional distribution of S_i
        mu_S <- 
            theta_hat[k,i] + gamma_hat[k]*sum(C[i,]*(S_hat[k,]-theta_hat[k,]))
        ## the standard error of the conditional distribution of S_i
        sigma_S <- 1/sqrt(prec_hat[k]*E[i])
        
        ## compute integrated weight 
        ## generate new S_i for computing integrated weight
        S_rep_w <-rnorm(R, mu_S,sigma_S)
        mu_rep_w <- exp(S_rep_w) * E[i] 
        Iweight_rep[k] <- 1/mean(dpois(O[i], mu_rep_w))
        
        ## compute integrated p-value            
        S_rep_A <- rnorm(R, mu_S,sigma_S)
        mu_rep_A <- exp(S_rep_A) * E[i]
        Ip_value_rep[k] <- mean(ppois(O[i], mu_rep_A,lower.tail=FALSE)) + 
            mean(dpois(O[i],mu_rep_A)) * 0.5
    }
    ## compute iIS p-values
    p_iis [i] <- sum(Ip_value_rep * Iweight_rep) / sum (Iweight_rep)
}


# compute ghosting p-values ---------------------------------------------

for (i in 1:N)
{
    Np_value_rep <- rep(0, Sims) ## a vector holding new p-values
    for (k in 1:Sims)
    {
        ## the mean of the conditional distribution of S_i
        mu_S <-
            theta_hat[k,i]+gamma_hat[k]*sum(C[i, ]*(S_hat[k, ]-theta_hat[k, ]))
        ## the standard error of the conditional distribution of S_i
        sigma_S <- 1 / sqrt(prec_hat[k] * E[i])
        
        ## generate a new S
        S_rep_A <- rnorm(1, mu_S, sigma_S)
        mu_rep_A <- exp(S_rep_A) * E[i]
        Np_value_rep[k] <-
            mean(ppois(O[i], mu_rep_A, lower.tail = FALSE)) +
            mean(dpois(O[i], mu_rep_A)) * 0.5
    }
    p_ghost [i] <- mean (Np_value_rep)
}



# compute p-values with non-integrated importance sampling  ---------------


for (i in 1:N){
    mu_hat <- exp(S_hat[,i]) * E[i]
    prob_hat <- dpois(O[i], mu_hat)
    weight_hat<- 1/prob_hat
    p_value_hat<- ppois(O[i], mu_hat,lower.tail=FALSE) + 0.5*dpois(O[i],mu_hat)
    p_nis[i] <-  sum(p_value_hat * weight_hat) / sum (weight_hat)
}

# compute p-values with posterior predictive checking ---------------------
for (i in 1:N){
    mu_hat <- exp(S_hat[,i]) * E[i]
    p_value_hat<- ppois(O[i], mu_hat,lower.tail=FALSE) + 0.5*dpois(O[i],mu_hat)
    p_post[i] <-  mean(p_value_hat)
}




