sample_simplex <- function(kappas, C, active = seq_along(kappas)) {
  e <- rexp(length(active))
  res <- rep(0, length(kappas))
  res[active] <- e
  (C * res) / (sum(kappas[active] * e))
}

make_blvim_test_result <- function(Z, iter = 2L, diagnostic = NULL) {
  list(
    Y = matrix(c(Z[1], Z[2]), nrow = 1L),
    Z = matrix(Z, ncol = 1L),
    iter = iter,
    diagnostic = diagnostic
  )
}
