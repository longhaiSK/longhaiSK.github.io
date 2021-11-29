system ("rm ars_exams.o ars_exams.so")
system ("R CMD SHLIB ars_exams.c")
dyn.load ("ars_exams.so")

sample_tnorm <- function (n, lb = -Inf, ub = Inf, dars = 0)
{
  .C("R_sample_tnorm", n:n, rep (0, n), lb, ub, dars, NAOK = TRUE )[[2]]

}

sample_tnorm_naive <- function (n, lb = -Inf, ub = Inf)
{
  x <- rep (0, n)
  for (i in 1:n)
  {
    rej <- TRUE
    while (rej)
    {
      x[i] <- rnorm (1)
      if (x[i] >= lb & x[i] <= ub) rej <- FALSE
    }
  }
  x
}

sample_gamma <- function (n, alpha, lambda, dars = 0)
{
  .C ("R_sample_gamma", n:n, rep (0,n), alpha, lambda, dars, NAOK = TRUE)[[2]]
}

sample_tbeta <- function (n, alpha, beta, lb, ub, dars = 0)
{
  .C("R_sample_beta", n:n, rep (0,n), alpha, beta, lb, ub, dars) [[2]]
}


# testing codes
# n <- 10000
# system.time (x1 <- sample_tnorm (n, -3, 0,  dars = 1))
# # qqnorm (x1)
# hist (x1)
# plot (x1)

# n <- 5000
# system.time (x1 <- sample_gamma (n, 1, 1, 1))
# system.time (x2 <- rgamma (n, 1, 1))
# qqplot (x1, x2)


n <- 10000
system.time (x1 <- sample_tbeta (n, 2,2, 0, 1, dars = 1))
hist (x1)
plot (x1)
x2 <- rbeta (n, 2,2)
qqplot (x1, x2)
