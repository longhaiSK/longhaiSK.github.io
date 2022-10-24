
source ("estimates.r")

pdf ("UPS/ups_ex6.10.pdf")
agpop <- read.csv ("data/agpop.csv", na = "-99")
N <- nrow (agpop)
totcares92<- sum (na.omit(agpop$acres92))

################## use acres87 to construct sampling probability #############
plot (agpop$acres87, agpop$acres92)


acres87 <- agpop[, "acres87"]
acres87 [is.na (acres87)] <- 0

est_srs300 <- est_ups15_acres87 <- rep (0, 5000)
for (i in 1:5000)
{
  ## srs sample
  srs300 <- sample (1:N, size = 300)
  ## survey
  acres92_srs300 <- agpop[srs300, "acres92"]
  ## estimate
  est_srs300 [i] <-  (srs_mean_est (na.omit (acres92_srs300), N = N) * N) [1] 
  
  ## ups sample
  ups15 <- sample (1:N, size = 15, prob = acres87, replace = TRUE)

  ## survey
  acres92_ups15 <- agpop[ups15, "acres92"]

  ## estimate
  psi <- (acres87 / sum (acres87)) [ups15]
  nona <- (!is.na (acres92_ups15) & !is.na (psi) )
  est_ups15_acres87 [i] <-  upswr_total_est (acres92_ups15[nona], psi[nona]) [1] 

}

boxplot (data.frame(est_srs300, est_ups15_acres87))

################## use smallf87 to construct sampling probability #############

plot (agpop$smallf92, agpop$acres92)

smallf87 <- agpop[, "smallf87"]
smallf87 [is.na (smallf87)] <- 0

est_ups300_smallf <- rep (0, 5000)

for (i in 1:5000)
{

    ## ups sample
    ups300 <- sample (1:N, size = 15, prob = smallf87, replace = TRUE)
    
    ## survey
    acres92_ups300 <- agpop[ups300, "acres92"]
    
    ## estimate
    psi <- (smallf87 / sum (smallf87)) [ups300]
    nona <- (!is.na (acres92_ups300) & !is.na (psi) )
    est_ups300_smallf [i] <-  upswr_total_est (acres92_ups300[nona], psi[nona]) [1] 
    
}

boxplot (data.frame(est_srs300, est_ups300_smallf), log = "y")


################## use largef87 to construct sampling probability #############

plot (agpop$largef87, agpop$acres92)

nona <- !is.na (agpop$largef87) & !is.na (agpop$acres92)
cor (agpop$largef87[nona], agpop$acres92[nona])

largef87 <- agpop[, "largef87"]
largef87 [is.na (largef87)] <- 0

est_ups300_largef <- rep (0, 5000)

for (i in 1:5000)
{
    
    ## ups sample
    ups300 <- sample (1:N, size = 15, prob = largef87, replace = TRUE)
    
    ## survey
    acres92_ups300 <- agpop[ups300, "acres92"]
    
    ## estimate
    psi <- (largef87 / sum (largef87)) [ups300]
    nona <- (!is.na (acres92_ups300) & !is.na (psi) )
    est_ups300_largef [i] <-  upswr_total_est (acres92_ups300[nona], psi[nona]) [1] 
    
}

boxplot (data.frame(est_srs300, est_ups300_largef), log = "y")

boxplot (data.frame(est_srs300, est_ups15_acres87, 
                    est_ups300_smallf,est_ups300_largef)
        , log= "y")
dev.off()