#' Compute flows between origin and destination locations
#'
#' This function computes flows between origin locations and destination
#' locations according to the production constrained entropy maximising model
#' proposed by A. Wilson.
#'
#' The model computes flows using the following parameters:
#' * `costs` (\eqn{c}) is a \eqn{n\times p} matrix whose \eqn{(i,j )} entry is the
#' cost of having a "unitary" flow from origin location \eqn{i} to destination
#' location \eqn{j}
#' * `X` (\eqn{X}) is a vector of size \eqn{n} containing non negative production
#' constraints for the \eqn{n} origin locations
#' * `alpha` (\eqn{\alpha}) is a return to scale parameter that enhance (or reduce
#' if smaller that 1) the attractivenesses of destination locations when they
#' are larger than 1
#' * `beta` (\eqn{\beta}) is the inverse of a cost scale parameter, i.e., costs
#' are multiplied by `beta` in the model
#' * `Z` (\eqn{Z}) is a vector of size \eqn{p} containing the positive
#' attractivenesses of the \eqn{p} destination locations
#'
#' According to Wilson's model, the flow from origin location \eqn{i} to
#' destination location \eqn{j}, \eqn{Y_{ij}}, is given by
#'
#' \deqn{Y_{ij}=\frac{X_iZ_j^{\alpha}\exp(-\beta
#' c_{ij})}{\sum_{k=1}^pZ_k^{\alpha}\exp(-\beta c_{ik})}.}
#'
#' The model is production constrained because
#'
#' \deqn{\forall i,\quad X_i=\sum_{j=1}^{p}Y_{ij},}
#'
#' that is the origin location \eqn{i} sends a total flow of exactly \eqn{X_i}.
#'
#' # Location data
#'
#' While models in this package do not use location data beyond `X` and `Z`,
#' additional data can be stored and used when analysing spatial interaction
#' models.
#'
#' ## Origin and destination location names
#'
#' Spatial interaction models can store names for origin and destination
#' locations, using [`origin_names<-()`] and [`destination_names<-()`]. Names
#' are taken by default from names of the cost matrix `costs`. More precisely,
#' `rownames(costs)` is used for origin location names and `colnames(costs)` for
#' destination location names.
#'
#' ## Origin and destination location positions
#'
#' Spatial interaction models can store the positions of the origin and
#' destination locations, using [`origin_positions<-()`] and
#' [`destination_positions<-()`].
#'
#' ## Specifying location data
#'
#' In addition to the functions mentioned above, location data can be specified
#' directly using the `origin_data` and `destination_data` parameters. Data are
#' given by a list whose components are not interpreted excepted the following
#' ones:
#'   - `names` is used to specify location names and its content has to follow
#'   the restrictions documented in [`origin_names<-()`] and [`destination_names<-()`]
#'   - `positions` is used to specify location positions and its content has
#'   to follow the restrictions documented in [`origin_positions<-()`] and
#'   [`destination_positions<-()`]
#'
#' @param costs a cost matrix
#' @param X a vector of production constraints
#' @param alpha the return to scale parameter
#' @param beta the inverse cost scale parameter
#' @param Z a vector of destination attractivenesses
#' @param bipartite when `TRUE` (default value), the origin and destination
#'   locations are considered to be distinct. When `FALSE`, a single set of
#'   locations plays the both roles. This has only consequences in functions
#'   specific to this latter case such as [terminals()].
#' @param origin_data `NULL` or a list of additional data about the origin
#'   locations (see details)
#' @param destination_data `NULL` or a list of additional data about the
#'   destination locations (see details)
#'
#' @returns an object of class `sim` (and `sim_wpc`) for spatial interaction
#'   model that contains the matrix of flows from the origin locations to the
#'   destination locations (see \eqn{(Y_{ij})_{1\leq i\leq n, 1\leq j\leq p}}
#'   above) and the attractivenesses of the destination locations.
#'
#' @export
#'
#' @examples
#' positions <- as.matrix(french_cities[1:10, c("th_longitude", "th_latitude")])
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 500, attractiveness,
#'   origin_data = list(names = french_cities$name[1:10], positions = positions),
#'   destination_data = list(names = french_cities$name[1:10], positions = positions)
#' )
#' model
#' location_names(model)
#' location_positions(model)
#' @references Wilson, A. (1971), "A family of spatial interaction models, and
#'   associated developments", Environment and Planning A: Economy and Space,
#'   3(1), 1-32 \doi{10.1068/a030001}
#' @seealso [origin_names()], [destination_names()]
static_blvim <- function(costs, X, alpha, beta, Z, bipartite = TRUE, origin_data = NULL, destination_data = NULL) {
  check_configuration(costs, X, alpha, beta, Z, bipartite)
  Y <- we_oc(costs, X, alpha, beta, Z)
  new_sim_wpc(Y, Z, costs, alpha, beta, bipartite, origin_data, destination_data)
}
