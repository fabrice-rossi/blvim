create_locations <- function(nprod, ndest, seed = 0, symmetric = FALSE) {
  if (symmetric & nprod != ndest) {
    cli::cli_abort(
      c("symmetric settings must have the same number of production and destination locations",
        "x" = "{.val {nprod}} (production) is different from {.val {ndest}} (destination)"
      )
    )
  }
  withr::local_seed(seed)
  if (symmetric) {
    positions <- matrix(rnorm(nprod * 2), ncol = 2)
    distances <- as.matrix(dist(positions))
    pos_prod <- positions
    pos_dest <- positions
  } else {
    pos_prod <- matrix(rnorm(nprod * 2), ncol = 2)
    pos_dest <- matrix(rnorm(ndest * 2), ncol = 2)
    distances <- as.matrix(dist(rbind(pos_prod, pos_dest)))[1:nprod, (nprod + 1):(nprod + ndest)]
  }
  dimnames(distances) <- NULL
  d_scale <- median(distances[distances > 0])
  production <- runif(nrow(pos_prod), min = 0.1, max = 2)
  attractiveness <- runif(nrow(pos_dest), min = 1, max = 2)
  list(
    costs = distances, X = production, Z = attractiveness, pp = pos_prod,
    pd = pos_dest, scale = d_scale
  )
}
