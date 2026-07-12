
#################### Vector ########################################
a <- 1

a

b <- 2:10

b

#concatenate two vectors
c <- c(a,b)

c

#vector arithmetics
1/c

c^2 

c^2 + 1

#apply a function to each element
log(c)

sapply(c,log)


#operation on two vectors
d <- (1:10)*10

d

c + d

c * d

d ^ c

#more concrete example: computing variance of 'c'
sum((c - mean(c))^2)/(length(c)-1)

#of course, there is build-in function for computing variance:
var(c)

#subsetting vector
c

c[2]

c[c(2,3)]

c[c(3,2)]

c[c > 5]

#let's see what is "c > 5"
c > 5

c[c > 5 & c < 10]

c[as.logical((c > 8) + (c < 3))] 

log(c)

c[log(c) < 2]

#modifying subset of vector
c[log(c) < 2] <- 3

c

#introduce a function ``seq''
seq(0,10,by=1)

seq(0,10,length=20)

1:10

#seq is more reliable than ":"
n <- 0

1:n

#seq(1,n,by=1) 
#Error in seq.default(1, n, by = 1) : wrong sign in 'by' argument
#Execution halted

#function ``rep''
c<- 1:5

c

rep(c,5)

rep(c,each=5)

#################### Operating string ########################################

A <- c("a","b","c")

A

paste("a","b",sep="")

paste0("a","b",sep="")

paste(A,c("d","e"))

paste(A,10)

paste(A,10,sep="")

paste0(A,10)

paste0(A,1:10)

#################### missing values ########################################

a <- 0/0

a

is.nan(a)

b <- log(0)

b

is.finite(b)

c <- c(0:4,NA)

c

is.na(c)


#################### Matrices ########################################
A <- matrix(0,4,5)

A
A <- matrix(1:20,4,5)

B <- matrix(1:20,4,5,byrow = T)



#subsectioning and modifying subsection

D <- A[c(1,4),c(2,3)]

A[c(1,4),c(2,3)] <- 1

A[c(1,4),c(2,3)] <- 101:104

A[c(1,4),c(2,3)] <- matrix (1001:1004, 2,2)

a<- A[4,]

b<- A[3:4,]

A[1,1]

a2<- A[4,, drop = FALSE]

#combining two matrices

#create another matrix using another way
A2 <- array(1:20,dim=c(4,5))

A2

cbind(A,A2)

rbind(A,A2)

#operating matrice

#transpose matrix
t(A)

A

A + 1

x <- 1:5

A*x

#the logical here is coercing the matrix "A" into a vector by joining the column
#and repeat the shorter vector,x, as many times as making it have the same
#length as the vector coerced from "A" 

#see another example

x <- 1:3

A*x

A^2

A <- matrix(sample(1:20),4,5)

A

B <- matrix(sample(1:20),5,4)

B

C <- A %*% B

C

solve(C)

#solving linear equation

x <- 1:4

d <- C %*% x

solve(C,d)

#altenative way (but not recommended)
solve(C) %*% d

#SVD (C = UDV') and determinant 

svd.C <- svd(C)

svd.C

#calculating determinant of C

prod(svd.C$d)

###################### data frame ########################################
name <- c("john","peter","jennifer")

gender <- factor(c("m","m","f"))

hw1 <- c(60,60,80)

hw2 <- c(40,50,30)

grades <- data.frame(name,gender,hw1,hw2)


grades[,"gender"]

grades[,2]

#subsectioning a data frame

grades[1,2]

grades[,"name"]

grades$name

grades[grades$gender=="m",]
subset (grades, hw1 >60)

grades[,"hw1"]

#divide the subjects by "gender", and calculating means in each group
tapply(grades[,"hw1"], grades[,"gender"],mean)


a <- 1:10

b <- matrix(1:10,2,5)

c <- c("name1","name2")

alst <- list(aa=a,b=b,c=c)

names (alst)
str(alst)


#refering to component of a list

alst$aa


alst[[2]]

blst <- list(d=2:10*10)

#concatenating list
ablst <- c(alst,blst)

ablst

################### reading and saving data ###################################
a<- scan (text = "3 4 5.3 3")
numbers <- scan (file="numbers.txt")
mtcars <- read.csv ("mtcars.csv")

## save objects
save (mtcars, numbers, file = "mtcars.RData")  
load ("mtcars.RData")

## to save everything in the current workspace
save.image () ## to .RData file, which is hidden
save.image(file = "myimage.RData")

## output numbers to a file
cat (numbers, file = "numbers.txt")

## save data frame as csv or other types of file
write.csv(mtcars, file = "mtcars2.csv")

############################ function ########################################

#looking for the maximum value of a numeric vector x
find.max <- function(x)
{
    n <- length(x)
    
    x.m <- x[1]
    ix.m <- 1
    
    if(n > 1)
    {
        for( i in seq(2,n,by=1) )
        {
            if(x[i] > x.m)
            {  
                x.m <- x[i]
                ix.m <- i
            }
        }
    }
    
    #return the maximum value and the index
    list(max=x.m,index.max=ix.m)
}

################ making graphics #############################################

demofun1 <- function(x)
{
    ( 1 + 2*x^2 + 3*x^3 + exp(x) ) / x^2
}
demofun2 <- function(x)
{
    ( 1 + 2*(10-x)^2 + 3*(10-x)^3 + exp(10-x) ) / (10-x)^2
}
#open a file to draw in it
pdf ("afig.pdf",height=4.8, width=10)
#specify plotting parameters
par(mfrow=c(1,2), mar = c(4,4,3,1))
x <- seq(0,10,by=0.1)
#make "Plot 1"
plot(x, demofun1(x), type="p", pch = 1, ylab="y", main="Plot 1")
#add another line to "Plot 1"
points(x, demofun2(x), type="l", lty = 1)
#make "plot 2"
plot(x, demofun1(x), type="b", pch = 3, lty=1, ylab="y", main="Plot 2")
#add another line to "Plot 2"
points(x, demofun2(x), type="b", pch = 4, lty = 2)

dev.off()
