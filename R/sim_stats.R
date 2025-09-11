#' Compute the median of a collection of spatial interaction models
#'
#' This function computes all pairwise distances between spatial interaction
#' models (SIMs) of its `x` parameter, using `sim_distance()` with the specified
#' distance parameters. Then it returns the median of the collection defined as
#' the SIM that is in average the closest to all the other SIMs. Tie breaking
#' uses the order of the SIMs in the collection.
#'
#' As distance calculation can be slow in a large collection of SIMs, the
#' distance object can be returned as a `distances` attribute of the median SIM
#' by setting the `return_distances` parameter to `TRUE`.
#'
#' @param x a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param na.rm not used
#' @param return_distances should the distances computed to find the median be
#'   returned as a `distances` attribute of the resulting object? (defaults to
#'   `FALSE`)
#' @param ... additional parameters (not used currently)
#'
#' @inheritParams sim_distance
#' @returns a spatial interaction model, an object of class `sim`
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
#' median(all_flows)
#' median(all_flows, flows = "destination")
#' median(all_flows, flows = "attractiveness")
median.sim_list <- function(x,
                            na.rm = FALSE,
                            flows = c("full", "destination", "attractiveness"),
                            method = c("euclidean"),
                            return_distances = FALSE,
                            ...) {
  if (length(x) > 1) {
    xd <- sim_distance(x, flows, method)
    xdm <- as.matrix(xd)
    pre <- x[[which.min(colSums(xdm))]]
  } else {
    pre <- x[[1]]
    xd <- stats::as.dist(0)
  }
  if (return_distances) {
    attr(pre, "distances") <- xd
  }
  pre
}
