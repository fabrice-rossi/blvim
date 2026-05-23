## helper functions

.sim_P <- function(sim) {
  flows(sim) / production(sim) # n x p, P_ij = Y_ij / X_i
}

.sim_S <- function(sim) {
  Z <- attractiveness(sim)
  C <- costs(sim)
  beta <- inverse_cost(sim)
  alpha <- return_to_scale(sim)
  W <- exp(-beta * C)
  rowSums(W * outer(rep(1, nrow(C)), Z^alpha)) # length n
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

  P <- .sim_P(sim) # n x p
  Z <- attractiveness(sim)
  alpha <- return_to_scale(sim)
  X <- production(sim)
  p <- length(Z)

  XP <- X * P # n x p  (broadcast X on rows)

  ## --- off diagonal terms: JG_{jk} = -alpha/kappa_j * (1/Z_k) * sum_i X_i P_ij P_ik
  ## t(P) %*% XP [j,k] = sum_i P_ij * X_i P_ik  (p x p)
  JG <- -alpha * (t(P) %*% XP) # p x p

  ## column "normalisation"
  JG <- sweep(JG, 1, Z, "/")

  ## Row "normalisation"
  JG <- sweep(JG, 2, kappa, "/")

  ## --- diagonal terms: JG_{jj} = alpha/kappa_j * (D_j - S_jj) / Z_j - 1
  Dj <- colSums(XP) # = destination_flow (p)
  Sjj <- colSums(XP * P) # = sum_i X_i P_ij^2  (p)

  diag(JG) <- alpha * (Dj - Sjj) / (kappa * Z) - 1

  dnames <- destination_names(sim)
  dimnames(JG) <- list(dnames, dnames)
  JG
}
