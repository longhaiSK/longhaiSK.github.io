## Examples for finding optimal allocation
## Ex 3.10
Nh <- c(400, 30, 61, 18, 70, 120)
N <- sum (Nh)
Sh <- c(3, 2, 9, 2, 12, 1) * 10 
# Note: the textbook numbers are too far away from the survey data presented
# in  Ex 3.3, so I changed to the above numbers. 
Ch <- rep (1, 6)

NhShDCh <- Nh * Sh / sqrt (Ch)

Lh <- NhShDCh / sum (NhShDCh);Lh
n <- 225
nh <- n * Lh; nh

## determine sample size for given margine error
e <- 5247 # set desired margine error for mean estimate of herd size
Lh <- Lh # suppose we use the optimal allocation
Nh <- Nh
Sh <- Sh

# compute nu
nu <- sum ((Nh/N)^2 * Sh^2 / Lh) 
# necessiry sample size 
n <- nu * qnorm (0.975)^2 / e^2; n

n * Lh

samplesize_str <- function (e, Lh, Nh, Sh)
{
  nu <- sum ((Nh/N)^2 * Sh^2 / Lh) 
  # necessiry sample size 
  n <- nu * qnorm (0.975)^2 / e^2; n

  nh <- n * Lh
  
  list (n = n, nh = nh)
}
