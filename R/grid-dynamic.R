#' Compute a collection of Boltzmann-Lotka-Volterra model solutions
#'
#' This function computes a collection of flows between origin locations and
#' destination locations using [blvim()] on a grid of parameters. The flows use
#' the same costs, same production constraints and same attractivenesses. Each
#' flow is computed using one of all the pairwise combinations between the alpha
#' values given by `alphas` and the beta values given by `betas`. The function
#' returns an object of class `sim_list` which contains the resulting flows.
#'
#' @inheritSection static_blvim Location data
#' @inheritParams blvim
#' @param alphas a vector of return to scale parameters
#' @param betas a vector of cost inverse scale parameters
#' @param progress if TRUE, a progress bar is shown during the calculation
#'   (defaults to FALSE)
#' @return an object of class `sim_list`
#' @export
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' all_flows <- grid_blvim(distances, production, c(1.25, 1.5), c(1, 2, 3), attractiveness)
#' all_flows
#' length(all_flows)
#' all_flows[[2]]
grid_blvim <- function(costs, X, alphas, betas, Z,
                       bipartite = TRUE, origin_data = NULL, destination_data = NULL,
                       epsilon = 0.01,
                       iter_max = 50000,
                       conv_check = 100,
                       precision = 1e-6,
                       quadratic = FALSE,
                       progress = FALSE) {
  params <- expand.grid(alpha = alphas, beta = betas)
  all_models <- vector(mode = "list", length = nrow(params))
  if (progress) { # nocov start
    cli::cli_progress_bar("Computing models", total = length(all_models))
  } # nocov end
  for (k in seq_along(all_models)) {
    all_models[[k]] <- blvim(
      costs, X,
      params$alpha[k],
      params$beta[k],
      Z,
      bipartite,
      origin_data,
      destination_data,
      epsilon = epsilon,
      iter_max = iter_max,
      conv_check = conv_check,
      precision = precision,
      quadratic = quadratic
    )
    if (progress) { # nocov start
      cli::cli_progress_update()
    } # nocov end
  }
  if (progress) { # nocov start
    cli::cli_progress_done()
  } # nocov end
  new_sim_list(all_models)
}
