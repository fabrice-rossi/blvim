#' Compute an equilibrium solution of the Harris and Wilson model
#'
#' This function computes flows between origin locations and destination
#' locations at an equilibrium solution of Harris and Wilson interaction model.
#' The model is initialised with the production constraints at the origin
#' locations and the initial values of the the attractivenesses of destination
#' locations. At convergence, attractivenesses fulfil the balance equations
#' \deqn{\forall j,\quad \kappa_j Z_j=\sum_{i=1}^{n}Y_{ij},} where the flows are
#' computed according to Wilson's  production constrained entropy maximising
#' model. The function implements several algorithms that all aim to reach an
#' equilibrium.
#'
#' All algorithms are initialised with user supplied attractivenesses and
#' proceed iteratively by updating them until convergence. Two algorithms are
#' instances of A. Wilson's Boltzmann-Lotka-Volterra (BLV) interaction model,
#' while the other two algorithms are based on gradient ascent.
#'
#' ##  Boltzmann-Lotka-Volterra (BLV) iterations
#'
#' In a step of the BLV model, flows are computed according to the production
#' constrained entropy maximising model proposed by A. Wilson and implemented in
#' [static_blvim()]. Then the flows received at a destination are computed as
#' follows
#'
#' \deqn{\forall j,\quad D_j=\sum_{i=1}^{n}Y_{ij},}
#'
#' for destination \eqn{j}. This enables the attractivenesses to be updated by
#' making them closer to the received flows, i.e. by trying to reduce
#' \eqn{|D_j-\kappa_j Z_j|}, where \eqn{\kappa_j} is a conversion factor between
#' the attractiveness and the destination flow.
#'
#' Two algorithms of this family are available through the `algorithm` parameter:
#'
#' 1. `"linear"` uses the original update rule proposed in Harris & Wilson
#'    (1978):
#'
#'    \deqn{
#'      Z_j^{t+1} =
#'      Z_j^t +
#'      \epsilon
#'      \left(
#'        \frac{D_j^t}{\kappa_j} - Z_j^t
#'      \right).
#'    }
#'
#' 2. `"quadratic"` uses the update rule proposed in Wilson (2008):
#'
#'    \deqn{
#'      Z_j^{t+1} =
#'      Z_j^t +
#'      \epsilon
#'      \left(
#'        \frac{D_j^t}{\kappa_j} - Z_j^t
#'      \right) Z_j^t.
#'    }
#'
#' For these algoritms(`"linear"` and `"quadratic"`), \eqn{\epsilon} is given by
#' the `epsilon` parameter and should generally be smaller than 1.
#'
#' Updates are performed until convergence or for a maximum of `iter_max`
#' iterations. Convergence is checked every `conv_check` iterations. The
#' algorithm is considered to have converged if
#'
#' \deqn{
#'   \|Z^{t+1}-Z^t\| <
#'   \delta \left(\|Z^{t+1}\|+\delta\right),
#' }
#'
#' where \eqn{\delta} is given by the `precision` parameter.
#'
#' ## Gradient algorithms
#'
#' Finding an equilibrium with the BLV  approach is equivalent to looking for a
#' maximum of the potential function (see [sim_potential()]). The gradient
#' descent algorithms use a direct approach of optimising the potential via a
#' projected gradient ascent. The `"gradient"` algorithm is optimises directly
#' the potential while `"gradient_unit"` rescales the problem in to work with
#' \eqn{U_j} instead of \eqn{Z_j} in such a way that \eqn{sum_{j=1}^p U_j=1}.
#' This can accelerate convergence in some settings. Results should be identical
#' from both gradient approaches, but they can be different from solutions
#' obtained by the `"linear"` and `"quadratic"` algorithms.
#'
#' The `epsilon` and `conv_check` parameters are not used by the `"gradient"`
#' algorithm.
#'
#' @param Z A vector of initial destination attractivenesses.
#' @param kappa A vector of conversion factors between attractivenesses and
#'   incoming flows. Values must be positive. Defaults to 1 for all
#'   destinations.
#' @param epsilon Update intensity used by the `"linear"` and `"quadratic"`
#'   algorithms.
#' @param iter_max Maximum number of iterations.
#' @param conv_check Number of iterations between convergence checks for the
#'   `"linear"` and `"quadratic"` algorithms.
#' @param precision Convergence threshold.
#' @param algorithm Character string selecting the algorithm used to compute
#'   the equilibrium. One of `"linear"`, `"quadratic"`, `"gradient"` or
#'   `"gradient_unit"`. Defaults to `"linear"`. Partial matching is supported.
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
#' distances <- french_cities_distances[1:10, 1:10] / 1000
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#'
#' # Rescale attractivenesses to total production
#' attractiveness <- attractiveness / sum(attractiveness) * sum(production)
#'
#' # Original Harris-Wilson update rule
#' flows <- blvim(
#'   distances,
#'   production,
#'   1.5,
#'   1 / 250,
#'   attractiveness,
#'   algorithm = "linear"
#' )
#' flows
#'
#' # Wilson's quadratic update rule
#' quadratic_flows <- blvim(
#'   distances,
#'   production,
#'   1.5,
#'   1 / 250,
#'   attractiveness,
#'   algorithm = "quadratic"
#' )
#'
#' # Gradient-based algorithm
#' gradient_flows <- blvim(
#'   distances,
#'   production,
#'   1.5,
#'   1 / 250,
#'   attractiveness,
#'   algorithm = "gradient"
#' )
#'
#' @references Harris, B., & Wilson, A. G. (1978). "Equilibrium Values and
#'   Dynamics of Attractiveness Terms in Production-Constrained
#'   Spatial-Interaction Models", Environment and Planning A: Economy and Space,
#'   10(4), 371-388. \doi{10.1068/a100371}
#'
#'   Wilson, A. (2008), "Boltzmann, Lotka and Volterra and spatial structural
#'   evolution: an integrated methodology for some dynamical systems", J. R.
#'   Soc. Interface.5865-871 \doi{10.1098/rsif.2007.1288}
#' @seealso [grid_blvim()] for systematic exploration of parameter influence,
#' [static_blvim()] for the static model, [sim_potential()] for the potential
#' function.
blvim <- function(costs, X, alpha, beta, Z,
                  kappa = 1,
                  bipartite = TRUE, origin_data = NULL, destination_data = NULL,
                  epsilon = 0.01,
                  iter_max = 50000,
                  conv_check = 100,
                  precision = 1e-6,
                  algorithm = c("linear", "quadratic", "gradient", "gradient_unit"),
                  trace = FALSE) {
  algorithm <- match.arg(algorithm)
  check_configuration(costs, X, alpha, beta, Z, kappa, bipartite)
  all_kappa <- rep(1, length(Z))
  if (isTRUE(kappa == 1)) {
    ## no real kappa
    with_kappa <- FALSE
  } else {
    with_kappa <- TRUE
    all_kappa[1:length(Z)] <- kappa
  }
  if (algorithm == "gradient") {
    pre <- blv_gradient(costs, X, alpha, beta, Z, all_kappa, precision = precision,
                        iter_max = iter_max,
                        c = min(10e-4, 10e-4 * precision/(.Machine$double.eps)^0.5))
  } else if (algorithm == "gradient_unit") {
    pre <- blv_gradient_unit(costs, X, alpha, beta, Z, all_kappa,
      precision = precision,
      iter_max = iter_max,
      rho_init = 0.5,
      c = min(10e-4, 10e-4 * precision/(.Machine$double.eps)^0.5),
      trace = trace
    )
  } else {
    pre <- blv(
      costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max, conv_check, precision,
      quadratic = algorithm == "quadratic", with_kappa
    )
  }
  new_sim_blvim(pre$Y, pre$Z[, 1], costs, alpha, beta,
    bipartite, origin_data, destination_data,
    iteration = pre$iter + 1L,
    converged = pre$iter < iter_max,
    kappa = all_kappa,
    algorithm = algorithm,
    pre = pre
  )
}
