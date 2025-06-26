#' Compute an equilibrium solution of the Boltzmann–Lotka–Volterra model
#'
#' This function computes flows between origin locations and destination
#' locations at an equilibrium solution of A. Wilson's Boltzmann–Lotka–Volterra
#' (BLV) interaction model. The BLV dynamic model is initialised with the
#' production constraints at the origin locations and the initial values of the
#' the attractiveness of destination locations. Iterations update the
#' attractivenesses according the received flows.
#'
#' In a step of the BLV model, flows are computed according to the production
#' constrained entropy maximising model proposed by A. Wilson and implemented in
#' [static_blvim()]. Then the flows received at a destination are computed as
#' follows
#'
#' \deqn{\forall j,\quad D_j=\sum_{i=1}^{n}Y_{ij},}
#'
#' for destination \eqn{j}. This enables updating the attractivenesses by making
#' them closer to the received flows, i.e. trying to reduce \eqn{|D_j-Z_j|}.
#'
#' A. Wilson and co-authors proposed two different update strategies:
#'
#' 1. The original model proposed in Harris & Wilson (1978) updates the
#' \eqn{Z_j} as follows \deqn{Z_j^{t+1} = Z_j^{t} + \epsilon (D^{t}_j-Z^{t}_j)}
#' 2. In Wilson (2008), the update is given by \deqn{Z_j^{t+1} = Z_j^{t} +
#' \epsilon (D^{t}_j-Z^{t}_j)Z^{t}_j}
#'
#' In both cases, \eqn{\epsilon} is given by the `epsilon` parameter. It should
#' be smaller than 1. The first update is used when the `quadratic` parameter is
#' `FALSE` which is the default value. The second update is used when
#' `quadratic` is `TRUE`.
#'
#' Updates are performed until convergence or for a maximum of `iter_max`
#' iterations. Convergence is checked every `conv_check` iterations. The
#' algorithm is considered to have converged if \deqn{\|Z^{t+1}-Z^t\|<\delta
#' (\|Z^{t+1}\|+\delta),} where \eqn{\delta} is given by the `precision`
#' parameter.
#'
#' @param Z a vector of initial destination attractivenesses
#' @param epsilon the update intensity
#' @param iter_max the maximal number of steps of the BLV dynamic
#' @param conv_check number of iterations between to convergence test
#' @param precision convergence threshold
#' @param quadratic selects the update rule, see details.
#'
#' @inheritParams static_blvim
#' @returns an object of class `sim`(and `sim_blvim`) for spatial interaction
#'   model that contains the matrix of flows between the origin and the
#'   destination locations as well as the final attractivenesses computed by the
#'   model.
#' @export
#'
#' @inheritSection static_blvim Location data
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' flows <- blvim(distances, production, 1.5, 1, attractiveness)
#' flows
#' @references Harris, B., & Wilson, A. G. (1978). "Equilibrium Values and
#'   Dynamics of Attractiveness Terms in Production-Constrained
#'   Spatial-Interaction Models", Environment and Planning A: Economy and Space,
#'   10(4), 371-388. \doi{10.1068/a100371}
#'
#'   Wilson, A. (2008), "Boltzmann, Lotka and Volterra and spatial structural
#'   evolution: an integrated methodology for some dynamical systems", J. R.
#'   Soc. Interface.5865–871 \doi{10.1098/rsif.2007.1288}
#'
blvim <- function(costs, X, alpha, beta, Z,
                  bipartite = TRUE, origin_data = NULL, destination_data = NULL,
                  epsilon = 0.01,
                  iter_max = 50000,
                  conv_check = 100,
                  precision = 1e-6,
                  quadratic = FALSE) {
  check_configuration(costs, X, alpha, beta, Z, bipartite)
  pre <- blv(costs, X, alpha, beta, Z, epsilon, iter_max, conv_check, precision, quadratic)
  new_sim_blvim(pre$Y, pre$Z[, 1], costs, alpha, beta,
    bipartite, origin_data, destination_data,
    iteration = pre$iter + 1L,
    converged = pre$iter < iter_max
  )
}
