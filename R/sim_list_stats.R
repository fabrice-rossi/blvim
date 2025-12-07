#' Compute the "median" of a collection of spatial interaction models
#'
#' This function computes all pairwise distances between spatial interaction
#' models (SIMs) of its `x` parameter, using `sim_distance()` with the specified
#' distance parameters. Then it returns the "median" of the collection defined
#' as the SIM that is in average the closest to all the other SIMs. Tie breaking
#' uses the order of the SIMs in the collection.
#'
#' As distance calculation can be slow in a large collection of SIMs, the
#' distance object can be returned as a `distances` attribute of the median SIM
#' by setting the `return_distances` parameter to `TRUE`. In addition, the
#' returned SIM has always two attributes:
#' -  `index` gives the index of the mode in the original `sim_list`
#' -  `distortion` gives the mean of the distances from the median SIM to all
#' the other SIMs
#'
#' @param x a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param na.rm not used
#' @param return_distances should the distances computed to find the median be
#'   returned as a `distances` attribute of the resulting object? (defaults to
#'   `FALSE`)
#' @param ... additional parameters (not used currently)
#'
#' @inheritParams sim_distance
#' @returns a spatial interaction model, an object of class `sim` with
#'   additional attributes
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.1),
#'   seq(1, 3, by = 0.5) / 400,
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000,
#' )
#' all_flows_median <- median(all_flows)
#' attr(all_flows_median, "index")
#' attr(all_flows_median, "distortion")
#' median(all_flows, flows = "destination")
#' median(all_flows, flows = "attractiveness")
median.sim_list <- function(x,
                            na.rm = FALSE, ## nolintr
                            flows = c("full", "destination", "attractiveness"),
                            method = c("euclidean"),
                            return_distances = FALSE,
                            ...) {
  if (length(x) > 1) {
    xd <- sim_distance(x, flows, method)
    xdm <- as.matrix(xd)
    sum_of_dist <- colSums(xdm)
    best_index <- which.min(sum_of_dist)
    pre <- x[[best_index]]
    attr(pre, "index") <- as.integer(best_index)
    attr(pre, "distortion") <- as.numeric(sum_of_dist[best_index]) / length(x)
  } else {
    pre <- x[[1]]
    xd <- stats::as.dist(0)
    attr(pre, "index") <- 1L
    attr(pre, "distortion") <- 0
  }
  if (return_distances) {
    attr(pre, "distances") <- xd
  }
  pre
}

quantile_sim_data <- function(sim_data, flows, probs) {
  prob_names <- paste0(format(100 * probs, trim = TRUE), "%")
  if (flows == "full") {
    all_stats <- tapply(
      sim_data,
      ~ origin_idx + destination_idx,
      function(x) {
        stats::quantile(x$flow,
          probs = probs,
          names = FALSE
        )
      }
    )
    res <- expand.grid(
      origin_idx = unique(sim_data$origin_idx),
      destination_idx = unique(sim_data$destination_idx)
    )
    nb_col <- 2
  } else {
    flow_name <- ifelse(flows == "destination", "flow", "attractiveness")
    all_stats <- tapply(
      sim_data[[flow_name]],
      sim_data$destination,
      function(x) {
        stats::quantile(x,
          probs = probs,
          names = FALSE
        )
      }
    )
    res <- data.frame(destination = as.integer(names(all_stats)))
    nb_col <- 1
  }
  for (k in seq_len(length(probs))) {
    res[[as.character(k)]] <- sapply(all_stats, function(x) x[k])
  }
  names(res) <- c(names(res)[seq_len(nb_col)], prob_names)
  res
}

#' Compute quantiles of the flows in a collection of spatial interaction models
#'
#' The function computes the specified quantiles for individual or aggregated
#' flows in a collection of spatial interaction models.
#'
#' The exact behaviour depends on the value of `flows`. In all cases, the
#' function returns a data frame. The data frame has one column per quantile,
#' named after the quantile using a percentage based named, as in the default
#' [stats::quantile()]. For a graphical representation of those quantiles, see
#' [autoplot.sim_list()].
#'
#' -  if `flows="full"`: this is the default case in which the function
#' computes for each pair of origin \eqn{o} and destination \eqn{d} locations
#' the quantiles of the distribution of the flow from \eqn{o} to \eqn{d} in the
#' collection of models (the flows maybe normalised before quantile
#' calculations, depending on the value of `normalisation`). In addition to the
#' quantiles, the data frame has two columns:
#'    - `origin_idx`: identifies the origin location by its index from 1 to the number
#' of origin locations;
#'    - `destination_idx`: identifies the destination location by its index from 1
#' to the number of destination locations.
#' -  if `flows="destination"`, the function computes quantiles for each
#' destination \eqn{d} location of the distribution of its incoming flow
#' ([destination_flow()]) in the collection of models. In addition to the
#' quantiles, the data frame has one column `destination` that identifies the
#' destination location by its index from 1 to the number of destination
#' locations.
#' - if `flows="attractiveness"`, the function computes quantiles for each
#' destination \eqn{d} location of the distribution of its attractiveness
#' ([attractiveness()]) in the collection of models. In addition to the
#' quantiles, the data frame has one column `destination` that identifies the
#' destination location by its index from 1 to the number of destination
#' locations.
#'
#' @param x a collection of spatial interaction models, a `sim_list`
#' @param flows `"full"` (default),  `"destination"` or `"attractiveness"`, see
#'   details.
#' @param probs numeric vector of probabilities with values in \eqn{[0,1]}.
#' @param normalisation when `flows="full"`, the flows are used as is, that
#'  without normalisation (`normalisation="none"`, default case) or they can be
#'   normalised prior the calculation of the quantiles, either to sum to one
#'   for each origin location (`normalisation="origin"`) or to sum to one globally
#'   (`normalisation="full"`). This is useful for [autoplot.sim_list()].
#' @param ... additional parameters, not used currently
#' @returns a date frame, see details
#' @seealso [fortify.sim_list()] [autoplot.sim_list()]
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- log(french_cities$area[1:10])
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.1),
#'   seq(1, 3, by = 0.5) / 400,
#'   attractiveness,
#'   bipartite = FALSE,
#'   epsilon = 0.1, iter_max = 1000
#' )
#' head(quantile(all_flows))
#' head(quantile(all_flows, flows = "destination"))
#' head(quantile(all_flows,
#'   flows = "attractiveness",
#'   probs = c(0.1, 0.3, 0.6, 0.9)
#' ))
quantile.sim_list <- function(x,
                              flows = c(
                                "full", "destination",
                                "attractiveness"
                              ),
                              probs = seq(0, 1, 0.25),
                              normalisation = c("none", "origin", "full"),
                              ...) {
  flows <- rlang::arg_match(flows)
  with_normalisation <- !missing(normalisation)
  normalisation <- rlang::arg_match(normalisation)
  if (flows != "full") {
    if (with_normalisation) {
      cli::cli_warn(
        c("{.arg normalisation} is not used when {.arg flows}
is not {.str full}",
          "!" = "{.arg flows} is {.val {flows}} and
{.arg normalisation} is {.val {normalisation}}"
        )
      )
    }
    sim_data <- fortify.sim_list(x,
      data = NULL, flows = flows,
    )
  } else {
    sim_data <- fortify.sim_list(x,
      data = NULL, flows = flows,
      normalisation = normalisation
    )
  }
  quantile_sim_data(sim_data, flows, probs)
}
