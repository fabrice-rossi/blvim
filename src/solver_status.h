#pragma once
#include <string>

namespace blvim {

enum class SolverCode {
  not_started,
  converged,
  maximum_iterations,
  invalid_state,
  non_interior_state,
  linear_solve_failed,
  singular_jacobian,
  line_search_failed,
  step_too_small,
  infeasible_step
};

inline const char* solver_code_name(SolverCode code) {
  switch(code) {
    case SolverCode::not_started: return "not_started";
    case SolverCode::converged: return "converged";
    case SolverCode::maximum_iterations: return "maximum_iterations";
    case SolverCode::invalid_state: return "invalid_state";
    case SolverCode::non_interior_state: return "non_interior_state";
    case SolverCode::linear_solve_failed: return "linear_solve_failed";
    case SolverCode::singular_jacobian: return "singular_jacobian";
    case SolverCode::line_search_failed: return "line_search_failed";
    case SolverCode::step_too_small: return "step_too_small";
    case SolverCode::infeasible_step: return "infeasible_step";
  }
  return "unknown";  // # nocov
}

struct SolverStatus {
  SolverCode code = SolverCode::not_started;
  std::string message = "not started";
  bool converged = false;
};

template <typename Result>
inline void set_solver_status(Result& result, SolverCode code,
                              const std::string& message) {
  result.status.code = code;
  result.status.message = message;
  result.status.converged = code == SolverCode::converged;
}

} // namespace blvim
