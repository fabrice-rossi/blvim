## ---------------------------------------------------------------------------
## 0. PRELIMINARY NOTATION
## ---------------------------------------------------------------------------

## Récupère kappa depuis l'objet sim (via sim_conversion du package)
.sim_kappa <- function(sim) {
  kappa <- sim_conversion(sim)
  if (anyNA(kappa)) {
    p <- ncol(costs(sim))
    return(rep(1.0, p))
  }
  as.numeric(kappa)
}

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
sim_potential.sim_wpc <- function(sim, kappa = NULL, ...) {
  if (is.null(kappa)) kappa <- .sim_kappa(sim)

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
sim_gradient.sim_wpc <- function(sim, kappa = NULL, ...) {
  if (is.null(kappa)) kappa <- .sim_kappa(sim)

  Z  <- unname(attractiveness(sim))
  Dj <- unname(destination_flow(sim))

  grad <- Dj / Z - kappa
  names(grad) <- destination_names(sim)
  grad
}

## ---------------------------------------------------------------------------
## 3. JACOBIAN OF G (fixed-point)
## ---------------------------------------------------------------------------

#' @export
sim_jacobian_G.sim_wpc <- function(sim, kappa = NULL, ...) {
  if (is.null(kappa)) kappa <- .sim_kappa(sim)

  P     <- .sim_P(sim)                # n x p
  Z     <- unname(attractiveness(sim))
  alpha <- return_to_scale(sim)
  X     <- unname(production(sim))
  p     <- length(Z)

  XP <- X * P                         # n x p  (broadcast X sur les lignes)

  ## --- hors-diagonale : JG_{jk} = -alpha/kappa_j * (1/Z_k) * sum_i X_i P_ij P_ik
  ## t(P) %*% XP  donne  [j,k] = sum_i P_ij * X_i P_ik  (p x p)
  JG <- -alpha * (t(P) %*% XP)       # p x p

  ## Division de chaque colonne k par Z_k
  JG <- JG / matrix(Z, p, p, byrow = TRUE)

  ## Division de chaque ligne j par kappa_j
  JG <- JG / matrix(kappa, p, p, byrow = FALSE)

  ## --- diagonale : JG_{jj} = alpha/kappa_j * (D_j - S_jj) / Z_j - 1
  Dj  <- colSums(XP)                  # = destination_flow (p)
  Sjj <- colSums(XP * P)             # = sum_i X_i P_ij^2  (p)

  diag(JG) <- alpha * (Dj - Sjj) / (kappa * Z) - 1

  dnames <- destination_names(sim)
  dimnames(JG) <- list(dnames, dnames)
  JG
}

## ---------------------------------------------------------------------------
## 4. HESSIAN OF f
## ---------------------------------------------------------------------------

#' @export
sim_hessian.sim_wpc <- function(sim,
                                kappa       = NULL,   # NULL = "prendre depuis l'objet"
                                z_min       = 1e-6,
                                active_only = FALSE,
                                threshold   = 1e-3,
                                ...) {
  if (is.null(kappa)) kappa <- .sim_kappa(sim)
  Z     <- pmax(unname(attractiveness(sim)), z_min)
  alpha <- return_to_scale(sim)
  X     <- unname(production(sim))
  P     <- .sim_P(sim)
  p     <- length(Z)

  H <- matrix(0.0, p, p)

  for (j in seq_len(p)) {
    Pj  <- P[, j]
    Dj  <- sum(X * Pj)
    sat <- sum(X * Pj^2)
    H[j, j] <- kappa[j] / Z[j]^2 * ((alpha - 1) * Dj - alpha * sat)
    for (m in seq_len(p)[-j])
      H[j, m] <- -kappa[j] * alpha / (Z[j] * Z[m]) * sum(X * Pj * P[, m])
  }

  H <- (H + t(H)) / 2

  dnames <- destination_names(sim)
  dimnames(H) <- list(dnames, dnames)

  ## Restriction aux villes actives si demandé
  if (active_only) {
    actifs <- which(unname(attractiveness(sim)) > threshold)
    H <- H[actifs, actifs, drop = FALSE]
  }

  H
}
