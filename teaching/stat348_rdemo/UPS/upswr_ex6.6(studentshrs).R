source ("estimates.r")

#This demonstration uses a dataset collected with UPSWR about students' hours on studying
studenthrs <- read.table ("studentshrs.txt", header = T)

## add sampling probability to the data
studenthrs$pik <- studenthrs$class_size/647

cluster_upswr_ratio_est (studenthrs, "sid" , "class_size", "pik", "hrs")

