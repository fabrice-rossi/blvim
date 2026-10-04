// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
#include "projection.h"

inline void weighted_gap(const arma::vec& grad,
                         const arma::vec& Z,
                         const arma::vec& kappa,
                         double X_tot,
                         double& gap,
                         double& scale) {
  arma::vec scaled_grad = grad / kappa;
  double lambda = arma::dot(grad, Z) / X_tot;

  gap = arma::max(scaled_grad - lambda);

  scale = std::max({1.0, std::abs(lambda), arma::max(arma::abs(scaled_grad))});
}

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
  double precision_projection = std::max(precision * 1e-3, 1e-10);
  int iter_max_projection = 50;
  std::string status = "maximum iteration reached";
  bool converged = false;
  double gap_atol = precision;
  double gap_rtol = precision;
  // pre-computation for the projection
  double sum_kappa_sq = arma::dot(kappa, kappa);
  double X_tot = arma::sum(X);
  // make sure Z is in the simplex
  arma::vec Z =
      project_weighted_simplex(Z_init, kappa, sum_kappa_sq, X_tot,
                               precision_projection, iter_max_projection);
  // we stabilize the cost calculation to avoid underflows
  // multiplying each row of W by a constant value cancels out because
  // of the normalisation in most quantities associated to the production
  // constraints
  arma::vec row_min = arma::min(costs, 1);
  arma::mat shifted_costs = costs;
  shifted_costs.each_col() -= row_min;
  arma::mat W = arma::exp(-beta * shifted_costs);
  // rescale rho_init to adapt to X_tot
  rho_init *= X_tot * X_tot;
  double rho;
  double rho_max = rho_init;
  double rho_trial = rho_init;
  bool ls_success;
  // A_i=sum_{k=1}^p Z_k^alpha W_{ik}
  arma::vec Z_alpha = arma::pow(Z, alpha);
  arma::vec A = W * Z_alpha;
  arma::vec grad;
  double gap;
  int iter = 0;
  int feval = 1;  // number of evaluations of A
  for(; iter < iter_max; ++iter) {
    // gradient
    grad = arma::pow(Z, alpha - 1.0) % (W.t() * (X / A));
    // duality gap
    double gap_scale;
    weighted_gap(grad, Z, kappa, X_tot, gap, gap_scale);
    if(gap <= gap_atol + gap_rtol * gap_scale) {
      converged = true;
      status = "converged";
      break;
    }
    rho = rho_trial;
    arma::vec Z_new = Z;
    arma::vec Z_new_alpha = Z_alpha;

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
      Z_new_alpha = arma::pow(Z_new, alpha);
      arma::vec A_new = W * Z_new_alpha;
      feval++;
      arma::vec rel_A_change = (A_new - A) / A;
      if(!rel_A_change.is_finite() || arma::any(rel_A_change <= -1.0)) {
        rho *= shrink;
        continue;
      }
      // compute the increase in objective with high precision
      actual_increase = arma::sum(X % arma::log1p(rel_A_change)) / alpha;

      // Armijo condition for maximization
      double expected_increase = c * arma::dot(grad, Z_new - Z);
      if(expected_increase <= 0) {
        rho *= shrink;
        continue;
      }

      if(actual_increase >= expected_increase) {
        ls_success = true;
        // prepare for next step
        A = std::move(A_new);
        rho_trial = std::min(rho_max, rho / shrink);
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
    const double eps = std::numeric_limits<double>::epsilon();
    const double x_atol = 10.0 * eps;
    const double x_rtol = 100.0 * eps;
    double step_norm = arma::norm(Z_new - Z, 2);
    double z_scale = std::max(1.0, arma::norm(Z, 2));
    bool small_step = step_norm <= x_atol + x_rtol * z_scale;
    if(small_step) {
      status = "stalled";
      Z = std::move(Z_new);
      Z_alpha = std::move(Z_new_alpha);
      break;
    }
    Z = std::move(Z_new);
    Z_alpha = std::move(Z_new_alpha);
  }
  if(!converged) {
    arma::vec grad_final = arma::pow(Z, alpha - 1.0) % (W.t() * (X / A));
    double gap_final, gap_scale_final;
    weighted_gap(grad_final, Z, kappa, X_tot, gap_final, gap_scale_final);
    if(gap_final <= gap_atol + gap_rtol * gap_scale_final) {
      converged = true;
      status = "converged";
    }
    gap = gap_final;
  }
  return Rcpp::List::create(
      Rcpp::Named("Z") = Z, Rcpp::Named("Y") = ((X / A) * Z_alpha.t()) % W,
      Rcpp::Named("iter") = iter, Rcpp::Named("eval") = feval,
      Rcpp::Named("gap") = gap, Rcpp::Named("status") = status,
      Rcpp::Named("converged") = converged);
}

inline void simplex_gap(const arma::vec& grad,
                        const arma::vec& U,
                        double& gap,
                        double& scale) {
  double lambda = arma::dot(grad, U);

  gap = arma::max(grad - lambda);

  scale = std::max({1.0, std::abs(lambda), arma::max(arma::abs(grad))});
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
  double precision_projection = std::max(precision * 1e-3, 1e-10);
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

  // cost rescaling (transformed problem)
  // we stabilize the cost calculation to avoid underflows
  // multiplying each row of W by a constant value cancels out because
  // of the normalisation in most quantities associated to the production
  // constraints
  arma::mat logW = -beta * costs;
  logW.each_row() -= (alpha * arma::log(kappa)).t();
  arma::vec row_max = arma::max(logW, 1);
  logW.each_col() -= row_max;
  arma::mat W = arma::exp(logW);

  double rho;
  double rho_max = rho_init;
  double rho_trial = rho_init;
  // A_i=sum_{k=1}^p U_k^alpha W_{ik}
  arma::vec U_alpha = arma::pow(U, alpha);
  arma::vec A = W * U_alpha;
  arma::vec grad;
  double gap;
  int iter = 0;
  int feval = 1;  // number of evaluations of A
  for(; iter < iter_max; ++iter) {
    grad = arma::pow(U, alpha - 1.0) % (W.t() * (X / A));
    // duality gap
    double gap_scale;
    simplex_gap(grad, U, gap, gap_scale);
    if(gap <= gap_atol + gap_rtol * gap_scale) {
      // converged
      converged = true;
      status = "converged";
      break;
    }
    arma::vec reduced_grad = grad - arma::dot(grad, U);
    rho = rho_trial;
    arma::vec U_new = U;
    arma::vec U_new_alpha = U_alpha;

    // Armijo Backtracking Line Search
    bool ls_success = false;
    double actual_increase;
    for(int ls_iter = 0; ls_iter < ls_iter_max; ++ls_iter) {
      // Gradient Ascent Step & Projection
      arma::vec Y = U + rho * reduced_grad;
      U_new = project_simplex(Y, precision_projection, iter_max_projection);
      U_new_alpha = arma::pow(U_new, alpha);

      // Evaluate new A which is sufficient for testing objective improvement
      arma::vec A_new = W * U_new_alpha;
      feval++;

      arma::vec rel_A_change = (A_new - A) / A;
      if(!rel_A_change.is_finite() || arma::any(rel_A_change <= -1.0)) {
        rho *= shrink;
        continue;
      }
      // compute the increase in objective with high precision
      actual_increase = arma::sum(X % arma::log1p(rel_A_change)) / alpha;

      // Armijo condition for maximisation
      double expected_increase = c * arma::dot(grad, U_new - U);
      if(expected_increase <= 0) {
        rho *= shrink;
        continue;
      }

      if(actual_increase >= expected_increase) {
        ls_success = true;
        // prepare for next step
        A = std::move(A_new);
        rho_trial = std::min(rho_max, rho / shrink);
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
    const double eps = std::numeric_limits<double>::epsilon();
    const double x_atol = 10.0 * eps;
    const double x_rtol = 100.0 * eps;
    double step_norm = arma::norm(U_new - U, 2);
    double u_scale = std::max(1.0, arma::norm(U, 2));
    bool small_step = step_norm <= x_atol + x_rtol * u_scale;
    if(small_step) {
      status = "stalled";
      U = std::move(U_new);
      U_alpha = std::move(U_new_alpha);
      break;
    }
    U = std::move(U_new);
    U_alpha = std::move(U_new_alpha);
  }
  if(!converged) {
    arma::vec grad_final = arma::pow(U, alpha - 1.0) % (W.t() * (X / A));
    double gap_final, gap_scale_final;
    simplex_gap(grad_final, U, gap_final, gap_scale_final);
    if(gap_final <= gap_atol + gap_rtol * gap_scale_final) {
      converged = true;
      status = "converged";
    }
    gap = gap_final;
  }
  // convert back
  arma::vec Z = U / kappa;
  Z *= X_tot;
  arma::vec row_min = arma::min(costs, 1);
  arma::mat shifted_costs = costs;
  shifted_costs.each_col() -= row_min;
  arma::mat preW = arma::exp(-beta * shifted_costs);
  arma::vec Z_alpha = arma::pow(Z, alpha);
  A = preW * Z_alpha;
  return Rcpp::List::create(
      Rcpp::Named("Z") = Z, Rcpp::Named("Y") = ((X / A) * Z_alpha.t()) % preW,
      Rcpp::Named("iter") = iter, Rcpp::Named("eval") = feval,
      Rcpp::Named("gap") = gap, Rcpp::Named("status") = status,
      Rcpp::Named("converged") = converged);
}
