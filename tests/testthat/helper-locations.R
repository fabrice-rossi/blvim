create_locations <- function(nprod, ndest, seed = 0) {
  withr::local_seed(seed)
  pos_prod <- matrix(rnorm(nprod * 2), ncol = 2)
  pos_dest <- matrix(rnorm(ndest * 2), ncol = 2)
  distances <- as.matrix(dist(rbind(pos_prod, pos_dest)))[1:nprod, (nprod + 1):(nprod + ndest)]
  production <- runif(nrow(pos_prod), min = 0.1, max = 2)
  attractiveness <- runif(nrow(pos_dest), min = 1, max = 2)
  list(costs = distances, X = production, Z = attractiveness, pp = pos_prod, pd = pos_dest)
}
