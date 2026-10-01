## only exported for testing purposes
R_project_simplex <- function(Y, tol = 1e-9, max_iter = 50L) {
  project_simplex(as.double(Y), tol, max_iter)[, 1]
}

R_project_weighted_simplex <- function(Y, kappa, X_tot, tol = 1e-9, max_iter = 50L) {
  project_weighted_simplex(
    as.double(Y), as.double(kappa), sum(kappa^2),
    as.double(X_tot), tol, max_iter
  )[, 1]
}
