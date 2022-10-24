######################## the first thing to do to use rstudio is 

# create a project and folder to save all your datasets, R files, and outputs

#################### input simple data into R #################################

# create a vector
a <- c(66.32, 69.87, 70.12, 90.37, 50.08, 61.20, 65.00, 57.65)
a
mean (a)
ma <- mean (a)
# read a vector of numbers from a file
x <- scan ("numbers.txt")

# one can also read number withoug saving to a file
y <- scan(text = "7  8  9 10 11 12 13 13 14 17 17 45")

# create a matrix
A <- matrix (a, 4, 2)

D <- matrix (a, 4, 2, byrow=T)
# create another matrix with all entry 0
B <- matrix (0, 100, 50)
# assign a number to B
B[1,4] <- 4.5

# create a list
E <- list (a = a, A = A)
# list the names of components
names (E)
# to look at the component of E
E$a
E$A
# create a dataframe
scores <- c (70, 80, 90)
names <- c("Peter", "John", "Alice")
stat245_scores <- data.frame (names, scores)
stat245_scores

###############################################################################
#### import a dataset into R environment 
###############################################################################

# import mymtcars.xls into an R data frame called 'mymtcars'
mtcars <- read.csv ("mtcars.csv")

# Now, we can use the data:

# preview mtcars
head (mtcars)

# look at the variable name
colnames (mtcars) 

# find number of cols
ncol (mtcars) 

# find number of rows
nrow (mtcars) 

mtcars[1,2]
mtcars[1,"mpg"]

# access a certain row
mtcars [2, ]
# access a certain column
mtcars [, 2]
mtcars$mpg
# access a certain column (variable)
mtcars$cyl

# find mean of cyl
mean (mtcars $cyl)

# find sd of cyl
sd (mtcars $cyl)


# subset mtcars with cyl == 4, saved in a new data frame called mtcars_cyl4
mtcars_cyl4 <- subset (mtcars, cyl == 4)

# subset mtcars with mgp < 20, saved in a new data frame called mtcars_mgpless20
mtcars_mgpless20 <- subset (mtcars, mpg < 20)
