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

#' Names of origin and destination locations in a spatial interaction model
#'
#' These functions provide low level access to origin and destination local
#' names. It is recommended to use [origin_names()] and [destination_names()]
#' instead of `location_names` and `location_names<-`.
#'
#' @param sim a spatial interaction model object
#' @returns for `location_names` `NULL` or a list with two components: `origin`
#'   for the origin location names and `destination` for the destination
#'   location names. For `location_names<-()` the modified `sim` object.
#'
#' @export
#' @seealso [origin_names()], [destination_names()]
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' rownames(positions) <- LETTERS[1:10]
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' ## the row/column names of the cost matrix are used for the location
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' location_names(model)
#' location_names(model) <- NULL
#' location_names(model) <- list(origin = letters[1:10], destination = LETTERS[1:10])
#' destination_names(model)
#' origin_names(model)
location_names <- function(sim) {
  list(origin = sim$origin[["names"]], destination = sim$destination[["names"]])
}

#' @rdname location_names
#' @param value a list with two components (see the returned value) or `NULL`
#' @export
`location_names<-` <- function(sim, value) {
  if (!is.null(value)) {
    if (!is.list(value)) {
      cli::cli_abort("{.arg value} must be a {.cls list}")
    }
    if (!identical(names(value), c("origin", "destination"))) {
      cli::cli_abort("{.arg value} must have exactly two elements: {.field origin} and {.field destination}")
    }
    if (!is.null(value$origin)) {
      if (!is.character(value$origin)) {
        cli::cli_abort("{.arg value$origin} must be a character vector")
      }
      if (length(value$origin) != nrow(sim$Y)) {
        cli::cli_abort("{.arg value$origin} must be of length {.val {nrow(sim$Y)}}")
      }
    }
    if (!is.null(value$destination)) {
      if (!is.character(value$destination)) {
        cli::cli_abort("{.arg value$destination} must be a character vector")
      }
      if (length(value$destination) != ncol(sim$Y)) {
        cli::cli_abort("{.arg value$destination} must be of length {.val {ncol(sim$Y)}}")
      }
    }
  }
  sim$origin[["names"]] <- value$origin
  sim$destination[["names"]] <- value$destination
  sim
}

#' Names of origin locations in a spatial interaction model
#'
#' Functions to get or set the names of the origin locations in a spatial
#' interaction model.
#'
#' @param sim a spatial interaction model object
#'
#' @returns for `origin_names` `NULL` or a character vector with one name
#'   per origin locations in the model. for `origin_names<-` the modified
#'   `sim` object
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' rownames(positions) <- LETTERS[1:10]
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' ## the row/column names of the cost matrix are used for the location
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' origin_names(model)
#' origin_names(model) <- letters[11:20]
#' origin_names(model)
#' @seealso [location_names()], [destination_names()]
origin_names <- function(sim) {
  if (!inherits(sim, "sim")) {
    cli::cli_abort("{.arg sim} must be a {.cls sim}")
  }
  sim$origin[["names"]]
}


#' @export
#' @rdname origin_names
#' @param value a character vector of length equal to the number of origin
#'  locations, or `NULL` (vectors of adapted length are converted to character vectors)
`origin_names<-` <- function(sim, value) {
  if (!inherits(sim, "sim")) {
    cli::cli_abort("{.arg sim} must be a {.cls sim}")
  }
  sim$origin[["names"]] <- check_names(value, nrow(sim$Y))
  sim
}

#' Names of destination locations in a spatial interaction model
#'
#' Functions to get or set the names of the destination locations in a spatial
#' interaction model.
#'
#' @param sim a spatial interaction model object
#'
#' @returns for `destination_names` `NULL` or a character vector with one name
#'   per destination locations in the model. for `destination_names<-` the modified
#'   `sim` object
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' rownames(positions) <- LETTERS[11:20]
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' ## the row/column names of the cost matrix are used for the location
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' destination_names(model)
#' destination_names(model) <- letters[1:10]
#' destination_names(model)
#' @seealso [location_names()], [origin_names()]
destination_names <- function(sim) {
  if (!inherits(sim, "sim")) {
    cli::cli_abort("{.arg sim} must be a {.cls sim}")
  }
  sim$destination[["names"]]
}

#' @export
#' @rdname destination_names
#' @param value a character vector of length equal to the number of destination
#'  locations, or `NULL` (vectors of adapted length are converted to character vectors)
`destination_names<-` <- function(sim, value) {
  if (!inherits(sim, "sim")) {
    cli::cli_abort("{.arg sim} must be a {.cls sim}")
  }
  sim$destination[["names"]] <- check_names(value, ncol(sim$Y))
  sim
}
