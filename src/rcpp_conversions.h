#pragma once
#include <RcppArmadillo.h>
#include <string>
#include <vector>
#include "iteration_history.h"
#include "solver_status.h"

namespace blvim {

  Rcpp::List solver_status_list(const SolverStatus& status);
  Rcpp::DataFrame iteration_history_frame(const IterationHistory& history);
}  // namespace blvim
