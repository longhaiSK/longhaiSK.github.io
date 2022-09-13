## fit a non-linear model with nls to sunspots data
x <- sunspots [1:500]
t <- 1:length(x)
ss_data <- data.frame (sunspots = x, t = t)

nlsfit_ss <- summary (
                nls (sunspots ~ abs(M*(a+sin(b+f*t))), 
                     data = ss_data,
                     start = c(a= 0, b = -1, f = 2*pi/200, M = 80))
                )
## note that this model is different from the model given in sunspots_nlm.r

names (nlsfit_ss)

nlsfit_coef <- nlsfit_ss$coef

a2 <- nlsfit_coef[1,1]
b2 <- nlsfit_coef[2,1]
f2 <- nlsfit_coef[3,1]
M2 <- nlsfit_coef[4,1]

plot(t,x,pch=20)
lines(t,abs(M2*(a2+sin(b2+f2*t))),col="red")
