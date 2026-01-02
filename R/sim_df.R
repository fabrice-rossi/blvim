new_sim_df <- function(sim_list, sim_column, ..., class = character()) {
  if (!inherits(sim_list, "sim_list")) {
    cli::cli_abort("{.arg sim_list} must be a {.cls sim_list}")
  }
  if (sim_column %in% c(
    "alpha", "beta", "diversity", "iterations",
    "converged"
  )) {
    cli::cli_abort("{.arg sim_column} cannot be the reserved column
name {.str {sim_column}}")
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

sim_df_reserved_column <- function() {
  c("alpha", "beta", "diversity", "iterations", "converged")
}

recompute_sim_df <- function(sim_df) {
  sim_list <- sim_column(sim_df)
  class(sim_df) <- setdiff(class(sim_df), "sim_df")
  sim_df$alpha <- sapply(sim_list, return_to_scale)
  sim_df$beta <- sapply(sim_list, inverse_cost)
  sim_df$diversity <- grid_diversity(sim_list)
  sim_df$iterations <- sapply(sim_list, sim_iterations)
  sim_df$converged <- sapply(sim_list, sim_converged)
  class(sim_df) <- c("sim_df", class(sim_df))
  sim_df
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
#' - `converged`: `TRUE` is the iterative calculation of the model converged
#' (for models produced by [blvim()] and related approaches), `FALSE` for no
#' convergence and `NA` for static models
#'
#' The resulting object behaves mostly like a `data.frame` and support standard
#' extraction and replacement operators. The object tries to keep its `sim_df`
#' class during modifications. In particular, `names<-.sim_df()` tracks
#' name change for the `sim_list` column. If a modification or an extraction
#' operation changes the type of the `sim_list` column or drops it, the
#' resulting object is a standard `data.frame`. See \code{\link{[.sim_df}}
#' and [names<-.sim_df()] for details.
#'
#' @param x a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param sim_column the name of the `sim_list` column (default `"sim"`)
#' @returns a data frame representation of the spatial interaction model
#'   collection with classes `sim_df` and `data.frame`
#' @export
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.2),
#'   seq(1, 3, by = 0.5) / 400,
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#' )
#' all_flows_df <- sim_df(all_flows)
#' all_flows_df$converged
#' ## change the name of the sim column
#' names(all_flows_df)[6] <- "models"
#' ## still a sim_df
#' class(all_flows_df)
#' ## get the models
#' sim_column(all_flows_df)
sim_df <- function(x, sim_column = "sim") {
  new_sim_df(x, sim_column)
}

#' Get the collection of spatial interaction models from a SIM data frame
#'
#' @param sim_df a data frame of spatial interaction models, an object of class
#'   `sim_df`
#'
#' @returns the collection of spatial interaction models in the `sim_df` object,
#' as a `sim_list` object
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.2),
#'   seq(1, 3, by = 0.5) / 400,
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#' )
#' all_flows_df <- sim_df(all_flows, sim_colum = "my_col")
#' names(all_flows_df)
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

#' Extract or replace parts of a SIM data frame
#'
#' Extract or replace subsets of SIM data frames. The behaviour of the functions
#' is very close to the one of the corresponding `data.frame` functions, see
#' \code{\link[base]{[.data.frame}}. However, modifications of the SIM columns
#' or suppression of core columns will turn the object into a standard
#' `data.frame` to void issues in e.g. graphical representations, see below for
#' details.
#'
#' In a `sim_df`, the core columns are derived from the `sim_list` column.
#' Replacement functions maintain this property by updating the columns after
#' any modification of the `sim_list` column. Modifications of the core columns
#' are rejected (removing a core column is accepted but this turns the `sim_df`
#' into a standard `data.frame`).
#'
#' In addition, the `sim_list` column obeys to restriction on `sim_list`
#' modifications (i.e, a `sim_list` contains a homogeneous collection of spatial
#' interaction models).
#'
#' Extraction functions keep the `sim_df` class only if the result is a data
#' frame with a `sim_list` column, the core columns and potentially additional
#' columns.
#'
#' @param x  data frame of spatial interaction models, an object of class
#'   `sim_df`
#' @param name a literal character string
#' @param drop If `TRUE` the result is coerced to the lowest possible
#'   dimension. The default is to drop if only one column is left, but not to
#'   drop if only one row is left.
#' @param i,j,...	 elements to extract or replace. For `[` and `[[`, these are
#'   numeric or character or, for `[` only, empty or logical. Numeric values are
#'   coerced to integer as if by as.integer. For replacement by `[`, a logical
#'   matrix is allowed.
#' @param value a suitable replacement value: it will be repeated a whole number
#'   of times if necessary and it may be coerced: see the Coercion section in
#'   \code{\link[base]{[.data.frame}}. If NULL, deletes the column if a single
#'   column is selected.
#'
#' @name sim_df_extract
#' @return For `[` a `sim_df`, a `data.frame` or a single column depending on the
#'  values of `i` and `j`.
#'
#'  For `[[` a column of the `sim_df` (or `NULL`) or an element of a column when
#'  two indices are used.
#'
#'  For `$` a column of the `sim_df` (or `NULL`).
#'
#'  For `[<-`, `[[<-`, and `$<-` a `sim_df` or a data frame (see
#'  details).
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.2),
#'   seq(1, 3, by = 0.5) / 400,
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#' )
#' all_flows_df <- sim_df(all_flows)
#' ## the models as a sim_list
#' all_flows_df[, "sim"]
#' ## sub data frame, a sim_df
#' all_flows_df[1:5, ]
#' ## sub data frame, not a sim_df (alpha is missing)
#' all_flows_df[6:10, 2:6]
#' all_flows_2 <- grid_blvim(distances, log(french_cities$population[1:10]),
#'   seq(1.05, 1.45, by = 0.2),
#'   seq(1, 3, by = 0.5) / 400,
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#' )
#' ## replace the sim_list column by the new models
#' ## before
#' all_flows_df$diversity
#' all_flows_df$sim <- all_flows_2
#' ## after (all core columns have been updated)
#' all_flows_df$diversity
#'
NULL
#> NULL


#' @rdname sim_df_extract
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
      ## we need to recompute the core values
      pre <- recompute_sim_df(pre)
    }
  } else if (name %in% sim_df_reserved_column()) {
    if (is.null(value)) {
      ## remove the sim_df class
      class(pre) <- setdiff(class(pre), "sim_df")
      attr(pre, "sim_column") <- NULL
    } else {
      if (!identical(x[[name]], pre[[name]])) {
        cli::cli_abort(c("Automatic columns cannot be modified",
          x = "Modification attempt on column {.val {name}}"
        ))
      }
    }
  }
  pre
}

#' @rdname sim_df_extract
#' @export
`[[<-.sim_df` <- function(x, i, j, value) {
  sim_column <- attr(x, "sim_column")
  pre <- NextMethod()
  if (!inherits(pre, "sim_df")) {
    class(pre) <- c("sim_df", class(pre))
    attr(pre, "sim_column") <- sim_column
  }
  if (is.character(i)) {
    col_name <- i
  } else {
    col_name <- names(x)[i]
  }
  if (col_name == sim_column) {
    if (is.null(value) || !inherits(value, "sim_list")) {
      class(pre) <- setdiff(class(pre), "sim_df")
      attr(pre, "sim_column") <- NULL
    } else {
      if (!inherits(pre[[i]], "AsIs")) {
        class(pre[[i]]) <- c("AsIs", class(pre[[i]]))
      }
      ## we need to recompute the core values
      pre <- recompute_sim_df(pre)
    }
  } else if (col_name %in% sim_df_reserved_column()) {
    if (is.null(value)) {
      ## remove the sim_df class
      class(pre) <- setdiff(class(pre), "sim_df")
      attr(pre, "sim_column") <- NULL
    } else {
      if (!identical(x[[col_name]], pre[[col_name]])) {
        cli::cli_abort(c("Automatic columns cannot be modified",
          x = "Modification attempt on column {.val {col_name}}"
        ))
      }
    }
  }
  pre
}

#' @rdname sim_df_extract
#' @export
`[.sim_df` <- function(x, i, j, ..., drop) {
  sim_column <- attr(x, "sim_column")
  pre <- NextMethod()
  if (!inherits(pre, "sim_df")) {
    class(pre) <- c("sim_df", class(pre))
    attr(pre, "sim_column") <- sim_column
  }
  if (sim_column %in% names(pre) &&
    all(sim_df_reserved_column() %in% names(pre))) {
    attr(pre, "sim_column") <- attr(x, "sim_column")
  } else {
    class(pre) <- setdiff(class(pre), "sim_df")
    attr(pre, "sim_column") <- NULL
  }
  pre
}

#' @rdname sim_df_extract
#' @export
`[<-.sim_df` <- function(x, i, j, value) {
  sim_column <- attr(x, "sim_column")
  if (rlang::is_missing(i)) {
    ## full replacement
    if ((is.character(j) && j == sim_column) ||
      (!is.character(j) && names(x)[j] == sim_column)) {
      if (is.null(value) || !inherits(value, "sim_list")) {
        x[[sim_column]] <- value
        class(x) <- setdiff(class(x), "sim_df")
        attr(x, "sim_column") <- NULL
      } else {
        x[[sim_column]] <- I(value)
        ## recompute core values
        x <- recompute_sim_df(x)
      }
    }
    x
  } else {
    pre <- NextMethod()
    if (!inherits(pre, "sim_df")) {
      class(pre) <- c("sim_df", class(pre))
      attr(pre, "sim_column") <- sim_column
    }
    pre
  }
}


#' Set the column names of a SIM data frame
#'
#' Set the column names of a SIM data frame. Renaming the `sim_list` column is
#' supported and tracked, but renaming any core column turns the `sim_df`
#' into a standard `data.frame`.
#'
#' @param x  data frame of spatial interaction models, an object of class
#'   `sim_df`
#' @param value unique names for the columns of the data frame
#' @returns a `sim_df` data frame if possible, a standard `data.frame` when
#'  this is not possible.
#' @export
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.2),
#'   seq(1, 3, by = 0.5) / 400,
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#' )
#' all_flows_df <- sim_df(all_flows)
#' names(all_flows_df)
#' names(all_flows_df)[6] <- "my_sim"
#' names(all_flows_df)
#' ## still a sim_df
#' class(all_flows_df)
#' names(all_flows_df)[1] <- "return to scale"
#' names(all_flows_df)
#' ## not a sim_df
#' class(all_flows_df)
`names<-.sim_df` <- function(x, value) {
  sim_column <- attr(x, "sim_column")
  position <- match(sim_column, names(x))
  pos_automatic <- match(sim_df_reserved_column(), names(x))
  pre <- NextMethod()
  new_names <- names(pre)
  if (!all(new_names[pos_automatic] == sim_df_reserved_column())) {
    class(pre) <- setdiff(class(pre), "sim_df")
    attr(pre, "sim_column") <- NULL
  } else {
    if (!is.null(new_names[position]) && !is.na(new_names[position])) {
      attr(pre, "sim_column") <- new_names[position]
      if (!inherits(pre, "sim_df")) {
        class(pre) <- c("sim_df", class(pre))
      }
    } else {
      class(pre) <- setdiff(class(pre), "sim_df")
      attr(pre, "sim_column") <- NULL
    }
  }
  pre
}
