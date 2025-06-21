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
  sim$location_positions
}

#' @rdname location_positions
#' @param value a list with two components (see the returned value) or `NULL`
#' @export
`location_positions<-` <- function(sim, value) {
  if (!is.null(value)) {
    if (!is.list(value)) {
      cli::cli_abort("{.arg value} must be a {.cls list}")
    }
    if (!identical(names(value), c("origin", "destination"))) {
      cli::cli_abort("{.arg value} must have exactly two elements: {.field origin} and {.field destination}")
    }
    if (!is.null(value$origin)) {
      if (!is.matrix(value$origin)) {
        cli::cli_abort("{.arg value$origin} must be a matrix")
      }
      if (nrow(value$origin) != nrow(sim$Y)) {
        cli::cli_abort("{.arg value$origin} must have {.val {nrow(sim$Y)}} rows")
      }
      if (ncol(value$origin) < 2 || ncol(value$origin) > 3) {
        cli::cli_abort("{.arg value$origin} must have 2 or 3 columns")
      }
    }
    if (!is.null(value$destination)) {
      if (!is.matrix(value$destination)) {
        cli::cli_abort("{.arg value$destination} must be a matrix")
      }
      if (nrow(value$destination) != ncol(sim$Y)) {
        cli::cli_abort("{.arg value$destination} must have {.val {ncol(sim$Y)}} rows")
      }
      if (ncol(value$destination) < 2 || ncol(value$destination) > 3) {
        cli::cli_abort("{.arg value$destination} must have 2 or 3 columns")
      }
    }
  }
  sim$location_positions <- value
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
  if (!inherits(sim, "sim")) {
    cli::cli_abort("{.arg sim} must be a {.cls sim}")
  }
  full_positions <- sim$location_positions
  if (!is.null(full_positions)) {
    full_positions$origin
  } else {
    NULL
  }
}


#' @export
#' @rdname origin_positions
#' @param value a matrix with as many rows as  the number of origin locations
#'   and 2 or 3 columns, or `NULL`
`origin_positions<-` <- function(sim, value) {
  if (!inherits(sim, "sim")) {
    cli::cli_abort("{.arg sim} must be a {.cls sim}")
  }
  if (!is.null(value)) {
    if (!is.matrix(value)) {
      cli::cli_abort("{.arg value} must be a matrix")
    }
    if (nrow(value) != nrow(sim$Y)) {
      cli::cli_abort("{.arg value} must have {.val {nrow(sim$Y)}} rows")
    }
    if (ncol(value) < 2 || ncol(value) > 3) {
      cli::cli_abort("{.arg value} must have 2 or 3 columns")
    }
  }
  if (is.null(sim$location_positions)) {
    sim$location_positions <- list(origin = value)
  } else {
    sim$location_positions["origin"] <- list(value)
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
  if (!inherits(sim, "sim")) {
    cli::cli_abort("{.arg sim} must be a {.cls sim}")
  }
  full_positions <- sim$location_positions
  if (!is.null(full_positions)) {
    full_positions$destination
  } else {
    NULL
  }
}

#' @export
#' @rdname destination_positions
#' @param value a matrix with as many rows as  the number of destination locations
#'   and 2 or 3 columns, or `NULL`
`destination_positions<-` <- function(sim, value) {
  if (!inherits(sim, "sim")) {
    cli::cli_abort("{.arg sim} must be a {.cls sim}")
  }
  if (!is.null(value)) {
    if (!is.matrix(value)) {
      cli::cli_abort("{.arg value} must be a matrix")
    }
    if (nrow(value) != ncol(sim$Y)) {
      cli::cli_abort("{.arg value} must have {.val {ncol(sim$Y)}} rows")
    }
    if (ncol(value) < 2 || ncol(value) > 3) {
      cli::cli_abort("{.arg value} must have 2 or 3 columns")
    }
  }
  if (is.null(sim$location_positions)) {
    sim$location_positions <- list(destination = value)
  } else {
    sim$location_positions["destination"] <- list(value)
  }
  sim
}
