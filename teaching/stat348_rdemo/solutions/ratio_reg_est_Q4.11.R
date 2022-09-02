source ("estimates.r")

counties <- read.csv("data/counties.csv", na = "-99", as.is = T)

## a) 

hist (counties$physician)

## b) Simple estimate

N <- 3141
srs_est (counties$physician, N = 3141) * N

## c) 

plot (counties$totpop, counties$physician)
# for a better view, we can use log
plot (counties$totpop, counties$physician, log = "xy")

## omit those counties with more than 1000 physicians
small_counties <- which (counties$physician < 1000)
plot (counties$totpop[small_counties], counties$physician[small_counties])
# for a better view, use log
plot (counties$totpop[small_counties], counties$physician[small_counties], log = "xy")


## regression estimate may be more appropriate, since when number of physicians is nearly 0 (1 is the smallest number), the number of total population is far from 0. 

## d)

## if we use ratio estimation:
srs_ratio_est (counties$physician, counties$totpop, N = N) * 255077536

## if we use regression estimation:
srs_reg_est (counties$physician, counties$totpop, 255077536/N, N = N) * N

## e)

## ratio and regression estimates are closer to the true value. The reason is that numbers of physicians vary greatly in different counties due to the population size. 
