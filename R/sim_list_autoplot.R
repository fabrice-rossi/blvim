sim_list_autoplot <- function(sim_list,
                              sim_data_stat,
                              flows,
                              with_names,
                              with_positions,
                              cut_off,
                              adjust_limits,
                              normalisation,
                              ...) {
  flow_name <- ifelse(flows == "destination", "flow", "attractiveness")
  if (flows == "full") {
    one_flow <- flows(sim_list[[1]])
    if (normalisation != "origin") {
      ## we rescale everything globally
      the_max <- max(sim_data_stat$Q_max)
      sim_data_stat$Q_min <- sim_data_stat$Q_min / the_max
      sim_data_stat$Q_max <- sim_data_stat$Q_max / the_max
      sim_data_stat$flow <- sim_data_stat$flow / the_max
    }
    sim_data_stat <- sim_data_stat[sim_data_stat$Q_max >= cut_off, ]
    sim_data_stat$Q_min <- sqrt(sim_data_stat$Q_min)
    sim_data_stat$Q_max <- sqrt(sim_data_stat$Q_max)
    sim_data_stat$flow <- sqrt(sim_data_stat$flow)
    x_pos <- seq_len(ncol(one_flow))
    y_pos <- seq_len(nrow(one_flow))
    x_labels <- NULL
    y_labels <- NULL
    if (with_names) {
      x_labels <- destination_names(sim_list)
      y_labels <- origin_names(sim_list)
    }
    if (is.null(x_labels)) {
      x_labels <- as.character(x_pos)
    }
    if (is.null(y_labels)) {
      y_labels <- as.character(y_pos)
    }
    sim_data_stat$origin_idx <- nrow(one_flow) + 1 - sim_data_stat$origin_idx
    background <- "#00000000"
    border <- "black"
    pre <- ggplot2::ggplot(
      sim_data_stat,
      ggplot2::aes(
        x = .data[["destination_idx"]],
        y = .data[["origin_idx"]]
      )
    ) +
      ggplot2::geom_tile(
        mapping = ggplot2::aes(
          height = .data[["Q_max"]],
          width = .data[["Q_max"]]
        ),
        colour = border,
        fill = background,
        linewidth = 0.25
      ) +
      ggplot2::geom_tile(
        mapping = ggplot2::aes(
          height = .data[["flow"]],
          width = .data[["flow"]]
        ),
        colour = border,
        fill = background,
        linewidth = 0.5
      ) +
      ggplot2::geom_tile(
        mapping = ggplot2::aes(
          height = .data[["Q_min"]],
          width = .data[["Q_min"]]
        ),
        colour = border,
        fill = background,
        linewidth = 0.25
      ) +
      ggplot2::scale_x_discrete("destination",
        breaks = x_pos,
        labels = x_labels,
        limits = as.character(x_pos)
      ) +
      ggplot2::scale_y_discrete("origin",
        breaks = y_pos,
        labels = y_labels,
        limits = rev(as.character(y_pos))
      ) +
      ggplot2::coord_fixed()
    if (with_names) {
      pre
    } else {
      pre +
        ggplot2::theme(
          axis.ticks = ggplot2::element_blank(),
          axis.text = ggplot2::element_blank()
        )
    }
  } else {
    if (with_positions) {
      positions <- location_positions(sim_list)
      pos_data <- positions_as_df(positions[["destination"]], NULL)
      sim_data_pos_names <- names(pos_data)
      if (nrow(pos_data) == nrow(sim_data_stat)) {
        full_data <- cbind(pos_data, sim_data_stat)
      } else {
        pos_data$destination <- seq_len(nrow(pos_data))
        full_data <- merge(sim_data_stat, pos_data, by = "destination")
      }
      full_data <- full_data[full_data$Q_max >= cut_off, ]
      pre <- ggplot2::ggplot(
        full_data,
        ggplot2::aes(
          x = .data[[sim_data_pos_names[1]]],
          y = .data[[sim_data_pos_names[2]]],
        )
      ) +
        ggplot2::geom_point(
          mapping = ggplot2::aes(size = .data[["Q_min"]]),
          shape = 21,
          stroke = 0.5
        ) +
        ggplot2::geom_point(
          mapping = ggplot2::aes(size = .data[[flow_name]]),
          shape = 21,
          stroke = 1
        ) +
        ggplot2::geom_point(
          mapping = ggplot2::aes(size = .data[["Q_max"]]),
          shape = 21,
          stroke = 0.25
        ) +
        ggplot2::labs(size = flow_name)
      if (!adjust_limits) {
        pre <- pre + ggplot2::lims(
          x = range(
            positions[["destination"]][, 1],
            positions[["origin"]][, 1]
          ),
          y = range(
            positions[["destination"]][, 2],
            positions[["origin"]][, 2]
          )
        )
      }
      pre
    } else {
      sim_data_stat$destination <- as.factor(sim_data_stat$destination)
      pre <-
        ggplot2::ggplot(
          sim_data_stat,
          ggplot2::aes(
            x = .data[["destination"]],
            y = .data[[flow_name]],
            ymin = .data[["Q_min"]],
            ymax = .data[["Q_max"]]
          )
        ) +
        ggplot2::geom_crossbar()
      if (with_names) {
        x_labels <- destination_names(sim_list)
        if (is.null(x_labels)) {
          x_labels <- seq_len(ncol(flows(sim_list[[1]])))
        }
        pre +
          ggplot2::scale_x_discrete(labels = x_labels)
      } else {
        pre +
          ggplot2::theme(
            axis.ticks.x = ggplot2::element_blank(),
            axis.text.x = ggplot2::element_blank()
          )
      }
    }
  }
}

#' Create a complete variability for a collection of spatial interaction models
#'
#' This function represents graphically the variability of the flows represented
#' by the spatial interaction models contained in a collection (a `sim_list`
#' object).
#'
#' The graphical representation depends on the values of `flows` and
#' `with_positions`. It is based on the data frame representation produced by
#' [fortify.sim_list()]. In all cases, the variations of the flows are
#' represented via quantiles of their distribution over the collection of
#' models. For instance, when `flows` is `"destination"`, the function computes
#' the quantiles of the incoming flows observed in the collection at each
#' destination. We consider three quantiles:
#' - a lower quantile `qmin` defaulting to 0.05;
#' - the median;
#' - a upper quantile `qmax` defaulting to 0.95.
#'
#' If `with_position` is `FALSE` (default value), the graphical representations
#' are "abstract". Depending on `flows` we have the following representations:
#'
#' -  `"full"`: the function displays the quantiles over the collection of models
#' of the flows using nested squares ([flows()]). The graph is organised as matrix with
#' origin locations on rows and destination locations on columns. At each row and
#' column intersection, three nested squares represent respectively the lower quantile,
#' the median and the upper quantile of the distribution of the flows between the
#' corresponding origin and destination locations over the collection of models. The
#' median square borders are thicker than the other two squares. The area of
#' each square is proportional to the represented value.
#'
#' -  `"destination"`: the function displays the quantiles over the collection of
#' models of the incoming flows for each destination location (using
#' [destination_flow()]). Quantiles are represented using
#' [ggplot2::geom_crossbar()]: each location is represented by a rectangle that
#' spans from its lower quantile to its upper quantile. An intermediate thicker
#' bar represents the median quantile.
#' -  `"attractiveness"`: the function displays the quantiles over the collection of
#' models of the attractivenesses of each destination location (as given by
#' [attractiveness()]). The graphical representation is the same as for
#' `"destination"`. This is interesting for dynamic models where those values
#' are updated during the iterations (see [blvim()] for details). When the
#' calculation has converged (see [sim_converged()]), both `"destination"` and
#' `"attractiveness"` graphics should be almost identical.
#'
#' When the `with_names` parameter is `TRUE`, the location names
#' ([location_names()]) are used to label the axis of the graphical
#' representation. If names are not specified, they are replaced by indexes.
#'
#' When the  `with_positions` parameter is `TRUE`, the location positions
#' ([location_positions()]) are used to produce more "geographically informed"
#' representations. Notice that if no positions are known for the locations, the
#' use of `with_positions = TRUE` is an error. Moreover, `flows = "full"` is not
#' supported: the function will issue a warning and revert to the position free
#' representation if this value is used.

#' @param object a collection of spatial interaction models, a `sim_list`
#' @param flows `"full"` (default),  `"destination"` or `"attractiveness"`, see
#'   details.
#' @param with_names specifies whether the graphical representation includes
#'   location names (`FALSE` by default)
#' @param with_positions specifies whether the graphical representation is based
#'   on location positions (`FALSE` by default)
#' @param cut_off cut off limit for inclusion of a graphical primitive when
#'   `with_positions = TRUE`. In the attractiveness or destination
#'   representation, disks are removed when the corresponding upper quantile
#'   value is below the cut off.
#' @param adjust_limits if `FALSE` (default value), the limits of the position
#'   based graph are not adjusted after removing graphical primitives. This
#'   eases comparison between graphical representations with different cut off
#'   value. If `TRUE`, limits are adjusted to the data using the standard
#'   ggplot2 behaviour.
#' @param qmin lower quantile, see details (default: 0.05)
#' @param qmax upper quantile, see details (default: 0.95)
#' @param normalisation when `flows="full"`, the flows can be reported without
#'    normalisation (`normalisation="none"`) or they can be normalised, either
#'    to sum to one for each origin location (`normalisation="origin"`, the default
#'    value) or to sum to one globally (`normalisation="full"`).
#' @param ... additional parameters, not used currently
#'
#' @returns a ggplot object
#' @seealso [fortify.sim_list()]
#' @exportS3Method ggplot2::autoplot
#'
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- c(2, rep(1, 9))
#' attractiveness <- c(2, rep(1, 9))
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.1),
#'   seq(1, 3, by = 0.5),
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#'   destination_data = list(names = LETTERS[1:10], positions = positions),
#'   origin_data = list(names = LETTERS[1:10], positions = positions),
#' )
#' ggplot2::autoplot(all_flows, with_names = TRUE)
#' ggplot2::autoplot(all_flows, with_names = TRUE, normalisation = "none")
#' ggplot2::autoplot(all_flows,
#'   flow = "destination", with_names = TRUE,
#'   qmin = 0, qmax = 1
#' )
#' ggplot2::autoplot(all_flows,
#'   flow = "destination", with_positions = TRUE,
#'   qmin = 0, qmax = 1
#' ) + ggplot2::scale_size_continuous(range = c(0, 6))
#' ggplot2::autoplot(all_flows,
#'   flow = "destination", with_positions = TRUE,
#'   qmin = 0, qmax = 1,
#'   cut_off = 1.1
#' )
autoplot.sim_list <- function(object,
                              flows = c("full", "destination", "attractiveness"),
                              with_names = FALSE,
                              with_positions = FALSE,
                              cut_off = 100 * .Machine$double.eps^0.5,
                              adjust_limits = FALSE,
                              qmin = 0.05,
                              qmax = 0.95,
                              normalisation = c("origin", "full", "none"),
                              ...) {
  flows <- rlang::arg_match(flows)
  normalisation <- rlang::arg_match(normalisation)
  if (with_positions) {
    positions <- location_positions(object)
    if (flows == "destination" || flows == "attractiveness") {
      if (is.null(positions[["destination"]])) {
        cli::cli_abort("Missing destination location positions")
      }
    }
    if (flows == "full") {
      cli::cli_warn(c("{.arg flows} = {.str full} cannot be combined with {.arg with_positions} = {.val TRUE}",
        "!" = "proceeding with {.arg with_positions} set to {.val FALSE}"
      ))
    }
  }
  sim_data <- fortify.sim_list(object,
    data = NULL,
    flows = flows,
    with_names = with_names,
    normalisation = normalisation,
    ...
  )
  sim_data_stat <- stat_sim_list(sim_data, flows, quantiles = c(qmin, qmax))
  sim_list_autoplot(
    object, sim_data_stat, flows, with_names, with_positions,
    cut_off, adjust_limits, normalisation
  )
}
