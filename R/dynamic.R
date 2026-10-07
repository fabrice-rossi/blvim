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
#' locations at an equilibrium solution of the Harris and Wilson interaction
#' model. At equilibrium, destination attractivenesses fulfil the balance
#' equations
#' \deqn{
#'   \forall j,\quad
#'   \kappa_j Z_j = \sum_{i=1}^{n} Y_{ij},
#' }
#' where \eqn{Y_{ij}} is the flow from origin \eqn{i} to destination \eqn{j},
#' \eqn{Z_j} is the attractiveness of destination \eqn{j}, and
#' \eqn{\kappa_j} is a conversion factor between attractiveness and incoming
#' flow. Flows are computed according to Wilson's production-constrained
#' entropy-maximising model implemented by [static_blvim()].
#'
#' The function implements several iterative algorithms that aim to reach an
#' equilibrium. It can run an algorithm from a single initial attractiveness
#' vector or from several initial vectors. When several starting points are
#' supplied, the result with the largest potential is returned.
#'
#' ## Initial attractivenesses
#'
#' Initial destination attractivenesses are specified through `Z`.
#'
#' If `Z` is a numeric vector, the selected algorithm is run once from that
#' vector.
#'
#' If `Z` is a numeric matrix, each row is interpreted as one initial
#' attractiveness vector. The selected algorithm is run independently from
#' each row, and the solution with the largest final potential is returned.
#' Consequently, `ncol(Z)` must equal `ncol(costs)`.
#'
#' If `Z` is `NULL`, a single initial attractiveness vector is constructed
#' automatically. In the bipartite case, it is the centre of mass of the
#' weighted simplex:
#'
#' \deqn{
#'   Z_j^0 =
#'   \frac{\sum_i X_i}{p\kappa_j},
#' }
#'
#' where \eqn{p} is the number of destinations. In the non-bipartite case, the
#' initial attractivenesses are
#'
#' \deqn{
#'   Z_j^0 = \frac{X_j}{\kappa_j}.
#' }
#'
#' Automatic initialisation with `Z = NULL` therefore produces one run. To
#' perform several runs, the starting points must be generated beforehand and
#' supplied as the rows of a matrix, for instance using the
#' [sample_weighted_simplex()] function.
#'
#' ## Boltzmann-Lotka-Volterra iterations
#'
#' At each step of a Boltzmann-Lotka-Volterra (BLV) algorithm, flows are
#' computed according to the production-constrained entropy-maximising model
#' implemented by [static_blvim()]. The total flow received by destination
#' \eqn{j} is
#'
#' \deqn{
#'   D_j = \sum_{i=1}^{n} Y_{ij}.
#' }
#'
#' Attractivenesses are then updated to bring \eqn{\kappa_j Z_j} closer to
#' \eqn{D_j}.
#'
#' Two BLV algorithms are available through `algorithm`:
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
#' For these two algorithms, \eqn{\epsilon} is specified by `epsilon` and
#' should generally be smaller than one.
#'
#' Updates are performed until convergence or until `iter_max` iterations have
#' been reached. Convergence is checked every `conv_check` iterations. The
#' algorithm is considered to have converged if
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
#' where \eqn{\delta} is specified by `precision`.
#'
#' ## Gradient algorithms
#'
#' Finding an equilibrium with the BLV approach is equivalent to looking for a
#' maximum of the potential function; see [sim_potential()]. The gradient
#' algorithms optimise this potential directly by projected gradient ascent.
#'
#' The `"gradient"` algorithm works directly with the attractivenesses
#' \eqn{Z_j}. The `"gradient_unit"` algorithm rescales the problem and works
#' with variables \eqn{U_j} satisfying
#'
#' \deqn{
#'   \sum_{j=1}^{p} U_j = 1.
#' }
#'
#' This rescaling can accelerate convergence in some settings. The two
#' gradient algorithms optimise equivalent formulations and should yield the
#' same solution up to numerical precision. They may, however, reach solutions
#' different from those produced by the `"linear"` and `"quadratic"`
#' algorithms.
#'
#' The `epsilon` and `conv_check` parameters are not used by either gradient
#' algorithm. Gradient convergence is assessed using a duality gap and the
#' tolerance specified by `precision`. The gradient ascent is limited to
#' `iter_max` iterations.
#'
#' Both gradient algorithms use a standard backtracking line search with an
#' Armijo sufficient-increase condition. Line-search parameters can be
#' modified through `control`; see [blvim_gradient_control()].
#'
#' ## Multiple starting points
#'
#' When `Z` is a matrix, the rows of `Z` are used as independent starting
#' points. Each run uses the same model parameters, algorithm, convergence
#' threshold, iteration limit, and algorithm-specific control parameters.
#'
#' The final potential of every run is evaluated using the corresponding final
#' attractiveness vector. The run with the strictly largest potential is
#' selected. If several runs attain the same largest potential, the first such
#' run is selected.
#'
#' The selected run is returned as the main fitted model. A data frame
#' summarising all runs is attached to the result and is available through the
#' `logs` information stored by the fitted object. If `keep_runs = TRUE`,
#' the complete fitted models obtained from all starting points are also
#' retained.
#'
#' @param Z Initial destination attractivenesses. It can be:
#'
#'   * `NULL`, in which case a single starting point is constructed
#'   automatically;
#'   * a numeric vector containing one initial attractiveness value per
#'   destination; or
#'   * a numeric matrix whose rows are initial attractiveness vectors and whose
#'   columns correspond to destinations.
#'
#'   With a matrix, the algorithm is run once per row and the solution with the
#'   largest final potential is returned.
#'
#' @param kappa A numeric vector of conversion factors between destination
#'   attractivenesses and incoming flows. Values must be strictly positive. A
#'   scalar value is recycled to all destinations. Defaults to `1`, which gives
#'   the standard balance equations without destination-specific conversion
#'   factors.
#'
#' @param algorithm A character string selecting the algorithm used to compute
#'   the equilibrium. It must be one of `"linear"`, `"quadratic"`, `"gradient"`,
#'   or `"gradient_unit"`. The default is `"linear"`. Partial matching is
#'   supported.
#'
#' @param precision A positive numeric scalar giving the convergence threshold.
#'   For `"linear"` and `"quadratic"`, it is used in the attractiveness-based
#'   convergence test. For `"gradient"` and `"gradient_unit"`, it is used in the
#'   duality-gap stopping criterion.
#'
#' @param iter_max A positive integer giving the maximum number of iterations
#'   for each run.
#'
#' @param epsilon A positive numeric scalar giving the update intensity for the
#'   `"linear"` and `"quadratic"` algorithms. It is not used by the gradient
#'   algorithms.
#'
#' @param conv_check A positive integer giving the number of iterations between
#'   convergence checks for the `"linear"` and `"quadratic"` algorithms. It is
#'   not used by the gradient algorithms.
#'
#' @param control A list of internal parameters for the gradient algorithms,
#'   normally produced by [blvim_gradient_control()]. It is not used by the
#'   `"linear"` and `"quadratic"` algorithms.
#'
#' @param keep_runs A logical scalar controlling whether complete fitted models
#'   from all runs are retained when `Z` is a matrix. If `FALSE`, the default,
#'   only the selected model and the run summaries are retained. If `TRUE`, a
#'   `sim_list` containing all fitted models is also stored in the returned
#'   object. This argument has no effect when `Z` is `NULL` or a vector.
#'
#' @inheritParams static_blvim
#'
#' @returns An object of class `sim` and `sim_blvim` containing the matrix of
#'   flows between origins and destinations, the final destination
#'   attractivenesses, and information about the algorithm and its convergence.
#'
#'   When `Z` is a matrix, the returned object corresponds to the run with the
#'   largest final potential. It additionally contains a run-summary data frame
#'   with one row per starting point and the following columns:
#'
#'   * `run`: index of the run from 1 to `nrow(Z)`;
#'   * `potential`: final value of the potential;
#'   * `iterations`: number of iterations reported for the run;
#'   * `converged`: whether the run stopped before reaching `iter_max`;
#'   * `status`: stopping status reported by a gradient algorithm;
#'   * `gap`: final duality gap reported by a gradient algorithm;
#'   * `evaluations`: number of evaluations reported by a gradient algorithm.
#'
#'   For `"linear"` and `"quadratic"`, `status`, `gap`, and `evaluations` are
#'   `NA`, because these diagnostics are specific to the gradient algorithms.
#'   The data frame can be accessed with the [sim_logs()] function.
#'
#'   If `Z` is a matrix and `keep_runs = TRUE`, the returned object also stores
#'   a `sim_list` containing the fitted models from all runs, in the same order
#'   as the rows of `Z`. The list can be obtained using [sim_runs()].
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
#' # Original Harris-Wilson update rule from an explicit starting point
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
#' # Rescaled gradient-based algorithm
#' unit_gradient_flows <- blvim(
#'   distances,
#'   production,
#'   1.5,
#'   1 / 250,
#'   attractiveness,
#'   algorithm = "gradient_unit"
#' )
#'
#' # Automatic initialisation from the centre of the weighted simplex
#' automatic_flows <- blvim(
#'   distances,
#'   production,
#'   1.5,
#'   1 / 250,
#'   algorithm = "gradient"
#' )
#'
#' # Multiple explicitly supplied starting points
#' starts <- rbind(
#'   attractiveness,
#'   c(
#'     rep(0, 5),
#'     rep(sum(production) / 5, 5)
#'   )
#' )
#'
#' multistart_flows <- blvim(
#'   distances,
#'   production,
#'   1.5,
#'   1 / 250,
#'   Z = starts,
#'   algorithm = "gradient",
#'   keep_runs = TRUE
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
#' @seealso
#' [blvim_gradient_control()] for gradient and line-search parameters,
#' [grid_blvim()] for systematic exploration of parameter influence,
#' [static_blvim()] for the static model, [sim_potential()] for the
#' potential function and [sample_weighted_simplex()] for a way to generate
#' initial configurations. Diagnostic for multiple runs can be obtained using
#' using [sim_runs()] and [sim_logs()].
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
  if (is.null(Z)) {
    ## automatic initialisation
    if (bipartite) {
      Z <- (sum(X) / length(all_kappa)) / all_kappa
    } else {
      Z <- X / all_kappa
    }
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
      if (!is.null(pre_diag)) {
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
#'   For a single run, a one-element `sim_list` containing `x` is returned. For
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
#'   * `run`: index of the run from 1 to number of initial point;
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
