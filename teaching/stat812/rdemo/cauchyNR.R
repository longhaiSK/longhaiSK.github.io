
lik <- function (x) log(1+x^2)
s <- function (x) 2*x/(1+x^2)

library(animation)
ani.options(interval = 1, nmax = 50)
saveHTML({
    
    xx1 = newton.method(FUN=s, init =0.5,rg=c(-1.5,1.5))
}, htmlfile = "nr-cauchy1.html", img.name = "nr-cauchy-good-"
)

saveHTML({
    
    xx1 = newton.method(FUN=s, init =0.8,rg=c(-8,1.5))
}, htmlfile = "nr-cauchy2.html", img.name = "nr-cauchy-fail1-"
)

saveHTML({
    
    xx2 = newton.method(FUN=s, init =1.2,rg=c(-2,20))
}, htmlfile = "nr-cauchy3.html", img.name = "nr-cauchy-fail2-"
)

