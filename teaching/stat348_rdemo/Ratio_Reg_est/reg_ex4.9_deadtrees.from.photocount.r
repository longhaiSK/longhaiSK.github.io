source ("estimates.r")

pdf ("reg_ex4.9.pdf")

photocounts <- c (10,12,7, 13,13, 6,17, 16, 15, 10, 14, 12, 10, 5,12, 10,
10, 9, 6, 11, 7, 9, 11, 10, 10)

fieldcounts <- c (15, 14, 9, 14, 8, 5, 18, 15, 13, 15, 11, 15, 12, 8, 13,
9, 11, 12, 9, 12, 13, 11, 10, 9, 8)

plot (photocounts, fieldcounts)
lmfit <- lm (fieldcounts ~ photocounts)
summary (lmfit)
abline (lmfit)

meanfieldtrees_reg <- srs_reg_est_mean (ydata = fieldcounts, xdata = photocounts, 
								xbarU = 11.3, N = 100)
# estimate for the mean number of dead trees per plot
meanfieldtrees_reg
# estimate for the total number of dead trees in the area
meanfieldtrees_reg * 100


dev.off ()

# compare to simple estimate
srs_mean_est (sdata = fieldcounts, N = 100)

# compare to ratio estimate 
srs_ratio_est (ydata = fieldcounts, xdata = photocounts, N = 100) * 11.3


