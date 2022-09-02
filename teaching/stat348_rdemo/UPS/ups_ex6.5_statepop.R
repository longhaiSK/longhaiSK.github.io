source ("estimates.r")
## true value of total number of physicians is 532638 in 1990
################### Hanzen-Hurvitz analysis with UPS sample ##############
# read ups sample of size 100
statepop <- read.csv ("statepop.csv")

M0 <- 255077536 ## pop of USA in 1992
popn <- statepop$popn ## pop per county in 1992
psi <- popn / M0
phys <- statepop$phys

# estimate the total number of physicians in USA
upswr_total_est (phys, psi)

# estimate number of physicians per capita
upswr_ratio_est (phys, popn, psi)

pdf ("ups_ex6.5.pdf")

plot (psi, phys)

hist (phys/psi, nclass = 10)

dev.off ()

############# results ignoring drawing probabilities (wrong!) ############
# estimate total number of physicians in USA using naive estimate
srs_mean_est (phys) * 3141 ##3141 is the number of counties in USA (from Q4.11)

# estimate number of physicians per capital
srs_ratio_est (phys, popn) 

# estimate total number of physicians in USA using ratio estimate
srs_ratio_est (phys, popn) * M0

########### results from question 4.11 using srs sample ##################
# read srs sample of size 100
counties <- read.csv ("counties.csv", na = "-99")
totpop <-  255077536
N <- 3141 # total number of counties
# naive estimate 
srs_est (counties$physician, N = 3141) * 3141

# ratio estimate
srs_ratio_est (counties$physician, counties$totpop, N = 3141) * totpop

# regression estimate
srs_reg_est (counties$physician, counties$totpop, totpop/N, N = N) * N 

## note that the true value is given in question 4.11: 
total_physician <- 532638




