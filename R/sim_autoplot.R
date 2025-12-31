sim_autoplot_warning <- function(with_names, with_positions,
                                 with_show_dest, with_show_att, with_show_prod,
                                 show_destination,
                                 show_attractiveness,
                                 show_production,
                                 with_cut_off, cut_off,
                                 with_adjust_limits, adjust_limits,
                                 with_with_labels, with_labels,
                                 call = rlang::caller_env()) {
  if (!with_positions) {
    if (with_cut_off) {
      cli::cli_warn(
        c("{.arg cut_off} is not used when {.arg with_positions}
is {.val {FALSE}}",
          "!" = "{.arg cut_off} is {.val {cut_off}}"
        ),
        call = call
      )
    }
    if (with_adjust_limits) {
      cli::cli_warn(
        c("{.arg adjust_limits} is not used when {.arg with_positions}
is {.val {FALSE}}",
          "!" = "{.arg adjust_limits} is {.val {adjust_limits}}"
        ),
        call = call
      )
    }
    if (with_with_labels) {
      cli::cli_warn(
        c("{.arg with_labels} is not used when {.arg with_positions}
is {.val {FALSE}}",
          "!" = "{.arg with_labels} is {.val {with_labels}}"
        ),
        call = call
      )
    }
    if (with_show_dest) {
      cli::cli_warn(
        c("{.arg show_destination} is not used when {.arg with_positions}
is {.val {FALSE}}",
          "!" = "{.arg show_destination} is {.val {show_destination}}"
        ),
        call = call
      )
    }
    if (with_show_att) {
      cli::cli_warn(
        c("{.arg show_attractiveness} is not used when {.arg with_positions}
is {.val {FALSE}}",
          "!" = "{.arg show_attractiveness} is {.val {show_attractiveness}}"
        ),
        call = call
      )
    }
    if (with_show_prod) {
      cli::cli_warn(
        c("{.arg show_production} is not used when {.arg with_positions}
is {.val {FALSE}}",
          "!" = "{.arg show_production} is {.val {show_production}}"
        ),
        call = call
      )
    }
  }
  if (!with_names && with_positions) {
    if (with_with_labels) {
      cli::cli_warn(
        c("{.arg with_labels} is not used when {.arg with_names}
is {.val {FALSE}}",
          "!" = "{.arg with_labels} is {.val {with_labels}}"
        ),
        call = call
      )
    }
  }
}

sim_autoplot_flow_pos <- function(sim, sim_data,
                                  sim_data_point,
                                  show_points,
                                  with_names,
                                  adjust_limits,
                                  with_labels,
                                  segment_parameters) {
  sim_data_names <- names(sim_data)[c(1, 3)]
  if (!sim_is_bipartite(sim)) {
    ## we remove zero length segments
    sim_data <- sim_data[sim_data[[sim_data_names[1]]] != sim_data$xend |
      sim_data[[sim_data_names[2]]] != sim_data$yend, ]
  }
  if (!rlang::has_name(segment_parameters, "arrow") &&
    (!show_points || sim_data_point$flows == "production")) {
    ## do not use arrow when showing destination values unless asked by the
    ## user
    segment_parameters$arrow <-
      ggplot2::arrow(length = ggplot2::unit(0.025, "npc"))
  }
  if (!rlang::has_name(segment_parameters, "lineend")) {
    segment_parameters$lineend <- "round"
  }
  if (!rlang::has_name(segment_parameters, "linejoin")) {
    segment_parameters$linejoin <- "round"
  }
  if (!rlang::has_name(segment_parameters, "alpha")) {
    segment_parameters$alpha <- ifelse(!show_points, 1, 0.75)
  }
  pre <- ggplot2::ggplot(
    sim_data,
    ggplot2::aes(
      x = .data[[sim_data_names[1]]],
      xend = .data[["xend"]],
      y = .data[[sim_data_names[2]]],
      yend = .data[["yend"]],
      linewidth = .data[["flow"]]
    )
  ) +
    do.call(ggplot2::geom_segment, segment_parameters)
  positions <- location_positions(sim)
  ranges <- list(
    x = range(
      positions[["destination"]][, 1],
      positions[["origin"]][, 1]
    ),
    y = range(
      positions[["destination"]][, 2],
      positions[["origin"]][, 2]
    )
  )
  if (show_points) {
    sim_data_pos_names <- names(sim_data_point$data)
    if (!is.null(sim_data_point$data[["type"]])) {
      pre <- pre +
        ggplot2::geom_point(
          data = sim_data_point$data,
          ggplot2::aes(
            x = .data[[sim_data_pos_names[1]]],
            y = .data[[sim_data_pos_names[2]]],
            size = .data[[sim_data_point$flows]],
            color = .data[["type"]]
          ),
          inherit.aes = FALSE,
          alpha = 0.75
        )
    } else {
      pre <- pre + ggplot2::geom_point(
        data = sim_data_point$data,
        ggplot2::aes(
          x = .data[[sim_data_pos_names[1]]],
          y = .data[[sim_data_pos_names[2]]],
          size = .data[[sim_data_point$flows]],
        ),
        inherit.aes = FALSE,
        alpha = 0.75
      )
    }
  }
  if (with_names) {
    plot_with_names <- sim_autoplot_add_names(
      sim_data_point$data, with_labels,
      pre, ranges
    )
    pre <- plot_with_names$plot
    ranges <- plot_with_names$ranges
  }
  if (!adjust_limits) {
    positions <- location_positions(sim)
    pre <- pre + ggplot2::lims(
      x = ranges$x,
      y = ranges$y
    )
  }
  pre
}

sim_autoplot_add_names <- function(sim_data, with_labels, current_plot,
                                   ranges) {
  sim_data_pos_names <- names(sim_data)
  if (has_ggrepel()) {
    if (with_labels) {
      current_plot <- current_plot +
        ggrepel::geom_label_repel(
          data = sim_data,
          mapping = ggplot2::aes(
            x = .data[[sim_data_pos_names[1]]],
            y = .data[[sim_data_pos_names[2]]],
            label = .data[["name"]]
          ),
          inherit.aes = FALSE,
          show.legend = FALSE
        )
    } else {
      current_plot <- current_plot +
        ggrepel::geom_text_repel(
          data = sim_data,
          mapping = ggplot2::aes(
            x = .data[[sim_data_pos_names[1]]],
            y = .data[[sim_data_pos_names[2]]],
            label = .data[["name"]]
          ),
          inherit.aes = FALSE,
          show.legend = FALSE
        )
    }
  } else {
    xnudge <- diff(ranges$x) / 25
    ynudge <- diff(ranges$y) / 25
    if (with_labels) {
      current_plot <- current_plot +
        ggplot2::geom_label(
          data = sim_data,
          mapping = ggplot2::aes(
            x = .data[[sim_data_pos_names[1]]],
            y = .data[[sim_data_pos_names[2]]],
            label = .data[["name"]]
          ),
          inherit.aes = FALSE,
          show.legend = FALSE,
          position = ggplot2::position_nudge(x = xnudge, y = ynudge)
        )
    } else {
      current_plot <- current_plot +
        ggplot2::geom_text(
          data = sim_data,
          mapping = ggplot2::aes(
            x = .data[[sim_data_pos_names[1]]],
            y = .data[[sim_data_pos_names[2]]],
            label = .data[["name"]]
          ),
          inherit.aes = FALSE,
          show.legend = FALSE,
          position = ggplot2::position_nudge(x = xnudge, y = ynudge)
        )
    }
    ranges$x[2] <- ranges$x[2] + xnudge
    ranges$y[2] <- ranges$y[2] + ynudge
  }
  list(plot = current_plot, ranges = ranges)
}

sim_autoplot_destination_pos <- function(sim, sim_data, flows,
                                         with_names, adjust_limits,
                                         with_labels) {
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
  positions <- location_positions(sim)
  ranges <- list(
    x = range(positions[["destination"]][, 1]),
    y = range(positions[["destination"]][, 2])
  )
  if (with_names) {
    plot_with_names <- sim_autoplot_add_names(sim_data, with_labels, pre, ranges)
    pre <- plot_with_names$plot
    ranges <- plot_with_names$ranges
  }
  if (!adjust_limits) {
    pre <- pre + ggplot2::lims(
      x = ranges$x,
      y = ranges$y
    )
  }
  pre
}

sim_autoplot <- function(sim, sim_data,
                         sim_data_point,
                         show_points,
                         flows,
                         with_names,
                         with_positions,
                         cut_off,
                         adjust_limits,
                         with_labels,
                         ...) {
  if (with_positions) {
    if (flows == "destination" || flows == "attractiveness") {
      sim_autoplot_destination_pos(
        sim, sim_data, flows, with_names,
        adjust_limits, with_labels
      )
    } else {
      sim_autoplot_flow_pos(
        sim, sim_data, sim_data_point,
        show_points,
        with_names,
        adjust_limits,
        with_labels,
        list(...)
      )
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
          x_labels <- seq_len(nrow(sim_data))
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
      full_f <- flows(sim)
      if (with_names) {
        x_labels <- destination_names(sim)
        if (is.null(x_labels)) {
          x_labels <- seq_len(ncol(full_f))
        }
        y_labels <- origin_names(sim)
        if (is.null(y_labels)) {
          y_labels <- seq_len(nrow(full_f))
        }
        pre +
          ggplot2::scale_x_discrete(
            breaks = seq_along(x_labels),
            labels = x_labels,
            limits = levels(sim_data$destination)
          ) +
          ggplot2::scale_y_discrete(
            breaks = seq_along(y_labels),
            labels = y_labels,
            limits = rev(levels(sim_data$origin))
          )
      } else {
        pre +
          ggplot2::theme(
            axis.ticks = ggplot2::element_blank(),
            axis.text = ggplot2::element_blank()
          ) +
          ggplot2::scale_x_discrete(limits = levels(sim_data$destination)) +
          ggplot2::scale_y_discrete(limits = rev(levels(sim_data$origin)))
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
#' -  `"full"`: this is the default case for which the full flow matrix is
#' represented. It is extracted from the spatial interaction model with
#' [flows()] and displayed using a matrix representation with origin locations
#' in rows and destination locations in columns. The colour of a cell
#' corresponds to the intensity of a flow between the corresponding locations.
#' To mimic the standard top to bottom reading order of a flow matrix, the top
#' row of the graphical representation corresponds to the first origin location.
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
#' -  `"full"`: this is the default case for which the full flow matrix is
#' represented. Positions for both origin and destination locations are needed.
#' The representation uses arrows from origin location positions to destination
#' location positions. The thickness of the lines (`linewidth` aesthetics) is
#' proportional to the flows. Only segments that carry a flow above the
#' `cut_off` value are included. When the spatial interaction model is not
#' bipartite (see [sim_is_bipartite()]), zero length segments corresponding to
#' self exchange are removed. Additional parameters in `...` are submitted to
#' [ggplot2::geom_segment()]. This can be used to override defaults parameters
#' used for the arrow shapes, for instance. Those parameters must be named. In
#' addition to the individual flows, the representation can include location
#' based information. If `show_production` is `TRUE`, the production constraints
#' (obtained by [production()]) are shown as disks centred on the origin
#' locations. If `show_destination` is `TRUE`, incoming flows (obtained by
#' [destination_flow()]) are shown as disks centred on the destination
#' locations. If `show_attractiveness` is `TRUE`, attractivenesses (obtained by
#' [attractiveness()]) are shown as disks centred on the destination locations.
#' `show_destination` and `show_attractiveness` are not compatible (only one can
#' be `TRUE`). `show_production` is compatible with `show_destination` or
#' `show_attractiveness` for bipartite models only (see [sim_is_bipartite()]).
#' When disks are used, segments are drawn without arrows, while the default
#' drawing uses arrows. This can be modified with the additional parameters.
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
#' For the position based representations and when `with_names` is `TRUE`, the
#' names of the destinations are added to the graphical representation . If
#' `with_labels` is `TRUE` the names are represented as labels instead of plain
#' texts (see [ggplot2::geom_label()]). If the `ggrepel` package is installed,
#' its functions are used instead of `ggplot2` native functions. When disks are
#' used to show aggregated flows, the names match the chosen locations: for
#' destination flow and attractiveness, destination locations are named, while
#' for production, origin locations are named (they can be both named when the
#' model is bipartite).
#'
#' @param object a spatial interaction model object
#' @param flows  `"full"` (default),  `"destination"` or `"attractiveness"`, see
#'   details.
#' @param with_names specifies whether the graphical representation includes
#'   location names (`FALSE` by default)
#' @param with_positions specifies whether the graphical representation is based
#'   on location positions (`FALSE` by default)
#' @param show_destination specifies whether the position based `"full"` flow
#'   figure includes a representation of the destination flows (`FALSE` by
#'   default)
#' @param show_attractiveness specifies whether the position based `"full"` flow
#'   figure includes a representation of the attractivenesses  (`FALSE` by
#'   default)
#' @param show_production specifies whether the position based `"full"` flow
#'   figure includes a representation of the productions (`FALSE` by default)
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
#' @param with_labels if `FALSE` (default value) names are displayed using plain
#'   texts. If `TRUE`, names are shown using labels.
#' @param ... additional parameters, see details
#' @seealso [fortify.sim()]
#' @exportS3Method ggplot2::autoplot
#' @returns a ggplot object
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' positions <- as.matrix(french_cities[1:10, c("th_longitude", "th_latitude")])
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' flows <- blvim(distances, production, 1.5, 1 / 150, attractiveness,
#'   origin_data = list(
#'     names = french_cities$name[1:10],
#'     positions = positions
#'   ),
#'   destination_data = list(
#'     names = french_cities$name[1:10],
#'     positions = positions
#'   ),
#'   bipartite = FALSE
#' )
#' ggplot2::autoplot(flows)
#' ## bar plots should be almost identical if convergence occurred
#' sim_converged(flows)
#' ggplot2::autoplot(flows, "destination")
#' ggplot2::autoplot(flows, "attractiveness")
#' ## names inclusion
#' ggplot2::autoplot(flows, "destination", with_names = TRUE) +
#'   ggplot2::coord_flip()
#' ggplot2::autoplot(flows, with_names = TRUE) +
#'   ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90))
#' ## positions
#' ggplot2::autoplot(flows, "attractiveness", with_positions = TRUE) +
#'   ggplot2::scale_size_continuous(range = c(0, 6)) +
#'   ggplot2::coord_sf(crs = "epsg:4326")
#' ggplot2::autoplot(flows, "destination",
#'   with_positions = TRUE,
#'   with_names = TRUE
#' ) +
#'   ggplot2::scale_size_continuous(range = c(0, 6)) +
#'   ggplot2::coord_sf(crs = "epsg:4326")
#' ggplot2::autoplot(flows, "destination",
#'   with_positions = TRUE,
#'   with_names = TRUE, with_labels = TRUE
#' ) +
#'   ggplot2::scale_size_continuous(range = c(0, 6)) +
#'   ggplot2::coord_sf(crs = "epsg:4326")
#' ggplot2::autoplot(flows, with_positions = TRUE) +
#'   ggplot2::scale_linewidth_continuous(range = c(0, 2)) +
#'   ggplot2::coord_sf(crs = "epsg:4326")
#' ggplot2::autoplot(flows,
#'   with_positions = TRUE,
#'   arrow = ggplot2::arrow(length = ggplot2::unit(0.025, "npc"))
#' ) +
#'   ggplot2::scale_linewidth_continuous(range = c(0, 2)) +
#'   ggplot2::coord_sf(crs = "epsg:4326")
#' ## individual flows combined with destination flows
#' ## no arrows
#' ggplot2::autoplot(flows,
#'   with_positions = TRUE,
#'   show_destination = TRUE
#' ) +
#'   ggplot2::scale_linewidth_continuous(range = c(0, 2)) +
#'   ggplot2::coord_sf(crs = "epsg:4326")
#' ## readding arrows
#' ggplot2::autoplot(flows,
#'   with_positions = TRUE,
#'   show_destination = TRUE,
#'   arrow = ggplot2::arrow(length = ggplot2::unit(0.025, "npc"))
#' ) +
#'   ggplot2::scale_linewidth_continuous(range = c(0, 2)) +
#'   ggplot2::coord_sf(crs = "epsg:4326")
#'
autoplot.sim <- function(object,
                         flows = c("full", "destination", "attractiveness"),
                         with_names = FALSE,
                         with_positions = FALSE,
                         show_destination = FALSE,
                         show_attractiveness = FALSE,
                         show_production = FALSE,
                         cut_off = 100 * .Machine$double.eps^0.5,
                         adjust_limits = FALSE,
                         with_labels = FALSE,
                         ...) {
  with_cut_off <- !missing(cut_off)
  with_adjust_limits <- !missing(adjust_limits)
  with_with_labels <- !missing(with_labels)
  with_show_dest <- !missing(show_destination)
  with_show_att <- !missing(show_attractiveness)
  with_show_prod <- !missing(show_production)
  check_autoplot_params(
    object,
    with_names,
    with_positions,
    show_destination,
    show_attractiveness,
    show_production,
    cut_off,
    adjust_limits,
    with_labels
  )
  check_dots_named(list(...))
  flows <- rlang::arg_match(flows)
  sim_autoplot_warning(
    with_names, with_positions,
    with_show_dest, with_show_att, with_show_prod,
    show_destination,
    show_attractiveness,
    show_production,
    with_cut_off, cut_off,
    with_adjust_limits, adjust_limits, with_with_labels,
    with_labels
  )
  sim_data <- fortify_sim_internal(object,
    flows = flows,
    with_names = with_names,
    with_positions = with_positions,
    cut_off = cut_off
  )
  show_points <- show_destination || show_attractiveness || show_production
  if (with_positions && flows == "full" &&
    (show_points || with_names)) {
    if (!show_points) {
      ## show destination names by default
      sim_data_point <- fortify_sim_agg(
        object, TRUE,
        FALSE, FALSE,
        cut_off
      )
    } else {
      sim_data_point <- fortify_sim_agg(
        object, show_destination,
        show_attractiveness, show_production,
        cut_off
      )
    }
  } else {
    sim_data_point <- NULL
  }
  sim_autoplot(
    object, sim_data, sim_data_point, show_points, flows, with_names, with_positions,
    cut_off,
    adjust_limits, with_labels, ...
  )
}
