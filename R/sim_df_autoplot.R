#' Create a complete ggplot for a spatial interaction models data frame
#'
#' This function uses a tile plot from ggplot2 to display a single value for
#' each of the parameter pairs used to produce the collection of spatial
#' interaction models.
#'
#' The value to display is specified via an expression evaluated in the context
#' of the data frame. It defaults to the diversity as computed by [diversity()].
#'
#' The horizontal axis is used by default for the cost scale parameter, that is
#' \eqn{1/\beta}. This is in general easier to read than using the inverse cost
#' scale. The `inverse` parameter can be used to turn off this feature. The
#' vertical axis is used by default for the return to scale parameter.
#'
#' @param object a data frame of spatial interaction models, an object of class
#'   `sim_df`
#' @param value the value to display, default to `diversity` if unspecified
#' @param inverse whether to use the cost scale parameter (default)
#' @param ... additional parameters (not used currently)
#' @seealso [sim_df()]
#' @returns a ggplot object
#' @exportS3Method ggplot2::autoplot
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' all_flows <- grid_blvim(distances, production, seq(1.05, 1.55, by = 0.05),
#'   seq(1, 3, by = 0.5),
#'   attractiveness,
#'   epsilon = 0.1, iter_max = 1000
#' )
#' all_flows_df <- sim_df(all_flows)
#'
#' ## default display: Shannon diversity
#' ggplot2::autoplot(all_flows_df)
#' ## iterations
#' ggplot2::autoplot(all_flows_df, iterations)
#' ## we leverage non standard evaluation to compute a different diversity
#' ggplot2::autoplot(all_flows_df, diversity(sim, "RW"))
#' ## we can also add variables
#' all_flows_df["Nystuen & Dacey"] <- diversity(all_flows_df$sim, "ND")
#' ggplot2::autoplot(all_flows_df, `Nystuen & Dacey`)
autoplot.sim_df <- function(object,
                            value,
                            inverse = TRUE,
                            ...) {
  expr <- rlang::enquo(value)
  if (rlang::quo_is_missing(expr)) {
    val <- object$diversity
    val_name <- "diversity"
  } else {
    val <- rlang::eval_tidy(expr, object)
    val_name <- rlang::as_label(expr)
  }
  xc <- to_rect(object$beta, inverse)
  yc <- to_rect(object$alpha)
  sim_data <- data.frame(xmin = xc$min, xmax = xc$max, ymin = yc$min, ymax = yc$max)
  sim_data[[val_name]] <- val
  pre <- ggplot2::ggplot(sim_data, ggplot2::aes(
    xmin = .data[["xmin"]],
    xmax = .data[["xmax"]],
    ymin = .data[["ymin"]],
    ymax = .data[["ymax"]],
    fill = .data[[val_name]]
  )) +
    ggplot2::geom_rect()
  if (inverse) {
    pre + ggplot2::labs(x = quote(1 / beta), y = quote(alpha))
  } else {
    pre + ggplot2::labs(x = quote(beta), y = quote(alpha))
  }
}
