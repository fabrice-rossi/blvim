#' Create a complete ggplot for a spatial interaction model
#'
#' This function represents graphical the flows of a spatial interaction model,
#' in different direct or aggregated forms.
#'
#' The graphical representation depends on the value of `flows`:
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
#' attractivenesses of the destination locations (as given by [attractiveness()]).
#' This is interesting for dynamic models where those values are updated during
#' the iterations (see [blvim()] for details). When the calculation has
#' converged (see [sim_converged()]), both `"destination"` and `"attractiveness"` graphics should
#' be almost identical.
#'
#'
#' @param object a spatial interaction model object
#' @param flows  `"full"` (default),  `"destination"` or `"attractiveness"`, see details.
#' @param ... additional parameters (not used currently)
#'
#' @exportS3Method ggplot2::autoplot
#' @returns a ggplot object
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' flows <- blvim(distances, production, 1.5, 4, attractiveness)
#' ggplot2::autoplot(flows)
#' ## bar plots should be almost identical if convergence occured
#' sim_converged(flows)
#' ggplot2::autoplot(flows, "destination")
#' ggplot2::autoplot(flows, "attractiveness")
autoplot.sim <- function(object,
                         flows = c("full", "destination", "attractiveness"),
                         ...) {
  flows <- rlang::arg_match(flows)
  if (flows == "destination" || flows == "attractiveness") {
    if (flows == "destination") {
      dest_f <- destination_flow(object)
      sim_data <- data.frame(
        destination = seq_along(dest_f),
        flow = dest_f
      )
      pre <- ggplot2::ggplot(sim_data, ggplot2::aes(
        x = .data[["destination"]],
        y = .data[["flow"]]
      ))
    } else {
      attra <- attractiveness(object)
      sim_data <- data.frame(
        destination = seq_along(attra),
        attractiveness = attra
      )
      pre <- ggplot2::ggplot(sim_data, ggplot2::aes(
        x = .data[["destination"]],
        y = .data[["attractiveness"]]
      ))
    }
    pre +
      ggplot2::geom_col() +
      ggplot2::theme(
        panel.grid.major.x = ggplot2::element_blank(),
        panel.grid.minor.x = ggplot2::element_blank(),
        axis.ticks.x = ggplot2::element_blank(),
        axis.text.x = ggplot2::element_blank()
      )
  } else {
    full_f <- flows(object)
    sim_data <- expand.grid(
      origin = rev(1:nrow(full_f)),
      destination = 1:ncol(full_f)
    )
    sim_data$flow <- as.vector(full_f)
    ggplot2::ggplot(sim_data, ggplot2::aes(
      y = .data[["origin"]],
      x = .data[["destination"]],
      fill = .data[["flow"]]
    )) +
      ggplot2::geom_raster() +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        axis.text = ggplot2::element_blank()
      )
  }
}
