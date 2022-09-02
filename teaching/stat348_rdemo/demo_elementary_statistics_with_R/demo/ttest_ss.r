# t.test_ss is a function for computing one sample or two sample t test from
# only summary statistic values, written by Longhai Li, 2012

# sx is summary information for x group, sy is summary for y group
# In sx and sy, the 1st is mean, the 2nd is sd, the 3rd is sample size
# mu0 is the hypothesized value for mu or mu_x - mu_y
t.test_ss <- function (
	sx, sy = NULL, mu0 = 0, var.equal = FALSE, level = 0.05, 
	altern = c("less", "greater","two.sided"))
{
  xbar <- sx[1]
  xsd <- sx[2]
  xn <- sx[3]
  
  if (!is.null (sy))
  {
	ybar <- sy[1]
	ysd <- sy[2]
	yn <- sy[3]
  }


  if (is.null (sy))
  {
	mu <- xbar
	sdmu <- xsd / sqrt (xn)
	tvalue <- (mu - mu0) / sdmu
	df <- xn - 1
  }
  else
  {
	if (var.equal == TRUE)
	{
	  df <- xn + yn - 2
	  sdpool <- sqrt ((xsd^2 * (xn - 1) + ysd^2 * (yn - 1))/df)
	  sdmu <- sdpool * sqrt (1/xn + 1/yn)
	  mu <- xbar - ybar
	  tvalue <- (mu - mu0) / sdmu
	}
	else
	{
	  sdmu <- sqrt(xsd^2/xn + ysd^2/yn)
	  df <- sdmu^4 / (xsd^4 / (xn^2 * (xn - 1)) + ysd^4 / (yn^2 * (yn - 1)))
	  mu <- xbar - ybar 
	  tvalue <- (mu - mu0) /sdmu
	}
  }
  
  if (altern [1] == "less") pvalue <- pt (tvalue, df = df)
  if (altern [1] == "greater") pvalue <- 1 - pt (tvalue, df = df)
  if (altern [1] == "two.sided") pvalue <- 2 * pt (-abs(tvalue), df = df)
  
  me <- - sdmu *  qt (level/2, df = df)
  
  cat(sprintf ("t = %f, df = %f\n\n", tvalue, df))
  cat(sprintf ("p-value = %f for testing: \nH0:mu=%f VS H1:mu %s %f\n\n", 
	  pvalue, mu0, altern [1], mu0))
  cat(sprintf ("CI for mu with confidence level %.2f is %f +- %f\n\n", 
	  1- level, mu, me))
}

# a simple test

x <- rnorm (30, 12, sd = 2)
sx <- c(mean (x), sd (x), 30)
y <- rnorm (40, 13, sd = 3)
sy <- c(mean (y), sd (y), 40)

# testing difference of two mus
t.test_ss (sx = sx, sy = sy, altern = "two.sided")

# testing one mu equalt to 11
t.test_ss (sx = sx, mu0 = 11, altern = "two.sided")

df_t <- function (s_1,n_1,s_2,n_2)
{
    (s_1^2/n_1 + s_2^2/n_2)^2 / 
    { {(s_1^2/n_1)^2 / { n_1 -1}} + {(s_2^2/n_2)^2 / { n_2 -1 }}
    }
}

df_t (8,100,10,100)
