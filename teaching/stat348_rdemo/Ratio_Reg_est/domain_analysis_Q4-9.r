# read survey data
agsrs <- read.csv ("data/agsrs.csv")
# source ratio estimate function
source ("estimates.r")

domaina <- 1 * (agsrs$farms92 < 600) ## x in ratio estimate
y_star <- agsrs$acres92 * domaina

View(cbind (y = agsrs$acres92, agsrs$farms92, domain = domaina, y_star= y_star))

####################### Domain Analysis for Mean ########################
## call ratio estimate function to y_star
srs_ratio_est (y_star, domaina, N = 3078)

####################### Domain Analysis for Total ########################
## call simple srs estimate to y_star (without knowing N_d)
srs_est (y_star, N = 3078) * 3078
## if N_d is known, we should
# srs_ratio_est (y_star, domaina, N = 3078) * N_d


#################### with another domain ################################

domainb <- 1 * (agsrs$farms92 >= 600) ## x in ratio estimate
y_star <- agsrs$acres92 * domainb ## y in ratio or srs simple estimate

####################### Domain Analysis ##################################
srs_ratio_est (y_star, domainb, N = 3078) ## for mean
srs_est (y_star, N = 3078) * 3078 ## for total
