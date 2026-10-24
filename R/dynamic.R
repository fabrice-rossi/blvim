#' Control parameters for the blvim gradient algorithms
#'
#' This function returns a list of parameters used to tune the gradient
#' algorithms of [blvim()]. These parameters control the line search
#' algorithm, which is a standard backtracking method with the Armijo stopping
#' criterion.
#'
#' @param rho_init Initial value of the gradient step in the line search.
#' @param shrink Shrink factor for the gradient step in the line search.
#' @param sufficient_increase Relative sufficient increase in the line search.
#' @param ls_iter_max Maximum number of iterations of the line search.
#' @returns a list containing the values of the parameters, to be used as the
#'   `control` argument of [blvim()] or [grid_blvim()]
#' @seealso [blvim()], [grid_blvim()]
#' @references Armijo, Larry (1966), "Minimization of functions having Lipschitz
#'   continuous first partial derivatives", Pacific J. Math. 16 (1): 1–3
#'   \doi{10.2140/pjm.1966.16.1}
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
#' `blvim()` computes equilibrium flows between origin and destination locations
#' in the Harris and Wilson spatial interaction model. At equilibrium,
#' destination attractivenesses satisfy
#' \deqn{
#'   \forall j,\quad
#'   \kappa_j Z_j = \sum_{i=1}^{n} Y_{ij},
#' }
#' where \eqn{Y_{ij}} is the flow from origin \eqn{i} to destination \eqn{j},
#' \eqn{Z_j} is the attractiveness of destination \eqn{j}, and
#' \eqn{\kappa_j} converts attractiveness into incoming flow. Flows are
#' computed using the production-constrained entropy-maximising model
#' implemented by [static_blvim()].
#'
#' Several iterative algorithms are available. The model can be run from a
#' single initial attractiveness vector or from several starting points. In
#' the latter case, the solution with the largest final potential is returned
#' (see [sim_potential()]).
#'
#' ## Initialisation and multiple runs
#'
#' Initial destination attractivenesses are specified through `Z`:
#'
#' * If `Z` is `NULL`, one starting point is constructed automatically.
#' * If `Z` is a numeric vector, the algorithm is run once from that vector.
#' * If `Z` is a numeric matrix, each row is used as an independent starting
#'   point.
#' * If `Z` is an object created by [blvim_initialise()], its initialiser is
#'   evaluated using the model context. The resulting vector or matrix is then
#'   handled in the same way as an explicitly supplied `Z`.
#'
#' In the bipartite case, automatic initialisation uses the centre of mass of
#' the weighted simplex:
#'
#' \deqn{
#'   Z_j^0 =
#'   \frac{\sum_i X_i}{p\kappa_j},
#' }
#'
#' where \eqn{p} is the number of destinations. In the non-bipartite case, it
#' uses
#'
#' \deqn{
#'   Z_j^0 = \frac{X_j}{\kappa_j}.
#' }
#'
#' Automatic initialisation therefore produces a single run. Use a matrix or
#' [blvim_initialise()] to perform multiple runs.
#'
#' For multiple runs, all starting points use the same model parameters,
#' algorithm, convergence settings, and algorithm-specific controls. The final
#' potential is evaluated for each run, and the run with the strictly largest
#' potential is selected (see [sim_potential()]). If several runs have the same
#' largest potential, the first is selected.
#'
#' Summaries of all runs are stored in the returned model and can be obtained
#' with [sim_logs()]. If `keep_runs = TRUE`, the complete fitted models are
#' retained and can be obtained with [sim_runs()].
#'
#' ## Boltzmann-Lotka-Volterra algorithms
#'
#' At each iteration of a Boltzmann-Lotka-Volterra (BLV) algorithm, flows are
#' computed with [static_blvim()]. The total flow received by destination
#' \eqn{j} is
#'
#' \deqn{
#'   D_j = \sum_{i=1}^{n} Y_{ij}.
#' }
#'
#' Attractivenesses are then updated to bring \eqn{\kappa_j Z_j} closer to
#' \eqn{D_j}. Two BLV algorithms are available:
#'
#' 1. `"linear"` uses the original update rule proposed by Harris and Wilson
#'    (1978):
#'
#'    \deqn{
#'      Z_j^{t+1}
#'      =
#'      Z_j^t
#'      +
#'      \epsilon
#'      \left(
#'        \frac{D_j^t}{\kappa_j} - Z_j^t
#'      \right).
#'    }
#'
#' 2. `"quadratic"` uses the update rule proposed by Wilson (2008):
#'
#'    \deqn{
#'      Z_j^{t+1}
#'      =
#'      Z_j^t
#'      +
#'      \epsilon
#'      \left(
#'        \frac{D_j^t}{\kappa_j} - Z_j^t
#'      \right) Z_j^t.
#'    }
#'
#' For both algorithms, \eqn{\epsilon} is specified by `epsilon` and should
#' generally be smaller than one. Convergence is checked every `conv_check`
#' iterations and is attained when
#'
#' \deqn{
#'   \lVert Z^{t+1} - Z^t \rVert
#'   <
#'   \delta
#'   \left(
#'     \lVert Z^{t+1} \rVert + \delta
#'   \right),
#' }
#'
#' where \eqn{\delta} is specified by `precision`. Iteration stops at
#' convergence or after `iter_max` iterations.
#'
#' ## Gradient algorithms
#'
#' Computing an equilibrium is equivalent to maximising the potential
#' function; see [sim_potential()]. The gradient algorithms optimise this
#' potential directly using projected gradient ascent.
#'
#' The `"gradient"` algorithm works directly with the attractivenesses
#' \eqn{Z_j}. The `"gradient_unit"` algorithm works with rescaled variables
#' \eqn{U_j} satisfying
#'
#' \deqn{
#'   \sum_{j=1}^{p} U_j = 1.
#' }
#'
#' The rescaling can accelerate convergence in some settings. The two
#' algorithms optimise equivalent formulations and should produce the same
#' solution up to numerical precision. They can nevertheless converge to
#' solutions different from those obtained with the `"linear"` and
#' `"quadratic"` algorithms.
#'
#' Both gradient algorithms use projected ascent with a backtracking line
#' search and an Armijo sufficient-increase condition. Convergence is assessed
#' using a duality gap with tolerance `precision`, and the number of iterations
#' is limited by `iter_max`. The `epsilon` and `conv_check` arguments are not
#' used. Line-search and other internal parameters can be modified through
#' `control`; see [blvim_gradient_control()].
#'
#' @param Z Initial destination attractivenesses. This can be `NULL` for
#'   automatic single-point initialisation, a numeric vector with one value per
#'   destination, a numeric matrix with one starting point per row, or an
#'   object created by [blvim_initialise()]. The number of columns of a matrix
#'   must equal `ncol(costs)`.
#'
#' @param kappa A strictly positive numeric vector of conversion factors
#'   between destination attractivenesses and incoming flows. A scalar is
#'   recycled to all destinations. The default `1` gives the standard balance
#'   equations without destination-specific conversion factors.
#'
#' @param epsilon A positive numeric scalar giving the update intensity for
#'   the `"linear"` and `"quadratic"` algorithms. It is not used by the
#'   gradient algorithms.
#'
#' @param iter_max A positive integer giving the maximum number of iterations
#'   for each run.
#'
#' @param conv_check A positive integer giving the number of iterations between
#'   convergence checks for the `"linear"` and `"quadratic"` algorithms. It is
#'   not used by the gradient algorithms.
#'
#' @param precision A positive numeric scalar giving the convergence tolerance.
#'   It is used in the attractiveness-based convergence test for `"linear"` and
#'   `"quadratic"`, and in the duality-gap stopping criterion for `"gradient"`
#'   and `"gradient_unit"`.
#'
#' @param algorithm A character string selecting the equilibrium algorithm. It
#'   must be one of `"linear"`, `"quadratic"`, `"gradient"`, or
#'   `"gradient_unit"`. Partial matching is supported.
#'
#' @param control A list of parameters for the gradient algorithms, normally
#'   produced by [blvim_gradient_control()]. It is not used by `"linear"` or
#'   `"quadratic"`.
#'
#' @param keep_runs A logical scalar controlling whether complete fitted models
#'   are retained when multiple starting points are used. If `FALSE`, only the
#'   selected model and the run summaries are retained. If `TRUE`, all fitted
#'   models are stored in a `sim_list`. This argument has no effect for a
#'   single starting point.
#'
#' @inheritParams static_blvim
#'
#' @returns An object inheriting from `sim` and `sim_blvim`. It contains the
#'   equilibrium flow matrix, final destination attractivenesses, initial
#'   attractivenesses of the selected run, and convergence information.
#'
#'   When multiple starting points are used, the returned object represents the
#'   run with the largest final potential. Run summaries are available through
#'   [sim_logs()] and contain:
#'
#'   * `run`: index of the starting point;
#'   * `potential`: final potential;
#'   * `iterations`: number of reported iterations;
#'   * `converged`: whether the run stopped before `iter_max`;
#'   * `status`: stopping status for a gradient algorithm;
#'   * `gap`: final duality gap for a gradient algorithm;
#'   * `evaluations`: number of evaluations for a gradient algorithm.
#'
#'   The last three columns are `NA` for `"linear"` and `"quadratic"`. If
#'   `keep_runs = TRUE`, the complete fitted models are additionally available
#'   through [sim_runs()], in the same order as the starting points.
#'
#' @inheritSection static_blvim Location data
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#'
#' # Rescale attractivenesses to total production
#' attractiveness <- attractiveness / sum(attractiveness) * sum(production)
#'
#' # Original Harris-Wilson update rule
#' linear_flows <- blvim(
#'   distances, production, 1.5, 1 / 250, attractiveness,
#'   algorithm = "linear"
#' )
#' linear_flows
#'
#' # Wilson's quadratic update rule
#' quadratic_flows <- blvim(
#'   distances, production, 1.5, 1 / 250, attractiveness,
#'   algorithm = "quadratic"
#' )
#'
#' # Gradient ascent on the potential
#' gradient_flows <- blvim(
#'   distances, production, 1.5, 1 / 250, attractiveness,
#'   algorithm = "gradient"
#' )
#'
#' # Gradient ascent using unit-simplex variables
#' unit_gradient_flows <- blvim(
#'   distances, production, 1.5, 1 / 250, attractiveness,
#'   algorithm = "gradient_unit"
#' )
#'
#' # Automatic single-point initialisation
#' automatic_flows <- blvim(
#'   distances, production, 1.5, 1 / 250,
#'   algorithm = "gradient"
#' )
#'
#' # Multiple explicitly supplied starting points
#' starts <- rbind(
#'   attractiveness,
#'   c(rep(0, 5), rep(sum(production) / 5, 5))
#' )
#' multistart_flows <- blvim(
#'   distances, production, 1.5, 1 / 250,
#'   Z = starts,
#'   algorithm = "gradient",
#'   keep_runs = TRUE
#' )
#'
#' # Generate starting points when the model context is known
#' generated_flows <- blvim(
#'   distances, production, 1.5, 1 / 250,
#'   Z = blvim_initialise(n = 20, face_fraction = 0.5),
#'   algorithm = "gradient"
#' )
#'
#' @references
#' Harris, B., & Wilson, A. G. (1978). "Equilibrium Values and Dynamics of
#' Attractiveness Terms in Production-Constrained Spatial-Interaction Models",
#' Environment and Planning A: Economy and Space, 10(4), 371-388.
#' \doi{10.1068/a100371}
#'
#' Wilson, A. (2008). "Boltzmann, Lotka and Volterra and spatial structural
#' evolution: an integrated methodology for some dynamical systems",
#' Journal of the Royal Society Interface, 5, 865-871.
#' \doi{10.1098/rsif.2007.1288}
#'
#' Osawa, M., Akamatsu, T., & Kogure, Y. (2025). "Most likely retail
#' agglomeration patterns: Potential maximization and stochastic stability of
#' spatial equilibria". <https://arxiv.org/abs/2011.06778v2>
#'
#' @seealso
#' [static_blvim()] for the underlying production-constrained interaction
#' model, [blvim_initialise()] for generated starting points,
#' [blvim_gradient_control()] for gradient and line-search parameters,
#' [sim_potential()] for the potential function, and [grid_blvim()] for
#' systematic exploration of parameter values. Multiple-run summaries and
#' fitted models can be obtained with [sim_logs()] and [sim_runs()].
#'
#' @export
blvim <- function(costs, X, alpha, beta, Z = NULL,
                  kappa = 1,
                  bipartite = TRUE, origin_data = NULL, destination_data = NULL,
                  epsilon = 0.01,
                  iter_max = 50000,
                  conv_check = 100,
                  precision = 1e-6,
                  algorithm = c("linear", "quadratic", "gradient", "gradient_unit"),
                  control = blvim_gradient_control(),
                  keep_runs = FALSE) {
  algorithm <- match.arg(algorithm)
  all_kappa <- rep(1, ncol(costs))
  if (isTRUE(kappa == 1)) {
    ## no real kappa
    with_kappa <- FALSE
  } else {
    with_kappa <- TRUE
    all_kappa[seq_len(ncol(costs))] <- kappa
  }
  context <- list(
    costs = costs,
    X = X,
    alpha = alpha,
    beta = beta,
    kappa = all_kappa,
    C = sum(X),
    bipartite = bipartite,
    n_origins = nrow(costs),
    n_destinations = ncol(costs)
  )

  if (is.null(Z)) {
    ## automatic initialisation
    if (bipartite) {
      Z <- (sum(X) / length(all_kappa)) / all_kappa
    } else {
      Z <- X / all_kappa
    }
  } else {
    resolved <- resolve_blvim_initialise(Z, context)
    Z <- resolved$Z
  }
  check_configuration(costs, X, alpha, beta, Z, kappa, bipartite)
  logs <- NULL
  all_sims <- NULL
  if (is.matrix(Z)) {
    ## multiple start
    best_potential <- -Inf
    best_sim <- NULL
    best_init <- Z[1, ]
    logs <- data.frame(
      run = seq_len(nrow(Z)),
      potential = rep(NA_real_, nrow(Z)),
      iterations = rep(NA_integer_, nrow(Z)),
      converged = rep(NA, nrow(Z)),
      status = rep(NA_character_, nrow(Z)),
      gap = rep(NA_real_, nrow(Z)),
      evaluations = rep(NA_integer_, nrow(Z))
    )
    if (keep_runs) {
      all_sims <- vector(mode = "list", nrow(Z))
    }
    for (k in seq_len(nrow(Z))) {
      pre <- one_blvim(
        costs, X, alpha, beta, Z[k, ], all_kappa, epsilon, iter_max,
        conv_check, precision, algorithm, control, with_kappa
      )
      pre_potential <- internal_sim_potential(costs, X, alpha, beta, pre$Z[, 1], all_kappa)
      logs$potential[k] <- pre_potential
      logs$iterations[k] <- pre$iter + 1L
      logs$converged[k] <- pre$iter < iter_max
      pre_diag <- pre$diagnostic
      if (length(pre_diag) > 0) {
        logs$status[k] <- pre_diag$status
        logs$gap[k] <- pre_diag$duality_gap
        logs$evaluations[k] <- pre_diag$eval
      }
      if (pre_potential > best_potential) {
        best_potential <- pre_potential
        best_sim <- pre
        best_init <- Z[k, ]
      }
      if (keep_runs) {
        all_sims[[k]] <- new_sim_blvim(pre$Y, pre$Z[, 1], costs, alpha, beta,
          bipartite, origin_data, destination_data,
          iteration = pre$iter + 1L,
          converged = pre$iter < iter_max,
          kappa = all_kappa,
          algorithm = algorithm,
          diagnostic = pre$diagnostic,
          logs = NULL,
          runs = NULL,
          initial_Z = Z[k, ]
        )
      }
    }
    pre <- best_sim
    if (keep_runs) {
      all_sims <- sim_list(all_sims, validate = FALSE)
    }
  } else {
    best_init <- Z
    pre <- one_blvim(
      costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
      conv_check, precision, algorithm, control, with_kappa
    )
  }
  new_sim_blvim(pre$Y, pre$Z[, 1], costs, alpha, beta,
    bipartite, origin_data, destination_data,
    iteration = pre$iter + 1L,
    converged = pre$iter < iter_max,
    kappa = all_kappa,
    algorithm = algorithm,
    diagnostic = pre$diagnostic,
    logs = logs,
    runs = all_sims,
    initial_Z = best_init
  )
}

#' Extract spatial interaction models produced by individual runs
#'
#' Extracts the spatial interaction model objects produced by the individual
#' algorithm runs performed by [blvim()].
#'
#' @param sim A spatial interaction model object produced by [blvim()], i.e. an
#'   object of class `sim` and `sim_blvim`
#'
#' @returns A `sim_list` containing the available spatial interaction models
#'   produced by the algorithm runs.
#'
#'   For a single run, a one-element `sim_list` containing `sim` is returned. For
#'   multiple runs retained with `keep_runs = TRUE`, the models are returned in
#'   the same order as the starting points supplied to [blvim()].
#'
#'   The function returns `NULL` when multiple runs were performed with
#'   `keep_runs = FALSE`, because only the model associated with the largest
#'   final potential was retained.
#'
#' @details See [blvim()] for details on how the `Z` and `keep_runs` arguments
#' determine the number of runs and whether the resulting spatial interaction
#' models are retained.
#'
#' Use [sim_logs()] to extract the summary information recorded for multiple
#' runs.
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' attractiveness <- attractiveness / sum(attractiveness) * sum(production)
#'
#' # A single run produces a one-element sim_list
#' single <- blvim(
#'   distances,
#'   production,
#'   1.5,
#'   1 / 250,
#'   attractiveness,
#'   algorithm = "gradient"
#' )
#' length(sim_runs(single))
#'
#' # Multiple runs, with all spatial interaction models retained
#' starts <- rbind(
#'   attractiveness,
#'   rev(attractiveness)
#' )
#'
#' multiple <- blvim(
#'   distances,
#'   production,
#'   1.5,
#'   1 / 250,
#'   starts,
#'   algorithm = "gradient",
#'   keep_runs = TRUE
#' )
#'
#' runs <- sim_runs(multiple)
#' length(runs)
#'
#' @seealso
#' [blvim()] for computing equilibrium spatial interaction models,
#' [sim_logs()] for summaries of the individual runs, and [sim_list()] for
#' collections of spatial interaction models.
#'
#' @export
sim_runs <- function(sim) {
  if (!inherits(sim, "sim_blvim")) {
    cli::cli_abort("{.arg sim} must be an object of class {.cls sim_blvim}")
  }
  if (!is.null(sim$runs)) {
    sim$runs
  } else {
    if (is.null(sim$logs)) {
      sim_list(list(sim), validate = FALSE)
    } else {
      NULL
    }
  }
}


#' Extract summaries of individual algorithm runs
#'
#' Extracts the summary information recorded for the individual algorithm runs
#' performed by [blvim()].
#'
#' @param sim A spatial interaction model object produced by [blvim()], i.e. an
#'   object of class `sim` and `sim_blvim`
#'
#' @returns A data frame with one row per starting point and the following
#'   columns:
#'
#'   * `run`: index of the run, from 1 to the number of starting points;
#'   * `potential`: final value of the potential;
#'   * `iterations`: number of iterations;
#'   * `converged`: whether the run converged;
#'   * `status`: stopping status reported by a gradient algorithm;
#'   * `gap`: final duality gap reported by a gradient algorithm;
#'   * `evaluations`: number of evaluations reported by a gradient algorithm.
#'
#'   The gradient-specific columns are `NA` for the `"linear"` and
#'   `"quadratic"` algorithms.
#'
#' @details
#' The rows are in the same order as the starting points supplied to
#' [blvim()]. Run summaries are retained independently of the value of
#' `keep_runs`.
#'
#' See [blvim()] for details on how the nature of `Z` determines the number of
#' runs. Use [sim_runs()] to extract the complete spatial interaction models
#' produced by the runs when they are available.
#'
#' @seealso [blvim()], [sim_runs()], [sim_diagnostic()]
#'
#' @export
sim_logs <- function(sim) {
  if (!inherits(sim, "sim_blvim")) {
    cli::cli_abort("{.arg sim} must be an object of class {.cls sim_blvim}")
  }
  if (is.null(sim$logs)) {
    sim_diag <- sim$diagnostic
    logs <- data.frame(
      run = 1,
      potential = sim_potential(sim),
      iterations = sim_iterations(sim),
      converged = sim_converged(sim),
      status = sim_diag$status,
      gap = sim_diag$duality_gap,
      evaluations = sim_diag$eval
    )
    logs
  } else {
    sim$logs
  }
}


#' @export
initial_attractiveness.sim_blvim <- function(sim, ...) {
  sim$initial_Z
}
