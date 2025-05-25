#' Create a complete ggplot for a collection of spatial interaction models
#'
#' This function uses a tile plot from ggplot2 to display a single numerical
#' value for each of the parameter pairs used to produce the collection of
#' spatial interaction models.
#'
#' The value to display is selected with the `statistics` parameter and defaults
#' to the Shannon diversity with `"shannon"` (see [diversity()]). Othervalues
#' include:
#'
#' - `"renyi"` (coupled with the `order` parameter) for Rényi diversity (see
#' [diversity()])
#' - `"terminals"` (coupled with the `definition` parameter) for the number of
#' terminals when the origin and destination locations are identical (see
#' [terminals()])
#' - `"iterations"` for the number of iterations the `[blvim()]` model took
#' to converge
#'
#' The horizontal axis is used by default for the cost scale parameter, that is
#' \eqn{1/\beta}. This is in general easier to read than using the inverse cost
#' scale. The `inverse` parameter can be used to turn off this feature. The
#' vertical axis is used by default for the return to scale parameter.
#'
#' @param object a collection of spatial interaction models, an object of class
#'   `sim_list`
#' @param inverse whether to use the cost scale parameter (default)
#' @param statistics the value to display, defaulting to `"shannon"`, see
#'   details
#' @param ... additional parameters (not used currently)
#'
#' @inheritParams diversity
#' @inheritParams terminals
#' @seealso [grid_blvim()], [diversity()], [terminals()]
#' @returns a ggplot object
#' @exportS3Method ggplot2::autoplot
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' all_flows <- grid_blvim(
#'   distances,
#'   production,
#'   c(1.25, 1.5, 1.75),
#'   1 / c(0.25, 0.5, 1),
#'   attractiveness
#' )
#' ggplot2::autoplot(all_flows)
autoplot.sim_list <- function(object,
                              statistics = c("shannon", "renyi", "terminals", "iterations"),
                              inverse = TRUE,
                              order = 1,
                              definition = c("ND", "RW"),
                              ...) {
  statistics <- rlang::arg_match(statistics)
  xc <- to_rect(object$betas, inverse)
  yc <- to_rect(object$alphas)
  sim_data <- data.frame(xmin = xc$min, xmax = xc$max, ymin = yc$min, ymax = yc$max)
  if (statistics == "shannon") {
    sname <- "Shannon diversity"
    val <- sapply(object, diversity)
  } else if (statistics == "renyi") {
    sname <- paste0("Renyi diversity (order = ", order, ")")
    val <- sapply(object, diversity, definition = "renyi", order = order)
  } else if (statistics == "terminals") {
    sname <- "Number of terminals"
    val <- sapply(object, function(x) {
      length(terminals(x, definition))
    })
  } else {
    sname <- "Iterations"
    val <- sapply(object, function(x) {
      x$iteration
    })
  }
  sim_data[sname] <- val
  pre <- ggplot2::ggplot(sim_data, ggplot2::aes(
    xmin = .data[["xmin"]],
    xmax = .data[["xmax"]],
    ymin = .data[["ymin"]],
    ymax = .data[["ymax"]],
    fill = .data[[sname]]
  )) +
    ggplot2::geom_rect()
  if (inverse) {
    pre + ggplot2::labs(x = quote(1 / beta), y = quote(alpha))
  } else {
    pre + ggplot2::labs(x = quote(beta), y = quote(alpha))
  }
}
