check_positions <- function(value, location_number, call = rlang::caller_env()) {
  if (!is.null(value)) {
    if (!is.matrix(value)) {
      cli::cli_abort("{.arg value} must be a matrix", call = call)
    }
    if (nrow(value) != location_number) {
      cli::cli_abort("{.arg value} must have {.val {location_number}} rows", call = call)
    }
    if (ncol(value) < 2 || ncol(value) > 3) {
      cli::cli_abort("{.arg value} must have 2 or 3 columns", call = call)
    }
  }
}

#' Positions of origin and destination locations in a spatial interaction model
#'
#' These functions provide low level access to origin and destination local
#' positions. It is recommended to use [origin_positions()] and
#' [destination_positions()] instead of `location_positions` and
#' `location_positions<-`.
#'
#' # Positions
#'
#' Location positions are given by numeric matrices with 2 or 3 columns. The
#' first two columns are assumed to be geographical coordinates while the 3rd
#' column can be used for instance to store altitude. Coordinates are interpreted
#' as is in graphical representations (see [autoplot.sim()]). They are not matched
#' to the costs as those can be derived from complex movement models and other
#' non purely geographic considerations.
#'
#' @param sim a spatial interaction model object
#' @returns for `location_positions` `NULL` or a list with two components:
#'   `origin` for the origin location positions and `destination` for the
#'   destination location positions. For `location_positions<-()` the modified
#'   `sim` object.
#'
#' @export
#' @seealso [origin_positions()], [destination_positions()]
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' ## No positions
#' location_positions(model) <- list(origin = positions, destination = positions)
#' destination_positions(model)
#' origin_positions(model)
location_positions <- function(sim) {
  UseMethod("location_positions")
}

#' @export
location_positions.sim <- function(sim) {
  list(
    origin = sim$origin[["positions"]],
    destination = sim$destination[["positions"]]
  )
}

#' @rdname location_positions
#' @param value a list with two components (see the returned value) or `NULL`
#' @export
`location_positions<-` <- function(sim, value) {
  UseMethod("location_positions<-")
}

#' @export
`location_positions<-.sim` <- function(sim, value) {
  if (!is.null(value)) {
    if (!is.list(value)) {
      cli::cli_abort("{.arg value} must be a {.cls list}")
    }
    if (!identical(names(value), c("origin", "destination"))) {
      cli::cli_abort("{.arg value} must have exactly two elements: {.field origin} and {.field destination}")
    }
    check_positions(value$origin, nrow(sim$Y))
    check_positions(value$destination, ncol(sim$Y))
  }
  if (!sim_is_bipartite(sim)) {
    if (!identical(value$origin, value$destination)) {
      cli::cli_abort("{.arg sim} is not bipartite but origin and destination location positions differ.")
    }
  }
  sim$origin[["positions"]] <- value$origin
  sim$destination[["positions"]] <- value$destination
  sim
}

#' Positions of origin locations in a spatial interaction model
#'
#' Functions to get or set the positions of the origin locations in a spatial
#' interaction model.
#'
#' @inheritSection location_positions Positions
#'
#' @param sim a spatial interaction model object
#'
#' @returns for `origin_positions` `NULL` or the coordinate matrix for the origin
#'   locations. for `origin_positions<-` the modified `sim` object
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' origin_positions(model) <- positions
#' origin_positions(model)
#' @seealso [location_positions()], [destination_positions()]
origin_positions <- function(sim) {
  UseMethod("origin_positions")
}

#' @export
origin_positions.sim <- function(sim) {
  sim$origin[["positions"]]
}


#' @export
#' @rdname origin_positions
#' @param value a matrix with as many rows as  the number of origin locations
#'   and 2 or 3 columns, or `NULL`
`origin_positions<-` <- function(sim, value) {
  UseMethod("origin_positions<-")
}

#' @export
`origin_positions<-.sim` <- function(sim, value) {
  check_positions(value, nrow(sim$Y))
  sim$origin[["positions"]] <- value
  if (!sim_is_bipartite(sim)) {
    sim$destination[["positions"]] <- value
  }
  sim
}

#' positions of destination locations in a spatial interaction model
#'
#' Functions to get or set the positions of the destination locations in a
#' spatial interaction model.
#'
#' @inheritSection location_positions Positions
#'
#' @param sim a spatial interaction model object
#'
#' @returns for `destination_positions` `NULL` or coordinate matrix for the
#'   destination locations. for `destination_positions<-` the modified `sim`
#'   object
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' destination_positions(model) <- positions
#' destination_positions(model)
#' @seealso [location_positions()], [origin_positions()]
destination_positions <- function(sim) {
  UseMethod("destination_positions")
}

#' @export
destination_positions.sim <- function(sim) {
  sim$destination[["positions"]]
}

#' @export
#' @rdname destination_positions
#' @param value a matrix with as many rows as  the number of destination locations
#'   and 2 or 3 columns, or `NULL`
`destination_positions<-` <- function(sim, value) {
  UseMethod("destination_positions<-")
}

#' @export
`destination_positions<-.sim` <- function(sim, value) {
  check_positions(value, ncol(sim$Y))
  sim$destination[["positions"]] <- value
  if (!sim_is_bipartite(sim)) {
    sim$origin[["positions"]] <- value
  }
  sim
}
