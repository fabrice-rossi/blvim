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

#' Validate quantile specification
#'
#' The function verifies that qmin and qmax are numerical values such that
#' 0<=qmin<qmax<=1. It aborts in case of problem.
#'
#' @param qmin low quantile
#' @param qmax high quantile
#' @param call caller environment for proper error reporting
#'
#' @returns nothing
#' @noRd
check_quantiles <- function(qmin, qmax, call = rlang::caller_env()) {
  if (!is.numeric(qmin) || length(qmin) != 1 || qmin < 0 || qmin > 1) {
    cli::cli_abort(
      c("{.arg qmin} must be a number between 0 and 1",
        "x" = "{.arg qmin} is {.val {qmin}}"
      ),
      call = call
    )
  }
  if (!is.numeric(qmax) || length(qmax) != 1 || qmax < 0 || qmax > 1) {
    cli::cli_abort(
      c("{.arg qmax} must be a number between 0 and 1",
        "x" = "{.arg qmax} is {.val {qmax}}"
      ),
      call = call
    )
  }
  if (qmin > qmax) {
    cli::cli_abort(
      c("{.arg qmin} cannot be larger than or equal to {.arg qmax}",
        "x" = "{.arg qmin} = {.val {qmin}} > {.val {qmax}} = {.arg qmax}"
      ),
      call = call
    )
  }
}

check_dots_named <- function(dot_list, call = rlang::caller_env()) {
  if (length(dot_list) > 0) {
    dot_list_names <- names(dot_list)
    if (is.null(dot_list_names)) {
      cli::cli_abort(
        "arguments in ... must be named",
        call = call
      )
    }
    if (any(dot_list_names == "")) {
      cli::cli_abort(
        "all arguments in ... must be named",
        call = call
      )
    }
  }
}

check_autoplot_params <- function(with_names, with_positions, cut_off,
                                  adjust_limits, with_labels,
                                  call = rlang::caller_env()) {
  if (!rlang::is_logical(with_names)) {
    cli::cli_abort(
      c("{.arg with_names} must be a logical value",
        "x" = "{.arg with_names} is {.val {with_names}}"
      ),
      call = call
    )
  }
  if (!rlang::is_logical(with_positions)) {
    cli::cli_abort(
      c("{.arg with_positions} must be a logical value",
        "x" = "{.arg with_positions} is {.val {with_positions}}"
      ),
      call = call
    )
  }
  if (!is.numeric(cut_off) || cut_off < 0) {
    cli::cli_abort(
      c("{.arg cut_off} must be non negative number",
        "x" = "{.arg cut_off} is {.val {cut_off}}"
      ),
      call = call
    )
  }
  if (!rlang::is_logical(adjust_limits)) {
    cli::cli_abort(
      c("{.arg adjust_limits} must be a logical value",
        "x" = "{.arg adjust_limits} is {.val {adjust_limits}}"
      ),
      call = call
    )
  }
  if (!rlang::is_logical(with_labels)) {
    cli::cli_abort(
      c("{.arg with_labels} must be a logical value",
        "x" = "{.arg with_labels} is {.val {with_labels}}"
      ),
      call = call
    )
  }
}
