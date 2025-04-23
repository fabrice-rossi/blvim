new_sim_list <- function(sims, ..., class = character()) {
  structure(
    list(
      sims = sims,
      alphas = sapply(sims, return_to_scale),
      betas = sapply(sims, inverse_cost),
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
  new_sim_list(x$sims[i, ...])
}

#' @export
`[[.sim_list` <- function(x, i, ...) {
  x$sims[[i, ...]]
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
  x$sims
}


#' Convert a collection of spatial interaction model into a Data Frame
#'
#' This function build a data frame from a collection of spatial interaction model.
#'
#' The data frame has one row per spatial interaction model and the following columns:
#' - `alpha`: the return to scale parameter used to build the model
#' - `beta`: the cost inverse scale parameter used to build the model
#' - `diversity`: model diversity
#' - `terminals`: if the origin and destination locations are identical, the
#'   terminals of the model
#' - `model`: if `models=TRUE`, the model
#'
#' @param x a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param models whether to include the models in the data frame (defaults to
#'   TRUE, that is to model inclusion)
#' @param ... additional parameters (not used currently)
#'
#' @returns a data frame representation of the spatial interaction model collection
#' @export
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' all_flows <- grid_blvim(distances, production, c(1.25, 1.5), c(1, 2, 3), attractiveness)
#' as.data.frame(all_flows, models = FALSE)
#'
as.data.frame.sim_list <- function(x, ..., models = TRUE) {
  pre_result <- data.frame(
    alpha = x$alphas,
    beta = x$betas,
    diversity = sapply(x, diversity)
  )
  dims <- dim(flows(x[[1]]))
  if (dims[1] == dims[2]) {
    pre_result$terminals <- I(lapply(x, terminals))
  }
  if (models) {
    pre_result$model <- I(x$sims)
  }
  pre_result
}
