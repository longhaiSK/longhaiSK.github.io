source ("estimates.r")
journal <- read.csv ("journal.csv")

srs_ratio_est (journal$nonprob, journal$numemp)



