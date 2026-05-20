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
## point the last with K active cities, just before the primary bifurcation.
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
                                 kappa      = rep(1, ncol(costs(sim))),
                                 beta_start = NULL,
                                 phi_start  = NULL,
                                 tol        = 1e-10,
                                 max_iter   = 500L,
                                 verbose    = FALSE) {

  if (!requireNamespace("nleqslv", quietly = TRUE))
    stop("Package 'nleqslv' required.")

  # --- PREPARATION DES DONNEES ---
  alpha  <- return_to_scale(sim)
  C_full <- costs(sim)
  X_full <- unname(production(sim))
  dnames <- destination_names(sim)
  K      <- length(dnames)

  # 1. Initialisation des variables d'état (Warm-start)
  Z0    <- pmax(unname(attractiveness(sim)), 1e-6)
  beta0 <- if (!is.null(beta_start)) beta_start else inverse_cost(sim)

  # 2. Gestion du vecteur propre de référence (Ancrage)
  # On calcule phi_ref une seule fois pour fixer la branche
  if (!is.null(phi_start)) {
    phi_ref <- phi_start
  } else {
    H0      <- blv_hessian(sim, kappa)
    eig0    <- eigen(H0, symmetric = TRUE)
    phi_ref <- eig0$vectors[, 1]
  }
  # Normalisation de sécurité de la référence
  phi_ref <- phi_ref / sqrt(sum(phi_ref^2))

  # On identifie l'indice de la ville "pivot" (ex: Brussels)
  idx_ref <- which.max(abs(phi_ref))
  val_ref <- phi_ref[idx_ref]

  # --- LE SYSTEME AUGMENTE DE KUZNETSOV ---
  F_aug <- function(u) {
    Z    <- u[seq_len(K)]
    beta <- u[K + 1L]
    phi  <- u[K + 1L + seq_len(K)]

    # Protections numériques
    if (!is.finite(beta) || beta <= 0 || any(Z <= 0))
      return(rep(1e8, 2L * K + 1L))

    # Calcul de l'état stationnaire (Z, beta)
    s <- static_blvim(
      costs = C_full, X = X_full, alpha = alpha, beta = beta,
      Z = Z, bipartite = FALSE
    )

    # Bloc 1 : Équilibre des flux (K équations)
    D   <- unname(destination_flow(s))
    F_v <- kappa * D / Z - 1.0

    # Bloc 2 : Singularité du Hessien (H * phi = 0) (K équations)
    H_A  <- blv_hessian(s, kappa)
    Hphi <- as.vector(H_A %*% phi)

    # Bloc 3 : L'ANCRAGE CHIRURGICAL (1 équation scalaire)
    # On force la composante de la ville pivot à rester stable.
    # Cela fixe la norme ET le signe de phi.
    F_norm <- phi[idx_ref] - val_ref

    c(F_v, Hphi, F_norm)
  }

  # --- RESOLUTION ---
  u0 <- c(Z0, beta0, phi_ref)

  sol <- nleqslv::nleqslv(
    x       = u0,
    fn      = F_aug,
    method  = "Newton",
    global  = "dbldog", # Stratégie "Double Dogleg" pour éviter les sauts brutaux
    control = list(maxit         = max_iter,
                   ftol          = tol,
                   xtol          = tol,
                   allowSingular = TRUE)
  )

  converged <- sol$termcd %in% c(1L, 2L, 3L)

  # --- EXTRACTION ET POST-TRAITEMENT ---
  Z_c    <- sol$x[seq_len(K)]
  beta_c <- sol$x[K + 1L]
  phi    <- sol$x[K + 1L + seq_len(K)]

  # On normalise proprement pour l'utilisateur final (max amplitude = 1)
  phi_norm <- phi / max(abs(phi))
  # Sécurité signe : la ville la plus attractive doit être positive
  if (phi_norm[which.max(Z_c)] < 0) phi_norm <- -phi_norm

  list(
    beta_c       = beta_c,
    beta_c_inv   = 1.0 / beta_c,
    Z_c          = setNames(Z_c, dnames),
    phi          = setNames(phi_norm, dnames),
    direction    = setNames(ifelse(phi_norm > 0, "emerging", "retracting"), dnames),
    converged    = converged,
    residual     = sqrt(sum(sol$fvec^2)),
    termcd       = sol$termcd
  )
}


## ---------------------------------------------------------------------------
## 8. FONCTION PLOT
## ---------------------------------------------------------------------------
plot_blv_bifurcation <- function(sim,
                                 kappa = rep(1, ncol(costs(sim))),
                                 threshold = 1e-3) {

  # 1. Calcul interne (Appel à ta fonction robuste)
  # On s'assure que le système augmenté tourne sur la simulation fournie
  res <- blv_augmented_1param(sim, kappa = kappa)

  if (!res$converged) {
    stop("Le système augmenté n'a pas convergé.
          Vérifiez que sim est proche d'une bifurcation.")
  }

  # 2. Préparation des données pour ggplot (Tidying)
  df_phi <- data.frame(
    dest   = names(res$phi),
    phi    = as.numeric(res$phi),
    type   = res$direction,
    Z_c    = as.numeric(res$Z_c)
  ) %>%
    mutate(dest = reorder(dest, phi)) # Tri pour le graphique

  # 3. Construction du graphique
  ggplot(df_phi, aes(x = dest, y = phi, fill = type)) +
    geom_col(alpha = 0.8) +
    coord_flip() +
    scale_fill_manual(values = c("emerging" = "#E41A1C", "retracting" = "#377EB8")) +
    labs(
      title = "Signature spectrale de la bifurcation",
      subtitle = paste("Localisation critique : beta_c^-1 =", round(res$beta_c_inv, 2)),
      x = "Destinations",
      y = "Amplitude du mode propre (phi)",
      fill = "Dynamique"
    ) +
    theme_minimal()
}


## ---------------------------------------------------------------------------
## 8. FONCTION CONTINUATION BIFURCATION
## ---------------------------------------------------------------------------
## =============================================================================
## blv_continue_bifurcation_v2 — version corrigée
##
## Correction :
##   À chaque alpha, on RECONSTRUIT le warm-start propre :
##     (a) Cold-start Z=1 à un beta sous-critique (last_beta * 0.95)
##         pour ressortir sur la branche DISPERSÉE stable.
##     (b) Approche fine du seuil par scan local de lambda_max(H) sur Z*(beta).
##     (c) Newton (blv_augmented_1param) à partir de ce point bien placé.
##
## =============================================================================
## --- Helper : trouve le dernier beta_inv pour lequel lambda_max(H) < 0
## sur l'équilibre cold-start Z=1, en partant d'un beta_inv_ref donné.
## Renvoie le sim_blvim correspondant (point juste sous-critique).
.find_subcritical_sim <- function(C, X, alpha, kappa,
                                  beta_inv_ref,
                                  search_window = c(0.7, 1.05),
                                  n_grid = 25) {

  K <- ncol(C)

  ## Grille de beta_inv autour du beta_inv_ref (en majorité inférieurs)
  bi_grid <- seq(beta_inv_ref * search_window[1],
                 beta_inv_ref * search_window[2],
                 length.out = n_grid)

  ## Cold-start Z=1 partout (grid_blvim fait ça en une passe)
  sims <- grid_blvim(
    costs   = C,
    X       = X,
    alphas  = alpha,
    betas   = 1 / bi_grid,
    Z       = rep(1, K),
    bipartite = FALSE,
    epsilon = 0.05,
    iter_max = 80000,
    precision = 1e-8
  )

  ## Calcul lmax(H) et n_active à chaque beta
  lmax_vec <- numeric(length(bi_grid))
  nact_vec <- integer(length(bi_grid))
  for (i in seq_along(bi_grid)) {
    s        <- sims[[i]]
    Z_i      <- unname(attractiveness(s))
    nact_vec[i] <- sum(Z_i > 1e-3)
    H        <- blv_hessian(s, kappa)
    lmax_vec[i] <- max(eigen(H, symmetric = TRUE, only.values = TRUE)$values)
  }

  ## Sélection : dernier point AVEC n_active == K ET lmax < 0
  ## (recette warm-start de blv_augmented_1param, mais alpha-adaptative)
  ok <- which(nact_vec == K & lmax_vec < 0)

  if (length(ok) == 0L) {
    ## Le seuil est au-delà de notre fenêtre : on retourne le plus grand bi sous K-actif
    stop(sprintf("Pas de point sous-critique trouvé dans la fenêtre [%.1f, %.1f]",
                 bi_grid[1], bi_grid[length(bi_grid)]))
  }

  best_i <- max(ok)
  list(
    sim       = sims[[best_i]],
    beta_inv  = bi_grid[best_i],
    lmax      = lmax_vec[best_i],
    n_active  = nact_vec[best_i]
  )
}


## ---------------------------------------------------------------------------
## blv_continue_bifurcation_v2
##   alpha_range : grille d'alpha à parcourir (monotone, croissant ou décroissant)
##   beta_inv_init : guess initial pour beta_c^-1 (utilisé pour cadrer le 1er scan)
##   kappa : vecteur de poids (défaut 1)
##   verbose : trace
## ---------------------------------------------------------------------------
blv_continue_bifurcation <- function(C, X,
                                     alpha_range,
                                     beta_inv_init = 100,
                                     kappa = NULL,
                                     verbose = TRUE) {

  K <- ncol(C)
  if (is.null(kappa)) kappa <- rep(1, K)

  results   <- list()
  beta_inv_guess <- beta_inv_init

  for (i in seq_along(alpha_range)) {
    a <- alpha_range[i]

    ## (1) Trouve un point sous-critique propre via cold-start scan
    sub <- tryCatch(
      .find_subcritical_sim(C, X, a, kappa, beta_inv_ref = beta_inv_guess),
      error = function(e) NULL
    )

    if (is.null(sub)) {
      ## La fenêtre était trop étroite : on l'élargit
      sub <- .find_subcritical_sim(C, X, a, kappa,
                                   beta_inv_ref = beta_inv_guess,
                                   search_window = c(0.4, 1.2),
                                   n_grid = 40)
    }

    ## (2) Newton sur le système augmenté avec ce sim bien placé
    res <- tryCatch(
      blv_augmented_1param(sub$sim, kappa = kappa),
      error = function(e) NULL
    )

    if (is.null(res) || !res$converged) {
      warning(sprintf("Echec a alpha = %.3f", a))
      next
    }

    ## (3) Sanity check : on doit avoir lambda_max(H) ~ 0 sur Z_c.
    ##     On reconstruit le sim au point critique et on vérifie.
    sim_at_bc <- static_blvim(
      costs = C, X = X, alpha = a, beta = res$beta_c,
      Z = res$Z_c, bipartite = FALSE
    )
    H_check   <- blv_hessian(sim_at_bc, kappa)
    lmax_chk  <- max(eigen(H_check, symmetric = TRUE, only.values = TRUE)$values)

    if (abs(lmax_chk) > 1e-3) {
      warning(sprintf(
        "alpha = %.3f : Newton converge mais lambda_max(H) = %.3e != 0. Resultat suspect.",
        a, lmax_chk
      ))
      next
    }

    results[[i]] <- data.frame(
      alpha         = a,
      beta_c_inv    = res$beta_c_inv,
      lmax_at_bc    = lmax_chk,
      emerging_city = names(res$phi)[which.max(res$phi)],
      stringsAsFactors = FALSE
    )

    if (verbose) {
      cat(sprintf("  [OK] alpha = %.3f | beta_c^-1 = %.3f | lmax=%.1e | %s\n",
                  a, res$beta_c_inv, lmax_chk, results[[i]]$emerging_city))
    }

    ## (4) Mise à jour du guess pour le prochain alpha
    beta_inv_guess <- res$beta_c_inv
  }

  do.call(rbind, results)
}


