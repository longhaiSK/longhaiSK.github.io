# read population data 
agpop <- read.csv ("data/agpop.csv")

plot (agpop [, "acres87"], agpop [, "acres92"])
cor (agpop [, "acres87"], agpop [, "acres92"])

pdf ("Ratio_Reg_est/ratio_agpop_sim.pdf")
# sample size
n <- 300
# population size
N <- nrow (agpop)

# true values that we want to estimate
tyU <- sum (agpop [,"acres92"])
# suppose known for ratio estimate
txU <- sum (agpop [,"acres87"]) 

# srs sampling
srs <- sample (N,n)
# survey
y_srs <- agpop [srs, "acres92"]
x_srs <- agpop [srs, "acres87"]

# simple estimate
simple_est <- mean (y_srs) * N 
# ratio estimate
B_hat <- mean (y_srs) / mean (x_srs)
ratio_est <-  B_hat * txU

abs (simple_est - tyU ) / tyU ## relative error of simple estimate
abs (ratio_est - tyU) / tyU ## relative error of ratio estimate

## repeat 5000 times
sim_rat <- data.frame (
	simple = rep (0, 10000), ratio = rep (0, 10000), B = rep (0, 10000))

for (i in 1:10000)
{
  srs <- sample (N,n)
  y_srs <- agpop[srs, "acres92"]
  x_srs <- agpop[srs, "acres87"]

  # simple estimate
  sim_rat$simple [i] <- mean (y_srs) * N 
  # ratio estimate
  sim_rat$B [i] <- mean (y_srs) / mean (x_srs)
  sim_rat$ratio [i] <-  sim_rat$B [i] * txU
}

boxplot (sim_rat [, 1:2])
abline (h = tyU, col = "red")

comp_vars <- apply (sim_rat, 2, var)
comp_vars[1]/comp_vars[2]


boxplot (sim_rat $ B)
abline (h = tyU/txU, col = "red")


dev.off()
