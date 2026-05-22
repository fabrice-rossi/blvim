## helper functions

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
