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
  arma::mat Y(exp_beta_costs.n_rows, exp_beta_costs.n_cols);
  arma::vec A = exp_beta_costs * Z_alpha;
  for(uint j = 0; j < Y.n_cols; j++) {
    for(uint i = 0; i < Y.n_rows; i++) {
      Y(i, j) = X.at(i) * Z_alpha.at(j) * exp_beta_costs.at(i, j) / A.at(i);
    }
  }
  return Y;
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
