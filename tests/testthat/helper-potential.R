fp_jacobian_non_zero <- function(sim) {
  kappa <- sim_conversion(sim)

  P <- flows(sim) / production(sim)
  Z <- attractiveness(sim)
  alpha <- return_to_scale(sim)
  X <- production(sim)
  p <- length(Z)

  XP <- X * P # n x p  (broadcast X on rows)

  ## --- off diagonal terms: JG_{jk} = -alpha* (1/Z_k) * sum_i X_i P_ij P_ik
  ## t(P) %*% XP [j,k] = sum_i P_ij * X_i P_ik  (p x p)
  JG <- -alpha * (t(P) %*% XP) # p x p

  ## column "normalisation"
  JG <- sweep(JG, 1, Z, "/")

  ## --- diagonal terms: JG_{jj} = alpha*(D_j - S_jj) / Z_j - kappa_j
  Dj <- colSums(XP) # = destination_flow (p)
  Sjj <- colSums(XP * P) # = sum_i X_i P_ij^2  (p)

  diag(JG) <- alpha * (Dj - Sjj) / Z - kappa

  dnames <- destination_names(sim)
  dimnames(JG) <- list(dnames, dnames)
  t(JG)
}

fp_value <- function(sim, Z) {
  Y <- we_oc(costs(sim), production(sim), return_to_scale(sim), inverse_cost(sim), Z)
  colSums(Y) - sim_conversion(sim) * Z
}

num_fp_jacobian <- function(sim, eps = 1e-8) {
  Z <- attractiveness(sim)
  JG <- matrix(0, ncol = length(Z), nrow = length(Z))
  for (k in seq_along(Z)) {
    Zp <- Z
    Zp[k] <- Zp[k] + eps
    Jzp <- fp_value(sim, Zp)
    Jzm <- fp_value(sim, Z)
    JG[, k] <- (Jzp - Jzm) / (eps)
  }
  JG
}
