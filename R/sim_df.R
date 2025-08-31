new_sim_df <- function(sim_list, ..., class = character()) {
  if (!inherits(sim_list, "sim_list")) {
    cli::cli_abort("{.arg sim_list} must be a {.cls sim_list}")
  }
  iterations <- sapply(sim_list, sim_iterations)
  converged <- sapply(sim_list, sim_converged)
  pre_result <- data.frame(
    alpha = sapply(sim_list, return_to_scale),
    beta = sapply(sim_list, inverse_cost),
    diversity = grid_diversity(sim_list),
    iterations = iterations,
    converged = converged,
    sim = I(sim_list)
  )
  class(pre_result) <- c(class, "sim_df", class(pre_result))
  pre_result
}

#' Create a spatial interaction models data frame from a collection of interaction models
#'
#' This function build a data frame from a collection of spatial interaction
#' models. The data frame has a list column `sim` which stores the collection
#' of models and classical columns that contain characteristics of the models.
#' See details for the default columns.
#'
#' The data frame has one row per spatial interaction model and the following columns:
#' - `sim`: the last column that contains the model
#' - `alpha`: the return to scale parameter used to build the model
#' - `beta`: the cost inverse scale parameter used to build the model
#' - `diversity`: model default [diversity()] (Shannon's diversity)
#' - `iterations`: the number of iterations used to produce the model (1 for a
#'    static model)
#' - `converged`: `TRUE` is the iterative calculation of the model converged (for
#'    models produced by [blvim()] and related approaches), `FALSE` for no convergence
#'    and `NA` for static models
#'
#'
#' @param x a collection of spatial interaction models, an object of class
#'   `sim_list`
#'
#' @returns a data frame representation of the spatial interaction model collection
#'  with classes `sim_df` and `data.frame`
#' @export
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' all_flows <- grid_blvim(distances, production, c(1.25, 1.5), c(1, 2, 3), attractiveness)
#' all_flows_df <- sim_df(all_flows)
#' all_flows_df$converged
#'
sim_df <- function(x) {
  new_sim_df(x)
}

#' @export
`$<-.sim_df` <- function(x, name, value) {
  if (name == "sim") {
    if (is.null(value) || !inherits(value, "sim_list")) {
      x[[name]] <- value
      ## remove the sim_df class
      class(x) <- setdiff(class(x), "sim_df")
      return(x)
    } else if (inherits(value, "sim_list")) {
      x[[name]] <- I(value)
      return(x)
    }
    ## sim_list replacement
  }
  x[[name]] <- value
  x
}

#' @export
`[.sim_df` <- function(x, i, ...) {
  ## if ... is empty and i does not contain sim, we have to remove the sim_df
  ## class.
  pre <- NextMethod()
  if (inherits(pre, "sim_df")) {
    if (!"sim" %in% names(pre)) {
      class(pre) <- setdiff(class(pre), "sim_df")
      return(pre)
    }
  }
  pre
}
