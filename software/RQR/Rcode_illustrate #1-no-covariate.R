library(ggplot2)
library(ggExtra)
library(gridExtra)

#####################################################
# generate data
#####################################################

#sample size
n <- 2000
smp <- sample(1:n, 100)## randomly selected sample for drawing scatterplot
#Generating data
y <- rbinom(n,2,.5)


#####################################################
# RPP for the true model
#####################################################
pv.r <- pbinom(y-1,2,.5)+runif(n)*dbinom(y,2,.5)

# select a small subset of pv.r for drawing scatterplot
pv.r2 <- rep (NA, n)
pv.r2[smp] <- pv.r[smp]

#####################################################
# RPP for the wrong model
#####################################################

# functions for calculating the pmf and the cdf of the wrong distribution(.1,.8,.1)
pmf <- function(x)
{
  return((x==0)*(.1)+(x==1)*(.8)+(x==2)*(.1))
}
cdf <- function(x)
{
  return((x==0)*(.1)+(x==1)*(.9)+(x==2)*(1))
}

#Residuals for wrong model
pv.w <- cdf(y-1)+runif(n)*pmf(y)
# select a small subset of pv.w for drawing scatterplot
pv.w2 <- rep (NA, n)
pv.w2[smp] <- pv.w[smp]

#####################################################
# dataset for ggplot
#####################################################

#Saving all the results in a data frame to be used in ggplot
df <- data.frame(y = y, pv.r=pv.r,pv.r=pv.r2,  
                 pv.w=pv.w, pv.w2=pv.w2
                )

#####################################################
## plot settings
pch = 1

#a function for different colors of the CDF
clr <- function(x)
{
  return((x==0)*(1)+(x==1)*(2)+(x==2)*(4))
}
#####################################################

#####################################################
# Drawing RPPs and their histogram for the true model
#####################################################

p.r <- ggplot(df, aes(as.factor(y), pv.r2)) + 
  geom_point(pch=pch,colour=clr(y),size=3) + 
  theme_classic() + 
  ylab("RPP") + 
  xlab("y") + 
  theme(axis.text=element_text(size=rel(1.5))) + 
  theme(axis.title = element_text(size = rel(1.5)))

#histogram for the true model
hist_right.r <- ggplot(data=df, aes(pv.r)) + 
  geom_histogram(breaks=seq(0, 1, by=.1),
                 fill=I("blue"),col=I("red"),alpha=I(.2)) + 
  coord_flip() + 
  scale_y_reverse() +
  xlab("RPP") + 
  theme(axis.text=element_text(size=rel(1.5))) +
  theme(axis.title = element_text(size = rel(1.5)))

#####################################################
# Drawing RPPs and their histogram for the true model
#####################################################

p.w <- ggplot(df, aes(as.factor(y), pv.w2)) + 
    geom_point(pch=pch,colour=clr(y), size=3) + 
    theme_classic() + 
    ylab("RPP") + 
    xlab("y") + 
    theme(axis.text=element_text(size=rel(1.5))) + 
    theme(axis.title = element_text(size = rel(1.5)))

#histogram for the wrong model
hist_right.w <- ggplot(data=df, aes(pv.w)) + 
    geom_histogram(breaks=seq(0, 1, by=.1),
                   fill=I("blue"),col=I("red"),alpha=I(.2)) + 
    coord_flip() + 
    scale_y_reverse() +
    xlab("RPP") + 
    theme(axis.text=element_text(size=rel(1.5))) +
    theme(axis.title = element_text(size = rel(1.5)))


#pdf("pvr1.pdf", height=7, width =7)
grid.arrange(hist_right.r,p.r, ncol=2, nrow=1)
#dev.off()

#pdf("pvw1.pdf", height=7, width =7)
grid.arrange(hist_right.w,p.w, ncol=2, nrow=1)
#dev.off()



