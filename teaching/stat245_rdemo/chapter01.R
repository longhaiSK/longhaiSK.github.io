#' ---
#' title: "Introduction to Statistical Methods"
#' subtitle: "Introduction to R"
#' author: "Longhai Li"
#' date: "September 2023"
#' output: 
#'    html_document:
#'        toc: true
#'        toc_float: true
#'        number_sections: true
#'        highlight: tango
#'        fig_width: 10
#'        fig_height: 8
#' ---


#' # Basic R Objects and Operations

# create a vector
x <- 1:10
x <- seq (30,3, by = -2)
a <- c(66.32, 69.87, 70.12, 90.37, 50.08, 61.20, 65.00, 57.65)
d <- a [1]
a [1] <- 85.34

mean (a)
ma <- mean (a)

# one can also read number withoug saving to a file
y <- scan(text = "7  8  9 10 11 12 13 13 14 17 17 45")

# create a matrix
A <- matrix (0, 4, 2)

A <- matrix (1:8, 4,2)

D <- matrix (a, 4, 2, byrow=T)

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


#' #Import a dataset into R environment 
#' If you know the path to the file to import
#' 

mtcars <- read.csv("mtcars.csv")



#' #Basic operations for a dataset

#' preview mtcars

mtcars

#' For large dataset, these methods for previewing mtcars:
#' 
#' Look at the first 6 rows
head (mtcars)

#' Look at the structure

str(mtcars)

#' look at the variable (column) names
colnames (mtcars) 

#' look at the row names
rownames(mtcars)

#' find the number of cols
ncol (mtcars) 

#' find the number of rows
nrow (mtcars) 

#' look at a certain row
mtcars [2, ]

#' look at a certain column
mtcars[,2]
mtcars [, "mpg"]
mtcars$mpg

#' find mean of cyl
mean (mtcars $cyl)

#' find sd of cyl
sd (mtcars $cyl)

#' subset mtcars with cyl == 4, saved in a new data frame called mtcars_cyl4
mtcars_cyl4 <- subset (mtcars, cyl == 4)

#' subset mtcars with mgp < 20, saved in a new data frame called mtcars_mgpless20
mtcars_mgpless20 <- subset (mtcars, mpg < 20)

#' #Other functions for inputing numbers
x <- scan ("numbers.txt")
x
z <- scan (text = "2 3 1 39 3 2")
x
y <- c(1,2,4,3.4)
y

