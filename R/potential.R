## ---------------------------------------------------------------------------
## 0. PRELIMINARY NOTATION
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
## 2. GRADIENT OF f
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
## 3. JACOBIAN OF G (fixed-point)
## ---------------------------------------------------------------------------

blv_jacobian_G <- function(sim, kappa = rep(1, ncol(costs(sim)))) {
  P     <- .blv_P(sim)
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

blv_hessian <- function(sim, kappa = rep(1, ncol(costs(sim))), z_min = 1e-6) {
  Z     <- pmax(unname(attractiveness(sim)), z_min)
  alpha <- return_to_scale(sim)
  X     <- unname(production(sim))
  P     <- .blv_P(sim)              # n x p shares P_ij = Y_ij / X_i
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

## ---------------------------------------------------------------------------
## 4. ACTIVE DESTINATION SELECTION
## ---------------------------------------------------------------------------

blv_active <- function(sim, threshold = 1e-3) {
  Z      <- unname(attractiveness(sim))
  active <- Z > threshold
  names(active) <- destination_names(sim)
  active
}

## ---------------------------------------------------------------------------
## 5. GREEDY ALGORITHM — two modes
## ---------------------------------------------------------------------------
blv_greedy <- function(sim,
                       mode      = c("hessian", "jacobian"),
                       threshold = 1e-3,
                       kappa     = rep(1, ncol(costs(sim)))) {

  mode   <- match.arg(mode)
  Z      <- unname(attractiveness(sim))
  dnames <- destination_names(sim)
  p      <- length(Z)

  if (mode == "jacobian") {
    ## --- Algorithm J: threshold on Z ---
    active     <- Z > threshold
    active_idx <- which(active)

    H_full <- blv_hessian(sim, kappa)
    diag_H <- rep(NA_real_, p)
    if (any(active_idx))
      diag_H[active_idx] <- diag(H_full)[active_idx]

    idx_inactive <- which(!active)
    ord_active   <- active_idx[order(diag_H[active_idx], decreasing = TRUE)]
    ord_inactive <- idx_inactive[order(Z[idx_inactive],   decreasing = TRUE)]
    ord          <- c(ord_active, ord_inactive)

    return(data.frame(
      destination = dnames[ord],
      index       = ord,
      Z           = Z[ord],
      diag_H      = diag_H[ord],
      status      = ifelse(active[ord], "active", "inactive"),
      rank        = seq_len(p),
      lambda_max  = NA_real_,
      row.names   = NULL
    ))
  }

  ## --- Algorithm H: greedy spectral elimination ---
  H_full      <- blv_hessian(sim, kappa)
  current_idx <- seq_len(p)
  history     <- list()
  step        <- 0L
  lmax        <- NA_real_

  repeat {
    H_act <- H_full[current_idx, current_idx, drop = FALSE]
    lmax  <- max(eigen(H_act, symmetric = TRUE, only.values = TRUE)$values)

    history[[step + 1L]] <- data.frame(
      step       = step,
      n_active   = length(current_idx),
      lambda_max = lmax,
      removed    = NA_character_,
      stringsAsFactors = FALSE
    )

    if (lmax <= 0 || length(current_idx) <= 1L) break

    ## Remove destination with largest diagonal entry of H
    diag_current <- diag(H_full)[current_idx]
    worst_local  <- which.max(diag_current)
    worst_global <- current_idx[worst_local]

    history[[step + 1L]]$removed <- dnames[worst_global]
    current_idx <- current_idx[-worst_local]
    step        <- step + 1L
  }

  ## Build output — lambda_max is scalar, stored as attribute not column
  active_final <- logical(p)
  active_final[current_idx] <- TRUE
  diag_H_full  <- diag(H_full)

  idx_active   <- current_idx
  idx_inactive <- setdiff(seq_len(p), current_idx)
  ord_active   <- idx_active[order(diag_H_full[idx_active],  decreasing = TRUE)]
  ord_inactive <- idx_inactive[order(Z[idx_inactive],         decreasing = TRUE)]
  ord          <- c(ord_active, ord_inactive)

  out <- data.frame(
    destination = dnames[ord],
    index       = ord,
    Z           = Z[ord],
    diag_H      = diag_H_full[ord],
    status      = ifelse(active_final[ord], "active", "inactive"),
    rank        = seq_len(p),
    row.names   = NULL
  )

  ## lambda_max and elimination history as attributes
  attr(out, "lambda_max") <- lmax
  attr(out, "history")    <- do.call(rbind, history)

  out
}

## ---------------------------------------------------------------------------
## 6. RESTRICTED SYSTEM
## ---------------------------------------------------------------------------
blv_restricted <- function(sim,
                           mode      = c("jacobian", "hessian"),
                           threshold = 1e-3,
                           kappa     = rep(1, ncol(costs(sim))),
                           ...) {

  mode <- match.arg(mode)

  if (mode == "jacobian") {
    active_idx <- which(unname(attractiveness(sim)) > threshold)
  } else {
    g          <- blv_greedy(sim, mode = "hessian", kappa = kappa)
    active_idx <- g$index[g$status == "active"]
  }

  if (length(active_idx) == 0L)
    stop("No active destinations found.")
  if (length(active_idx) == ncol(costs(sim)))
    message("All destinations are active: restricted system equals full system.")

  C_res <- costs(sim)[active_idx, active_idx, drop = FALSE]
  Z_res <- unname(attractiveness(sim))[active_idx]
  X_res <- unname(production(sim))[active_idx]

  sim_res <- blvim(
    costs            = C_res,
    X                = X_res,
    alpha            = return_to_scale(sim),
    beta             = inverse_cost(sim),
    Z                = Z_res,
    bipartite        = FALSE,
    destination_data = list(names = destination_names(sim)[active_idx]),
    origin_data      = list(names = origin_names(sim)[active_idx]),
    ...
  )

  list(
    sim_res      = sim_res,
    active_idx   = active_idx,
    active_names = destination_names(sim)[active_idx],
    mode         = mode
  )
}
## ---------------------------------------------------------------------------
## 7. SPLIT DIRECTION — dominant eigenvector of H (active destinations only)
## ---------------------------------------------------------------------------
blv_split_direction <- function(sim,
                                threshold = 1e-3,
                                kappa     = rep(1, ncol(costs(sim)))) {
  active     <- blv_active(sim, threshold)
  active_idx <- which(active)

  if (length(active_idx) == 0L)
    stop("No active destinations (all Z <= threshold).")
  if (length(active_idx) == 1L)
    stop("Only one active destination — split direction undefined.")

  ## Hessian restricted to active subspace
  H_full <- blv_hessian(sim, kappa)
  H_act  <- H_full[active_idx, active_idx, drop = FALSE]

  ## Dominant eigenvector (H is symmetric -> eigen() returns real values)
  ## eigen() returns eigenvalues in DECREASING order -> [[1]] is lambda_max
  eig       <- eigen(H_act, symmetric = TRUE)
  lambda_max <- eig$values[1]
  psi        <- eig$vectors[, 1]

  ## Normalise so that max |psi_j| = 1  (easier to read than unit norm)
  psi <- psi / max(abs(psi))

  ## Sign convention: the emerging city (largest Z) gets a positive component
  ## If not, flip the whole vector (eigenvectors defined up to sign)
  largest_Z_local <- which.max(unname(attractiveness(sim))[active_idx])
  if (psi[largest_Z_local] < 0) psi <- -psi

  data.frame(
    destination = destination_names(sim)[active_idx],
    index       = active_idx,
    Z           = unname(attractiveness(sim))[active_idx],
    psi         = psi,
    direction   = ifelse(psi > 0, "emerging", "retracting"),
    lambda_max  = lambda_max,
    row.names   = NULL
  )
}


## =============================================================================
## WARM-START RECIPE FOR blv_augmented_1param
## How to find the correct initialisation point for the augmented system.
##
## CONTEXT
## -------
## blv_augmented_1param solves the (2K+1) Kuznetsov system on the FULL set
## of K destinations (no subspace restriction at the primary bifurcation,
## since all Z_j ~ 1 there). Newton converges only if the warm-start is very
## close to the bifurcation: ||F(u0)|| must be small, which requires both
## G(Z0, beta0) ~ 0  AND  H(Z0, beta0) * phi0 ~ 0.
##
## The second condition means lambda_max(H) must be close to 0, i.e. we
## must start near beta_c. The key insight is to take as the optimal initialisation
## point the last with K active cities, just befor the primary bifurcation.
##
##
## ALGORITHM
## ---------
## 1. Cold-start Z=1 at each beta (finds the multipolaire / dispersed branch).
##    Cold-start is essential: warm-start would follow the concentrated branch
##    after the bifurcation and never return to the dispersed branch.
##
## 2. Track n_active = #{j : Z_j > threshold} and lambda_max(H) at each point.
##
## 3. Select the point with n_active == K AND lambda_max(H) < 0, with the
##    LARGEST lambda_max (= least negative = closest to 0 from below).
##    This is the last stable multipolaire point before the primary bifurcation.
##
## IMPLEMENTATION
## --------------
## Data: eurodist (as.matrix(eurodist), NO unit conversion — used as-is).
##       alpha = 1.4, kappa = 1, K = 21 cities.
## Expected result: beta_c^-1 ~ 91.1.
##
## Code used to produce the working warm-start (beta^-1 = 91, lmax = -0.017):

## beta_inv_scan <- c(10, 20, 30, 40, 50, 60, 70, 75, 80, 85, 90,
##                    91, 92, 93, 94, 95, 100, 110, 120, 150, 200)
##
## for (i in seq_along(beta_inv_scan)) {
##   s_tmp            <- blvim(costs=C, X=X, alpha=alpha, beta=1/beta_inv_scan[i],
##                             Z=rep(1,K), bipartite=FALSE, ...)  # cold-start Z=1
##   Z_i              <- unname(attractiveness(s_tmp))
##   n_active_scan[i] <- sum(Z_i > 1e-3)
##   lmax_scan[i]     <- max(eigen(blv_hessian(s_tmp, kappa),
##                                 symmetric=TRUE, only.values=TRUE)$values)
## }
##
## full_neg <- which(n_active_scan == K & lmax_scan < 0)
## best_i   <- max(full_neg)   # last = closest to bifurcation from below
## sim_ws   <- sims_scan[[best_i]]
##
## Result at beta^-1 = 91: n_active = 21/21, lambda_max(H) = -0.017
## Newton converged in 3 iterations, ||F|| = 5.96e-11
## beta_c^-1 = 91.1024
## Brussels rank 1 in phi: PASS
##
## WHY THIS WORKS
## --------------
## - Cold-start Z=1 forces blvim onto the dispersed branch at each beta.
## - The dispersed branch is stable (lambda_max(H) < 0) until beta = beta_c.
## - At beta_c, lambda_max(H) = 0 exactly — this is the bifurcation condition.
## - The warm-start at beta^-1 = 91 (just below beta_c) gives ||F(u0)|| ~ 0.017,
##   small enough for Newton to converge quadratically in 3 steps.
## - phi_0 = dominant eigenvector of H(Z0, beta0) provides the phase normalisation.
##
## REQUIREMENTS
## ------------
## - blv_hessian must use the EXACT formula :
##   H_jj = kappa/Z_j^2 * [(alpha-1)*D_j - alpha*sum_i X_i P_ij^2]
##   NOT the approximation diag(1/Z) * J_G (only valid at Z_j = 1).
## - nleqslv package must be installed.
## - eurodist used WITHOUT unit conversion (as.matrix(eurodist)).
## =============================================================================

blv_augmented_1param <- function(sim,
                                 kappa    = rep(1, ncol(costs(sim))),
                                 tol      = 1e-10,
                                 max_iter = 500L,
                                 verbose  = FALSE) {

  if (!requireNamespace("nleqslv", quietly = TRUE))
    stop("Package 'nleqslv' required. Install with install.packages('nleqslv').")

  alpha  <- return_to_scale(sim)
  C_full <- costs(sim)
  X_full <- unname(production(sim))
  dnames <- destination_names(sim)
  K      <- length(dnames)

  ## Warm-start: Z and beta directly from sim (no subspace restriction)
  Z0    <- pmax(unname(attractiveness(sim)), 1e-6)
  beta0 <- inverse_cost(sim)

  ## phi_0: dominant eigenvector of H (unit norm for normalisation)
  H0   <- blv_hessian(sim, kappa)
  eig0 <- eigen(H0, symmetric = TRUE)
  phi0 <- eig0$vectors[, 1]
  phi0 <- phi0 / sqrt(sum(phi0^2))

  if (verbose)
    cat(sprintf("  K = %d | lambda_max(H) at start = %.6f\n",
                K, eig0$values[1]))

  ## Residual: u = (Z [K], beta [1], phi [K]), length 2K+1
  F_aug <- function(u) {
    Z    <- u[seq_len(K)]
    beta <- u[K + 1L]
    phi  <- u[K + 1L + seq_len(K)]

    if (!is.finite(beta) || beta <= 0 || any(Z <= 0))
      return(rep(1e6, 2L * K + 1L))

    ## Compute static flows at (Z, beta)
    s <- static_blvim(
      costs = C_full, X = X_full, alpha = alpha, beta = beta,
      Z = Z, bipartite = FALSE
    )

    ## Block 1: grad_f_j = kappa_j * D_j / Z_j - 1 = 0
    D   <- unname(destination_flow(s))
    F_v <- kappa * D / Z - 1.0

    ## Block 2: H(Z, beta) * phi = 0
    H_A  <- blv_hessian(s, kappa)
    Hphi <- as.vector(H_A %*% phi)

    ## Block 3: phi' phi_0 = 1
    c(F_v, Hphi, sum(phi * phi0) - 1.0)
  }

  u0 <- c(Z0, beta0, phi0)
  if (verbose)
    cat(sprintf("  ||F(u0)|| = %.3e\n", sqrt(sum(F_aug(u0)^2))))

  sol <- nleqslv::nleqslv(
    x       = u0,
    fn      = F_aug,
    method  = "Newton",
    control = list(maxit         = max_iter,
                   ftol          = tol,
                   xtol          = tol,
                   allowSingular = TRUE,
                   trace         = if (verbose) 1L else 0L)
  )

  converged <- sol$termcd %in% c(1L, 2L, 3L)
  residual  <- sqrt(sum(sol$fvec^2))

  if (!converged)
    warning("blv_augmented_1param: did not converge (termcd=", sol$termcd,
            ", ||F||=", formatC(residual, format = "e", digits = 2), ")")

  Z_c    <- sol$x[seq_len(K)]
  beta_c <- sol$x[K + 1L]
  phi    <- sol$x[K + 1L + seq_len(K)]
  phi    <- phi / max(abs(phi))
  if (phi[which.max(Z_c)] < 0) phi <- -phi

  list(
    beta_c       = beta_c,
    beta_c_inv   = 1.0 / beta_c,
    Z_c          = setNames(Z_c, dnames),
    phi          = setNames(phi, dnames),
    direction    = setNames(ifelse(phi > 0, "emerging", "retracting"), dnames),
    converged    = converged,
    termcd       = sol$termcd,
    residual     = residual
  )
}
