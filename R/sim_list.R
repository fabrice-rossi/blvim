compatible_sim_list <- function(sims, costs, origin, destination, first_index = 2,
                                call = rlang::caller_env()) {
  if (length(sims) >= first_index) {
    ## we want consistency between the sims
    sims <- sims[seq(from = first_index, to = length(sims))]
    costs_test <- sapply(sims, function(x) isTRUE(all.equal(costs(x), costs)))
    if (!all(costs_test)) {
      cli::cli_abort(
        c("all sim objects in {.arg sims} must share the same costs",
          x = "{.arg sims[[{which(!costs_test)[1]}]]}
has different costs"
        ),
        call = call
      )
    }
    origin_test <- sapply(sims, function(x) isTRUE(all.equal(x$origin, origin)))
    if (!all(origin_test)) {
      cli::cli_abort(
        c("all sim objects in {.arg sims} must share the same origin data",
          x = "{.arg sims[[{which(!origin_test)[1]}]]}
has different origin data"
        ),
        call = call
      )
    }
    destination_test <- sapply(
      sims,
      function(x) {
        isTRUE(all.equal(
          x$destination,
          destination
        ))
      }
    )
    if (!all(destination_test)) {
      cli::cli_abort(
        c("all sim objects in {.arg sims} must share the same destination data",
          x = "{.arg sims[[{which(!destination_test)[1]}]]}
has different destination data"
        ),
        call = call
      )
    }
  }
}


#' Validate a collection of sims
#'
#' This function validates its inputs and abort in case of problems. To be
#' valid, sims has to verify the following properties:
#'
#' 1) it must be a list of sim objects 2) if it contains more than one object,
#' they need to share a) the same cost matrix b) the same origin data (if any)
#' c) the same destination data (if any)
#'
#' @param sims a list of sim objects
#' @param call caller environment for proper error reporting
#'
#' @returns nothing
#' @noRd
validate_sim_list <- function(sims, call = rlang::caller_env()) {
  if (!is.list(sims) || !all(sapply(sims, inherits, "sim"))) {
    cli::cli_abort("{.arg sims} must be a list of {.class sim} objects",
      call = call
    )
  }
  if (length(sims) > 1) {
    ## we want consistency between the sims
    costs <- costs(sims[[1]])
    origin <- sims[[1]]$origin
    destination <- sims[[1]]$destination
    compatible_sim_list(sims, costs, origin, destination,
      first_index = 2,
      call = call
    )
  }
}

## remove from the sims common content
## the first sim is assumed to contain the common content
sims_compress <- function(sims) {
  costs <- sims[[1]]$costs
  origin <- sims[[1]]$origin
  destination <- sims[[1]]$destination
  sims <- lapply(sims, function(x) {
    x$costs <- NULL
    x$origin <- NULL
    x$destination <- NULL
    x
  })
  list(sims = sims, common = list(
    costs = costs, origin = origin,
    destination = destination
  ))
}

## reverse of compression for one sim
sim_restore <- function(sim, common) {
  sim$costs <- common$costs
  sim$origin <- common$origin
  sim$destination <- common$destination
  sim
}

## All sim in a sim list must have a collection of common elements:
## - the cost matrix
## - location data
## This is not verified for efficiency reasons
new_sim_list <- function(sims, common = NULL, ..., class = character()) {
  ## if common is NULL, we extract the common parameters from the first
  ## sim and the sims are "compressed"
  if (is.null(common)) {
    cp_sims <- sims_compress(sims)
    common <- cp_sims$common
    sims <- cp_sims$sims
  }
  ## when common is specified, we assume the common elements were removed
  ## from the sim objects
  structure(
    sims,
    common = common,
    class = c(class, "sim_list", "list"),
    ...
  )
}

#' Create a sim_list object from a list of spatial interaction objects
#'
#' The collection of `sim` objects represented by a `sim_list` object is assumed
#' to be homogeneous, that is to correspond to a fix set of origin and
#' destination locations, associated to a fixed cost matrix.
#'
#' @param sims a list of homogeneous spatial interaction objects
#' @param validate should the function validate the homogeneity of the list of
#'   spatial interaction objects (defaults to `TRUE`)
#'
#' @returns a `sim_list` object
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' flows_1 <- blvim(distances, production, 1.5, 1, attractiveness)
#' flows_2 <- blvim(distances, production, 1.25, 2, attractiveness)
#' all_flows <- sim_list(list(flows_1, flows_2))
sim_list <- function(sims, validate = TRUE) {
  if (validate) {
    validate_sim_list(sims)
  }
  new_sim_list(sims)
}


#' @export
`[.sim_list` <- function(x, i, ...) {
  ## validate the indexes
  out_of_range <- i > length(x)
  if (any(out_of_range)) {
    cli::cli_abort(c("{.arg i} contains out of range indexes for {.arg x}
with length {.val {length(x)}}",
      x = "out of range value(s): {.val {i[out_of_range]}}"
    ))
  }
  new_sim_list(NextMethod(), common = attr(x, "common"))
}

#' @export
`[[.sim_list` <- function(x, i, ...) {
  if (length(i) > 1) {
    cli::cli_abort(c("{.arg i} contains more than one index",
      x = "{.val {i}}"
    ))
  }
  out_of_range <- i > length(x)
  if (any(out_of_range)) {
    cli::cli_abort(c("{.arg i} contains out of range indexes for {.arg x} with
length {.val {length(x)}}",
      x = "out of range value(s): {.val {i[out_of_range]}}"
    ))
  }
  sim_restore(NextMethod(), attr(x, "common"))
}

#' @export
`[<-.sim_list` <- function(x, i, ..., value) {
  out_of_range <- i > length(x)
  if (any(out_of_range)) {
    cli::cli_abort(c("{.arg i} contains out of range indexes for {.arg x}
with length {.val {length(x)}}",
      x = "out of range value(s): {.val {i[out_of_range]}}"
    ))
  }
  if (!inherits(value, "sim_list")) {
    cli::cli_abort("{.arg value} must be of class {.class sim_list}")
  }
  common <- attr(x, "common")
  compatible_sim_list(value, costs(x), common$origin, common$destination,
    first_index = 1
  )
  new_sim_list(NextMethod(), common)
}

#' @export
`[[<-.sim_list` <- function(x, i, ..., value) {
  if (length(i) > 1) {
    cli::cli_abort(c("{.arg i} contains more than one index",
      x = "{.val {i}}"
    ))
  }
  if (!inherits(value, "sim")) {
    cli::cli_abort("{.arg value} must be of class {.class sim}")
  }
  if (!isTRUE(all.equal(costs(value), costs(x)))) {
    cli::cli_abort("{.arg value} is not compatible with {.arg x}:
different costs")
  }
  common <- attr(x, "common")
  if (!isTRUE(all.equal(value$origin, common$origin))) {
    cli::cli_abort("{.arg value} is not compatible with {.arg x}:
different origin data")
  }
  if (!isTRUE(all.equal(value$destination, common$destination))) {
    cli::cli_abort("{.arg value} is not compatible with {.arg x}:
different destination data")
  }
  out_of_range <- i > length(x)
  if (any(out_of_range)) {
    cli::cli_abort(c("{.arg i} contains out of range indexes for {.arg x}
with length {.val {length(x)}}",
      x = "out of range value(s): {.val {i[out_of_range]}}"
    ))
  }
  new_sim_list(NextMethod(), common = common)
}


#' @export
format.sim_list <- function(x, ...) {
  one_model <- x[[1]] # nolint
  cli::cli_format_method({
    cli::cli_text(
      "Collection of {.val {length(x)}} spatial interaction models with ",
      "{.val {nrow(one_model$Y)}} origin locations and ",
      "{.val {ncol(one_model$Y)}} destination locations ",
      "computed on the following grid: "
    )
    sl <- cli::cli_ul()
    cli::cli_li("alpha: {.val {unique(sapply(unclass(x), return_to_scale))}}")
    cli::cli_li("beta: {.val {unique(sapply(unclass(x), inverse_cost))}}")
    cli::cli_end(sl)
  })
}

#' @export
print.sim_list <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' @export
as.list.sim_list <- function(x, ...) {
  lapply(unclass(x), sim_restore, attr(x, "common"))
}

#' Extract all the attractivenesses from a collection of spatial interaction
#' models
#'
#' The function extract attractivenesses from all the spatial interaction models
#' of the collection and returns them in a matrix in which each row corresponds
#' to a model and each column to a destination location.
#'
#' @param sim_list a collection of spatial interaction models, an object of
#'   class `sim_list`
#' @param ... additional parameters for the [attractiveness()] function
#'
#' @returns a matrix of attractivenesses at the destination locations
#' @seealso [attractiveness()] and [grid_blvim()]
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
#' production <- log(french_cities$population[1:15])
#' attractiveness <- log(french_cities$area[1:15])
#' all_flows <- grid_blvim(
#'   distances, production, c(1.1, 1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1
#' )
#' g_Z <- grid_attractiveness(all_flows)
#' ## should be 12 rows (3 times 4 parameter pairs) and 15 columns (15
#' ## destination locations)
#' dim(g_Z)
grid_attractiveness <- function(sim_list, ...) {
  if (!inherits(sim_list, "sim_list")) {
    cli::cli_abort("{.arg sim_list} must be an object of class {.cls sim_list}")
  }
  t(sapply(sim_list, attractiveness, ...))
}

#' Extract all the destination flows from a collection of spatial interaction
#' models
#'
#' The function extract destination flows from all the spatial interaction
#' models of the collection and returns them in a matrix in which each row
#' corresponds to a model and each column to a destination location.
#'
#' @param sim_list a collection of spatial interaction models, an object of
#'   class `sim_list`
#' @param ... additional parameters for the [destination_flow()] function
#'
#' @returns a matrix of destination flows at the destination locations
#' @seealso [destination_flow()] and [grid_blvim()]
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(
#'   distances, production, c(1.1, 1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1
#' )
#' g_df <- grid_destination_flow(all_flows)
#' ## should be 12 rows (3 times 4 parameter pairs) and 10 columns (10
#' ## destination locations)
#' dim(g_df)
grid_destination_flow <- function(sim_list, ...) {
  if (!inherits(sim_list, "sim_list")) {
    cli::cli_abort("{.arg sim_list} must be an object of class {.cls sim_list}")
  }
  t(sapply(sim_list, destination_flow, ...))
}

#' Extract all terminal status from a collection of spatial interaction models
#'
#' The function extract terminal status from all the spatial interaction models
#' of the collection and returns them in a matrix in which each row corresponds
#' to a model and each column to a destination location. The value at row `i`
#' and column `j` is `TRUE` if destination `j` is a terminal in model `i`. This
#' function applies only to non bipartite models.
#'
#' See [terminals()] for the definition of terminal locations.
#'
#' @param sim_list a collection of non bipartite spatial interaction models, an
#'   object of class `sim_list`
#' @inheritParams is_terminal
#' @param ... additional parameters for the [is_terminal()] function
#'
#' @returns a matrix of terminal status at the destination locations
#' @seealso [is_terminal()] and [grid_blvim()]
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
#' production <- log(french_cities$population[1:15])
#' attractiveness <- log(french_cities$area[1:15])
#' all_flows <- grid_blvim(
#'   distances, production, c(1.1, 1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1,
#'   bipartite = FALSE
#' )
#' g_df <- grid_is_terminal(all_flows)
#' ## should be 12 rows (3 times 4 parameter pairs) and 15 columns (15
#' ## destination locations)
#' dim(g_df)
grid_is_terminal <- function(sim_list, definition = c("ND", "RW"), ...) {
  if (!inherits(sim_list, "sim_list")) {
    cli::cli_abort("{.arg sim_list} must be an object of class {.cls sim_list}")
  }
  t(sapply(sim_list, is_terminal, definition, ...))
}

#' Compute diversities for a collection of spatial interaction models
#'
#' The function computes for each spatial interaction model of its `sim_list`
#' parameter the [diversity()] of the corresponding destination flows and
#' returns the values as a vector. The type of diversity and the associated
#' parameters are identical for all models.
#'
#' See [diversity()] for the definition of the diversities. Notice that
#' [diversity()] is generic and can be applied directly to `sim_list` objects.
#' The current function is provided to be explicit in R code about what is a
#' unique model and what is a collection of models (using function names that
#' start with `"grid_"`)
#'
#' @param sim a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @inheritParams diversity
#'
#' @returns a vector of diversities, one per spatial interaction model
#' @seealso [diversity()] and [grid_blvim()]
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
#' production <- log(french_cities$population[1:15])
#' attractiveness <- log(french_cities$area[1:15])
#' all_flows <- grid_blvim(
#'   distances, production, c(1.1, 1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1,
#'   bipartite = FALSE
#' )
#' diversities <- grid_diversity(all_flows)
#' diversities ## should be a length 12 vector
#' grid_diversity(all_flows, "renyi", 3)
grid_diversity <- function(sim, definition = c("shannon", "renyi", "ND", "RW"),
                           order = 1L, ...) {
  diversity(sim, definition, order, ...)
}

#' @export
sim_converged.sim_list <- function(sim, ...) {
  sapply(sim, sim_converged)
}

#' Reports the convergence statuses of a collection of spatial interaction
#' models
#'
#' The function reports for each spatial interaction model of its `sim_list`
#' parameter its convergence status, as defined in [sim_converged()].
#'
#' Notice that [sim_converged()] is generic and can be applied directly to
#' `sim_list` objects. The current function is provided to be explicit in R code
#' about what is a unique model and what is a collection of models (using
#' function names that start with `"grid_"`)
#'
#' @inheritParams sim_converged
#' @param sim a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @returns a vector of convergence status, one per spatial interaction model
#' @seealso [sim_converged()], [grid_sim_iterations()] and [grid_blvim()]
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
#' production <- log(french_cities$population[1:15])
#' attractiveness <- log(french_cities$area[1:15])
#' all_flows <- grid_blvim(
#'   distances, production, c(1.1, 1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1,
#'   bipartite = FALSE,
#'   iter_max = 750
#' )
#' grid_sim_converged(all_flows)
grid_sim_converged <- function(sim, ...) {
  sim_converged(sim, ...)
}

#' @export
sim_iterations.sim_list <- function(sim, ...) {
  sapply(sim, sim_iterations)
}

#' Returns the number of iterations used to produce of a collection of spatial
#' interaction models
#'
#' The function reports for each spatial interaction model of its `sim_list`
#' parameter the number of iterations used to produce it (see
#' [sim_iterations()])
#'
#' Notice that [sim_iterations()] is generic and can be applied directly to
#' `sim_list` objects. The current function is provided to be explicit in R code
#' about what is a unique model and what is a collection of models (using
#' function names that start with `"grid_"`)
#'
#' @inheritParams sim_iterations
#' @param sim a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @returns a vector of numbers of iteration, one per spatial interaction model
#' @seealso [sim_iterations()], [grid_sim_converged()] and [grid_blvim()]
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
#' production <- log(french_cities$population[1:15])
#' attractiveness <- log(french_cities$area[1:15])
#' all_flows <- grid_blvim(
#'   distances, production, c(1.1, 1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1,
#'   bipartite = FALSE,
#'   iter_max = 750
#' )
#' grid_sim_iterations(all_flows)
grid_sim_iterations <- function(sim, ...) {
  sim_iterations(sim, ...)
}

#' Combine multiple sim_list objects into a single one
#'
#' This function combines the `sim_list` and `sim` objects use as arguments
#' in a single `sim_list`, provided they are compatible. Compatibility is
#' defined as in `sim_list()`: all spatial interaction models must share
#' the same costs as well as the same origin and destination data.
#'
#' @param ... `sim_list` and `sim` to be concatenated.
#' @return A combined object of class `sim_list`.
#' @export
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
#' production <- log(french_cities$population[1:15])
#' attractiveness <- log(french_cities$area[1:15])
#' all_flows_log <- grid_blvim(
#'   distances, production, c(1.1, 1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1,
#'   bipartite = FALSE,
#'   iter_max = 750
#' )
#' production <- rep(1, 15)
#' attractiveness <- rep(1, 15)
#' all_flows_unit <- grid_blvim(
#'   distances, production, c(1.1, 1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1,
#'   bipartite = FALSE,
#'   iter_max = 750
#' )
#' all_flows <- c(all_flows_log, all_flows_unit)
c.sim_list <- function(...) {
  args <- list(...)
  base_sl <- args[[1]]
  costs <- costs(base_sl)
  origin <- base_sl[[1]]$origin
  destination <- base_sl[[1]]$destination
  for (k in seq_len(length(args) - 1)) {
    current_sl <- args[[k + 1]]
    if (inherits(current_sl, "sim_list")) {
      compatible_sim_list(current_sl, costs, origin, destination,
        first_index = 1
      )
    } else if (inherits(current_sl, "sim")) {
      current_sl <- sim_list(list(current_sl))
      compatible_sim_list(current_sl, costs, origin, destination,
        first_index = 1
      )
      args[[k + 1]] <- current_sl
    } else {
      cli::cli_abort("All arguments passed to {.fn c} must be of class
{.cls sim_list} or {.cls sim}.")
    }
  }
  c_args <- unlist(args, recursive = FALSE)
  ## we need to restore the shared content
  new_sim_list(c_args, common = attr(base_sl, "common"))
}

#' Coerce to a Data Frame
#'
#' This function creates a data frame with a single column storing its
#' collection of spatial interaction models. The default name of the column
#' is `"sim"` (can be modified using the `sim_column` parameter). An more
#' flexible alternative is provided by the [sim_df()] function.
#'
#' @param x a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param ... additional parameters (not used currently)
#' @param sim_column the name of the `sim_list` column (default `"sim"`)
#' @seealso [sim_df()]
#' @returns a data frame
#' @export
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
#' production <- log(french_cities$population[1:15])
#' attractiveness <- log(french_cities$area[1:15])
#' all_flows_log <- grid_blvim(
#'   distances, production, c(1.1, 1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1,
#'   bipartite = FALSE,
#'   iter_max = 750
#' )
#' as.data.frame(all_flows_log, sim_column = "log flows")
as.data.frame.sim_list <- function(x, ..., sim_column = "sim") {
  sc <- as.character(sim_column)
  if (length(sc) > 1) {
    cli::cli_abort(c("{.arg sim_column} must be a singe column name",
      "x" = "{.arg sim_column} is {.val {sim_column}}"
    ))
  }
  pre_res <- data.frame(sim = I(x))
  if (sc != "sim") {
    names(pre_res) <- sim_column
  }
  pre_res
}
