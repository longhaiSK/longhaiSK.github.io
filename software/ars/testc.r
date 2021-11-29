system ("rm ajs.o ajs.so")
system ("R CMD SHLIB ajs.c")
dyn.load ("ajs.so")

n <- 1000

hist(.C("sample_elin",
        as.integer (n), -Inf, 0, .1, rep (0,n), 1E-10, NAOK = TRUE)[[5]])

qqplot(.C("sample_elin",
        as.integer (n), 0, Inf, -1, rep (0,n), 1E-10, NAOK = TRUE)[[5]],
        rexp(1000))

qqplot(.C("sample_elin",
        as.integer (n), -Inf, 1, 1, rep (0,n), 1E-10, NAOK = TRUE)[[5]],
        - rexp(1000) + 1)

system ("rm ajs.o ajs.so")
system ("R CMD SHLIB ajs.c")
dyn.load ("ajs.so")

.C("logint_elin", -2000, -10, 0, 0, Inf, 0,  1E-10, NAOK = TRUE)[[6]]

system ("rm ajs.o ajs.so")
system ("R CMD SHLIB ajs.c")
dyn.load ("ajs.so")

.C("interc", 0, -1, 1, -2, 2, 1, -1)

system ("rm testc.o testc.so")
system ("R CMD SHLIB testc.c")
dyn.load ("testc.so")

.C("mycall", 0)

system ("rm ajs.o ajs.so")
system ("R CMD SHLIB ajs.c")
dyn.load ("ajs.so")

system ("rm ajs_norm.o ajs_norm.so")
system ("R CMD SHLIB ajs_norm.c")
dyn.load ("ajs_norm.so")
n <- 1000
sample_tnorm <- function (n, lb, ub)
{
  cout <- .C("sample_tnorm", as.integer (n), rep (0, n), 1, lb, ub, NAOK = T )

  x <- cout[[2]]
  attr (x, "rate.rej") <- cout[[3]]
  x
}
sample_tnorm_naive <- function (n, lb, ub)
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
n <- 1000
lb <- -Inf
ub <- 0
x1 <- sample_tnorm (n, lb, ub)
x2 <- sample_tnorm_naive (n, lb, ub)
qqplot (x1,x2)
