## ---------------------------------------------------------------------------
## 0. NOTATION PRELIMINAIRE
## ---------------------------------------------------------------------------

.blv_P <- function(sim) {
  flows(sim) / production(sim)   # n x p, P_ij = Y_ij / X_i
}

.blv_S <- function(sim) {
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

blv_potential <- function(sim, kappa = rep(1, ncol(costs(sim)))) {
  X     <- unname(production(sim))
  alpha <- return_to_scale(sim)
  Z     <- unname(attractiveness(sim))
  S     <- .blv_S(sim)
  sum(X * log(S)) / alpha - sum(kappa * Z)
}


## ---------------------------------------------------------------------------
## 2. GRADIENT OF f (unconstrained)
## ---------------------------------------------------------------------------

blv_gradient <- function(sim, kappa = rep(1, ncol(costs(sim)))) {
  Z  <- unname(attractiveness(sim))
  Dj <- unname(destination_flow(sim))
  Gj <- Dj - kappa * Z

  grad <- Gj / Z
  names(grad) <- destination_names(sim)
  grad
}

## ---------------------------------------------------------------------------
## 3. JACOBIAN OF G (fixed-point residual)
## ---------------------------------------------------------------------------

blv_jacobian_G <- function(sim, kappa = rep(1, ncol(costs(sim)))) {
  P <- .blv_P(sim)
  Z     <- unname(attractiveness(sim))
  alpha <- return_to_scale(sim)
  X     <- unname(production(sim))
  p <- ncol(costs(sim))


  XP  <- X * P
  JG  <- -alpha * (t(P) %*% XP)
  JG  <- JG / matrix(Z, p, p, byrow = TRUE)

  diag(JG) <- diag(JG) + alpha * colSums(XP) / Z - kappa

  dnames <- destination_names(sim)
  dimnames(JG) <- list(dnames, dnames)
  JG
}

## ---------------------------------------------------------------------------
## 4. HESSIAN OF f
## ---------------------------------------------------------------------------

blv_hessian <- function(sim, kappa = rep(1, ncol(costs(sim)))) {
  Z  <- unname(attractiveness(sim))
  JG <- blv_jacobian_G(sim, kappa)

  H <- diag(1 / Z) %*% JG
  H <- (H + t(H)) / 2

  dnames <- destination_names(sim)
  dimnames(H) <- list(dnames, dnames)
  H
}


