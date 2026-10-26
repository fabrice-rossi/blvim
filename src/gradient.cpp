// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
#include "projected_ascent.h"
#include "projection.h"
#include "rcpp_conversions.h"

// Projected gradient ascent of the potential, see maximise_potential(). With a
// NULL metric, the ascent uses the Euclidean metric in U = kappa Z / sum(X)
// ("gradient_unit"). Otherwise metric gives a diagonal preconditioner in U
// coordinates (rescaled to a unit mean): metric = kappa^2 corresponds to the
// Euclidean metric in Z ("gradient").
// [[Rcpp::export]]
Rcpp::List blv_gradient(const arma::mat& costs,
                        const arma::vec& X,
                        double alpha,
                        double beta,
                        const arma::vec& Z_init,
                        const arma::vec& kappa,
                        Rcpp::Nullable<Rcpp::NumericVector> metric = R_NilValue,
                        double rho_init = 0.5,
                        double shrink = 0.5,  // Shrinkage factor
                        double c = 1e-4,      // Sufficient increase param
                        int iter_max = 1000,
                        int ls_iter_max = 50,  // Max line search steps
                        double precision = 1e-7,
                        bool record_history = false) {
  blvim::AscentControl control;
  control.rho_initial = rho_init;
  control.shrink = shrink;
  control.armijo = c;
  control.max_iterations = iter_max;
  control.max_linesearch = ls_iter_max;
  control.gap_tolerance = precision;
  control.record_history = record_history;
  // we work on a transformed problem: make sure Z is in the weighted simplex,
  // then rescale it to the unit simplex
  const double X_tot = arma::sum(X);
  arma::vec Z = project_weighted_simplex(
      Z_init, kappa, arma::dot(kappa, kappa), X_tot,
      control.projection_tolerance, control.projection_max_iterations);
  arma::vec U = (Z % kappa);
  U /= X_tot;
  blvim::AscentResult result;
  if(metric.isNull()) {
    blvim::EuclideanMetric euclidean;
    result = blvim::maximise_potential(costs, X, alpha, kappa, beta, U,
                                       control, euclidean);
  } else {
    const arma::vec d = Rcpp::as<arma::vec>(metric);
    if(d.n_elem != kappa.n_elem || !d.is_finite() || d.min() <= 0.0)
      Rcpp::stop(
          "`metric` must be a finite and strictly positive vector with one "
          "value per destination.");
    blvim::DiagonalMetric diagonal(d);
    result = blvim::maximise_potential(costs, X, alpha, kappa, beta, U,
                                       control, diagonal);
  }
  // convert back
  Z = result.U / kappa;
  Z *= X_tot;
  Rcpp::List output = Rcpp::List::create(
      Rcpp::Named("Z") = Z, Rcpp::Named("Y") = result.flows,
      Rcpp::Named("iter") = result.iterations,
      Rcpp::Named("eval") = result.evaluations,
      Rcpp::Named("gap") = result.gap,
      Rcpp::Named("status") = result.status.message,
      Rcpp::Named("converged") = result.status.converged);
  if(record_history) {
    output.push_back(blvim::solver_status_list(result.status),
                     "solver_status");
    output.push_back(blvim::iteration_history_frame(result.history),
                     "history");
  }
  return output;
}
