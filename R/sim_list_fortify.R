#' Turn a collection of spatial interaction models into a data frame
#'
#' This function extracts from a collection of spatial interaction models
#' (represented by a `sim_list`) a data frame in a long format, with one flow
#' per row. This can be seen a collection oriented version of [fortify.sim()].
#' The resulting data frame is used by [autoplot.sim_list()] to produce summary
#' graphics.
#'
#' The data frame produced by the method depends on the values of `flows` and to
#' a lesser extent on the value of `with_names`. In all cases, the data frame
#' has a `configuration` column that identify from which spatial interaction
#' model the other values have been extracted: this is the index of the model in
#' the original `sim_list`. Depending on `flows` we have the following
#' representations:
#'
#' -  if `flows="full"`: this is the default case for which the full flow matrix
#' of each spatial interaction model is extracted. The data frame contains 4
#' columns:
#'    - `origin_idx`: identifies the origin location by its index from 1 to the number
#' of origin locations
#'    - `destination_idx`: identifies the destination location by its index from 1
#' to the number of destination locations
#'    - `flow`: the flow between the corresponding location. By default, flows
#'    are normalised by origin location (when `normalisation="origin"`): the total
#'    flows originating from each origin location is normalised to 1. If
#'     `normalisation="full"`, this normalisation is global: the sum of all flows in
#'     each model is normalised to 1. If `normalisation="none"` flows are not
#'     normalised.
#'    - `configuration`: the spatial interaction model index
#' - if `flows="destination"` or `flows="attractiveness"`, the data frame contains
#' 3 columns:
#'    - `destination`: identifies the destination location by its index from 1
#' to the number of destination locations when `with_names=FALSE` or by its
#' name.
#'    - `flow` or `attractiveness` depending on the value of `"flows"`: this contains
#' either the [destination_flow()] or the [attractiveness()] of the destination
#' location
#'    - `configuration`: the spatial interaction model index
#'
#' The normalisation operated when `flows="full"` can improve the readability
#' of the graphical representation proposed in [autoplot.sim_list()] when the
#' production constraints differ significantly from one origin location to another.
#'
#' @param model a collection of spatial interaction models, a `sim_list`
#' @param data not used
#' @param flows  `"full"` (default),  `"destination"` or `"attractiveness"`, see
#'   details.
#' @param with_names specifies whether the extracted data frame includes
#'   location names (`FALSE` by default), see details.
#' @param normalisation when `flows="full"`, the flows can be reported without
#'    normalisation (`normalisation="none"`) or they can be normalised, either
#'    to sum to one for each origin location (`normalisation="origin"`, the default
#'    value) or to sum to one globally (`normalisation="full"`).
#' @param ... additional parameters, not used currently
#' @exportS3Method ggplot2::fortify
#' @seealso [autoplot.sim_list()]
#' @examplesIf requireNamespace("ggplot2", quietly = TRUE)
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' flows_1 <- blvim(distances, production, 1.5, 1, attractiveness)
#' flows_2 <- blvim(distances, production, 1.25, 2, attractiveness)
#' all_flows <- sim_list(list(flows_1, flows_2))
#' ggplot2::fortify(all_flows) ## somewhat similar to a row bind of sim_df results
#' ggplot2::fortify(all_flows, flows = "destination")
#' destination_names(all_flows) <- letters[1:10]
#' ggplot2::fortify(all_flows, flows = "attractiveness", with_names = TRUE)
fortify.sim_list <- function(model, data,
                             flows = c("full", "destination", "attractiveness"),
                             with_names = FALSE,
                             normalisation = c("origin", "full", "none"),
                             ...) {
  flows <- rlang::arg_match(flows)
  normalisation <- rlang::arg_match(normalisation)
  if (flows == "full") {
    fl_1 <- flows(model[[1]])
    indexes <- expand.grid(
      origin_idx = seq_len(nrow(fl_1)),
      destination_idx = seq_len(ncol(fl_1))
    )
    sim_data <- data.frame(
      origin_idx = rep(indexes$origin_idx, length(model)),
      destination_idx = rep(indexes$destination_idx, length(model)),
      flow = rep(NA, nrow(indexes) * length(model)),
      configuration = rep(seq_along(model), each = nrow(indexes))
    )
    pos <- 0
    prods <- production(model[[1]])
    total_prod <- sum(prods)
    for (k in seq_along(model)) {
      the_flow <- flows(model[[k]])
      if (normalisation == "full") {
        the_flow <- the_flow / total_prod
      } else if (normalisation == "origin") {
        the_flow <- sweep(the_flow, 1, prods, "/")
      }
      sim_data$flow[(pos + 1):(pos + nrow(indexes))] <- as.vector(the_flow)
      pos <- pos + nrow(indexes)
    }
    sim_data
  } else {
    if (flows == "destination") {
      sim_data <- grid_destination_flow(model)
    } else {
      sim_data <- grid_attractiveness(model)
    }
    sim_names <- destination_names(model)
    if (is.null(sim_names)) {
      sim_names <- as.character(seq_len(ncol(sim_data)))
      colnames(sim_data) <- sim_names
    }
    if (!with_names) {
      colnames(sim_data) <- as.character(seq_len(ncol(sim_data)))
    }
    loc_name <- ifelse(flows == "destination", "flow", "attractiveness")
    sim_data_long <- stats::reshape(as.data.frame(sim_data),
      direction = "long",
      varying = list(colnames(sim_data)),
      times = colnames(sim_data),
      timevar = "destination",
      v.names = loc_name,
      idvar = "configuration"
    )
    rownames(sim_data_long) <- NULL
    if (!with_names) {
      sim_data_long$destination <- as.integer(sim_data_long$destination)
    }
    sim_data_long
  }
}

stat_sim_list <- function(sim_data, flow_name, quantiles = c(0.05, 0.95)) {
  all_stats <- tapply(
    sim_data[[flow_name]],
    sim_data$destination,
    function(x) {
      stats::quantile(x,
        probs = c(0, quantiles[1], 0.5, quantiles[2], 1),
        names = FALSE
      )
    }
  )
  m_all_stats <- matrix(NA,
    nrow = length(all_stats),
    ncol = length(all_stats[[1]])
  )
  for (k in seq_len(ncol(m_all_stats))) {
    m_all_stats[, k] <- sapply(all_stats, function(x) x[k])
  }
  colnames(m_all_stats) <- c("min", "Q_min", flow_name, "Q_max", "max")
  m_all_stats <- as.data.frame(m_all_stats)
  m_all_stats$destination <- factor(levels(sim_data$destination),
    levels = levels(sim_data$destination)
  )
  m_all_stats
}

stat_flow_sim_list <- function(sim_data, quantiles = c(0.05, 0.95)) {
  all_stats <- tapply(
    sim_data,
    ~ origin_idx + destination_idx,
    function(x) {
      stats::quantile(x$flow,
        probs = c(0, quantiles[1], 0.5, quantiles[2], 1),
        names = FALSE
      )
    }
  )
  m_all_stats <- matrix(NA,
    nrow = length(all_stats),
    ncol = length(all_stats[[1]])
  )
  for (k in seq_len(ncol(m_all_stats))) {
    m_all_stats[, k] <- sapply(all_stats, function(x) x[k])
  }
  colnames(m_all_stats) <- c("min", "Q_min", "flow", "Q_max", "max")
  m_all_stats <- as.data.frame(m_all_stats)
  cbind(sim_data[c("origin_idx", "destination_idx")], m_all_stats)
}
