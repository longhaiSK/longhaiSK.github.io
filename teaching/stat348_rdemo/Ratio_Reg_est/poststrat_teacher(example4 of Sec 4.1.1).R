source ("estimates.r")

teacher <- read.csv ("data/college_teacher.csv")
n <- nrow (teacher)
yh <- tapply (teacher$teacher, INDEX = teacher$gender, FUN = mean); yh
sh <- tapply (teacher$teacher, INDEX = teacher$gender, FUN = sd); sh

nh_obs <- table (teacher$gender); nh_obs

ph_obs <- nh_obs/sum (nh_obs); ph_obs

Nh <- c(2700, 1300)

ph <- Nh/sum (Nh); ph

## there is a big difference in response rates for this question 
sqrt(0.675*0.325/400)*1.96

ph[1]-ph_obs[1]

## for poststratification, we use nh proportional to Nh, instead of observed nh
nh <- Nh/sum (Nh) * n
## poststratification estimation of mean



strata_mean_estimate (yh, sh, nh, Nh)

## without postratification
srs_mean_est (teacher$teacher, N=sum(Nh))
