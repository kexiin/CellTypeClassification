#include <Rcpp.h>
#include <RcppEigen.h>
#include <algorithm>
using namespace Rcpp;
// using namespace Eigen;

// Function to perform cosine normalization for matrix using RcppEigen
// [[Rcpp::depends(RcppEigen)]]
// [[Rcpp::export]]
Eigen::MatrixXd cosine_norm (const Eigen::MatrixXd& A) {
  Eigen::VectorXd norm2 = ((A.array().square()).rowwise().sum()).array().sqrt();
  return A.array().colwise() / norm2.array();
}


// Function to find the k nearest neighbors
// [[Rcpp::depends(RcppEigen)]]
// [[Rcpp::export]]
Eigen::MatrixXi kNN(const Eigen::MatrixXd& cell_dist, int k) {
  int n = cell_dist.rows();
  int m = cell_dist.cols();
  Eigen::MatrixXi result = Eigen::MatrixXi::Zero(n, m);
  
  for (int i = 0; i < n; ++i) {
    Eigen::VectorXd rowValues = cell_dist.row(i);
    
    // vector of indices
    std::vector<int> indices(rowValues.size());
    std::iota(indices.begin(), indices.end(), 0);
    
    // std::partial_sort to find the k-smallest indices in each row
    std::partial_sort(indices.begin(), indices.begin() + k, indices.end(),
                      [&rowValues](int i, int j) { return rowValues[i] < rowValues[j]; });
    
    // copy the k-smallest indices by setting adjacency matrix to 1
    for (int j = 0; j < k; ++j) {
      result(i, indices[j]) = 1;
    }
  }
  
  return result;
}


// Function to find the mutual nearest neighbors
// [[Rcpp::depends(RcppEigen)]]
// [[Rcpp::export]]
Eigen::MatrixXi MNN_match(const Eigen::MatrixXd& cell_dist, int k) {
  // kNN of each batch
  Eigen::MatrixXi knn_ref = kNN(cell_dist, k);
  Eigen::MatrixXi add_ref = kNN(cell_dist.transpose(), k);
  
  Eigen::MatrixXi neighbors = knn_ref + add_ref.transpose();
  return neighbors;
}


