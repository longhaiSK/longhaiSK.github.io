
## R code for demonstrating Chapter 2

################ frequency plot with data on a categorical variable ########################
## import 'survey.csv' data as an R data frame called 'survey'
survey <-  read.csv ("survey.csv")

## get frequency table of variable 'Smoke' of data set 'survey' 
smoke_freq <- table (survey$Smoke)

## draw bar graph of variable 'Smoke' of data set 'survey'
barplot (smoke_freq)

## we can also use a compact expression
barplot (table (survey$Smoke))

## note: it doesn't work with barplot (survey$Smoke)

## draw pie chart
pie (smoke_freq)

## or you can use a compact expression
pie (table (survey$Smoke))

## find relative frequency
smoke_relfreq <- smoke_freq / nrow (survey)
## find percentage
smoke_perc <- smoke_freq / nrow (survey) * 100
## find angles used in pie chart
smoke_pie <- smoke_freq / nrow (survey) * 360

#################### histogram for continuous variable ########################

######## do histogram given a vector of numbers 
x <- sort(round(rnorm (200, 70,10),0))
hist (x)
rug (jitter(x))

stem (x)

## input a data vector from a file
## numbers.txt was created with write (x, file = "numbers.txt")
x <- scan ("numbers.txt")
hist (x)
rug (jitter(x))

stem (x)

####### histogram given an imported data frame
## draw histogram of variable 'Pulse' of data set 'survey' with default choice
hist (survey$Pulse)
# use nclass to determine the number of bins
hist (survey$Pulse, nclass = 20)
# use breaks to specify boundaries
hist (survey$Pulse, breaks = seq (35, 110, by = 5))

## histogram with polygon
pulse_hist <- hist (survey$Pulse, breaks = seq (35, 110, by = 5))
## show original observations
rug(survey$Pulse )
## add polygon line to histogram
points (pulse_hist$mids, pulse_hist$counts, type = "b")


## draw ogive plot on histogram
pulse_hist <- hist (survey$Pulse, nclass = 10, ylim = c(0, 200))
n <- sum (pulse_hist$counts)
points (pulse_hist$breaks, c(0, cumsum(pulse_hist$counts)), type = "b")

##in R, a more convenient way is to look at empirical distribution function
plot(ecdf (survey$Pulse))

## draw stemplot
stem (survey$Pulse)

