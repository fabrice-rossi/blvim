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
#' meaningless representations. Parameters of [ggplot2::facet_wrap()] can
#' be set using the `fw_params` parameter (in a list).
#'
#' @param sim_df a data frame of spatial interaction models, an object of class
#'   `sim_df`
#' @param key the wrapping variable which acts as an identifier for spatial
#'   interaction models
#' @inheritParams autoplot.sim
#' @param max_sims the maximum number of spatial interaction models allowed in
#'   the `sim_df` data frame
#' @param fw_params parameters for the [ggplot2::facet_wrap] call (if non `NULL`)
#' @param ... additional parameters passed to [autoplot.sim()]
#' @export
#' @returns a ggplot object
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.1),
#'   seq(1, 3, by = 0.5),
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#'   destination_data = list(names = LETTERS[1:10], positions = positions),
#'   origin_data = list(names = LETTERS[1:10], positions = positions),
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
#'   ggplot2::scale_size_continuous(range = c(0, 2))
#' grid_autoplot(all_flows_df, with_positions = TRUE) +
#'   ggplot2::scale_linewidth_continuous(range = c(0, 1))
grid_autoplot <- function(sim_df, key,
                          flows = c("full", "destination", "attractiveness"),
                          with_names = FALSE,
                          with_positions = FALSE,
                          cut_off = 100 * .Machine$double.eps^0.5,
                          adjust_limits = FALSE,
                          max_sims = 25,
                          fw_params = NULL,
                          ...) {
  rlang::check_installed("ggplot2", reason = "to use `grid_autoplot()`")
  if (!inherits(sim_df, "sim_df")) {
    cli::cli_abort("{.arg sim_df} must be a {.cls sim_df} object")
  }
  if (nrow(sim_df) > max_sims) {
    cli::cli_abort("Too many spatial interaction models ({.val {nrow(sim_df)}} > {.arf max_sims} = {.val {max_sims}})")
  }
  flows <- rlang::arg_match(flows)
  expr <- rlang::enquo(key)
  if (rlang::quo_is_missing(expr)) {
    val <- seq_len(nrow(sim_df))
    val_name <- "id"
  } else {
    val <- rlang::eval_tidy({{ expr }}, sim_df)
    val_name <- rlang::as_label(expr)
  }
  pre_data <- lapply(sim_column(sim_df), fortify.sim,
    data = NULL, flows,
    with_positions, cut_off
  )
  final_df <- combine_df(pre_data, val, val_name)
  pre <- sim_autoplot(
    sim_column(sim_df)[[1]], final_df, flows, with_names,
    with_positions, adjust_limits, ...
  )
  fw_parameters <- list(facets = ggplot2::vars(.data[[val_name]]))
  if (!is.null(fw_params)) {
    fw_parameters <- c(fw_parameters, fw_params)
  }
  pre +
    do.call(ggplot2::facet_wrap, fw_parameters)
}
