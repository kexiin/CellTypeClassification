load("result.RData")

classes = list(1,3,4,5,6,9,"Combined") # from draft.R file

class_name=c(cell_type_name[c(1,2,4,5,6,9)],"combined")

class_one_nonzero_beta_index = read.table(file="non_zero_coefficients_for_predicting_Class 1.txt",header = F)
class_three_nonzero_beta_index = read.table(file="non_zero_coefficients_for_predicting_Class 3.txt",header = F)
class_four_nonzero_beta_index = read.table(file="non_zero_coefficients_for_predicting_Class 4.txt",header = F)
class_five_nonzero_beta_index = read.table(file="non_zero_coefficients_for_predicting_Class 5.txt",header = F)
class_six_nonzero_beta_index = read.table(file="non_zero_coefficients_for_predicting_Class 6.txt",header = F)
class_nine_nonzero_beta_index = read.table(file="non_zero_coefficients_for_predicting_Class 9.txt",header = F)
class_combined_nonzero_beta_index = read.table(file="non_zero_coefficients_for_predicting_Class Combined.txt",header = F)


class_one_nonzero_beta = result$theta[,1][class_one_nonzero_beta_index$V1]
class_one_nonzero_beta_name = gene_name[class_one_nonzero_beta_index$V1]
temp_df = data.frame(name = class_one_nonzero_beta_name,
                     abs_beta = abs(class_one_nonzero_beta),
                     beta=class_one_nonzero_beta)

library(dplyr)

temp_df_sorted = temp_df %>% arrange(desc(abs_beta))
fisrt_5_df = head(temp_df_sorted,5)
fisrt_5_df$beta = round(fisrt_5_df$beta,3)
fisrt_5_df[,c("name","beta")]






generate_fisrt_5 = function(cell_type,theta_index,class_nonzero_beta_index,gene_name,result){
  class_nonzero_beta = result$theta[,theta_index][class_nonzero_beta_index$V1]
  class_nonzero_beta_name = gene_name[class_nonzero_beta_index$V1]
  temp_df = data.frame(name = class_nonzero_beta_name,
                       abs_beta = abs(class_nonzero_beta),
                       beta=class_nonzero_beta)
  
  library(dplyr)
  
  temp_df_sorted = temp_df %>% arrange(desc(abs_beta))
  fisrt_5_df = head(temp_df_sorted,5)
  fisrt_5_df$beta = round(fisrt_5_df$beta,3)
  fisrt_5_df=fisrt_5_df[,c("name","beta")]
  
  write.csv(fisrt_5_df,file=paste("first_5_genes_for_predicting_",cell_type,".csv",sep=""),row.names = F)
}

generate_fisrt_5(class_name[1],1,class_one_nonzero_beta_index,gene_name,result)
generate_fisrt_5(class_name[2],2,class_three_nonzero_beta_index,gene_name,result)
generate_fisrt_5(class_name[3],3,class_four_nonzero_beta_index,gene_name,result)
generate_fisrt_5(class_name[4],4,class_five_nonzero_beta_index,gene_name,result)
generate_fisrt_5(class_name[5],5,class_six_nonzero_beta_index,gene_name,result)
generate_fisrt_5(class_name[6],6,class_nine_nonzero_beta_index,gene_name,result)
generate_fisrt_5(class_name[7],7,class_combined_nonzero_beta_index,gene_name,result)
