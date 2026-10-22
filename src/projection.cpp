// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
#include <iomanip>
#include <sstream>

inline void eval_g_and_gprime(double lambda,
                              const arma::vec& y,
                              const arma::vec& kappa,
                              double C,
                              double& g,
                              double& g_prime) {
  g = -C;
  g_prime = 0.0;
  arma::uword p = y.n_elem;
  for(arma::uword i = 0; i < p; ++i) {
    double val = y[i] - lambda * kappa[i];
    if(val > 0.0) {
      g += kappa[i] * val;
      g_prime -= kappa[i] * kappa[i];
    }
  }
}

// Projection onto the weighted simplex
// [[Rcpp::export]]
arma::vec project_weighted_simplex(const arma::vec& y,
                                   const arma::vec& kappa,
                                   double sum_kappa_sq,
                                   double C,
                                   double tol,
                                   int max_iter) {
  arma::uword p = y.n_elem;
  if(p == 0)
    return arma::vec();
  if(p == 1)
    return arma::vec({C / kappa[0]});

  // 1. Analytical bounds calculation in O(p)
  double sum_kappa_y = arma::dot(kappa, y);
  double max_ratio = y[0] / kappa[0];
  for(arma::uword i = 1; i < p; ++i) {
    double ratio = y[i] / kappa[i];
    if(ratio > max_ratio)
      max_ratio = ratio;
  }

  double lambda_low = (sum_kappa_y - C) / sum_kappa_sq;
  double lambda_high = max_ratio - (C / sum_kappa_sq);

  // Initial guess at the midpoint of analytical bounds
  double lambda = 0.5 * (lambda_low + lambda_high);

  for(int iter = 0; iter < max_iter; ++iter) {
    double g, g_prime;
    eval_g_and_gprime(lambda, y, kappa, C, g, g_prime);

    // Tighten active bracket
    if(g > 0.0) {
      lambda_low = lambda;
    } else {
      lambda_high = lambda;
    }

    // Convergence check on function value or interval width
    if(std::abs(g) < tol || (lambda_high - lambda_low) < tol)
      break;

    // 2. Proposed Newton-Raphson Step
    double lambda_next;
    if(g_prime < -1e-12) {
      lambda_next = lambda - (g / g_prime);
      if(lambda_next <= lambda_low || lambda_next >= lambda_high) {
        lambda_next = 0.5 * (lambda_low + lambda_high);
      }
    } else {
      lambda_next = 0.5 * (lambda_low + lambda_high);  // Force safeguard
    }

    lambda = lambda_next;
  }

  // Construct final Z
  // No memory allocation
  arma::vec z(p);
  for(arma::uword i = 0; i < p; ++i) {
    z[i] = std::max(y[i] - lambda * kappa[i], 0.0);
  }
  return z;
}

// Projection onto the simplex
// [[Rcpp::export]]
arma::vec project_simplex(const arma::vec& y, double tol, int max_iter) {
  arma::uword p = y.n_elem;
  if(p == 0)
    return arma::vec();
  if(p == 1)
    return arma::vec({1.0});

  // 1. Initialize lambda using Armadillo's fast reduction
  double max_y = y.max();
  double lambda = max_y - 1.0 / static_cast<double>(p);

  // 2. Newton Iterations
  for(int iter = 0; iter < max_iter; ++iter) {
    double sum_active = 0.0;
    arma::uword count_active = 0;

    // Scalar loop avoids intermediate memory allocation
    for(arma::uword j = 0; j < p; ++j) {
      if(y[j] > lambda) {
        sum_active += y[j];
        count_active++;
      }
    }

    double lambda_new = (sum_active - 1.0) / static_cast<double>(count_active);

    if(std::abs(lambda - lambda_new) < tol) {
      lambda = lambda_new;
      break;
    }
    lambda = lambda_new;
  }

  // Construct final Z
  // no memory allocation
  arma::vec z(p);
  arma::uword count_active;
  for(size_t i = 0; i < p; ++i) {
    if(y[i] > lambda) {
      z[i] = y[i] - lambda;
      count_active++;
    } else {
      z[i] = 0.0;
    }
  }
  const double correction =
      (1.0 - arma::accu(z)) / static_cast<double>(count_active);

  if(abs(correction) < std::numeric_limits<double>::epsilon()) {
    // apply only to the largest value
    const arma::uword pivot = z.index_max();
    z[pivot] += static_cast<double>(count_active) * correction;
  } else {
    // spread the correction
    for(arma::uword j = 0; j < p; ++j) {
      if(z(j) > 0.0) {
        z(j) += correction;
      }
    }
  }
  // final check of the returned point. z>=0 is guaranteed by the construction
  // above we just need to test the sum
  double mass_error = std::abs(arma::accu(z) - 1.0);
  if(mass_error > tol) {
    std::ostringstream message;
    message << std::scientific
            << "Cannot project within the specified precision: "
            << "mass error = " << mass_error << ", tolerance = " << tol
            << ", correction = " << correction;
    Rcpp::stop(message.str());
  }
  return z;
}
