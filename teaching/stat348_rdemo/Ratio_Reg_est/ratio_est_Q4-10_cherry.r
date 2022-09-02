source ("estimates.r")

cherry <- read.csv ("data/cherry.csv", header = T)

pdf ("ratio_est_cherry.pdf")

View (cherry)
plot (cherry$volume ~ cherry$diameter)
############################ simple estimate ###################################
N <- 2967
srs_mean_est(cherry$volume) * N

############## ratio estimation using step-by-step calculation #################
## input
ydata <- cherry$volume
xdata <- cherry$diameter
N <- 2967

## calculation
n <- length (xdata)
xbar <- mean (xdata)
ybar <- mean (ydata)
B_hat <- ybar / xbar ## ratio estimate
d <- ydata - B_hat * xdata ## errors
var_d <- sum (d^2) / (n - 1) ## variance of errors
sd_B_hat <- sqrt ((1 - n/N) * var_d / n) / xbar ## SE for B
mem <- qt (0.975, df = n - 1) * sd_B_hat ## margin error for B

## output
output <- c (B_hat, sd_B_hat, B_hat - mem, B_hat + mem )
names (output) <- c("Est.", "S.E.", "ci.low", "ci.upp" )
output

plot (cherry$volume ~ cherry$diameter)
abline (a = 0, b = B_hat)

## to estimate total volume of wood
t_diameters <- 41835
output * t_diameters


###################### ratio estimation with a function #######################
# estimate ratio of volume to diameter
B_v2d <- srs_ratio_est (ydata = cherry$volume, xdata = cherry$diameter, N = 2967)
B_v2d

# estimate total volume
t_diameters <- 41835
B_v2d * t_diameters

# simple estimate
srs_mean_est (cherry$volume, N = 2967) * 2967


################### another imcomplete ratio estimate #########################
cherry$volumehat <- cherry$diameter^2 * cherry$height
lm.cherry.volumehat <- lm(cherry$volume~cherry$volumehat)
summary (lm.cherry.volumehat)
plot(cherry$volumehat, cherry$volume)
abline (lm.cherry.volumehat)

Bhat <- srs_ratio_est (ydata = cherry$volume, xdata = cherry$volumehat,N = 2967)
## we need total of volumehat to estimate volume total

########################## regression estimate step-by-step ###################
ydata = cherry$volume 
xdata = cherry$diameter
t_diameters <- 41835
xbarU = t_diameters/2967 
N = 2967

n <- length (ydata)
lmfit <- lm (ydata ~ xdata)
summary (lmfit)
plot (xdata, ydata)
abline (lmfit)
Bhat <- lmfit$coefficients
efit <- ydata - (Bhat[1] + Bhat[2] * xdata)
cbind (xdata, ydata, efit) ## for visualization

SSe <- sum (efit^2) / (n - 2) 

yhat_reg <- Bhat[1] + Bhat[2] * xbarU
se_yhat_reg <- sqrt ((1-n/N) * SSe / n)
mem <- qt (0.975, df = n - 2) * se_yhat_reg
output <- c(yhat_reg, se_yhat_reg, yhat_reg - mem, yhat_reg + mem)
names (output) <- c("Est.", "S.E.", "ci.low", "ci.upp" )
output
output * N ## estiamte total
########################## regression estimate with function ##################

lm.cherry <- lm(cherry$volume~cherry$diameter)
summary (lm.cherry)
plot(cherry$diameter, cherry$volume)
abline (lm.cherry)

t_diameters <- 41835
srs_reg_est_mean(ydata = cherry$volume, xdata = cherry$diameter, 
                 xbarU=t_diameters/2967, N = 2967) * 2967

dev.off ()
