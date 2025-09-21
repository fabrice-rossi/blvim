#' Validate inputs of interaction models
#'
#' This function validates its inputs and abort in case of problems.
#'
#' @param costs a cost matrix of size (n,p)
#' @param X a vector of production constraints of size n
#' @param alpha a positive return to scale parameter
#' @param beta a positive inverse cost scale parameter
#' @param Z a vector of destination attractivenesses of size p
#' @param call caller environment for proper error reporting
#'
#' @noRd
#' @returns nothing
check_configuration <- function(costs, X, alpha, beta, Z, bipartite, call = rlang::caller_env()) {
  ## basic check for bipartite
  if (!bipartite && length(X) != length(Z)) {
    cli::cli_abort(
      c("If {.arg bipartite} is {.val FALSE}, origin and location data must be equal.",
        "x" = "the model has {.val {length(X)}} origin locations and {.val {length(Z)}} destination locations"
      ),
      call = call
    )
  }
  if (!is.matrix(costs)) {
    cli::cli_abort("{.arg costs} must be a matrix",
      call = call
    )
  }
  if (nrow(costs) != length(X)) {
    cli::cli_abort(
      c("{.arg costs} must have {.val {length(X)}} rows",
        "x" = "{.arg costs} has {.val {nrow(costs)}} rows"
      ),
      call = call
    )
  }
  if (ncol(costs) != length(Z)) {
    cli::cli_abort(
      c("{.arg costs} must have {.val {length(Z)}} columns",
        "x" = "{.arg costs} has {.val {ncol(costs)}} columns"
      ),
      call = call
    )
  }
  if (!is.numeric(alpha) || length(alpha) != 1 || alpha <= 0) {
    cli::cli_abort(
      c("{.arg alpha} must be a positive number",
        "x" = "{.arg alpha} is {.val {head(alpha)}}"
      ),
      call = call
    )
  }
  if (!is.numeric(beta) || length(beta) != 1 || beta <= 0) {
    cli::cli_abort(
      c("{.arg beta} must be a positive number",
        "x" = "{.arg beta} is {.val {head(beta)}}"
      ),
      call = call
    )
  }
}
