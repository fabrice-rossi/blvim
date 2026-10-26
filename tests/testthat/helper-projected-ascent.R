fixture_ascent <- function(p = 6, n = p, seed = 3, alpha = 1.4, beta = 4,
                           kappa = NULL) {
  withr::with_seed(seed, {
    costs <- matrix(runif(n * p, 0, 2), n, p)
    if (is.null(kappa)) {
      kappa <- runif(p, 0.5, 2)
    }
    list(
      costs = costs,
      X = runif(n, 1, 3),
      alpha = alpha,
      beta = beta,
      Z = runif(p, 0.5, 1.5),
      kappa = kappa
    )
  })
}

run_ascent <- function(fixture, ...) {
  blv_gradient(
    fixture$costs, fixture$X, fixture$alpha, fixture$beta, fixture$Z,
    fixture$kappa, ...
  )
}

# Direct R computation of the projected-ascent quantities at Z.
reference_ascent <- function(fixture, Z) {
  X_total <- sum(fixture$X)
  U <- fixture$kappa * Z / X_total
  W <- exp(-fixture$beta * fixture$costs)
  W <- sweep(W, 2, fixture$kappa^fixture$alpha, "/")
  A <- drop(W %*% U^fixture$alpha)
  gradient <- U^(fixture$alpha - 1) * drop(crossprod(W, fixture$X / A))
  lambda <- sum(gradient * U)
  list(
    U = U,
    gap = max(gradient) - lambda,
    gap_scale = max(1, abs(lambda), max(abs(gradient))),
    flows = sweep(W, 2, U^fixture$alpha, "*") * (fixture$X / A)
  )
}
