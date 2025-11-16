check_names <- function(value, location_number, call = rlang::caller_env()) {
  if (!is.null(value)) {
    value <- as.character(value)
    if (length(value) != location_number) {
      cli::cli_abort("{.arg values} must be of length {.val {location_number}}",
        call = call
      )
    }
  }
  value
}

check_location_names <- function(sim, value, call = rlang::caller_env()) {
  if (!is.null(value)) {
    if (!is.list(value)) {
      cli::cli_abort("{.arg value} must be a {.cls list}",
        call = call
      )
    }
    if (!identical(names(value), c("origin", "destination"))) {
      cli::cli_abort("{.arg value} must have exactly two elements:
{.field origin} and {.field destination}",
        call = call
      )
    }
    if (!is.null(value$origin)) {
      if (!is.character(value$origin)) {
        cli::cli_abort("{.arg value$origin} must be a character vector",
          call = call
        )
      }
      if (length(value$origin) != nrow(sim$Y)) {
        cli::cli_abort("{.arg value$origin} must be of length
{.val {nrow(sim$Y)}}",
          call = call
        )
      }
    }
    if (!is.null(value$destination)) {
      if (!is.character(value$destination)) {
        cli::cli_abort("{.arg value$destination} must be a character vector",
          call = call
        )
      }
      if (length(value$destination) != ncol(sim$Y)) {
        cli::cli_abort("{.arg value$destination} must be of length
{.val {ncol(sim$Y)}}",
          call = call
        )
      }
    }
  }
  if (!sim_is_bipartite(sim)) {
    if (!identical(value$origin, value$destination)) {
      cli::cli_abort("{.arg sim} is not bipartite but origin and destination
location names differ.",
        call = call
      )
    }
  }
}

#' Names of origin and destination locations in a spatial interaction model
#'
#' Those functions provide low level access to origin and destination local
#' names. It is recommended to use [origin_names()] and [destination_names()]
#' instead of `location_names` and `location_names<-`.
#'
#' @param sim a spatial interaction model object (an object of class `sim`) or a
#'   collection of spatial interaction  models (an object of class `sim_list`)
#' @returns for `location_names` `NULL` or a list with two components: `origin`
#'   for the origin location names and `destination` for the destination
#'   location names. For `location_names<-()` the modified `sim` object or
#'   `sim_list` object.
#'
#' @export
#' @seealso [origin_names()], [destination_names()]
#' @examples
#' distances <- french_cities_distances[1:10, 1:10]
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' ## the row/column names of the cost matrix are used for the location
#' model <- static_blvim(distances, production, 1.5, 1 / 250000, attractiveness)
#' location_names(model)
#' location_names(model) <- NULL
#' location_names(model)
#' location_names(model) <- list(
#'   origin = french_cities$name[1:10],
#'   destination = LETTERS[1:10]
#' )
#' destination_names(model)
#' origin_names(model)
location_names <- function(sim) {
  UseMethod("location_names")
}

#' @export
location_names.sim <- function(sim) {
  list(origin = sim$origin[["names"]], destination = sim$destination[["names"]])
}

#' @rdname location_names
#' @param value a list with two components (see the returned value) or `NULL`
#' @export
`location_names<-` <- function(sim, value) {
  UseMethod("location_names<-")
}

#' @export
`location_names<-.sim` <- function(sim, value) {
  check_location_names(sim, value)
  sim$origin[["names"]] <- value$origin
  sim$destination[["names"]] <- value$destination
  sim
}

#' Names of origin locations in a spatial interaction model
#'
#' Functions to get or set the names of the origin locations in a spatial
#' interaction model (or in a collection of spatial interaction models).
#'
#' @param sim a spatial interaction model object (an object of class `sim`) or a
#'   collection of spatial interaction  models (an object of class `sim_list`)
#'
#' @returns for `origin_names` `NULL` or a character vector with one name per
#'   origin locations in the model. for `origin_names<-` the modified `sim`
#'   object or `sim_list` object.
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10]
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' ## the row/column names of the cost matrix are used for the location
#' model <- static_blvim(distances, production, 1.5, 1 / 250000, attractiveness)
#' origin_names(model)
#' origin_names(model) <- french_cities$name[1:10]
#' origin_names(model)
#' @seealso [location_names()], [destination_names()]
origin_names <- function(sim) {
  UseMethod("origin_names")
}

#' @export
origin_names.sim <- function(sim) {
  sim$origin[["names"]]
}


#' @export
#' @rdname origin_names
#' @param value a character vector of length equal to the number of origin
#'  locations, or `NULL` (vectors of adapted length are converted to character
#'  vectors)
`origin_names<-` <- function(sim, value) {
  UseMethod("origin_names<-")
}

#' @export
`origin_names<-.sim` <- function(sim, value) {
  sim$origin[["names"]] <- check_names(value, nrow(sim$Y))
  if (!sim_is_bipartite(sim)) {
    sim$destination[["names"]] <- sim$origin[["names"]]
  }
  sim
}

#' Names of destination locations in a spatial interaction model
#'
#' Functions to get or set the names of the destination locations in a spatial
#' interaction model (or in a collection of spatial interaction models).
#'
#' @param sim a spatial interaction model object (an object of class `sim`) or a
#'   collection of spatial interaction  models (an object of class `sim_list`)
#'
#' @returns for `destination_names` `NULL` or a character vector with one name
#'   per destination locations in the model. for `destination_names<-` the
#'   modified `sim` object or `sim_list` object.
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10]
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' ## the row/column names of the cost matrix are used for the location
#' model <- static_blvim(distances, production, 1.5, 1 / 250000, attractiveness)
#' destination_names(model)
#' destination_names(model) <- french_cities$name[1:10]
#' destination_names(model)
#' @seealso [location_names()], [origin_names()]
destination_names <- function(sim) {
  UseMethod("destination_names")
}

#' @export
destination_names.sim <- function(sim) {
  sim$destination[["names"]]
}

#' @export
#' @rdname destination_names
#' @param value a character vector of length equal to the number of destination
#'  locations, or `NULL` (vectors of adapted length are converted to character
#'  vectors)
`destination_names<-` <- function(sim, value) {
  UseMethod("destination_names<-")
}

#' @export
`destination_names<-.sim` <- function(sim, value) {
  sim$destination[["names"]] <- check_names(value, ncol(sim$Y))
  if (!sim_is_bipartite(sim)) {
    sim$origin[["names"]] <- sim$destination[["names"]]
  }
  sim
}
