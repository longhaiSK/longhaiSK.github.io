A <- 7^5
M <-  2^31-1

N <- 100000
rn <- rep (0, N)
rn[1] <- 10
for (i in 2:length (rn))
{
    rn[i] <- (A * rn[i-1] ) %% M
}

nrn <- rn/(M-2)
plot (nrn[1:100])
acf (nrn)
hist (nrn)

