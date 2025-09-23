new_sim_df <- function(sim_list, sim_column, ..., class = character()) {
  if (!inherits(sim_list, "sim_list")) {
    cli::cli_abort("{.arg sim_list} must be a {.cls sim_list}")
  }
  if (sim_column %in% c("alpha", "beta", "diversity", "iterations", "converged")) {
    cli::cli_abort("{.arg sim_column} cannot be the reserved column name {.str {sim_column}}")
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
  names(pre_result)[6] <- sim_column
  attr(pre_result, "sim_column") <- sim_column
  class(pre_result) <- c(class, "sim_df", class(pre_result))
  pre_result
}

#' Create a spatial interaction models data frame from a collection of
#' interaction models
#'
#' This function build a data frame from a collection of spatial interaction
#' models. The data frame has a list column `sim` of type `sim_list` which
#' stores the collection of models and classical columns that contain
#' characteristics of the models. The name of the list column can be set to
#' something else than `sim` (but not a name used by other default columns). See
#' details for the default columns.
#'
#' The data frame has one row per spatial interaction model and the following
#' columns:
#' - `sim` (default name): the last column that contains the models
#' - `alpha`: the return to scale parameter used to build the model
#' - `beta`: the cost inverse scale parameter used to build the model
#' - `diversity`: model default [diversity()] (Shannon's diversity)
#' - `iterations`: the number of iterations used to produce the model (1 for a
#' static model)
#' - `converged`: `TRUE` is the iterative calculation of the model converged (for
#' models produced by [blvim()] and related approaches), `FALSE` for no
#' convergence and `NA` for static models
#'
#'
#' @param x a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param sim_column the name of the `sim_list` column (default `"sim"`)
#' @returns a data frame representation of the spatial interaction model
#'   collection with classes `sim_df` and `data.frame`
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
sim_df <- function(x, sim_column = "sim") {
  new_sim_df(x, sim_column)
}

#' Get the collection of spatial interaction models from a sim data frame
#'
#' @param sim_df a data frame of spatial interaction models, an object of class
#'   `sim_df`
#'
#' @returns the collection of spatial interaction models in the `sim_df` object,
#' as a `sim_list` object
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' all_flows <- grid_blvim(distances, production, c(1.25, 1.5), c(1, 2, 3), attractiveness)
#' all_flows_df <- sim_df(all_flows)
#' sim_column(all_flows_df)
sim_column <- function(sim_df) {
  if (!inherits(sim_df, "sim_df")) {
    cli::cli_abort("{.arg sim_df} must be a {.cls sim_df} object")
  }
  pre <- sim_df[[attr(sim_df, "sim_column")]]
  ## remove the "AsIs" class
  class(pre) <- setdiff(class(pre), "AsIs")
  pre
}

#' @export
`$<-.sim_df` <- function(x, name, value) {
  sim_column <- attr(x, "sim_column")
  pre <- NextMethod()
  if (name == sim_column) {
    if (is.null(value) || !inherits(value, "sim_list")) {
      ## remove the sim_df class
      class(pre) <- setdiff(class(pre), "sim_df")
      attr(pre, "sim_column") <- NULL
    } else {
      if (!inherits(pre[[name]], "AsIs")) {
        class(pre[[name]]) <- c("AsIs", class(pre[[name]]))
      }
    }
  }
  pre
}

#' @export
`[[<-.sim_df` <- function(x, i, value) {
  sim_column <- attr(x, "sim_column")
  pre <- NextMethod()
  if (!inherits(pre, "sim_df")) {
    class(pre) <- c("sim_df", class(pre))
    attr(pre, "sim_column") <- sim_column
  }
  if ((is.character(i) && i == sim_column) ||
    (!is.character(i) && names(x)[i] == sim_column)) {
    if (is.null(value) || !inherits(value, "sim_list")) {
      class(pre) <- setdiff(class(pre), "sim_df")
      attr(pre, "sim_column") <- NULL
    } else {
      if (!inherits(pre[[i]], "AsIs")) {
        class(pre[[i]]) <- c("AsIs", class(pre[[i]]))
      }
    }
  }
  pre
}

#' @export
`[.sim_df` <- function(x, i, j, ..., drop) {
  sim_column <- attr(x, "sim_column")
  pre <- NextMethod()
  if (!inherits(pre, "sim_df")) {
    class(pre) <- c("sim_df", class(pre))
    attr(pre, "sim_column") <- sim_column
  }
  if (sim_column %in% names(pre)) {
    attr(pre, "sim_column") <- attr(x, "sim_column")
  } else {
    class(pre) <- setdiff(class(pre), "sim_df")
    attr(pre, "sim_column") <- NULL
  }
  pre
}

#' @export
`[<-.sim_df` <- function(x, i, j, value) {
  ## we can handle only full column replacement for the sim_columns
  sim_column <- attr(x, "sim_column")
  if (rlang::is_missing(i)) {
    if ((is.character(j) && j == sim_column) ||
      (!is.character(j) && names(x)[j] == sim_column)) {
      if (is.null(value) || !inherits(value, "sim_list")) {
        x[[sim_column]] <- value
        class(x) <- setdiff(class(x), "sim_df")
        attr(x, "sim_column") <- NULL
      } else {
        x[[sim_column]] <- I(value)
      }
      return(x)
    }
  } else {
    pre <- NextMethod()
    if (!inherits(pre, "sim_df")) {
      class(pre) <- c("sim_df", class(pre))
      attr(pre, "sim_column") <- sim_column
    }
    return(pre)
  }
}


#' @export
`names<-.sim_df` <- function(x, value) {
  sim_column <- attr(x, "sim_column")
  position <- match(sim_column, names(x))
  pre <- NextMethod()
  new_names <- names(pre)
  if (!is.null(new_names[position]) && !is.na(new_names[position])) {
    attr(pre, "sim_column") <- new_names[position]
    if (!inherits(pre, "sim_df")) {
      class(pre) <- c("sim_df", class(pre))
    }
  } else {
    class(pre) <- setdiff(class(pre), "sim_df")
    attr(pre, "sim_column") <- NULL
  }
  pre
}
