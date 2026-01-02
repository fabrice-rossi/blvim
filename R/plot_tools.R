## tools for graphical representations

## turns a collection of values into a collection of intervals. If the sorted
## values in x are a, b, c, the output is x_0, (a+b)/2, (b+c)/2, x_1
## with x_0=a-(b-a)/2 and x_1=c+(b+c)/2
to_rect <- function(x, inverse = FALSE) {
  if (inverse) {
    x <- 1 / x
  }
  xu <- sort(unique(x))
  xi <- match(x, xu)
  if (length(xu) == 1) {
    delta <- abs(xu) * 0.5
    list(min = rep(xu - delta, length(x)), max = rep(xu + delta, length(x)))
  } else {
    xcenter <- (xu[-length(xu)] + xu[2:length(xu)]) / 2
    xmin <- c(2 * xu[1] - xcenter[1], xcenter)
    xmax <- c(xcenter, 2 * xu[length(xu)] - xcenter[length(xcenter)])
    list(min = xmin[xi], max = xmax[xi])
  }
}

#'
#' @param op origin positions
#' @param dp destination positions
#' @param Y flow matrix
#' @param cut_off cut off threshold
#'
#' @noRd
flow_to_lines <- function(op, dp, Y, cut_off, use_names = FALSE) {
  x_df <- expand.grid(x = op[, 1], xend = dp[, 1])
  y_df <- expand.grid(y = op[, 2], yend = dp[, 2])
  if (use_names) {
    dim_names <- colnames(op)
    if (!is.null(dim_names)) {
      names(x_df)[1] <- dim_names[1]
      names(y_df)[1] <- dim_names[2]
    }
  }
  pre <- cbind(x_df, y_df, flow = as.vector(Y))
  pre[pre$flow >= cut_off, ]
}

# this function is introduced only to ease mocking in tests
has_ggrepel <- function() {
  rlang::is_installed("ggrepel")
}
