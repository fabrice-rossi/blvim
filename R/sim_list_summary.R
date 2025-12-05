#' Summary of a collection of spatial interaction models
#'
#' @param object a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param ... additional parameters (not used currently)
#'
#' @returns a list with a set of summary statistics computed on the collection
#'   of spatial interaction models
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
    withinss = sum(attr(median_sim, "distances"))
  )
  if (!any(sapply(object, sim_is_bipartite))) {
    all_configurations <- lapply(object, terminals, definition = "RW")
    pre$nb_configurations <- length(unique(all_configurations))
  }
  pre
}
