source ("estimates.r")
coots <- read.csv ("coots.csv")

cluster_ratio_est (data = coots, 
                   cname = "clutch", csize = "csize", 
                   yvar = "length")



