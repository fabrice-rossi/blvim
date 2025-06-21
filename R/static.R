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
#' Spatial interaction models can store the positions of the origin and destination
#' locations, using [`origin_positions<-()`] and [`destination_positions<-()`].
#'
#' @param costs a cost matrix
#' @param X a vector of production constraints
#' @param alpha the return to scale parameter
#' @param beta the inverse cost scale parameter
#' @param Z a vector of destination attractivenesses
#'
#' @returns an object of class `sim` (and `sim_wpc`) for spatial interaction
#'   model that contains the matrix of flows from the origin locations to the
#'   destination locations (see \eqn{(Y_{ij})_{1\leq i\leq n, 1\leq j\leq p}}
#'   above) and the attractivenesses of the destination locations.
#'
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#'
#' @references Wilson, A. (1971), "A family of spatial interaction models, and
#'   associated developments", Environment and Planning A: Economy and Space,
#'   3(1), 1-32 \doi{10.1068/a030001}
#' @seealso [origin_names()], [destination_names()]
static_blvim <- function(costs, X, alpha, beta, Z) {
  check_configuration(costs, X, alpha, beta, Z)
  Y <- we_oc(costs, X, alpha, beta, Z)
  new_sim_wpc(Y, Z, costs, alpha, beta)
}
