new_sim_diagnostic <- function(...,
                               class = character()) {
  structure(
    list(
      ...
    ),
    class = c(class, "sim_diagnostic")
  )
}

sim_diagnostic_cli_rep <- function(sim_d, ...) {
  UseMethod("sim_diagnostic_cli_rep")
}

#' @export
sim_diagnostic_cli_rep.sim_diagnostic <- function(sim_d, ...) {
  cli::cli_text("Static spatial interaction model")
}

#' @export
format.sim_diagnostic <- function(x, ...) {
  cli::cli_format_method({
    sim_diagnostic_cli_rep(x, ...)
  })
}

#' @export
print.sim_diagnostic <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}
