sample_simplex <- function(kappas, C, active = seq_along(kappas)) {
  e <- rexp(length(active))
  res <- rep(0, length(kappas))
  res[active] <- e
  (C * res) / (sum(kappas[active] * e))
}
