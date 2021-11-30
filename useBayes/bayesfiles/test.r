# irep <- 1 # this line will be added by qsubR with 1 taking 1,2,... 
if (!exists("irep")) irep <- 1 # adding this line to test your code in 
Rstudio

## analysis
result <- rnorm (100, mean = 10) 

## save outputs
system ("if [ ! -d test_routs ]; then mkdir test_routs; fi") # create 
directory test_routs to hold outputs

pdf(file = sprintf("test_routs/scat%d.pdf", irep))
plot (result)
dev.off()

cat (result, file = sprintf("test_routs/test%d.txt", irep))

