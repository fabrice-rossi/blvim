#' Compute the "median" of a collection of spatial interaction models
#'
#' This function computes all pairwise distances between spatial interaction
#' models (SIMs) of its `x` parameter, using `sim_distance()` with the specified
#' distance parameters. Then it returns the "median" of the collection defined
#' as the SIM that is in average the closest to all the other SIMs. Tie breaking
#' uses the order of the SIMs in the collection.
#'
#' As distance calculation can be slow in a large collection of SIMs, the
#' distance object can be returned as a `distances` attribute of the median SIM
#' by setting the `return_distances` parameter to `TRUE`. In addition, the
#' returned SIM has always two attributes:
#' -  `index` gives the index of the mode in the original `sim_list`
#' -  `distortion` gives the mean of the distances from the median SIM to all
#' the other SIMs
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
#' @returns a spatial interaction model, an object of class `sim` with
#'   additional attributes
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.1),
#'   seq(1, 3, by = 0.5) / 400,
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#' )
#' all_flows_median <- median(all_flows)
#' attr(all_flows_median, "index")
#' attr(all_flows_median, "distortion")
#' median(all_flows, flows = "destination")
#' median(all_flows, flows = "attractiveness")
median.sim_list <- function(x,
                            na.rm = FALSE, ## nolintr
                            flows = c("full", "destination", "attractiveness"),
                            method = c("euclidean"),
                            return_distances = FALSE,
                            ...) {
  if (length(x) > 1) {
    xd <- sim_distance(x, flows, method)
    xdm <- as.matrix(xd)
    sum_of_dist <- colSums(xdm)
    best_index <- which.min(sum_of_dist)
    pre <- x[[best_index]]
    attr(pre, "index") <- as.integer(best_index)
    attr(pre, "distortion") <- as.numeric(sum_of_dist[best_index]) / length(x)
  } else {
    pre <- x[[1]]
    xd <- stats::as.dist(0)
    attr(pre, "index") <- 1L
    attr(pre, "distortion") <- 0
  }
  if (return_distances) {
    attr(pre, "distances") <- xd
  }
  pre
}
