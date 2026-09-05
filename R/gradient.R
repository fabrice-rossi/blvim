## only exported for testing purposes
project <- function(Y, kappa, X_tot, tol = 1e-9, max_iter = 50L) {
  project_weighted_simplex(as.double(Y), as.double(kappa), as.double(X_tot), tol, max_iter)[, 1]
}
