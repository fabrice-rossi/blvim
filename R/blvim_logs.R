## Rescaled attractivenesses U_j = kappa_j Z_j / sum_k kappa_k Z_k of a final
## configuration
rescaled_attractiveness <- function(Z, kappa) {
  U <- kappa * Z
  U / sum(U)
}

## A destination is active in a final configuration when U_j > active_tolerance
active_tolerance <- 1e-5

## Two final configurations are identical when they have the same active
## destinations and their U differ by at most configuration_tolerance
configuration_tolerance <- 1e-3

## Groups the final configurations of the runs of blvim() (one row of U per
## run). The runs are processed by decreasing potential and compared to the
## best run of each configuration found so far, so that the configurations are
## numbered by decreasing best potential.
run_configurations <- function(U, potential) {
  active <- U > active_tolerance
  configuration <- rep(NA_integer_, nrow(U))
  representatives <- integer()
  for (k in order(potential, decreasing = TRUE)) {
    for (r in seq_along(representatives)) {
      best <- representatives[r]
      same <- isTRUE(all(active[k, ] == active[best, ])) &&
        isTRUE(max(abs(U[k, ] - U[best, ])) <= configuration_tolerance)
      if (same) {
        configuration[k] <- r
        break
      }
    }
    if (is.na(configuration[k])) {
      representatives <- c(representatives, k)
      configuration[k] <- length(representatives)
    }
  }
  data.frame(
    n_active = as.integer(rowSums(active)),
    configuration = configuration
  )
}

new_blvim_logs <- function(logs) {
  class(logs) <- c("blvim_logs", setdiff(class(logs), "blvim_logs"))
  logs
}

check_blvim_logs <- function(object) {
  needed <- c(
    "run", "potential", "iterations", "converged", "status", "gap",
    "evaluations", "n_active", "configuration"
  )
  missing_columns <- setdiff(needed, names(object))
  if (length(missing_columns) > 0) {
    cli::cli_abort(c(
      "{.arg object} must contain the columns produced by {.fn sim_logs}",
      "x" = "Missing column{?s}: {.field {missing_columns}}"
    ))
  }
}

## Status of each run: the status of the gradient algorithms when available,
## the convergence otherwise
run_status <- function(logs) {
  status <- ifelse(logs$converged, "converged", "not converged")
  with_status <- !is.na(logs$status)
  status[with_status] <- logs$status[with_status]
  status
}

range_summary <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) {
    NULL
  } else {
    c(min = min(x), median = stats::median(x), max = max(x))
  }
}

#' Summary of the runs of a multiple start blvim
#'
#' Summarises the runs of [blvim()] described by [sim_logs()]: convergence of
#' the runs, cost of the runs, and distinct final configurations reached by
#' the runs.
#'
#' The final configurations are identified as explained in [sim_logs()]. The
#' number of runs that reach the configuration of the selected run (the best
#' one) measures the reliability of the multiple starts. When this
#' configuration is reached by a single run, a better one might have been
#' missed and more starting points are advisable.
#'
#' @param object a data frame of class `blvim_logs` produced by [sim_logs()]
#' @param ... additional parameters (not used currently)
#'
#' @returns an object of class `summary_blvim_logs` and `list` with the
#'   following elements:
#'
#'   - `n_runs`: number of runs;
#'   - `n_converged`: number of runs that converged;
#'   - `status`: number of runs for each status reported by the gradient
#'     algorithms (`NULL` for the other algorithms);
#'   - `iterations`, `evaluations`: minimum, median and maximum number of
#'     iterations and of evaluations of the runs (`evaluations` is `NULL` for
#'     algorithms that do not report it);
#'   - `max_gap`: largest final duality gap of the converged runs (`NA` when
#'     not reported);
#'   - `configurations`: a data frame with one row per final configuration,
#'     by decreasing potential, with columns `configuration`, `potential` (best
#'     potential of its runs), `n_active`, `runs` (number of runs reaching
#'     it), `share` (proportion of the runs) and `converged` (number of
#'     converged runs reaching it);
#'   - `selected_converged`: whether the selected run converged.
#' @seealso [sim_logs()], [blvim()], [autoplot.blvim_logs()]
#' @export
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000
#' production <- rep(1, 15)
#' set.seed(1)
#' starts <- blvim_initialise(n = 20)
#' model <- blvim(distances, production, 1.5, 1 / 50, starts,
#'   algorithm = "gradient", bipartite = FALSE
#' )
#' summary(sim_logs(model))
summary.blvim_logs <- function(object, ...) {
  check_blvim_logs(object)
  runs <- split(seq_len(nrow(object)), object$configuration)
  ids <- as.integer(names(runs))
  configurations <- data.frame(
    configuration = ids,
    potential = vapply(runs, function(k) max(object$potential[k]), numeric(1)),
    n_active = vapply(runs, function(k) object$n_active[k[1]], integer(1)),
    runs = lengths(runs, use.names = FALSE),
    share = lengths(runs, use.names = FALSE) / nrow(object),
    converged = vapply(runs, function(k) sum(object$converged[k]), integer(1))
  )
  configurations <- configurations[order(ids), ]
  rownames(configurations) <- NULL
  status <- object$status[!is.na(object$status)]
  if (length(status) > 0) {
    status <- table(status)
  } else {
    status <- NULL
  }
  gaps <- object$gap[object$converged & !is.na(object$gap)]
  if ("selected" %in% names(object)) {
    selected <- object$selected
  } else {
    selected <- seq_len(nrow(object)) == which.max(object$potential)
  }
  structure(
    list(
      n_runs = nrow(object),
      n_converged = sum(object$converged),
      status = status,
      iterations = range_summary(object$iterations),
      evaluations = range_summary(object$evaluations),
      max_gap = if (length(gaps) > 0) max(gaps) else NA_real_,
      configurations = configurations,
      selected_converged = all(object$converged[selected])
    ),
    class = c("summary_blvim_logs", "list")
  )
}

cli_range <- function(label, values) {
  if (!is.null(values)) {
    values <- signif(values, 4)
    cli::cli_li(
      "{label}: median {.val {values[['median']]}},
range [{.val {values[['min']]}}, {.val {values[['max']]}}]."
    )
  }
}

#' @export
format.summary_blvim_logs <- function(x, ...) {
  configurations <- x$configurations
  best <- configurations[1, ]
  potential <- signif(best$potential, 7)
  if (nrow(configurations) > 1) {
    second <- signif(configurations$potential[2], 7)
    difference <- signif(best$potential - configurations$potential[2], 4)
  }
  cli::cli_format_method({
    cli::cli_h2("Summary of {.val {x$n_runs}} run{?s} of blvim")
    cli::cli_ul()
    cli::cli_li(
      "{.val {x$n_converged}} of {.val {x$n_runs}} run{?s} converged."
    )
    if (!is.null(x$status)) {
      status <- paste0(names(x$status), " (", as.vector(x$status), ")")
      cli::cli_li("Status: {status}.")
    }
    cli_range("Iterations", x$iterations)
    cli_range("Evaluations", x$evaluations)
    if (!is.na(x$max_gap)) {
      cli::cli_li(
        "Largest duality gap of the converged runs:
{.val {signif(x$max_gap, 4)}}."
      )
    }
    cli::cli_end()
    cli::cli_h3("Final configurations")
    cli::cli_text(
      "{.val {nrow(configurations)}} distinct configuration{?s}. The best one
(potential {.val {potential}}, {.val {best$n_active}} active
destination{?s}) was reached by {.val {best$runs}} of {.val {x$n_runs}}
run{?s}."
    )
    if (nrow(configurations) > 1) {
      cli::cli_text(
        "The second best potential is {.val {second}} (difference
{.val {difference}})."
      )
      shown <- utils::head(configurations, 5)
      shown$share <- signif(shown$share, 3)
      cli::cli_verbatim(utils::capture.output(
        print(shown, row.names = FALSE, digits = 6)
      ))
      if (nrow(configurations) > 5) {
        cli::cli_text("... and {.val {nrow(configurations) - 5}} more.")
      }
    }
    if (x$n_runs > 1 && best$runs == 1) {
      cli::cli_alert_warning(
        "The best configuration was reached by a single run: more starting
points might find a better one."
      )
    }
    if (!x$selected_converged) {
      cli::cli_alert_warning("The selected run did not converge.")
    }
  })
}

#' @export
#' @param x an object of class `summary_blvim_logs` produced by
#'   [summary.blvim_logs()]
#' @rdname summary.blvim_logs
print.summary_blvim_logs <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' Plot the runs of a multiple start blvim
#'
#' Displays the runs of [blvim()] described by [sim_logs()].
#'
#' With `type = "staircase"` (default), the final potentials of the runs are
#' shown by decreasing value as a function of their rank. Each plateau
#' corresponds to a final configuration, and its width to the number of runs
#' that reach it.
#'
#' With `type = "scatter"`, the final potential of each run is shown as a
#' function of its number of evaluations (for the gradient algorithms) or
#' iterations (for the other algorithms).
#'
#' In both cases, the colour gives the status of the run (see [sim_logs()]).
#'
#' @param object a data frame of class `blvim_logs` produced by [sim_logs()]
#' @param type the type of graphical representation, `"staircase"` or
#'   `"scatter"`
#' @param ... additional parameters (not used currently)
#' @returns a ggplot object
#' @seealso [sim_logs()], [summary.blvim_logs()]
#' @exportS3Method ggplot2::autoplot
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' distances <- french_cities_distances[1:15, 1:15] / 1000
#' production <- rep(1, 15)
#' set.seed(1)
#' starts <- blvim_initialise(n = 20)
#' model <- blvim(distances, production, 1.5, 1 / 50, starts,
#'   algorithm = "gradient", bipartite = FALSE
#' )
#' ggplot2::autoplot(sim_logs(model))
#' ggplot2::autoplot(sim_logs(model), "scatter")
autoplot.blvim_logs <- function(object, type = c("staircase", "scatter"),
                                ...) {
  check_blvim_logs(object)
  check_dots_named(list(...))
  type <- rlang::arg_match(type)
  runs <- data.frame(
    potential = object$potential,
    status = run_status(object)
  )
  if (type == "staircase") {
    runs$rank <- rank(-runs$potential, ties.method = "first")
    runs <- runs[order(runs$rank), ]
    ggplot2::ggplot(runs, ggplot2::aes(.data$rank, .data$potential)) +
      ggplot2::geom_step(colour = "grey") +
      ggplot2::geom_point(ggplot2::aes(colour = .data$status)) +
      ggplot2::labs(x = "rank of the run", y = "final potential", colour = NULL)
  } else {
    if (all(is.na(object$evaluations))) {
      runs$cost <- object$iterations
      cost_label <- "iterations"
    } else {
      runs$cost <- object$evaluations
      cost_label <- "evaluations"
    }
    ggplot2::ggplot(runs, ggplot2::aes(.data$cost, .data$potential)) +
      ggplot2::geom_point(ggplot2::aes(colour = .data$status)) +
      ggplot2::labs(x = cost_label, y = "final potential", colour = NULL)
  }
}
