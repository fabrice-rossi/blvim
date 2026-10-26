#pragma once
#include <RcppArmadillo.h>
#include <limits>
#include <vector>

namespace blvim {

  struct IterationRecord {
    int iteration = 0;
    double residual = R_PosInf;
    double merit = R_PosInf;
    double step_norm = 0.0;
    double accepted_scale = 0.0;
    int line_search_reductions = 0;
    double reciprocal_condition = NA_REAL;
    double minimum_U = R_PosInf;
    int active = NA_INTEGER;  // number of positive U_j (projected ascent only)
    double beta = NA_REAL;
  };

  using IterationHistory = std::vector<IterationRecord>;

}  // namespace blvim
