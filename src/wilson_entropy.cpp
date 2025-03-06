#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]

// low level calculation of Wilson's output constrained maximal entropy model
// exp_beta_costs is exp(-beta cost)
// X contains the outputs (production)
// Z_alpha is Z^alpha (attractivenesses)
// the function returns the flow matrix
arma::mat ll_we_oc(const arma::mat& exp_beta_costs,
                   const arma::vec& X,
                   const arma::vec& Z_alpha) {
  return ((X/(exp_beta_costs * Z_alpha)) * Z_alpha.t()) % exp_beta_costs;
}

// [[Rcpp::export]]
arma::mat we_oc(const arma::mat& costs,
                const arma::vec& X,
                double alpha,
                double beta,
                const arma::vec& Z) {
  arma::mat exp_beta_costs = arma::exp(-beta * costs);
  arma::vec Z_alpha = arma::pow(Z, alpha);
  return ll_we_oc(exp_beta_costs, X, Z_alpha);
}

