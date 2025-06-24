validate_sim <- function(Y, Z, origin_names, destination_names) {
  if (ncol(Y) != length(Z)) {
    cli::cli_abort("{.arg Z} must be of length {.val {ncol(Y)}}")
  }
  if (!is.null(origin_names) && length(origin_names) != nrow(Y)) {
    cli::cli_abort("{.arg origin_names} must be of length {.val {nrow(Y)}}")
  }
  if (!is.null(destination_names) && length(destination_names) != ncol(Y)) {
    cli::cli_abort("{.arg destination_names} must be of length {.val {ncol(Y)}}")
  }
}

new_sim <- function(Y,
                    Z,
                    origin_names = NULL,
                    destination_names = NULL,
                    ...,
                    class = character()) {
  validate_sim(Y, Z, origin_names, destination_names)
  if (is.null(origin_names) && is.null(destination_names)) {
    location_names <- NULL
  } else {
    location_names <- list(
      origin = origin_names,
      destination = destination_names
    )
  }
  structure(
    list(
      Y = Y,
      Z = Z,
      location_names = location_names,
      ...
    ),
    class = c(class, "sim")
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

#' Extract the flow matrix from a spatial interaction model object in data frame
#' format
#'
#' @details This function extracts the flow matrix in a long format. Each row
#' contains the flow between an origin location and a destination location. The
#' resulting data frame has at least three columns:
#'  - `origin_idx`: identifies the origin location by its index from 1 to the number
#' of origin locations
#'  - `destination_idx`: identifies the destination location by its index from 1
#' to the number of destination locations
#'  - `flow`: the flow between the corresponding location
#'
#' In addition, if location information is available, it will be included in
#' the data frame as follows:
#' - location names are included using columns `origin_name` or `destination_name`
#' - positions are included using 2 or 3 columns (per location type, origin or
#' destination) depending on the number of dimensions used for the location. The
#' names of the columns are by default `origin_x`, `origin_y` and `origin_z` (
#' and equivalent names for destination location) unless coordinate names are
#' specified in the location positions. In this latter case, the names are
#' prefixed by `origin_` or `destination_`. For instance, if the destination
#' location position coordinates are named `"longitude"` and `"latitude"`, the
#' resulting columns will be `destination_longitude` and `destination_latitude`.
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters (not used currently)
#'
#' @returns a data frame of flows between origin locations and destination
#'   locations with additional content if available (see Details).
#' @seealso [location_positions()],  [location_names()]
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' flows_df(model)
flows_df <- function(sim, ...) {
  UseMethod("flows_df")
}

#' @export
flows_df.sim <- function(sim, ...) {
  indexes <- expand.grid(
    origin_idx = 1:nrow(sim$Y),
    destination_idx = 1:ncol(sim$Y)
  )
  pre <- cbind(indexes, flow = as.vector(sim$Y))
  if (!is.null(origin_names(sim))) {
    pre <- cbind(pre,
      origin_name = origin_names(sim)[pre$origin_idx]
    )
  }
  if (!is.null(origin_positions(sim))) {
    pos_df <- positions_as_df(origin_positions(sim), "origin")
    pre <- cbind(
      pre,
      pos_df[pre$origin_idx, ]
    )
  }
  if (!is.null(destination_names(sim))) {
    pre <- cbind(pre,
      destination_name = destination_names(sim)[pre$destination_idx]
    )
  }
  if (!is.null(destination_positions(sim))) {
    pos_df <- positions_as_df(destination_positions(sim), "destination")
    pre <- cbind(
      pre,
      pos_df[pre$destination_idx, ]
    )
  }
  pre
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


#' Returns the number of iterations used to produce this spatial interaction model
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a number of iterations that may be one if the spatial interaction model
#'  has been obtained using a static model (see [static_blvim()]).
#' @export
#' @seealso [sim_converged()]
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' sim_iterations(model) ## must be one
sim_iterations <- function(sim, ...) {
  UseMethod("sim_iterations")
}

#' @export
sim_iterations.sim <- function(sim, ...) {
  1L
}

#' Reports whether the spatial interaction model construction converged
#'
#' Some spatial interaction models are the result of an iteration calculation,
#' see for instance [blvim()]. This calculation may have been interrupted before
#' convergence. The present function returns `TRUE` if the calculation converged,
#' `FALSE` if this was not the case and `NA` if the spatial interaction model
#' is not the result of an interative calculation .
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns `TRUE`, `FALSE` or `NA`, as described above
#' @export
#' @seealso [sim_iterations()]
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' sim_converged(model) ## must be NA
sim_converged <- function(sim, ...) {
  UseMethod("sim_converged")
}

#' @export
sim_converged.sim <- function(sim, ...) {
  NA
}
