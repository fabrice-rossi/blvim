#' @export
format.summary_sim_list <- function(x, ...) {
  a_flow <- flows(x$median)
  cli::cli_format_method({
    cli::cli_h2("Summary of a collection of {.val {x$nb_sims}} spatial interaction model{?s}")
    cli::cli_text(
      "All models have {.val {nrow(a_flow)}} origin locations and ",
      "{.val {ncol(a_flow)}} destination locations."
    )
    cli::cli_h2("Median representation")
    cli::cli_h3("Median spatial interaction model")
    sim_cli_rep(x$median)
    cli::cli_h3("Homogeneity")
    divid <- cli::cli_div(theme = list(.val = list(digits = 3)))
    cli::cli_ul(
      cli::cli_text("distortion: {.val {x$distortion}}"),
      cli::cli_text("within variance: {.val {x$withinss}}")
    )
    cli::cli_end(divid)
    if (!is.null(x[["nb_configurations"]])) {
      cli::cli_h2("Terminals")
      cli::cli_text("The list has {.val {x$nb_configurations}} different
terminal configuration{?s}")
    }
  })
}

#' Summary of a collection of spatial interaction models
#'
#' This function computes summary statistics on a collection of spatial
#' interaction models (in a `sim_list`).
#'
#' The list returned by the function contains the following elements:
#'
#' - `median`: the median of the collection, as return by the `median.sim_list()`
#'   function
#' - `distortion`: the average distance of all elements of the collection to
#'  the median model
#' -  `withinss`: the sum of all pairwise distances between the elements of
#'  the collection
#' -  `nb_sims`: the size of the collection
#'
#' In addition, if the collection contains non bipartite models, the result
#' has another element, `nb_configurations` which gives the number of distinct
#' terminal sets in the collection, where the terminals are computed by
#' `terminals()`, using the `"RW"` definition.
#'
#' @param object a collection of spatial interaction models, an object of class
#'   `sim_list`
#' [summary.sim_list()]
#' @param ... additional parameters (not used currently)
#'
#' @returns an object of class `summary_sim_list` and `list` with a set of
#' summary statistics computed on the collection of spatial interaction models
#' @seealso [median.sim_list()], [terminals()]
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
#'   epsilon = 0.1,
#'   bipartite = FALSE,
#' )
#' summary(all_flows)
summary.sim_list <- function(object, ...) {
  median_sim <- median(object, return_distances = TRUE)
  pre <- list(
    median = median_sim,
    distortion = attr(median_sim, "distortion"),
    withinss = sum(attr(median_sim, "distances")),
    nb_sims = length(object)
  )
  if (!any(sapply(object, sim_is_bipartite))) {
    all_configurations <- lapply(object, terminals, definition = "RW")
    pre$nb_configurations <- length(unique(all_configurations))
  }
  structure(pre, class = c("summary_sim_list", "list"))
}

#' @export
#' @param x an object of class `summary_sim_list` produced by
#' @rdname summary.sim_list
print.summary_sim_list <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}
