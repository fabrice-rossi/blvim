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
