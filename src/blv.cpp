#include <RcppArmadillo.h>
#include <tuple>
// [[Rcpp::depends(RcppArmadillo)]]

// Low level calculation of the BLV model
// [[Rcpp::export]]
Rcpp::List blv(const arma::mat& costs,
               const arma::vec& X,
               double alpha,
               double beta,
               const arma::vec& Z_init,
               double epsilon,
               int iter_max,
               int conv_check,
               double precision,
               bool quadratic) {
  arma::mat exp_beta_costs = arma::exp(-beta * costs);
  arma::vec Z(Z_init);
  arma::mat Y;

  int iter = 0;
  for(; iter < iter_max; iter++) {
    arma::vec Z_alpha = arma::pow(Z, alpha);
    arma::vec A = exp_beta_costs * Z_alpha;
    // one step of the output constrained model
    Y = ((X / (exp_beta_costs * Z_alpha)) * Z_alpha.t()) % exp_beta_costs;
    // dynamic part
    arma::vec D = (arma::sum(Y, 0)).t();
    arma::vec delta_Z;
    if(quadratic) {
      delta_Z = (D - Z) % Z;
    } else {
      delta_Z = (D - Z);
    }
    Z += epsilon * delta_Z;
    // test for convergence
    if((iter + 1) % conv_check == 0) {
      // relative precision
      double delta_norm = arma::norm(delta_Z);
      if(delta_norm < precision * (arma::norm(Z) + precision)) {
        break;
      }
    }
  }
  return Rcpp::List::create(Rcpp::Named("Y") = Y, Rcpp::Named("iter") = iter,
                            Rcpp::Named("Z") = Z);
}
