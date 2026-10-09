#' Specify how initial attractivenesses are generated
#'
#' `blvim_initialise()` creates a reusable specification for generating initial
#' attractivenesses in [blvim()]. The generator is evaluated only after the
#' dimensions, production values, and conversion factors of the model are
#' known.
#'
#' A generator must be a function whose first argument is `context`. It must
#' return either:
#'
#' * a numeric vector representing one initial configuration;
#' * a numeric matrix whose rows represent initial configurations; or
#' * a list containing one of these objects in a component named `Z`.
#'
#' The `context` argument is a named list containing:
#'
#' * `costs`: the cost matrix;
#' * `X`: the production vector;
#' * `alpha` and `beta`: the interaction-model parameters;
#' * `kappa`: the conversion factors expanded to one value per destination;
#' * `C`: total production, equal to `sum(X)`;
#' * `bipartite`: whether the model is bipartite;
#' * `n_origins`: number of origins;
#' * `n_destinations`: number of destinations.
#'
#' Some of the parameters are easily deducible from others (`C`, `n_origins`
#' and `n_destinations`) but are included to simplify the design of
#' initialisers.
#'
#' Additional arguments supplied through `...` are stored in the specification
#' and passed to `generator` when starting points are generated.
#'
#' @param generator A function used to generate initial attractivenesses.
#'   Its first argument must be `context`. The default uses
#'   [sample_weighted_simplex()].
#'
#' @param ... Arguments stored in the specification and passed to `generator`.
#'
#' @return An object of class `blvim_initialise`.
#' @seealso [blvim()] for the use of this function, and
#' [blvim_simplex_initialise()] for the default initialiser.
#'
#' @examples
#' # Ten starting points from the default simplex generator
#' initialise <- blvim_initialise(n = 10)
#'
#' # Emphasise proper faces of the simplex
#' boundary_initialise <- blvim_initialise(
#'   n = 100,
#'   face_fraction = 0.8,
#'   points_per_face = 5
#' )
#'
#' # A custom generator
#' concentrated_initialise <- function(context, n = 20, concentration = 100) {
#'   centre <- rep(1 / context$n_destinations, context$n_destinations)
#'   U <- matrix(
#'     stats::rgamma(n * context$n_destinations,
#'       shape = concentration * centre
#'     ),
#'     nrow = n, byrow = TRUE
#'   )
#'   U <- U / rowSums(U)
#'   sweep(U * context$C, 2, context$kappa, "/")
#' }
#'
#' initialise <- blvim_initialise(
#'   generator = concentrated_initialise,
#'   n = 50,
#'   concentration = 20
#' )
#'
#' @export
blvim_initialise <- function(generator = blvim_simplex_initialise, ...) {
  generator_label <- rlang::as_label(rlang::enexpr(generator))
  if (!is.function(generator)) {
    cli::cli_abort(
      "{.arg generator} must be a function, not {.obj_type_friendly {generator}}."
    )
  }
  args <- list(...)
  if (is.null(names(args))) {
    names(args) <- rep("", length(args))
  }
  if (any(names(args) == "")) {
    cli::cli_abort(
      "All arguments in a {.cls blvim_initialise} specification must be named."
    )
  }
  duplicated_args <- unique(names(args)[duplicated(names(args))])
  if (length(duplicated_args) > 0L) {
    cli::cli_abort(
      "Arguments in a {.cls blvim_initialise} specification must have unique names.",
      "x" = "Duplicated argument{?s}: {.arg {duplicated_args}}."
    )
  }
  if ("context" %in% names(args)) {
    cli::cli_abort(
      "{.arg context} cannot be supplied in a {.cls blvim_initialise} specification.",
      "i" = "It is constructed internally by {.fun blvim}."
    )
  }
  structure(
    list(
      generator = generator, generator_label = generator_label,
      args = args
    ),
    class = "blvim_initialise"
  )
}


#' @export
format.blvim_initialise <- function(x, ...) {
  cli::cli_format_method({
    cli::cli_text("{.cls blvim_initialise}")
    cli::cli_text("Generator: {.fn {x$generator_label}}")
    if (length(x$args) == 0L) {
      cli::cli_text("Arguments: {.emph none}")
    } else {
      cli::cli_text("Arguments:")
      ul <- cli::cli_ul()
      for (arg in names(x$args)) {
        cli::cli_li("{.arg {arg}}: {.val {x$args[[arg]]}}")
      }
      cli::cli_end(ul)
    }
  })
}


#' @export
print.blvim_initialise <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' Generate initial attractivenesses from the weighted simplex
#'
#' This is the default generator used by [blvim_initialise()]. It samples initial
#' attractivenesses from the weighted simplex
#' \deqn{
#'   \sum_j \kappa_j Z_j = \sum_i X_i.
#' }
#'
#' @param context A model context created internally by [blvim()].
#'
#' @param n Number of initial configurations to generate. The default is
#'   deliberately modest because [blvim()] performs one complete optimisation
#'   from each generated configuration.
#'
#' @param face_fraction Proportion of starting points generated on proper
#'   faces of the weighted simplex.
#'
#' @param points_per_face Parameter controlling the allocation of points among
#'   simplex faces. See [sample_weighted_simplex()].
#'
#' @param max_partial_attempts Maximum number of proposals used when selecting
#'   distinct faces in a partial codimension layer. See
#'   [sample_weighted_simplex()].
#'
#' @param include_centre Whether to include the centre of the weighted simplex
#'   as the first starting point. If `TRUE`, `n - 1` points are sampled and the
#'   centre is prepended. Thus, the returned matrix always has `n` rows.
#'
#' @return A list containing:
#'
#' * `Z`: the matrix of initial attractivenesses;
#' * `sampling`: diagnostics returned by [sample_weighted_simplex()], or `NULL`
#'   when no random point is requested.
#'
#' @export
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000
#' production <- rep(1, 10)
#' # Emphasise proper faces of the simplex
#' boundary_initialise <- blvim_initialise(
#'   generator = blvim_simplex_initialise,
#'   n = 100,
#'   face_fraction = 0.8,
#'   points_per_face = 5
#' )
#' multistart_flows <- blvim(
#'   distances, production, 1.5, 1 / 100,
#'   Z = boundary_initialise,
#'   algorithm = "gradient",
#'   keep_runs = TRUE
#' )
#' head(sim_logs(multistart_flows))
blvim_simplex_initialise <- function(
  context,
  n = 10L,
  face_fraction = 0.5,
  points_per_face = 0L,
  max_partial_attempts = 1000000L,
  include_centre = TRUE
) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) ||
    !is.finite(n) || n != as.integer(n) || n <= 0) {
    cli::cli_abort(
      c(
        "{.arg n} must be a finite positive integer.",
        "x" = "{.arg n} is {.val {n}}."
      )
    )
  }
  if (!is.logical(include_centre) || length(include_centre) != 1L ||
    is.na(include_centre)) {
    cli::cli_abort(
      "{.arg include_centre} must be a non-missing logical scalar."
    )
  }
  n <- as.integer(n)
  centre <- (context$C / context$n_destinations) / context$kappa
  if (include_centre) {
    n_random <- n - 1L
  } else {
    n_random <- n
  }
  if (n_random > 0L) {
    sampling <- sample_weighted_simplex(
      kappa = context$kappa,
      C = context$C,
      n = n_random,
      face_fraction = face_fraction,
      points_per_face = points_per_face,
      max_partial_attempts = max_partial_attempts
    )
    Z <- sampling$Z
  } else {
    sampling <- NULL
    Z <- matrix(
      numeric(),
      nrow = 0L,
      ncol = context$n_destinations
    )
  }
  if (include_centre) {
    Z <- rbind(centre, Z, deparse.level = 0)
  }
  list(
    Z = Z,
    sampling = sampling
  )
}


# Validate and standardise the value returned by a starting-point generator.
normalise_generated_Z <- function(result, n_destinations) {
  if (is.list(result) && !is.data.frame(result)) {
    if (is.null(result$Z)) {
      cli::cli_abort(
        c(
          "A starting-point generator returned a list without a {.field Z} component.",
          "i" = "Return a numeric vector, a numeric matrix, or a list containing {.field Z}."
        )
      )
    }
    Z <- result$Z
  } else {
    Z <- result
  }
  if (is.data.frame(Z)) {
    Z <- as.matrix(Z)
  }
  if (!is.numeric(Z)) {
    cli::cli_abort(
      c(
        "A starting-point generator must return numeric initial attractivenesses.",
        "x" = "The generated {.field Z} is {.obj_type_friendly {Z}}."
      )
    )
  }
  if (is.array(Z) && length(dim(Z)) != 2L) {
    cli::cli_abort(
      "Generated initial attractivenesses must be a vector or a matrix."
    )
  }
  if (is.matrix(Z)) {
    if (nrow(Z) == 0L) {
      cli::cli_abort(
        "A starting-point generator must generate at least one configuration."
      )
    }
    if (ncol(Z) != n_destinations) {
      cli::cli_abort(
        c(
          "Generated initial attractivenesses have an incompatible dimension.",
          "x" = "{.code ncol(Z)} is {ncol(Z)}.",
          "i" = "It must equal the number of destinations, {n_destinations}."
        )
      )
    }
  } else {
    if (length(Z) != n_destinations) {
      cli::cli_abort(
        c(
          "Generated initial attractivenesses have an incompatible length.",
          "x" = "{.code length(Z)} is {length(Z)}.",
          "i" = "It must equal the number of destinations, {n_destinations}."
        )
      )
    }
  }

  if (anyNA(Z) || any(!is.finite(Z))) {
    cli::cli_abort(
      "Generated initial attractivenesses must contain only finite values."
    )
  }
  Z
}


resolve_blvim_initialise <- function(Z, context) {
  generation <- NULL
  if (inherits(Z, "blvim_initialise")) {
    generation <- do.call(
      Z$generator,
      c(list(context = context), Z$args)
    )
    Z <- normalise_generated_Z(
      generation,
      n_destinations = context$n_destinations
    )
  } else if (is.function(Z)) {
    generation <- Z(context)
    Z <- normalise_generated_Z(
      generation,
      n_destinations = context$n_destinations
    )
  }
  list(Z = Z, generation = generation)
}
