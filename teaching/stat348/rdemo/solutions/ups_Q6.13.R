source ("estimates.r")
## true value of total number of physicians is 532638 in 1990
################### Hanzen-Hurvitz analysis with UPS sample ##############
# read ups sample of size 100
statepop <- read.csv ("data/statepop.csv")

M0 <- 255077536 ## pop of USA in 1992
popn <- statepop$popn ## pop per county in 1992
psi <- popn / M0 ## exact value of psi is required in upswr

# estimate the total number of veterans in USA
upswr_total_est (statepop$veterans, psi)

# estimate the total number of vietnam veteran in USA
upswr_total_est (statepop$veterans * statepop$percviet/100, psi)
