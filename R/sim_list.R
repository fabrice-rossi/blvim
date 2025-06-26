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
  list(sims = sims, common = list(costs = costs, origin = origin, destination = destination))
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
  ## when common is specified, we assume the common elements were removed from the sim objects
  structure(
    list(
      sims = sims,
      alphas = sapply(sims, return_to_scale),
      betas = sapply(sims, inverse_cost),
      common = common,
      ...
    ),
    class = c(class, "sim_list")
  )
}

#' @export
length.sim_list <- function(x) {
  length(x$sims)
}

#' @export
`[.sim_list` <- function(x, i, ...) {
  new_sim_list(x$sims[i, ...], common = x$common)
}

#' @export
`[[.sim_list` <- function(x, i, ...) {
  pre <- x$sims[[i, ...]]
  sim_restore(pre, x$common)
}

#' @export
`[<-.sim_list` <- function(x, i, ..., value) {
  cli::cli_abort("{.cls sim_list} objects do not support modification")
}

#' @export
`[[<-.sim_list` <- function(x, i, ..., value) {
  cli::cli_abort("{.cls sim_list} objects do not support modification")
}


#' @export
format.sim_list <- function(x, ...) {
  one_model <- x$sims[[1]]
  cli::cli_format_method({
    cli::cli_text(
      "Collection of {.val {length(x$sims)}} spatial interaction models with ",
      "{.val {nrow(one_model$Y)}} origin locations and ",
      "{.val {ncol(one_model$Y)}} destination locations ",
      "computed on the following grid: "
    )
    sl <- cli::cli_ul()
    cli::cli_li("alpha: {.val {unique(x$alphas)}}")
    cli::cli_li("beta: {.val {unique(x$betas)}}")
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
  lapply(x$sims, sim_restore, x$common)
}


#' Convert a collection of spatial interaction model into a Data Frame
#'
#' This function build a data frame from a collection of spatial interaction
#' model.
#'
#' The data frame has one row per spatial interaction model and the following
#' columns:
#' - `alpha`: the return to scale parameter used to build the model
#' - `beta`: the cost inverse scale parameter used to build the model
#' - `diversity`: model diversity
#' - `terminals`: if the model is not bipartite, the
#' terminals of the model
#' - `model`: if `models=TRUE`, the model
#'
#' @param x a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param models whether to include the models in the data frame (defaults to
#'   TRUE, that is to model inclusion)
#' @param ... additional parameters (not used currently)
#'
#' @returns a data frame representation of the spatial interaction model
#'   collection
#' @export
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' all_flows <- grid_blvim(distances, production, c(1.25, 1.5), c(1, 2, 3), attractiveness,
#'   bipartite = FALSE
#' )
#' as.data.frame(all_flows, models = FALSE)
#'
as.data.frame.sim_list <- function(x, ..., models = TRUE) {
  pre_result <- data.frame(
    alpha = x$alphas,
    beta = x$betas,
    diversity = sapply(x, diversity)
  )
  if (!sim_is_bipartite(x$sims[[1]])) {
    pre_result$terminals <- I(lapply(x, terminals))
  }
  if (models) {
    pre_result$model <- I(as.list(x))
  }
  pre_result
}

#' Extract all the attractivenesses from a collection of spatial interaction models
#'
#' The function extract attractivenesses from all the spatial interaction models
#' of the collection and returns then in a matrix in which each row corresponds
#' to a model and each column to a destination location.
#'
#' @param sim_list a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param ... additional parameters of the [attractiveness()] function
#'
#' @returns a matrix of attractivenesses at the destination locations
#' @seealso [attractiveness()] and [grid_blvim()]
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(15 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 15)
#' attractiveness <- rep(1, 15)
#' all_flows <- grid_blvim(distances,
#'   production,
#'   c(1.1, 1.25, 1.5),
#'   c(1, 2, 3),
#'   attractiveness,
#'   epsilon = 0.1
#' )
#' g_Z <- grid_attractiveness(all_flows)
#' ## should be 9 rows (3 times 3 parameter pairs) and 15 columns (15 destination
#' ## sites)
#' dim(g_Z)
grid_attractiveness <- function(sim_list, ...) {
  if (!inherits(sim_list, "sim_list")) {
    cli::cli_abort("{.var sim_list} must be an object of class {.cls sim_list}")
  }
  t(sapply(sim_list, attractiveness, ...))
}

#' Extract all the destination flows from a collection of spatial interaction models
#'
#' The function extract destination flows from all the spatial interaction models
#' of the collection and returns then in a matrix in which each row corresponds
#' to a model and each column to a destination location.
#'
#' @param sim_list a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param ... additional parameters of the [destination_flow()] function
#'
#' @returns a matrix of destination flows at the destination locations
#' @seealso [destination_flow()] and [grid_blvim()]
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(15 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 15)
#' attractiveness <- rep(1, 15)
#' all_flows <- grid_blvim(distances,
#'   production,
#'   c(1.1, 1.25, 1.5),
#'   c(1, 2, 3),
#'   attractiveness,
#'   epsilon = 0.1
#' )
#' g_df <- grid_destination_flow(all_flows)
#' ## should be 9 rows (3 times 3 parameter pairs) and 15 columns (15 destination
#' ## sites)
#' dim(g_df)
grid_destination_flow <- function(sim_list, ...) {
  if (!inherits(sim_list, "sim_list")) {
    cli::cli_abort("{.var sim_list} must be an object of class {.cls sim_list}")
  }
  t(sapply(sim_list, destination_flow, ...))
}
