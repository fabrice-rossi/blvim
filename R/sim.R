new_sim <- function(Y, Z, ..., class = character()) {
  structure(
    list(
      Y = Y,
      Z = Z,
      ...
    ),
    class = c("sim")
  )
}

#' @export
format.sim <- function(x, ...) {
  cli::cli_format_method({
    cli::cli_text(
      "Spatial interaction model with ",
      "{.val {nrow(x$Y)}} origin locations and ",
      "{.val {ncol(x$Y)}} destination locations"
    )
  })
}

#' @export
print.sim <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' Extract the flow matrix from a spatial interaction model object
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a matrix of flows between origin locations and destination locations
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' flows(model)
flows <- function(sim, ...) {
  UseMethod("flows")
}

#' @export
flows.sim <- function(sim, ...) {
  sim$Y
}

#' Extract the production constraints from a spatial interaction model object
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a vector of production constraints at the origin locations
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' all.equal(production(model), production)
production <- function(sim, ...) {
  UseMethod("production")
}

#' @export
production.sim <- function(sim, ...) {
  rowSums(sim$Y)
}

#' Extract the attractivenesses from a spatial interaction model object
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a vector of attractivenesses at the destination locations
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' attractiveness(model)
attractiveness <- function(sim, ...) {
  UseMethod("attractiveness")
}

#' @export
attractiveness.sim <- function(sim, ...) {
  sim$Z
}

#' Compute the flows incoming at each destination location
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a vector of flows incoming at destination locations
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' destination_flow(model)
destination_flow <- function(sim, ...) {
  UseMethod("destination_flow")
}

#' @export
destination_flow.sim <- function(sim, ...) {
  colSums(sim$Y)
}
