new_sim_blvim <- function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                          destination_data, iteration, converged, kappa,
                          algorithm,
                          diagnostic, ...,
                          class = character()) {
  new_sim_wpc(Y,
    Z,
    costs = costs,
    alpha = alpha,
    beta = beta,
    bipartite,
    origin_data,
    destination_data,
    iteration = iteration,
    converged = converged,
    kappa = kappa,
    algorithm = algorithm,
    diagnostic = diagnostic,
    ...,
    class = c(class, "sim_blvim")
  )
}

#' @export
sim_cli_rep.sim_blvim <- function(sim, ...) {
  if (sim$converged) {
    status <- "{cli::symbol$info} The BLV model converged after
{.val {sim$iteration}} iterations."
  } else {
    status <- "{cli::symbol$warning} The BLV model did not converged after
{.val {sim$iteration-1}} iterations."
  }
  c(
    NextMethod(),
    cli::cli_text(
      status
    )
  )
}

#' @export
sim_iterations.sim_blvim <- function(sim, ...) {
  sim$iteration
}

#' @export
sim_converged.sim_blvim <- function(sim, ...) {
  sim$converged
}

#' @export
sim_conversion.sim_blvim <- function(sim, ...) {
  sim$kappa
}

#' @export
sim_diagnostic.sim_blvim <- function(sim, ...) {
  new_sim_diagnostic(
    algorithm = sim$algorithm,
    iteration = sim$iteration,
    converged = sim$converged,
    cd = sim$diagnostic,
    ...,
    class = "sim_blvim_diagnostic"
  )
}

#' @export
sim_diagnostic_cli_rep.sim_blvim_diagnostic <- function(sim_d, ...) {
  cli::cli_text("BLV model obtained with the {.str {sim_d$algorithm}} algorithm.")
  if (sim_d$algorithm %in% c("linear", "quadratic")) {
    if (sim_d$converged) {
      cli::cli_text("{cli::symbol$info} The algorithm converged after
{.val {sim_d$iteration}} iterations.")
    } else {
      cli::cli_text("{cli::symbol$warning} The algorithm did not converged after
{.val {sim_d$iteration-1}} iterations.")
    }
  } else {
    if (sim_d$cd$status == "converged") {
      cli::cli_text("{cli::symbol$info} The algorithm converged after
{.val {sim_d$iteration}} iterations:")
    } else {
      cli::cli_text("{cli::symbol$warning} The algorithm stopped after
{.val {sim_d$iteration-1}} iterations:")
    }
    cli::cli_ul()
    cli::cli_li("Number of potential evaluations: {.val {sim_d$cd$eval}}.")
    cli::cli_li("Duality gap: {.val {signif(sim_d$cd$duality_gap,7)}}.")
    cli::cli_li("Return status: {.str {sim_d$cd$status}}.")
  }
}
