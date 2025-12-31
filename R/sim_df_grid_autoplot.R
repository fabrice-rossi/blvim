#' Create a complete ggplot for spatial interaction models in a data frame
#'
#' This function combines spatial interaction model representations similar to
#' the ones produced by [autoplot.sim()] into a single ggplot. It provides an
#' alternative graphical representation to the one produced by
#' [autoplot.sim_df()] for collection of spatial interaction models in a
#' `sim_df` object.
#'
#' The rationale of [autoplot.sim_df()] is to display a single value for each
#' spatial interaction model (SIM) in the `sim_df` data frame. On the contrary,
#' this function produces a full graphical representation of each SIM. It is
#' therefore limited to small collection of SIMs (as specified by the `max_sims`
#' parameter which default to 25).
#'
#' Under the hood, the function uses [fortify.sim()] and shares code with
#' [autoplot.sim()] to have identical representations. It is simply based on
#' facet wrapping facility of ggplot2. In particular the `key` parameter is used
#' as the wrapping variable in the call to [ggplot2::facet_wrap()]. If not
#' specified, the function generates an `id` variable which ranges from 1 to the
#' number of SIMs in the `sim_df` data frame. If specified, it is evaluated in
#' the context of the data frame and used for wrapping. Notice that if the
#' expression evaluates to identical values for different SIMs, they will be
#' drawn on the same panel of the final figure, which may end up with
#' meaningless representations. Parameters of [ggplot2::facet_wrap()] can be set
#' using the `fw_params` parameter (in a list).
#'
#' @param sim_df a data frame of spatial interaction models, an object of class
#'   `sim_df`
#' @param key the wrapping variable which acts as an identifier for spatial
#'   interaction models
#' @inheritParams autoplot.sim
#' @param max_sims the maximum number of spatial interaction models allowed in
#'   the `sim_df` data frame
#' @param fw_params parameters for the [ggplot2::facet_wrap] call (if non
#'   `NULL`)
#' @param ... additional (named) parameters passed to [autoplot.sim()]
#' @export
#' @returns a ggplot object
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' positions <- as.matrix(french_cities[1:10, c("th_longitude", "th_latitude")])
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.1),
#'   seq(1, 3, by = 0.5) / 400,
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#'   destination_data = list(
#'     names = french_cities$name[1:10],
#'     positions = positions
#'   ),
#'   origin_data = list(
#'     names = french_cities$name[1:10],
#'     positions = positions
#'   )
#' )
#' all_flows_df <- sim_df(all_flows)
#' ## default display: flows as matrices
#' grid_autoplot(all_flows_df)
#' ## custom wrapping variable
#' grid_autoplot(all_flows_df, paste(alpha, "~", beta))
#' ## bar plots
#' grid_autoplot(all_flows_df, flows = "destination")
#' grid_autoplot(all_flows_df, flows = "attractiveness")
#' ## with positions
#' grid_autoplot(all_flows_df, flows = "destination", with_positions = TRUE) +
#'   ggplot2::scale_size_continuous(range = c(0, 2)) +
#'   ggplot2::coord_sf(crs = "epsg:4326")
#' grid_autoplot(all_flows_df, with_positions = TRUE) +
#'   ggplot2::scale_linewidth_continuous(range = c(0, 1)) +
#'   ggplot2::coord_sf(crs = "epsg:4326")
grid_autoplot <- function(sim_df, key,
                          flows = c("full", "destination", "attractiveness"),
                          with_names = FALSE,
                          with_positions = FALSE,
                          show_destination = FALSE,
                          show_attractiveness = FALSE,
                          show_production = FALSE,
                          cut_off = 100 * .Machine$double.eps^0.5,
                          adjust_limits = FALSE,
                          with_labels = FALSE,
                          max_sims = 25,
                          fw_params = NULL,
                          ...) {
  rlang::check_installed("ggplot2", reason = "to use `grid_autoplot()`")
  with_cut_off <- !missing(cut_off)
  with_adjust_limits <- !missing(adjust_limits)
  with_with_labels <- !missing(with_labels)
  with_show_dest <- !missing(show_destination)
  with_show_att <- !missing(show_attractiveness)
  with_show_prod <- !missing(show_production)
  check_autoplot_params(
    sim_column(sim_df)[[1]],
    with_names,
    with_positions,
    show_destination,
    show_attractiveness,
    show_production,
    cut_off,
    adjust_limits,
    with_labels
  )
  if (!is.numeric(max_sims) || max_sims <= 0) {
    cli::cli_abort(
      c("{.arg max_sims} must be non negative number",
        "x" = "{.arg max_sims} is {.val {max_sims}}"
      )
    )
  }
  if (!inherits(sim_df, "sim_df")) {
    cli::cli_abort("{.arg sim_df} must be a {.cls sim_df} object")
  }
  if (nrow(sim_df) > max_sims) {
    cli::cli_abort("Too many spatial interaction models
({.val {nrow(sim_df)}} > {.arf max_sims} = {.val {max_sims}})")
  }
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
  expr <- rlang::enquo(key)
  if (rlang::quo_is_missing(expr)) {
    val <- seq_len(nrow(sim_df))
    val_name <- "id"
  } else {
    val <- rlang::eval_tidy({{ expr }}, sim_df)
    val_name <- rlang::as_label(expr)
  }
  pre_data <- lapply(
    sim_column(sim_df), fortify_sim_internal,
    flows,
    with_names,
    with_positions, cut_off
  )
  final_df <- combine_df(pre_data, val, val_name)
  show_points <- show_destination || show_attractiveness || show_production
  if (with_positions && flows == "full" &&
    (show_points || with_names)) {
    pre_data_point <- lapply(
      sim_column(sim_df),
      function(x) {
        fortify_sim_agg(
          x,
          show_destination,
          show_attractiveness, show_production,
          cut_off
        )$data
      }
    )
    final_point <- list(
      data = combine_df(pre_data_point, val, val_name),
      flows = colnames(pre_data_point[[1]])[3]
    )
    ## fix the name if needed
    colnames(final_point$data)[3] <- final_point$flows
  } else {
    final_point <- NULL
  }
  pre <- sim_autoplot(
    sim_column(sim_df)[[1]], final_df, final_point, show_points, flows, with_names,
    with_positions, cut_off, adjust_limits,
    with_labels, ...
  )
  fw_parameters <- list(facets = ggplot2::vars(.data[[val_name]]))
  if (!is.null(fw_params)) {
    fw_parameters <- c(fw_parameters, fw_params)
  }
  pre +
    do.call(ggplot2::facet_wrap, fw_parameters)
}
