library (rstan)
code <- '
  data {
    int<lower=0> T;
    vector[T] y;
  }

  parameters { 
    real mu;
    real<lower=0,upper=1> phis;
    real<lower=0.01> tausq;
    real h0;
    vector[T] h;
  }

  transformed parameters {
    real phi;
    real<lower=0> tau;
    phi <- 2*phis - 1;
    tau <- sqrt(tausq);
  }

  model {
    
    mu ~ normal(-10,5);
    phis ~ beta(20, 1.5);
    tausq ~ inv_gamma(2.5, 0.025);
    h0 ~ normal(mu, tau);
    h[1] ~ normal(mu + phi*(h0-mu), tau);
    for (t in 2:T)
      h[t] ~ normal(mu + phi*(h[t-1]-mu), tau);
    for (t in 1:T)
      y[t] ~ normal(0,exp(h[t]/2)); 
  }

  generated quantities {
    vector[T] log_lik;
    for (t in 1:T){
      log_lik[t] <- normal_log (y[t], 0 ,exp (h[t]/2)  );
    }
  }
'

N <- 500
mu <- 3
phi <- 0.3
tau <- 1
h0 <- 2
y<- h <- rep (0, N)
h[1] <- rnorm (1, mu + phi * (h0 - mu), tau)
for (i in 2:N) h[i] <- rnorm (1,mu + phi* (h[i-1] - mu), tau)
for (t in 1:N) y[t] <-  rnorm (1, 0, exp (h[t]/2) )

fit <- stan(model_code = code, 
            data = list(y = y, T = N), 
    	    iter = 5000, chains = 4)
print(fit)

extract (fit) -> fit.list

traceplot (fit)
