// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
#include "projection.h"

// [[Rcpp::export]]
Rcpp::List blv_gradient(const arma::mat& costs,
                        const arma::vec& X,
                        double alpha,
                        double beta,
                        const arma::vec& Z_init,
                        const arma::vec& kappa,
                        double rho_init = 0.75,
                        double shrink = 0.5,  // Shrinkage factor
                        double c = 1e-4,      // Sufficient increase param
                        int iter_max = 1000,
                        int ls_iter_max = 50,  // Max line search steps
                        double precision = 1e-7) {
  double sum_kappa_sq = arma::dot(kappa, kappa);
  double X_tot = arma::sum(X);
  double precision_projection = std::max(precision * 1e-7, 1e-14);
  int iter_max_projection = 50;
  std::string status = "maximum iteration reached";
  bool converged = false;
  // make sure Z is in the simplex
  arma::vec Z =
      project_weighted_simplex(Z_init, kappa, sum_kappa_sq, X_tot,
                               precision_projection, iter_max_projection);
  arma::mat W = arma::exp(-beta * costs);
  arma::mat YdivZ;
  int iter = 0;
  int feval = 1;
  // rescale rho_init to adapt to X_tot
  rho_init *= X_tot * X_tot;
  double rho;
  bool ls_success;
  arma::vec A = W * arma::pow(Z, alpha);
  arma::vec grad;
  double gap;
  for(; iter < iter_max; ++iter) {
    // gradient
    grad = arma::pow(Z, alpha - 1.0) % (W.t() * (X / A));
    // duality gap
    gap = X_tot * arma::max(grad / kappa) - arma::dot(grad, Z);
    if(gap < precision) {
      // converged
      converged = TRUE;
      status = "converged";
      break;
    }
    rho = rho_init;
    arma::vec Z_new = Z;

    // Armijo Backtracking Line Search
    ls_success = false;
    double actual_increase;
    double normal_coefficient = arma::dot(grad, kappa) / sum_kappa_sq;
    arma::vec reduced_grad = grad - normal_coefficient * kappa;
    for(int ls_iter = 0; ls_iter < ls_iter_max; ++ls_iter) {
      // Gradient Ascent Step & Projection
      arma::vec Y = Z + rho * reduced_grad;
      Z_new =
          project_weighted_simplex(Y, kappa, sum_kappa_sq, X_tot,
                                   precision_projection, iter_max_projection);

      // Evaluate new objective value
      arma::vec A_new = W * arma::pow(Z_new, alpha);
      feval++;
      arma::vec rel_A_change = (A_new - A) / A;
      if(!rel_A_change.is_finite() || arma::any(rel_A_change <= -1.0)) {
        rho *= shrink;
        continue;
      }
      // compute the increase in objective with high precision
      actual_increase = arma::sum(X % arma::log1p(rel_A_change)) / alpha;

      // Armijo condition for maximization
      double expected_increase = c * arma::dot(reduced_grad, Z_new - Z);

      if(actual_increase >= expected_increase) {
        ls_success = true;
        // prepare for next step
        A = A_new;
        break;  // Step size accepted
      }

      // Backtrack
      rho *= shrink;
    }

    if(!ls_success) {
      // we keep the current Z
      status = "line search failed";
      break;
    }
    // checking for a stalled process
    double x_atol = 1e-15;
    double f_atol = 1e-15;
    double f_rtol = 1e-13;
    double step_norm = arma::norm(Z_new - Z, 2);
    bool small_step = step_norm <= x_atol;
    if(small_step) {
      // A has been updated
      double f_val = arma::sum(X % log(A)) / alpha;
      double f_scale = std::max(1.0, std::abs(f_val));
      if(abs(actual_increase) <= f_atol + f_rtol * f_scale) {
        status = "stalled";
        Z = Z_new;
        break;
      }
    }
    Z = Z_new;
  }
  return Rcpp::List::create(
      Rcpp::Named("Z") = Z,
      Rcpp::Named("Y") = ((X / A) * arma::pow(Z, alpha).t()) % W,
      Rcpp::Named("iter") = iter, Rcpp::Named("eval") = feval,
      Rcpp::Named("gap") = gap, Rcpp::Named("status") = status,
      Rcpp::Named("converged") = converged);
}

// [[Rcpp::export]]
Rcpp::List blv_gradient_unit(const arma::mat& costs,
                             const arma::vec& X,
                             double alpha,
                             double beta,
                             const arma::vec& Z_init,
                             const arma::vec& kappa,
                             double rho_init = 0.75,
                             double shrink = 0.5,  // Shrinkage factor
                             double c = 1e-4,      // Sufficient increase param
                             int iter_max = 1000,
                             int ls_iter_max = 50,  // Max line search steps
                             double precision = 1e-7) {
  double precision_projection = std::max(precision * 1e-7, 1e-14);
  int iter_max_projection = 50;
  std::string status = "maximum iteration reached";
  bool converged = false;
  double gap_atol = precision;
  double gap_rtol = precision;
  // we work on a transformed problem
  double X_tot = arma::sum(X);
  arma::vec U = (Z_init % kappa);
  U /= X_tot;
  // make sure U is in the simplex !
  U = project_simplex(U, precision_projection, iter_max_projection);

  arma::mat preW = arma::exp(-beta * costs);
  arma::mat W = preW.each_row() / arma::pow(kappa, alpha).t();
  int iter = 0;
  int feval = 1;
  double rho;
  // sum_{k=1}^p U_p^alpha W_{ik}
  arma::vec A = W * arma::pow(U, alpha);
  arma::vec grad;
  double gap;
  for(; iter < iter_max; ++iter) {
    grad = arma::pow(U, alpha - 1.0) % (W.t() * (X / A));
    // duality gap
    double grad_mean = arma::dot(grad, U);
    arma::vec reduced_grad = grad - grad_mean;
    gap = arma::max(reduced_grad);
    double gap_scale = std::max(1.0, arma::max(arma::abs(reduced_grad)));

    if(gap <= gap_atol + gap_rtol * gap_scale) {
      // converged
      converged = TRUE;
      status = "converged";
      break;
    }
    rho = rho_init;
    arma::vec U_new = U;

    // Armijo Backtracking Line Search
    bool ls_success = false;
    double actual_increase;
    for(int ls_iter = 0; ls_iter < ls_iter_max; ++ls_iter) {
      // Gradient Ascent Step & Projection
      arma::vec Y = U + rho * reduced_grad;
      U_new = project_simplex(Y, precision_projection, iter_max_projection);

      // Evaluate new A which is sufficient for testing objective improvement
      arma::vec A_new = W * arma::pow(U_new, alpha);
      feval++;

      arma::vec rel_A_change = (A_new - A) / A;
      if(!rel_A_change.is_finite() || arma::any(rel_A_change <= -1.0)) {
        rho *= shrink;
        continue;
      }
      // compute the increase in objective with high precision
      actual_increase = arma::sum(X % arma::log1p(rel_A_change)) / alpha;

      // Armijo condition for maximisation
      double expected_increase = c * arma::dot(reduced_grad, U_new - U);

      if(actual_increase >= expected_increase) {
        ls_success = true;
        // prepare for next step
        A = A_new;
        break;  // Step size accepted
      }

      // Backtrack
      rho *= shrink;
    }

    if(!ls_success) {
      // we keep the current U
      status = "line search failed";
      break;
    }
    // checking for a stalled process
    double x_atol = 1e-15;
    double f_atol = 1e-15;
    double f_rtol = 1e-13;
    double step_norm = arma::norm(U_new - U, 2);
    bool small_step = step_norm <= x_atol;
    if(small_step) {
      // A has been updated
      double f_val = arma::sum(X % log(A)) / alpha;
      double f_scale = std::max(1.0, std::abs(f_val));
      if(abs(actual_increase) <= f_atol + f_rtol * f_scale) {
        status = "stalled";
        U = U_new;
        break;
      }
    }
    U = U_new;
  }
  if(!converged) {
    arma::vec A_unit = W * arma::pow(U, alpha);
    arma::vec grad_final = arma::pow(U, alpha - 1.0) % (W.t() * (X / A_unit));
    double grad_mean_final = arma::dot(grad_final, U);
    arma::vec reduced_grad_final = grad_final - grad_mean_final;
    double gap_final = arma::max(reduced_grad_final);
    double gap_scale_final =
        std::max(1.0, arma::max(arma::abs(reduced_grad_final)));
    if(gap_final <= gap_atol + gap_rtol * gap_scale_final) {
      converged = true;
      status = "converged";
    }
    gap = gap_final;
  }
  // convert back
  arma::vec Z = U / kappa;
  Z *= X_tot;
  A = preW * arma::pow(Z, alpha);
  return Rcpp::List::create(
      Rcpp::Named("Z") = Z,
      Rcpp::Named("Y") = ((X / A) * arma::pow(Z, alpha).t()) % preW,
      Rcpp::Named("iter") = iter, Rcpp::Named("eval") = feval,
      Rcpp::Named("gap") = gap, Rcpp::Named("status") = status,
      Rcpp::Named("converged") = converged);
}
