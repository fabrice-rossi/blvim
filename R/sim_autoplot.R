sim_autoplot <- function(sim, sim_data,
                         flows,
                         with_names,
                         with_positions,
                         adjust_limits,
                         ...) {
  if (with_positions) {
    if (flows == "destination" || flows == "attractiveness") {
      sim_data_pos_names <- names(sim_data)
      pre <- ggplot2::ggplot(
        sim_data,
        ggplot2::aes(
          x = .data[[sim_data_pos_names[1]]],
          y = .data[[sim_data_pos_names[2]]],
          size = .data[[flows]]
        )
      ) +
        ggplot2::geom_point()
      if (!adjust_limits) {
        positions <- location_positions(sim)
        pre <- pre + ggplot2::lims(
          x = range(positions[["destination"]][, 1]),
          y = range(positions[["destination"]][, 2])
        )
      }
      pre
    } else {
      segment_parameters <- list(...)
      if (!rlang::has_name(segment_parameters, "arrow")) {
        segment_parameters$arrow <- ggplot2::arrow(length = ggplot2::unit(0.025, "npc"))
      }
      if (!rlang::has_name(segment_parameters, "lineend")) {
        segment_parameters$lineend <- "round"
      }
      if (!rlang::has_name(segment_parameters, "linejoin")) {
        segment_parameters$linejoin <- "round"
      }
      pre <- ggplot2::ggplot(
        sim_data,
        ggplot2::aes(
          x = .data[["x"]],
          xend = .data[["xend"]],
          y = .data[["y"]],
          yend = .data[["yend"]],
          linewidth = .data[["flow"]]
        )
      ) +
        do.call(ggplot2::geom_segment, segment_parameters)
      if (!adjust_limits) {
        positions <- location_positions(sim)
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
    }
  } else {
    if (flows == "destination" || flows == "attractiveness") {
      var_name <- ifelse(flows == "destination", "flow", flows)
      pre <- ggplot2::ggplot(sim_data, ggplot2::aes(
        x = .data[["destination"]],
        y = .data[[var_name]]
      )) +
        ggplot2::geom_col()
      if (with_names) {
        x_labels <- destination_names(sim)
        if (is.null(x_labels)) {
          x_labels <- 1:nrow(sim_data)
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
    } else {
      pre <- ggplot2::ggplot(sim_data, ggplot2::aes(
        y = .data[["origin"]],
        x = .data[["destination"]],
        fill = .data[["flow"]]
      )) +
        ggplot2::geom_raster()
      if (with_names) {
        full_f <- flows(sim)
        x_labels <- destination_names(sim)
        if (is.null(x_labels)) {
          x_labels <- 1:ncol(full_f)
        }
        y_labels <- origin_names(sim)
        if (is.null(y_labels)) {
          y_labels <- 1:nrow(full_f)
        }
        y_labels <- rev(y_labels)
        pre +
          ggplot2::scale_x_discrete(breaks = seq_along(x_labels), labels = x_labels) +
          ggplot2::scale_y_discrete(breaks = seq_along(y_labels), labels = y_labels)
      } else {
        pre +
          ggplot2::theme(
            axis.ticks = ggplot2::element_blank(),
            axis.text = ggplot2::element_blank()
          )
      }
    }
  }
}

#' Create a complete ggplot for a spatial interaction model
#'
#' This function represents graphical the flows of a spatial interaction model,
#' in different direct or aggregated forms.
#'
#' The graphical representation depends on the values of `flows` and
#' `with_positions`. It is based on the data frame representation produced by
#' [fortify.sim()].
#'
#' If `with_position` is `FALSE` (default value), the graphical representations
#' are "abstract". Depending on `flows` we have the following representations:
#'
#' -  `"full"`: this is the default case for which the full flow matrix is represented.
#' It is extracted from the spatial interaction model with [flows()] and
#' displayed using a matrix representation with origin locations in rows and
#' destination locations in columns. The colour of a cell corresponds to the
#' intensity of a flow between the corresponding locations. To mimic the
#' standard top to bottom reading order of a flow matrix, the top row of the
#' graphical representation corresponds to the first origin location.
#' -  `"destination"`: the function computes the
#' incoming flows for destination locations (using [destination_flow()]) and
#' represents them with a bar plot (each bar is proportional to the incoming
#' flow);
#' -  `"attractiveness"`: the function uses a bar plot to represent the
#' attractivenesses of the destination locations (as given by
#' [attractiveness()]). This is interesting for dynamic models where those
#' values are updated during the iterations (see [blvim()] for details). When
#' the calculation has converged (see [sim_converged()]), both `"destination"`
#' and `"attractiveness"` graphics should be almost identical.
#'
#' When the `with_names` parameter is `TRUE`, the location names
#' ([location_names()]) are used to label the axis of the graphical
#' representation. If names are not specified, they are replaced by indexes.
#'
#' When the  `with_positions` parameter is `TRUE`, the location positions
#' ([location_positions()]) are used to produce more "geographically informed"
#' representations. Notice that if no positions are known for the locations, the
#' use of `with_positions = TRUE` is an error. Depending on `flows` we have the
#' following representations:
#'
#' -  `"full"`: this is the default case for which the full flow matrix is represented.
#' Positions for both origin and destination locations are needed. The
#' representation uses arrows from origin location positions to destination
#' location positions. The thickness of the lines (`linewidth` aesthetics) is
#' proportional to the flows. Only segments that carry a flow above the
#' `cut_off` value are included. Additional parameters in `...` are submitted to
#' [ggplot2::geom_segment()]. This can be used to override defaults parameters
#' used for the arrow shapes, for instance.
#' -  `"destination"`: the function draws a disk at each destination location
#' using for the `size` aesthetics the incoming flow at this destination
#' location (using [destination_flow()]). Only destinations with an incoming
#' flow above  the `cut_off` value are included.
#' -  `"attractiveness"`: the function draws a disk at each destination location
#' using for the `size` aesthetics the attractiveness of the destination. When
#' the calculation has converged (see [sim_converged()]), both `"destination"`
#' and `"attractiveness"` graphics should be almost identical. Only destinations
#' with an attractiveness above  the `cut_off` value are included.
#'
#' @param object a spatial interaction model object
#' @param flows  `"full"` (default),  `"destination"` or `"attractiveness"`, see
#'   details.
#' @param with_names specifies whether the graphical representation includes
#'   location names (`FALSE` by default)
#' @param with_positions specifies whether the graphical representation is based
#'   on location positions (`FALSE` by default)
#' @param cut_off cut off limit for inclusion of a graphical primitive when
#'   `with_positions = TRUE`. In the full flow matrix representation, segments
#'   are removed when their flow is smaller than the cut off. In the
#'   attractiveness or destination representation, disks are removed when the
#'   corresponding value is below the cut off.
#' @param adjust_limits if `FALSE` (default value), the limits of the position
#'   based graph are not adjusted after removing graphical primitives. This
#'   eases comparison between graphical representations with different cut off
#'   value. If `TRUE`, limits are adjusted to the data using the standard
#'   ggplot2 behaviour.
#' @param ... additional parameters, see details
#' @seealso [fortify.sim()]
#' @exportS3Method ggplot2::autoplot
#' @returns a ggplot object
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' flows <- blvim(distances, production, 1.5, 4, attractiveness,
#'   origin_data = list(names = LETTERS[1:10], positions = positions),
#'   destination_data = list(names = LETTERS[1:10], positions = positions)
#' )
#' ggplot2::autoplot(flows)
#' ## bar plots should be almost identical if convergence occurred
#' sim_converged(flows)
#' ggplot2::autoplot(flows, "destination")
#' ggplot2::autoplot(flows, "attractiveness")
#' ## names inclusion
#' ggplot2::autoplot(flows, "destination", with_names = TRUE)
#' ggplot2::autoplot(flows, with_names = TRUE)
#' ## positions
#' ggplot2::autoplot(flows, "attractiveness", with_positions = TRUE) +
#'   ggplot2::scale_size_continuous(range = c(0, 6))
#' ggplot2::autoplot(flows, with_positions = TRUE) +
#'   ggplot2::scale_linewidth_continuous(range = c(0, 2))
autoplot.sim <- function(object,
                         flows = c("full", "destination", "attractiveness"),
                         with_names = FALSE,
                         with_positions = FALSE,
                         cut_off = 100 * .Machine$double.eps^0.5,
                         adjust_limits = FALSE,
                         ...) {
  flows <- rlang::arg_match(flows)
  sim_data <- ggplot2::fortify(object, data = NULL, flows, with_positions, cut_off, ...)
  sim_autoplot(object, sim_data, flows, with_names, with_positions, adjust_limits, ...)
}
