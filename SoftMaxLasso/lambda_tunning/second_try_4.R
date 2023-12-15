load("x_matrix.RData")
load("y.RData")

library(Rcpp)
library(caret)
library(ggplot2)
library(patchwork)
library(nnet)
sourceCpp("test.cpp")
source("fista_self_try.R")


n = dim(x_matrix)[1]
p = dim(x_matrix)[2]
k = length(table(y))

beta0 = matrix(0.05,k*p,1)



for(i in 1:5){
  
  lambda = 0.04+(i-1)/1000
  L_init = 1
  
  y_one_hot=nnet::class.ind(y)
  
  class_list = c("Class 1","Class 3","Class 4","Class 5","Class 6","Class 9","Class Combined")
  
  result = fistaCpp(lambda,L_init,beta0,x_matrix,y_one_hot,n=n,p=p,k=k)
  
  dir_name = paste("result_",lambda,sep="")
  
  dir.create(dir_name)
  
  save(result,file=file.path(dir_name,"result.RData"))
  
  write.table(result$loss,file=file.path(dir_name,"loss.txt"),row.names = F,col.names = F)
  
  write.table(c(result$iter_times,result$loss[length(result$loss)]),file=file.path(dir_name,"Times_and_Loss.txt"),row.names = F,col.names = F)
  
  write_confusion(result,dir_name)
  
  write_coefficients(result,dir_name)
  
  plot_function(result,dir_name)
  
}
