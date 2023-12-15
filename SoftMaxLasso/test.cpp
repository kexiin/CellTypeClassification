
#include <RcppArmadillo.h>
using namespace arma;
// [[Rcpp::depends(RcppArmadillo)]]

// [[Rcpp::export]]

mat softmaxCpp(const mat& X)
{
  mat expX = arma::exp(X-repmat(max(X,1),1,X.n_cols));
  mat expXsum = arma::sum(expX, 1);
  mat expXsum_rep = repmat(expXsum, 1, X.n_cols);
  mat P = expX / expXsum_rep;
  return P;
}

// [[Rcpp::export]]
double fCpp(const mat& Beta,const mat& X,const mat& y_one_hot, int n,int p, int k)
{
  mat beta_resize = reshape(Beta, p, k);
  mat score = X * beta_resize;
  mat P = softmaxCpp(score);
  double epsilon = 1e-10;
  mat P_safe = P + epsilon;
  double loss = -arma::accu(y_one_hot % arma::log(P_safe)) / n;
  return(loss);
}

// [[Rcpp::export]]

mat gradfCpp(const mat& Beta,const mat& X,const mat& y_one_hot, int n,int p, int k)
{
  mat beta_resize = reshape(Beta, p, k);
  mat score = X * beta_resize;
  mat P = softmaxCpp(score);
  mat grad_matrix = X.t() * (P - y_one_hot) / n;
  return(reshape(grad_matrix,p*k,1));
}

// [[Rcpp::export]]

double gCpp(const mat& Beta, double lambda)
{
  double norm_Beta = norm(Beta, 1);
  double gvalue = lambda * norm_Beta;
  return(gvalue);
}

// [[Rcpp::export]]

mat gradgCpp(const mat& Beta,double tau, double lambda)
{
  mat result =  abs(Beta)-tau*lambda;
  result = max(result,zeros<mat>(result.n_rows, result.n_cols));
  mat gradg = result % sign(Beta);
  return(gradg);
}

// [[Rcpp::export]]

mat p_yCpp(double& lambda,double& L,mat& theta,const mat& X,const mat& y_one_hot,int& n,int& p,int& k)
{
  mat u = theta - 1/L * gradfCpp(theta,X,y_one_hot,n,p,k);
  mat v = gradgCpp(u,1/L,lambda);
  return(v);
}

// [[Rcpp::export]]

double QCpp(mat& theta1,mat& theta2,const mat& X,const mat& y_one_hot,double lambda, double& L,int& n,int& p,int& k)
{
  double arg = fCpp(theta2,X,y_one_hot,n,p,k)+dot((theta1-theta2).t(),gradfCpp(theta2,X,y_one_hot,n,p,k)) + L/2 * dot((theta1-theta2).t(),theta1-theta2)+gCpp(theta1,lambda);
  return(arg);
}


// [[Rcpp::export]]
Rcpp::List fistaCpp(double lambda, double L_init, const mat& theta0, const mat& X, const mat& y_one_hot, int max_iter=10000, double eps = 1e-6, double eita = 1.1, bool loss_compute =true, int n=1, int p=1, int k=1) 
{
  // Initialization
  double L_old = L_init;
  mat gama = theta0;
  mat p_l_gama = theta0;
  mat theta_old = theta0;
  mat theta_new = theta0;
  double t_old = 1;
  std::vector<double> loss_list = {100};
  double L_bar = 0;
  double fvalue = 0;
  double qvalue = -1;
  bool smallest_ik_condition = true;
  double L_new = 0;
  double tk = 0;
  
  // Iteration
  bool condition = true;
  int times = 1;
  int ik = 1;
  
  
  
  while (condition) {
    ik = 1;
    smallest_ik_condition = true;
    
    while (smallest_ik_condition) {
      L_bar = pow(eita, ik) * L_old;
      
      p_l_gama = p_yCpp(lambda, L_bar, gama, X, y_one_hot, n, p, k);
      fvalue = fCpp(p_l_gama, X, y_one_hot, n, p, k) + gCpp(p_l_gama, lambda);
      qvalue = QCpp(p_l_gama, gama, X, y_one_hot, lambda, L_bar, n, p, k);
      
      if (fvalue <= qvalue) {
        smallest_ik_condition = false;
      } else {
        ik++;
      }
    }
    
    loss_list.push_back(fvalue);
    
    L_new = L_bar;
    theta_new = p_yCpp(lambda, L_new, gama, X, y_one_hot, n, p, k);
    tk = (1 + sqrt(1 + 4 * t_old * t_old)) / 2;
    gama = theta_new + (t_old - 1) / tk * (theta_new - theta_old);
    t_old = tk;
    L_old = L_new;
    
    //bool end_loop_condition = false;
    
    double beta_delta = arma::max(arma::max(arma::abs(theta_new - theta_old)));
    //double loss_delta = std::abs(loss_list[times] - loss_list[times - 1]);
    
    // if (!loss_compute) {
    //   end_loop_condition = (times > max_iter) || (bool)(arma::max(arma::abs(theta_new - theta_old)) < eps);
    // } else {
    //   end_loop_condition = (times > max_iter) || (bool)(arma::max(arma::abs(theta_new - theta_old)) < eps) || (bool)(std::abs(loss_list[times] - loss_list[times - 1]) < 1e-3);
    // }
    
    if ((times > max_iter) || beta_delta < eps) {
      condition = false;
    } else {
      times++;
      theta_old = theta_new;
    }
  }
  
  return Rcpp::List::create(Rcpp::Named("theta") = reshape(theta_new, p, k),
                            Rcpp::Named("loss") = loss_list,
                            Rcpp::Named("iter_times") = times);
}



