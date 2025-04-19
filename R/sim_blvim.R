new_sim_blvim <- function(Y, Z, costs, alpha, beta, iteration, converged, ..., class = character()) {
  new_sim_wpc(Y, Z,
    costs = costs, alpha = alpha, beta = beta, iteration = iteration, converged = converged, ...,
    class = c(class, "sim_blvim")
  )
}

#' @export
format.sim_blvim <- function(x, ...) {
  if (x$converged) {
    status <- "{cli::symbol$info} The BLV model converged after {.val {x$iteration}} iterations."
  } else {
    status <- "{cli::symbol$warning} The BLV model did not converged after {.val {x$iteration-1}} iterations."
  }
  c(
    NextMethod(),
    cli::cli_format_method({
      cli::cli_text(
        status
      )
    })
  )
}
