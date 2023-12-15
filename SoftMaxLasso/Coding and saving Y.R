
adata_nn = read.csv("adata_nn.csv",header=T)
y_raw = adata_nn[,"celltype"]
y_num = as.numeric(factor(y_raw))
y = y_num

### recoding y into 0-6

for (i in 1:length(y))
{
  if(y[i] == 1){
    y[i] = 0
  }else if(y[i] %in% c(3, 4, 5, 6)){
    y[i] = y[i]-2
  }else if(y[i] == 9){
    y[i] = 5
  }else
  {
  y[i] = 6
  }
}

# Saving the y into RData
save(y,file="y.RData")






