## helper functions

.sim_S <- function(sim) {
  Z <- attractiveness(sim)
  C <- costs(sim)
  beta <- inverse_cost(sim)
  alpha <- return_to_scale(sim)
  W <- exp(-beta * C)
  W %*% (Z^alpha)
}

## potential

#' @export
sim_potential.sim_blvim <- function(sim, ...) {
  X <- production(sim)
  alpha <- return_to_scale(sim)
  Z <- attractiveness(sim)
  S <- .sim_S(sim)
  kappa <- sim_conversion(sim)

  sum(X * log(S)) / alpha - sum(kappa * Z)
}

## Jacobian of the fixed point map

#' @export
sim_fp_jacobian.sim_blvim <- function(sim, ...) {
  kappa <- sim_conversion(sim)
  alpha <- return_to_scale(sim)
  beta <- inverse_cost(sim)
  Z <- attractiveness(sim)
  X <- production(sim)
  C <- costs(sim)
  W <- exp(-beta * C)

  Z_alpha <- Z^alpha
  Z_alpha_1 <- Z^(alpha - 1)

  ZkZj <- outer(Z_alpha, Z_alpha_1)
  WZalpha <- W %*% Z_alpha
  WZalpha_sq <- (WZalpha)^2
  Wnorm <- sweep(W, 1, WZalpha, "/")
  XWnorm <- sweep(Wnorm, 1, X, "*")
  coreval <- crossprod(XWnorm, Wnorm)
  JG <- -alpha * ZkZj * coreval
  diag(JG) <- diag(JG) - kappa + alpha * Z_alpha_1 * colSums(XWnorm)

  dnames <- destination_names(sim)
  dimnames(JG) <- list(dnames, dnames)
  JG
}
