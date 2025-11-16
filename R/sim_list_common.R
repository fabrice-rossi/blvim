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
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(
#'   distances, production, c(1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness
#' )
#' ## should be TRUE
#' identical(distances, costs(all_flows))
#'
costs.sim_list <- function(sim, ...) {
  attr(sim, "common")$costs
}
