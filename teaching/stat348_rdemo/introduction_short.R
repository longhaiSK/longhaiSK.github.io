######################## the first thing to do to use rstudio is 

# create a project and folder to save all your datasets, R files, and outputs

#################### input simple data into R #################################

# create a vector
x <- 1:10
x <- seq (30,3, by = -2)
a <- c(66.32, 69.87, 70.12, 90.37, 50.08, 61.20, 65.00, 57.65)
d <- a [1]
a [1] <- 85.34

mean (a)
ma <- mean (a)
# read a vector of numbers from a file
x <- scan("numbers.txt")

# one can also read number withoug saving to a file
y <- scan(text = "7  8  9 10 11 12 13 13 14 17 17 45")

# create a matrix
A <- matrix (0, 4, 2)

A <- matrix (1:8, 4,2)

D <- matrix (a, 4, 2, byrow=T)

?matrix

D <- matrix(1:8, 2, 4)

# create another matrix with all entry 0
B <- matrix (0, 100, 50)
# assign a number to B
B[1,4] <- 4.5
B[1,] <- 1:50


# create a list
E <- list (newa = a, newA = A)
# list the names of components
names (E)
# to look at the component of E
E$newA 

E$newa <- 10:17

# create a dataframe
scores <- c (30, 45, 50)
names <- c("Peter", "John", "Alice")
stat245_scores <- data.frame (names, scores)
stat245_scores$names
stat245_scores$scores [2] <- 17
stat245_scores$perc <- stat245_scores$score/50 * 100 + 10


###############################################################################
#### import a dataset into R environment 
###############################################################################

# import myagpop.xls into an R data frame called 'myagpop'
agpop <- read.csv ("data/agpop.csv")

# Now, we can use the data:

# preview agpop
head (agpop)

# look at the variable name
colnames (agpop) 

# find number of cols
ncol (agpop) 

# find number of rows
nrow (agpop) 

# access a certain row
agpop [2, ]
# access a certain column
agpop [, "acres92"] ## equivalent to 
agpop$acres92
agpop$largef92
# find mean of acres92
mean (agpop $acres92)
# find sd of acres92
sd (agpop $acres92)

agpop_AK  <- agpop [agpop$state == "AK", ]

agpop_AK <- subset (agpop, state == "AK")

agpop_W <- subset (agpop, region == "W")

agpop_largefarm <- subset (agpop, largef92 > 10)

## simple analysis
summary (agpop)


hist (agpop$acres92)

# to save plot in a file

pdf ("hist_acres92.pdf")
hist (agpop$acres92)
dev.off()

jpeg ("agpop_acres_87v92.jpg")

plot (agpop$acres87, agpop$acres92)
abline (a = 0, b = 1)

dev.off()

## create your own function

## data is a matrix or data.frame
means_col <- function (data)
{
    n <- ncol (data)
    cmeans <- rep (NA, n)
    for (j in 1:n)
    {
        cmeans[j] <- mean (data[,j])
        
    }
    cmeans
}

## apply function
means_col (agpop[, 3:13])
## R built-in function
colMeans (agpop[, 3:13])
