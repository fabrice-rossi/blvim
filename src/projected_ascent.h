#pragma once

#include <RcppArmadillo.h>

#include <limits>
#include <string>

#include "iteration_history.h"
#include "solver_status.h"

namespace blvim {

struct AscentControl {
  int max_iterations = 1000;
  int max_linesearch = 50;
  double rho_initial = 0.5;
  double shrink = 0.5;
  double growth = 1.25;
  double armijo = 1e-4;
  double gap_tolerance = 1e-7;
  double projection_tolerance =
    10.0 * std::numeric_limits<double>::epsilon();
  int projection_max_iterations = 50;
  bool record_history = false;
};

struct AscentResult {
  arma::vec U;
  arma::mat flows;
  int iterations = 0;
  int evaluations = 0;  // evaluations of A, including the initial one
  double gap = R_PosInf;
  SolverStatus status;
  IterationHistory history;
};

/**
 * Metrics (preconditioners) for maximise_potential(). A metric defines a
 * diagonal, possibly state dependent, inner product <u, v> = sum_j u_j v_j /
 * d_j in U coordinates. The ascent direction is then d % gradient and trial
 * points are projected onto the unit simplex for the associated norm.
 *
 * A metric class provides:
 * - void update(const arma::vec& U): called at each iterate before the line
 *   search;
 * - arma::vec direction(const arma::vec& gradient, double lambda) const:
 *   returns d % (gradient - lambda); the shift by lambda = gradient' U does
 *   not change projected points but keeps the trial points well scaled;
 * - arma::vec project(const arma::vec& y, double tol, int max_iter) const.
 *
 * d should have a typical value of 1 so that rho_initial keeps its meaning
 * across metrics. New metrics must be instantiated in projected_ascent.cpp.
 */

// The standard Euclidean metric (d = 1).
class EuclideanMetric {
 public:
  void update(const arma::vec&) {}
  arma::vec direction(const arma::vec& gradient, double lambda) const {
    return gradient - lambda;
  }
  arma::vec project(const arma::vec& y, double tol, int max_iter) const;
};

// A constant diagonal metric, rescaled to a unit mean.
class DiagonalMetric {
 public:
  explicit DiagonalMetric(const arma::vec& d) : d_(d / arma::mean(d)) {}
  void update(const arma::vec&) {}
  arma::vec direction(const arma::vec& gradient, double lambda) const {
    return d_ % (gradient - lambda);
  }
  arma::vec project(const arma::vec& y, double tol, int max_iter) const;
  const arma::vec& values() const { return d_; }

 private:
  arma::vec d_;
};

/**
 * Projected gradient ascent of the potential in U = kappa Z / sum(X) on the
 * unit simplex, with Armijo backtracking, for the metric given by `metric`.
 * Stops when the duality gap max(gradient) - gradient' U is below
 * gap_tolerance * (1 + scale). The duality gap does not depend on the metric.
 *
 * costs is origins by destinations; kappa has one entry per destination.
 */
template <typename Metric>
AscentResult maximise_potential(const arma::mat& costs,
                                const arma::vec& X,
                                double alpha,
                                const arma::vec& kappa,
                                double beta,
                                const arma::vec& U_start,
                                const AscentControl& control,
                                Metric& metric);

}  // namespace blvim
