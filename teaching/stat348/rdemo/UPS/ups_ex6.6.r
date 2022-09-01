source ("estimates.r")

psi <- c(24, 100, 100, 76, 44) / 647
Mi <- c(24, 100, 100, 76, 44)
hrs_pers <- c(2.4, 1.6, 2.0, 2.8, 3.7)
hrs_class <- hrs_pers * Mi # tao_j

## Hansen-Hurwits estimate of total hrs that all 647 students spent
upswr_total_est (hrs_class, psi)

## Hansen-hurvits estimate of mean hrs per student
upswr_ratio_est (hrs_class, Mi, psi)
