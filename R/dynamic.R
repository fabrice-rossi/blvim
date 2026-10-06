#' Control parameters for the blvim gradient algorithms
#'
#' This function returns a list with parameters used to tweak the gradient
#' algorithms used in [blvim()]. These parameters control the line search
#' algorithm which is a standard backtracking method with Armijo stopping
#' criterion.
#'
#' @param rho_init Initial value of the gradient step in the line search.
#' @param shrink Shrink factor for the gradient step in the line search.
#' @param sufficient_increase Relative sufficient increase in the line search.
#' @param ls_iter_max  Maximum number of iterations of the line search.
#' @returns a list containing the values of the parameters
#' @seealso [blvim()]
#' @references Armijo, Larry (1966), "Minimization of functions having Lipschitz
#'   continuous first partial derivatives", Pacific J. Math. 16 (1): 1–3
#'   \doi{doi:10.2140/pjm.1966.16.1}
#' @export
#' @examples
#' blvim_gradient_control(0.5, 0.7, 1e-4, 25)
blvim_gradient_control <- function(rho_init = 0.5,
                                   shrink = 0.5,
                                   sufficient_increase = 1e-5,
                                   ls_iter_max = 50) {
  list(
    rho_init = rho_init,
    shrink = shrink,
    sufficient_increase = sufficient_increase,
    ls_iter_max = ls_iter_max
  )
}

one_blvim <- function(costs, X, alpha, beta, Z,
                      all_kappa,
                      epsilon,
                      iter_max,
                      conv_check,
                      precision,
                      algorithm,
                      control,
                      with_kappa) {
  convergence_diagnostic <- list()
  if (algorithm == "gradient") {
    pre <- blv_gradient(costs, X, alpha, beta, Z, all_kappa,
      rho_init = control$rho_init,
      shrink = control$shrink,
      c = control$sufficient_increase,
      iter_max = iter_max,
      ls_iter_max = control$ls_iter_max,
      precision = precision
    )
  } else if (algorithm == "gradient_unit") {
    pre <- blv_gradient_unit(costs, X, alpha, beta, Z, all_kappa,
      rho_init = control$rho_init,
      shrink = control$shrink,
      c = control$sufficient_increase,
      iter_max = iter_max,
      ls_iter_max = control$ls_iter_max,
      precision = precision
    )
  } else {
    pre <- blv(
      costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
      conv_check, precision,
      quadratic = algorithm == "quadratic", with_kappa
    )
  }
  if (algorithm %in% c("gradient", "gradient_unit")) {
    convergence_diagnostic$status <- pre$status
    convergence_diagnostic$duality_gap <- pre$gap
    convergence_diagnostic$eval <- pre$eval
  }
  pre$diagnostic <- convergence_diagnostic
  pre
}


#' Compute an equilibrium solution of the Harris and Wilson model
#'
#' This function computes flows between origin locations and destination
#' locations at an equilibrium solution of Harris and Wilson interaction model.
#' The model is initialised with the production constraints at the origin
#' locations and the initial values of the the attractivenesses of destination
#' locations. At convergence, attractivenesses fulfil the balance equations
#' \deqn{\forall j,\quad \kappa_j Z_j=\sum_{i=1}^{n}Y_{ij},} where the flows are
#' computed according to Wilson's  production constrained entropy maximising
#' model ([static_blvim()]). The function implements several algorithms that all
#' aim to reach an equilibrium.
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
#' For these algorithms(`"linear"` and `"quadratic"`), \eqn{\epsilon} is given
#' by the `epsilon` parameter and should generally be smaller than 1.
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
#' algorithms use a direct approach of optimising the potential via a projected
#' gradient ascent. The `"gradient"` algorithm optimises directly the potential
#' while `"gradient_unit"` rescales the problem in order to work with \eqn{U_j}
#' instead of \eqn{Z_j} in such a way that \eqn{\sum_{j=1}^p U_j=1}. This can
#' accelerate convergence in some settings. Results should be identical from
#' both gradient approaches, but they can be different from solutions obtained
#' by the `"linear"` and `"quadratic"` algorithms.
#'
#' The `epsilon` and `conv_check` parameters are not used by the `"gradient"`
#' algorithm. Convergence is assessed using the duality gap and the `precision`
#' parameter. The gradient ascent runs for a maximum of `iter_max` iterations.
#' Both algorithms use a standard backtracking line search with Armijo stopping
#' criterion. Its parameters can be modified using the `control` parameter and
#' the associated  [blvim_gradient_control()] function.
#'
#' @param Z A vector of initial destination attractivenesses.
#' @param kappa A vector of conversion factors between attractivenesses and
#'   incoming flows. Values must be positive. Defaults to 1 for all
#'   destinations.
#' @param algorithm Character string selecting the algorithm used to compute
#'   the equilibrium. One of `"linear"`, `"quadratic"`, `"gradient"` or
#'   `"gradient_unit"`. Defaults to `"linear"`. Partial matching is supported.
#' @param precision Convergence threshold.
#' @param iter_max Maximum number of iterations.
#' @param epsilon Update intensity used by the `"linear"` and `"quadratic"`
#'   algorithms.
#' @param conv_check Number of iterations between convergence checks for the
#'   `"linear"` and `"quadratic"` algorithms.
#' @param control List of internal parameters for the gradient algorithms as
#'   produced by [blvim_gradient_control()].
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
                  control = blvim_gradient_control()) {
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
  pre <- one_blvim(
    costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
    conv_check, precision, algorithm, control, with_kappa
  )
  new_sim_blvim(pre$Y, pre$Z[, 1], costs, alpha, beta,
    bipartite, origin_data, destination_data,
    iteration = pre$iter + 1L,
    converged = pre$iter < iter_max,
    kappa = all_kappa,
    algorithm = algorithm,
    diagnostic = pre$diagnostic
  )
}
