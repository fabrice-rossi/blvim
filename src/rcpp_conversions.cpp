#include "rcpp_conversions.h"
using namespace Rcpp;
namespace blvim {

// Turn a named list of equal-length columns into a data frame by setting its
// attributes. Rcpp::DataFrame::create() calls back into R's as.data.frame(),
// which costs about 0.2 ms per call: more than a complete small solve.
static Rcpp::DataFrame as_data_frame(Rcpp::List columns, int rows) {
  columns.attr("class") = "data.frame";
  columns.attr("row.names") = IntegerVector::create(NA_INTEGER, -rows);
  return columns;
}

Rcpp::List solver_status_list(const SolverStatus& status) {
  return Rcpp::List::create(
    Rcpp::_["code"] = solver_code_name(status.code),
    Rcpp::_["message"] = status.message,
    Rcpp::_["converged"] = status.converged);
}

Rcpp::DataFrame iteration_history_frame(const IterationHistory& history) {
  const int n = static_cast<int>(history.size());
  Rcpp::IntegerVector iteration(n), reductions(n);
  Rcpp::NumericVector residual(n), merit(n), step_norm(n), accepted_scale(n),
    reciprocal_condition(n), minimum_U(n), beta(n);
  for(int i = 0; i < n; ++i) {
    iteration[i] = history[i].iteration;
    residual[i] = history[i].residual;
    merit[i] = history[i].merit;
    step_norm[i] = history[i].step_norm;
    accepted_scale[i] = history[i].accepted_scale;
    reductions[i] = history[i].line_search_reductions;
    reciprocal_condition[i] = history[i].reciprocal_condition;
    minimum_U[i] = history[i].minimum_U;
    beta[i] = history[i].beta;
  }
  return as_data_frame(List::create(
    _["iteration"] = iteration, _["residual"] = residual, _["merit"] = merit,
    _["step_norm"] = step_norm, _["accepted_scale"] = accepted_scale,
    _["line_search_reductions"] = reductions,
    _["reciprocal_condition"] = reciprocal_condition,
    _["minimum_U"] = minimum_U, _["beta"] = beta), n);
}

} // namespace blvim
