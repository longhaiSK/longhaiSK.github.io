source ("estimates.r")
coots <- read.csv ("data/coots.csv")

cluster_ratio_est (data = coots, 
				   cname = "clutch", csize = "csize", 
				   yvar = "volume")


