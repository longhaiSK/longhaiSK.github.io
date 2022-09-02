source ("estimates.r")

school = c(1,2,3,4)
no.stu = c(1471, 890, 1021, 1587)
no.female = c(792, 447, 511, 800)
no.female.int = c(25, 15, 20, 40)
no.smoke = c(10, 3, 6, 27)
					
## a 

phat_cls <- no.smoke/no.female.int

est_smoke_rate <- srs_ratio_est (phat_cls * no.female, no.female, N = 29)
est_smoke_rate

## b, using unbiased estimate

srs_mean_est (no.smoke/no.female.int * no.female, N = 29) * 29


## b, using ratio estimate

NO_female <- srs_mean_est (no.female)  [1] * 29
est_smoke_rate * NO_female
