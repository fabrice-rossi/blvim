## simple functions to return elements that are common to all sim objects in a sim_list

#' Extract the common cost matrix from a collection of spatial interaction models
#'
#' @param sim a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param ... additional parameters
#'
#' @returns the cost matrix
#' @seealso [costs()], [grid_blvim()]
#' @export
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
#' ## should be TRUE
#' identical(distances, costs(all_flows))
#'
costs.sim_list <- function(sim, ...) {
  attr(sim, "common")$costs
}
