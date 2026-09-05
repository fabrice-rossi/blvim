// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

// Helper function to evaluate the root-finding constraint g(lambda)
double eval_g(double lambda,
              const arma::vec& Y,
              const arma::vec& kappa,
              double C) {
  double sum = 0.0;
  for(size_t i = 0; i < Y.n_elem; ++i) {
    double val = Y[i] + lambda * kappa[i];
    if(val > 0)
      sum += kappa[i] * val;
  }
  return sum - C;
}

// Projection onto the weighted simplex
// [[Rcpp::export]]
arma::vec project_weighted_simplex(const arma::vec& Y,
                                   const arma::vec& kappa,
                                   double C,
                                   double tol,
                                   int max_iter) {
  // 1. Bracket the root for lambda
  double lambda_low = -1.0;
  while(eval_g(lambda_low, Y, kappa, C) > 0) {
    lambda_low *= 2.0;
  }

  double lambda_high = 1.0;
  while(eval_g(lambda_high, Y, kappa, C) < 0) {
    lambda_high *= 2.0;
  }

  // 2. Bisection search to find exact lambda
  double lambda_mid = 0.0;

  for(int iter = 0; iter < max_iter; ++iter) {
    lambda_mid = (lambda_low + lambda_high) / 2.0;
    if(eval_g(lambda_mid, Y, kappa, C) > 0) {
      lambda_high = lambda_mid;
    } else {
      lambda_low = lambda_mid;
    }
    if((lambda_high - lambda_low) < tol)
      break;
  }

  // 3. Compute final Z based on lambda*
  arma::vec Z = arma::zeros(Y.n_elem);
  for(size_t i = 0; i < Y.n_elem; ++i) {
    double val = Y[i] + lambda_mid * kappa[i];
    if(val > 0)
      Z[i] = val;
  }
  return Z;
}
