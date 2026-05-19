## ---------------------------------------------------------------------------
## 1. CONSTRAINED GRADIENT (restricted to the budget tangent space)
## ---------------------------------------------------------------------------

blv_gradient_constrained <- function(sim, kappa = rep(1, ncol(costs(sim)))) {
  grad       <- blv_gradient(sim, kappa)
  kappa_unit <- kappa / sqrt(sum(kappa^2))
  grad - sum(grad * kappa_unit) * kappa_unit
}

## ---------------------------------------------------------------------------
## 2. CONSTRAINED JACOBIEN (restricted to the budget tangent space)
## ---------------------------------------------------------------------------

blv_jacobian_G_constrained <- function(sim, kappa = rep(1, ncol(costs(sim)))) {
  JG         <- blv_jacobian_G(sim, kappa)
  p          <- ncol(costs(sim))
  kappa_unit <- kappa / sqrt(sum(kappa^2))
  PT         <- diag(p) - outer(kappa_unit, kappa_unit)
  JGT        <- PT %*% JG %*% PT
  JGT        <- (JGT + t(JGT)) / 2
  dnames     <- destination_names(sim)
  dimnames(JGT) <- list(dnames, dnames)
  JGT
}

## ---------------------------------------------------------------------------
## 3. CONSTRAINED HESSIAN (restricted to the budget tangent space)
## ---------------------------------------------------------------------------

blv_hessian_constrained <- function(sim, kappa = rep(1, ncol(costs(sim)))) {
  H <- blv_hessian(sim, kappa)
  p <- ncol(costs(sim))
  kappa_unit <- kappa / sqrt(sum(kappa^2))
  PT <- diag(p) - outer(kappa_unit, kappa_unit)

  HT <- PT %*% H %*% PT
  ## enforce symmetry
  HT <- (HT + t(HT)) / 2

  dnames <- destination_names(sim)
  dimnames(HT) <- list(dnames, dnames)
  HT
}
