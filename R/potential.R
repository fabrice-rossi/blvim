## ---------------------------------------------------------------------------
## 0. PRELIMINARY NOTATION
## ---------------------------------------------------------------------------

.sim_P <- function(sim) {
  flows(sim) / production(sim)   # n x p, P_ij = Y_ij / X_i
}

.sim_S <- function(sim) {
  Z    <- unname(attractiveness(sim))
  C    <- costs(sim)
  beta <- inverse_cost(sim)
  alpha <- return_to_scale(sim)
  W    <- exp(-beta * C)
  rowSums(W * outer(rep(1, nrow(C)), Z^alpha))   # length n
}

## ---------------------------------------------------------------------------
## 1. POTENTIAL FUNCTION
## ---------------------------------------------------------------------------

#' @export
sim_potential.sim_wpc <- function(sim, kappa = rep(1, ncol(costs(sim))), ...) {
  X     <- unname(production(sim))
  alpha <- return_to_scale(sim)
  Z     <- unname(attractiveness(sim))
  S     <- .sim_S(sim)
  sum(X * log(S)) / alpha - sum(kappa * Z)
}


## ---------------------------------------------------------------------------
## 2. GRADIENT OF f
## ---------------------------------------------------------------------------

#' @export
sim_gradient.sim_wpc <- function(sim, kappa = rep(1, ncol(costs(sim))), ...) {
  Z  <- unname(attractiveness(sim))
  Dj <- unname(destination_flow(sim))
  Gj <- Dj - kappa * Z

  grad <- Gj / Z
  names(grad) <- destination_names(sim)
  grad
}

## ---------------------------------------------------------------------------
## 3. JACOBIAN OF G (fixed-point)
## ---------------------------------------------------------------------------

#' @export
sim_jacobian_G.sim_wpc <- function(sim, kappa = rep(1, ncol(costs(sim))), ...) {
  P     <- .sim_P(sim)
  Z     <- unname(attractiveness(sim))
  alpha <- return_to_scale(sim)
  X     <- unname(production(sim))
  p     <- ncol(costs(sim))

  XP  <- X * P                              # n x p
  JG  <- -alpha * (t(P) %*% XP)            # off-diagonal numerator
  JG  <- JG / matrix(Z, p, p, byrow = TRUE) # divide columns by Z_k

  ## Corrected diagonal: alpha/Z_j * (D_j - sum_i X_i P_ij^2) - kappa_j
  Dj       <- colSums(XP)                   # = destination_flow
  Sjj      <- colSums(XP * P)              # = sum_i X_i P_ij^2
  diag(JG) <- alpha * (Dj - Sjj) / Z - kappa

  dnames <- destination_names(sim)
  dimnames(JG) <- list(dnames, dnames)
  JG
}

## ---------------------------------------------------------------------------
## 4. HESSIAN OF f
## ---------------------------------------------------------------------------

#' @export
sim_hessian.sim_wpc <- function(sim, kappa = rep(1, ncol(costs(sim))), z_min = 1e-6, ...) {
  Z     <- pmax(unname(attractiveness(sim)), z_min)
  alpha <- return_to_scale(sim)
  X     <- unname(production(sim))
  P     <- .sim_P(sim)              # n x p shares P_ij = Y_ij / X_i
  p     <- length(Z)

  H <- matrix(0.0, p, p)

  for (j in seq_len(p)) {
    Pj  <- P[, j]
    Dj  <- sum(X * Pj)              # = destination_flow[j]
    sat <- sum(X * Pj^2)            # saturation term

    H[j, j] <- kappa[j] / Z[j]^2 * ((alpha - 1) * Dj - alpha * sat)

    for (m in seq_len(p)[-j])
      H[j, m] <- -kappa[j] * alpha / (Z[j] * Z[m]) * sum(X * Pj * P[, m])
  }

  ## Symmetrise (should already be symmetric by construction)
  H <- (H + t(H)) / 2

  dnames <- destination_names(sim)
  dimnames(H) <- list(dnames, dnames)
  H
}

