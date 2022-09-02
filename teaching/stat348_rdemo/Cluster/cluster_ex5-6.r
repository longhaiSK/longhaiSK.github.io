## solutions to example 5.6

source ("estimates.r")
algebra <- read.csv ("data/algebra.csv")

## find cluster total
cluster_ratio_est (data = algebra, 
				   cname = "class", csize = "Mi", yvar = "score", N = 187)
