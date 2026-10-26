#include "projected_ascent.h"

#include <algorithm>
#include <cmath>
#include <limits>
#include <utility>

#include "projection.h"

namespace blvim {

  namespace {
    // Duality gap of the simplex-constrained problem and its scale. Returns
    // lambda = gradient' U.
    double simplex_gap(const arma::vec& gradient,
                       const arma::vec& U,
                       double& gap,
                       double& scale) {
      const double lambda = arma::dot(gradient, U);
      gap = gradient.max() - lambda;
      scale = std::max({1.0, std::abs(lambda), arma::abs(gradient).max()});
      return lambda;
    }
  }  // namespace

  arma::vec EuclideanMetric::project(const arma::vec& y,
                                     double tol,
                                     int max_iter) const {
    return project_simplex(y, tol, max_iter);
  }

  arma::vec DiagonalMetric::project(const arma::vec& y,
                                    double tol,
                                    int max_iter) const {
    return project_simplex_metric(y, d_, tol, max_iter);
  }

  template <typename Metric>
  AscentResult maximise_potential(const arma::mat& costs,
                                  const arma::vec& X,
                                  double alpha,
                                  const arma::vec& kappa,
                                  double beta,
                                  const arma::vec& U_start,
                                  const AscentControl& control,
                                  Metric& metric) {
    AscentResult out;
    const double eps = std::numeric_limits<double>::epsilon();
    const double tolerance = control.gap_tolerance;
    arma::vec U = project_simplex(U_start, control.projection_tolerance,
                                  control.projection_max_iterations);

    // W_ij = exp(-beta c_ij) / kappa_j^alpha, with each row scaled by its
    // maximum to avoid underflows. Row scaling cancels from the gradient, the
    // flows and relative changes of A.
    arma::mat log_W = -beta * costs;
    log_W.each_row() -= (alpha * arma::log(kappa)).t();
    const arma::vec log_row_scale = arma::max(log_W, 1);
    log_W.each_col() -= log_row_scale;
    const arma::mat W = arma::exp(log_W);

    // A_i = sum_j W_ij U_j^alpha
    arma::vec U_alpha = arma::pow(U, alpha);
    arma::vec A = W * U_alpha;
    arma::vec gradient;
    out.evaluations = 1;
    double rho_trial = control.rho_initial;
    bool converged = false;
    SolverCode code = SolverCode::maximum_iterations;
    const char* message = "maximum iteration reached";

    int iteration = 0;
    for(; iteration < control.max_iterations; ++iteration) {
      // R API calls are expensive for tiny problems: check from time to time.
      if((iteration & 63) == 0)
        Rcpp::checkUserInterrupt();
      gradient = arma::pow(U, alpha - 1.0) % (W.t() * (X / A));
      double gap_scale;
      const double lambda = simplex_gap(gradient, U, out.gap, gap_scale);
      if(control.record_history) {
        IterationRecord record;
        record.iteration = iteration;
        record.residual = out.gap;
        record.merit = -arma::dot(X, arma::log(A) + log_row_scale) / alpha;
        record.minimum_U = U.min();
        record.beta = beta;
        out.history.push_back(record);
      }
      if(out.gap <= tolerance + tolerance * gap_scale) {
        converged = true;
        break;
      }

      metric.update(U);
      const arma::vec direction = metric.direction(gradient, lambda);
      const double step_tolerance =
          std::max(10.0 * eps * std::max(1.0, arma::norm(U, 2)),
                   control.projection_tolerance);
      double rho = rho_trial;
      bool accepted = false;
      bool stalled = false;
      for(int ls = 0; ls < control.max_linesearch; ++ls) {
        arma::vec U_new =
            metric.project(U + rho * direction, control.projection_tolerance,
                           control.projection_max_iterations);
        const arma::vec step = U_new - U;
        const double step_norm = arma::norm(step, 2);
        if(step_norm <= step_tolerance) {
          stalled = true;
          break;
        }
        const double expected_increase =
            control.armijo * arma::dot(gradient, step);
        if(expected_increase <= 0.0) {
          rho *= control.shrink;
          continue;
        }
        arma::vec U_new_alpha = arma::pow(U_new, alpha);
        arma::vec A_new = W * U_new_alpha;
        ++out.evaluations;
        const arma::vec relative_change = (A_new - A) / A;
        if(!relative_change.is_finite() || arma::any(relative_change <= -1.0)) {
          rho *= control.shrink;
          continue;
        }
        // Accurate potential increase, even when the two values are close.
        const double increase =
            arma::sum(X % arma::log1p(relative_change)) / alpha;
        if(increase >= expected_increase) {
          U = std::move(U_new);
          U_alpha = std::move(U_new_alpha);
          A = std::move(A_new);
          rho_trial =
              ls == 0 ? std::min(control.rho_initial, control.growth * rho)
                      : rho;
          accepted = true;
          if(control.record_history) {
            out.history.back().step_norm = step_norm;
            out.history.back().accepted_scale = rho;
            out.history.back().line_search_reductions = ls;
          }
          break;
        }
        rho *= control.shrink;
      }
      if(stalled) {
        code = SolverCode::step_too_small;
        message = "stalled";
        break;
      }
      if(!accepted) {
        code = SolverCode::line_search_failed;
        message = "line search failed";
        break;
      }
    }
    out.iterations = iteration;

    if(!converged) {
      // The last accepted step may have reached the tolerance.
      gradient = arma::pow(U, alpha - 1.0) % (W.t() * (X / A));
      double gap_scale;
      simplex_gap(gradient, U, out.gap, gap_scale);
      converged = out.gap <= tolerance + tolerance * gap_scale;
    }
    if(converged)
      set_solver_status(out, SolverCode::converged, "converged");
    else
      set_solver_status(out, code, message);

    out.flows = W;
    out.flows.each_row() %= U_alpha.t();
    out.flows.each_col() %= X / A;
    out.U = std::move(U);
    return out;
  }

  template AscentResult maximise_potential<EuclideanMetric>(
      const arma::mat&, const arma::vec&, double, const arma::vec&, double,
      const arma::vec&, const AscentControl&, EuclideanMetric&);
  template AscentResult maximise_potential<DiagonalMetric>(
      const arma::mat&, const arma::vec&, double, const arma::vec&, double,
      const arma::vec&, const AscentControl&, DiagonalMetric&);

}  // namespace blvim
