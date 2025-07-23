boxplotlogt <- function (df, w, p = 5000)
{
    s <- log (w, base = 10)
    labetas <- log(abs(rt (5000, df = df)), base = 10) +  0.5 * s
    boxplot (labetas, ylab = "")
    title (ylab = bquote(paste (log[10](abs(beta)))) ) 
    title (xlab = sprintf("t (df=%g, log(scale)= %.1f)", df, 0.5*s*log(10)))
}

#boxplotlogt (1, exp (-10))

