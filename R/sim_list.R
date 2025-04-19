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
