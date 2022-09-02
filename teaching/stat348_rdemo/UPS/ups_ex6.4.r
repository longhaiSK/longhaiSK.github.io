source ("estimates.r")

psi <- c(24, 100, 100, 76, 44) / 647
Mi <- c(24, 100, 100, 76, 44)
hrs <- c(75, 203, 203, 191, 168)

## total hrs spent by all students

upswr_total_est (total = hrs, psi = psi)

## mean hrs spent by each student
upswr_ratio_est (total = hrs, M = Mi, psi = psi)
