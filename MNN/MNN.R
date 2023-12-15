library(proxy)
library(Rcpp)
Rcpp::sourceCpp("~/biostat625/CellTypeClassification/MNN/MNN.cpp")


#' Function to calculate the cosine distance between reference group and new group
#' @param data input dataset, including reference and new group
#' @param ref_id ID of reference group
#' @param add_id ID of new group that plan to add
#' @return A matrix of cosine distance
#' @export
#'
cosine_dist = function(data, ref_id, add_id) {
  return(2 * proxy::dist(cosine_norm(data[ref_id, ]), cosine_norm(data[add_id, ]), method = "cosine"))
}


#' A implementation of Mutual Nearest Neighbors
#' @param data input dataset, including reference and new group
#' @param b vector for Krylov-subspace
#' @param ref_id ID of reference group
#' @param add_id ID of new group that plan to add
#' @param p dimension of column numbers of data
#' @return A list containing new features of each cell and new reference group
#' @import Rcpp
#' @export
#'
MNN = function(data, ref_id, add_id, p) {
  cell_dist = cosine_dist(as.matrix(data[, 1:p]), cell_ref_id, cell_add_id)
  neighbors = MNN_match(as.matrix(cell_dist), k)
  rownames(neighbors) = ref_id
  colnames(neighbors) = add_id

  ids = which(neighbors == 2, arr.ind = TRUE)
  pair_row = rownames(neighbors)[ids[, 1]]
  pair_col = colnames(neighbors)[ids[, 2]]
  gene_expression_diff = data[pair_row, 1:p] - data[pair_col, 1:p]

  # Gaussian kernel
  sigma = 10
  weights = exp(-rowSums(gene_expression_diff^2) / (2 * sigma^2))
  # wighted mean of diff vectors
  batch_correction_vector = colSums(gene_expression_diff * weights) / sum(weights)

  data[ref_id, 1:p] = data[ref_id, 1:p] - as.matrix(batch_correction_vector)
  return(list(data=data, ref_new=c(ref_id, add_id)))
}


#' Function to evaluate the clustering accuracy
#' @param true_labels true labels of cells
#' @param pred_labels predicted labels of cells
#' @return Accuracy of clustering using Greed Algorithm
#' @export
#'
eval_clustering_accuracy = function(true_labels, pred_labels) {
  counts = table(true_labels, pred_labels)
  row_sel = c()
  col_sel = c()
  matches = 0
  for(i in 1:nrow(counts)) {
    if ( i <= ncol(counts) ) {
      # set up the count matrix excluding the selected rows/cols
      tmp_counts = counts
      tmp_counts[row_sel, 1:ncol(counts)] = -1
      tmp_counts[1:nrow(counts), col_sel] = -1
      # identify the best matching row/cols
      idx = which.max(tmp_counts)                 # 1-based index from the entire matrix
      row_idx = ((idx - 1) %% ncol(counts)) + 1   # extract the row index
      col_idx = ((idx - 1) %/% ncol(counts)) + 1  # extract the column index
      matches = matches + tmp_counts[idx]         # update the match count
      # add the selected rows and columns
      row_sel = c(row_sel, row_idx)
      col_sel = c(col_sel, col_idx)
    }
  }
  return(matches/sum(counts))
}
