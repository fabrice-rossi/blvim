insert_names <- function(data, names) {
  if (!is.null(names)) {
    if (is.null(data)) {
      data <- list(names = names)
    } else if (!rlang::has_name(data, "names")) {
      data$names <- names
    }
  }
  data
}

new_sim_wpc <- function(Y, Z, costs, alpha, beta, bipartite, origin_data, destination_data, ..., class = character()) {
  new_sim(Y,
    Z,
    bipartite,
    insert_names(origin_data, rownames(costs)),
    insert_names(destination_data, colnames(costs)),
    costs = costs,
    alpha = alpha,
    beta = beta,
    ...,
    class = c(class, "sim_wpc")
  )
}

#' @export
format.sim_wpc <- function(x, ...) {
  c(
    NextMethod(),
    cli::cli_format_method({
      cli::cli_ul(c(
        "Model: Wilson's production constrained",
        "Parameters: return to scale (alpha) = {.val {x$alpha}} and inverse cost scale (beta) = {.val {x$beta}}"
      ))
    })
  )
}

#' Extract the return to scale parameter used to compute this model
#'
#' @param sim a spatial interaction model with a return to scale parameter
#' @param ... additional parameters
#'
#' @returns the return to scale parameter
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' return_to_scale(model) ## should be 1.5
return_to_scale <- function(sim, ...) {
  UseMethod("return_to_scale")
}

#' @export
return_to_scale.sim_wpc <- function(sim, ...) {
  sim$alpha
}

#' Extract the inverse cost scale parameter used to compute this model
#'
#' @param sim a spatial interaction model with a inverse cost scale parameter
#' @param ... additional parameters
#'
#' @returns the inverse cost scale parameter
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' inverse_cost(model) ## should be 1
inverse_cost <- function(sim, ...) {
  UseMethod("inverse_cost")
}

#' @export
inverse_cost.sim_wpc <- function(sim, ...) {
  sim$beta
}

#' Extract the cost matrix used to compute this model
#'
#' @param sim a spatial interaction model with a cost matrix
#' @param ... additional parameters
#'
#' @returns the cost matrix
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' costs(model) ## should be equal to distances above
costs <- function(sim, ...) {
  UseMethod("costs")
}

#' @export
costs.sim_wpc <- function(sim, ...) {
  sim$costs
}
