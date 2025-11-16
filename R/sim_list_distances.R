#' Compute all pairwise distances between the spatial interaction models in a
#' collection
#'
#' This function extracts from each spatial interaction model of the collection
#' a vector representation derived from its flow matrix (see details). This
#' vector is then used to compute distances between the models.
#'
#' The vector representation is selected using the `flows` parameters. Possible
#' values are
#'
#' -  `"full"` (default value): the representation is obtained by considering
#' the matrix of [flows()] as a vector (with the standard [as.vector()]
#' function);
#' -  `"destination"`: the representation is the [destination_flow()] vector
#' associated to each spatial interaction model;
#' -  `"attractiveness"`: the representation is the [attractiveness()] vector
#' associated to each spatial interaction model.
#'
#' @param sim_list a collection of spatial interaction models, an object of
#'   class `sim_list`
#' @param flows `"full"` (default),  `"destination"` or `"attractiveness"`, see
#'   details.
#' @param method the distance measure to be used. Currently only `"euclidean"`
#'   is supported
#' @param ... additional parameters (not used currently)
#'
#' @returns an object of class `"dist"`
#' @seealso [dist()]
#' @export
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(
#'   distances, production, c(1.25, 1.5),
#'   c(1, 2, 3, 4) / 500, attractiveness,
#'   epsilon = 0.1
#' )
#' flows_distances <- sim_distance(all_flows)
#' inflows_distances <- sim_distance(all_flows, "destination")
sim_distance <- function(sim_list,
                         flows = c("full", "destination", "attractiveness"),
                         method = c("euclidean"),
                         ...) {
  if (!inherits(sim_list, "sim_list")) {
    cli::cli_abort("{.arg sim_list} must be an object of class {.cls sim_list}")
  }
  flows <- rlang::arg_match(flows)
  method <- rlang::arg_match(method)
  if (flows == "full") {
    n_flows <- t(sapply(sim_list, function(x) as.vector(flows(x))))
  } else if (flows == "destination") {
    n_flows <- grid_destination_flow(sim_list)
  } else {
    n_flows <- grid_attractiveness(sim_list)
  }
  collapse::fdist(n_flows)
}
