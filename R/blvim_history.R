new_blvim_history <- function(history) {
  class(history) <- c("blvim_history", setdiff(class(history), "blvim_history"))
  history
}

check_blvim_history <- function(object) {
  needed <- c("iteration", "gap", "potential", "step", "min_U")
  missing_columns <- setdiff(needed, names(object))
  if (length(missing_columns) > 0) {
    cli::cli_abort(c(
      "{.arg object} must contain the columns produced by {.fn sim_history}",
      "x" = "Missing column{?s}: {.field {missing_columns}}"
    ))
  }
}

## Splits a history into the histories of its runs (identified by the sim
## column of the history of a sim_list)
history_runs <- function(history) {
  if ("sim" %in% names(history)) {
    split(as.data.frame(history), history$sim)
  } else {
    list("1" = as.data.frame(history))
  }
}

## Convergence rate of the duality gap: geometric mean of the ratio of
## successive gaps, estimated by a least squares fit of log(gap) on the last
## iterations (at most half of them, at most 20)
gap_rate <- function(iteration, gap) {
  keep <- is.finite(gap) & gap > 0
  iteration <- iteration[keep]
  gap <- gap[keep]
  used <- min(20L, length(gap) %/% 2L)
  if (used < 3L) {
    return(NA_real_)
  }
  last <- utils::tail(seq_along(gap), used)
  slope <- stats::coef(stats::lm.fit(
    cbind(1, iteration[last]), log(gap[last])
  ))[2]
  exp(unname(slope))
}

history_run_summary <- function(run) {
  steps <- run$step[run$step > 0]
  last <- nrow(run)
  if ("n_active" %in% names(run)) {
    active <- run$n_active
  } else {
    active <- rep(NA_integer_, last)
  }
  changes <- diff(active) != 0
  changes <- !is.na(changes) & changes
  data.frame(
    iterations = last,
    initial_potential = run$potential[1],
    final_potential = run$potential[last],
    final_gap = run$gap[last],
    rate = gap_rate(run$iteration, run$gap),
    reductions = if ("line_search_reductions" %in% names(run)) {
      sum(run$line_search_reductions)
    } else {
      NA_integer_
    },
    min_step = if (length(steps) > 0) min(steps) else NA_real_,
    initial_active = active[1],
    final_active = active[last],
    face_changes = sum(changes),
    last_change = if (any(changes)) max(run$iteration[-1][changes]) else NA,
    final_min_U = run$min_U[last],
    vanishing = vanishing_destination(run$min_U)
  )
}

## An interior run whose smallest rescaled attractiveness decreased by more
## than a factor 10 over the last half of its iterations: a destination may be
## vanishing, which slows down the convergence
vanishing_destination <- function(min_U) {
  last <- length(min_U)
  half <- min_U[max(1L, last %/% 2L)]
  min_U[last] > active_tolerance && min_U[last] < half / 10
}

#' Summary of the iteration history of blvim
#'
#' Summarises the iteration history of the gradient algorithms of [blvim()],
#' as returned by [sim_history()], for one model or for a collection of
#' models.
#'
#' For each run, the summary gives the number of iterations, the initial and
#' final potentials, the final duality gap, the estimated convergence rate of
#' the duality gap, the total number of step reductions in the line search,
#' the smallest accepted step, and the evolution of the active destinations.
#' The convergence rate is the factor by which the gap is multiplied at each
#' iteration, estimated on the last iterations (at most 20): a rate close to
#' one denotes a slow linear convergence.
#'
#' The projected gradient ascent moves on the faces of the simplex: a
#' destination vanishes when its rescaled attractiveness becomes zero, and
#' can come back later. Each change of the number of active destinations is a
#' face change. The duality gap often decreases quickly only once the ascent
#' stays on the face of its final configuration, that is after the last face
#' change. A final configuration whose smallest rescaled attractiveness is
#' below \eqn{10^{-5}} is on a face of the simplex. Conversely, when the
#' final configuration is not on a face but its smallest rescaled
#' attractiveness decreased by more than a factor 10 over the last half of
#' the iterations, a destination may be slowly vanishing, which slows down
#' the convergence.
#'
#' @param object a data frame of class `blvim_history` produced by
#'   [sim_history()]
#' @param ... additional parameters (not used currently)
#'
#' @returns an object of class `summary_blvim_history` and `list` with the
#'   following elements:
#'
#'   - `runs`: a data frame with one row per run and columns `sim` (index of
#'     the model in the collection, 1 for a single model), `iterations`,
#'     `initial_potential`, `final_potential`, `final_gap`, `rate`,
#'     `reductions`, `min_step`, `initial_active` and `final_active` (number
#'     of active destinations), `face_changes` (number of changes of the
#'     number of active destinations), `last_change` (iteration of the last
#'     face change, `NA` without change), `final_min_U` (smallest rescaled
#'     attractiveness of the final configuration), `vanishing` (whether a
#'     destination may be slowly vanishing) and `on_face` (whether the final
#'     configuration is on a face of the simplex);
#'   - `collection`: whether the history describes a collection of models.
#' @seealso [sim_history()], [grid_sim_history()],
#'   [autoplot.blvim_history()]
#' @export
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000
#' production <- rep(1, 15)
#' attractiveness <- rep(1, 15)
#' model <- blvim(distances, production, 1.5, 1 / 50, attractiveness,
#'   algorithm = "gradient", bipartite = FALSE,
#'   control = blvim_gradient_control(history = TRUE)
#' )
#' summary(sim_history(model))
summary.blvim_history <- function(object, ...) {
  check_blvim_history(object)
  runs <- history_runs(object)
  summaries <- do.call(rbind, lapply(runs, history_run_summary))
  summaries <- cbind(sim = as.integer(names(runs)), summaries)
  summaries$on_face <- summaries$final_min_U <= active_tolerance
  rownames(summaries) <- NULL
  structure(
    list(runs = summaries, collection = "sim" %in% names(object)),
    class = c("summary_blvim_history", "list")
  )
}

#' @export
format.summary_blvim_history <- function(x, ...) {
  runs <- x$runs
  shown <- runs
  numeric_columns <- vapply(shown, is.double, logical(1))
  shown[numeric_columns] <- lapply(shown[numeric_columns], signif, 4)
  shown$initial_potential <- signif(runs$initial_potential, 7)
  shown$final_potential <- signif(runs$final_potential, 7)
  cli::cli_format_method({
    if (nrow(runs) == 1 && !x$collection) {
      cli::cli_h2("Iteration history of a gradient ascent")
      cli::cli_ul()
      cli::cli_li(
        "{.val {runs$iterations}} iterations, potential from
{.val {shown$initial_potential}} to {.val {shown$final_potential}}."
      )
      cli::cli_li("Final duality gap: {.val {shown$final_gap}}.")
      if (!is.na(runs$rate)) {
        cli::cli_li(
          "Convergence rate of the duality gap: {.val {shown$rate}} per
iteration."
        )
      }
      if (!is.na(runs$reductions)) {
        cli::cli_li(
          "Line search: {.val {runs$reductions}} step reduction{?s}, smallest
accepted step {.val {shown$min_step}}."
        )
      }
      if (!is.na(runs$final_active)) {
        if (runs$face_changes == 0) {
          cli::cli_li(
            "{.val {runs$final_active}} active destination{?s}, no face
change."
          )
        } else {
          cli::cli_li(
            "Active destinations: from {.val {runs$initial_active}} to
{.val {runs$final_active}}, {.val {runs$face_changes}} face change{?s}, the
last one at iteration {.val {runs$last_change}}."
          )
        }
      }
      if (runs$on_face) {
        cli::cli_li("The final configuration is on a face of the simplex.")
      }
      cli::cli_end()
      if (runs$vanishing) {
        cli::cli_alert_warning(
          "The smallest rescaled attractiveness decreased to
{.val {shown$final_min_U}}: a destination may be slowly vanishing."
        )
      }
    } else {
      cli::cli_h2(
        "Iteration histories of {.val {nrow(runs)}} gradient ascent{?s}"
      )
      cli::cli_ul()
      cli_range("Iterations", range_summary(runs$iterations))
      cli::cli_li("Largest final duality gap: {.val {max(shown$final_gap)}}.")
      cli_range("Convergence rate of the duality gap", range_summary(runs$rate))
      cli_range("Face changes", range_summary(runs$face_changes))
      cli::cli_li(
        "{.val {sum(runs$on_face)}} of {.val {nrow(runs)}} final
configuration{?s} on a face of the simplex."
      )
      cli::cli_end()
      if (any(runs$vanishing)) {
        cli::cli_alert_warning(
          "In {.val {sum(runs$vanishing)}} run{?s}, a destination may be slowly
vanishing."
        )
      }
      columns <- c(
        "sim", "iterations", "final_potential", "final_gap", "rate",
        "final_active", "face_changes", "last_change"
      )
      cli::cli_verbatim(utils::capture.output(
        print(utils::head(runs[columns], 20), row.names = FALSE, digits = 4)
      ))
      if (nrow(runs) > 20) {
        cli::cli_text("... and {.val {nrow(runs) - 20}} more.")
      }
    }
  })
}

#' @export
#' @param x an object of class `summary_blvim_history` produced by
#'   [summary.blvim_history()]
#' @rdname summary.blvim_history
print.summary_blvim_history <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

history_quantities <- c(
  gap = "duality gap",
  potential = "distance to the final potential",
  step = "accepted step",
  n_active = "active destinations",
  min_U = "smallest rescaled attractiveness"
)

#' Plot the iteration history of blvim
#'
#' Displays the iteration history of the gradient algorithms of [blvim()], as
#' returned by [sim_history()], for one model or for a collection of models.
#'
#' Each selected quantity is shown in its own panel, on a logarithmic scale,
#' as a function of the iteration number:
#'
#' - `"gap"`: the duality gap;
#' - `"potential"`: the difference between the final potential of the run and
#'   its current potential;
#' - `"step"`: the accepted step of the line search;
#' - `"n_active"`: the number of active destinations, which changes when the
#'   ascent moves from one face of the simplex to another;
#' - `"min_U"` (not shown by default): the smallest rescaled attractiveness.
#'   It drops to zero, and is no longer shown, as soon as a destination
#'   vanishes, so it is mainly useful for runs that stay in the interior of
#'   the simplex.
#'
#' Values that are not positive (for instance the final step, or the
#' distance to the final potential at the last iteration) are not shown. For
#' a collection of models, each run has its own line, coloured by model when
#' there are at most `max_colours` of them.
#'
#' @param object a data frame of class `blvim_history` produced by
#'   [sim_history()]
#' @param what the quantities to display, one or several of `"gap"`,
#'   `"potential"`, `"step"`, `"n_active"` and `"min_U"`
#' @param max_colours the largest number of runs for which each run has its
#'   own colour
#' @param ... additional parameters (not used currently)
#' @returns a ggplot object
#' @seealso [sim_history()], [summary.blvim_history()]
#' @exportS3Method ggplot2::autoplot
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' distances <- french_cities_distances[1:15, 1:15] / 1000
#' production <- rep(1, 15)
#' attractiveness <- rep(1, 15)
#' model <- blvim(distances, production, 1.5, 1 / 50, attractiveness,
#'   algorithm = "gradient", bipartite = FALSE,
#'   control = blvim_gradient_control(history = TRUE)
#' )
#' ggplot2::autoplot(sim_history(model))
#' ggplot2::autoplot(sim_history(model), c("gap", "potential"))
autoplot.blvim_history <- function(
  object,
  what = c("gap", "potential", "step", "n_active"),
  max_colours = 8L,
  ...
) {
  check_blvim_history(object)
  check_dots_named(list(...))
  what <- rlang::arg_match(what, names(history_quantities), multiple = TRUE)
  runs <- history_runs(object)
  curves <- do.call(rbind, lapply(names(runs), function(name) {
    run <- runs[[name]]
    values <- list(
      gap = run$gap,
      potential = run$potential[nrow(run)] - run$potential,
      step = run$step,
      n_active = if (is.null(run$n_active)) NA_integer_ else run$n_active,
      min_U = run$min_U
    )[what]
    data.frame(
      sim = name,
      iteration = rep(run$iteration, length(what)),
      quantity = factor(
        rep(history_quantities[what], each = nrow(run)),
        levels = history_quantities[what]
      ),
      value = unlist(values, use.names = FALSE)
    )
  }))
  curves <- curves[is.finite(curves$value) & curves$value > 0, ]
  curves$sim <- factor(curves$sim, levels = names(runs))
  ## a curve with a single positive value (e.g. min_U when a destination
  ## vanishes at the first iteration) is shown as a point
  sizes <- stats::ave(curves$value, curves$sim, curves$quantity, FUN = length)
  if (length(runs) > 1 && length(runs) <= max_colours) {
    colour <- ggplot2::aes(colour = .data$sim)
    alpha <- 1
  } else {
    colour <- NULL
    alpha <- if (length(runs) > 1) 0.3 else 1
  }
  result <- ggplot2::ggplot(curves, ggplot2::aes(.data$iteration, .data$value,
    group = .data$sim
  )) +
    ggplot2::geom_line(colour, data = curves[sizes > 1, ], alpha = alpha) +
    ggplot2::geom_point(colour, data = curves[sizes == 1, ], alpha = alpha) +
    ggplot2::facet_wrap(ggplot2::vars(.data$quantity), scales = "free_y") +
    ggplot2::scale_y_log10() +
    ggplot2::labs(x = "iteration", y = NULL)
  if (!is.null(colour)) {
    result <- result + ggplot2::labs(colour = "model")
  }
  result
}
