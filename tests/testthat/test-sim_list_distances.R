test_that("sim_distance works as expected", {
  config <- create_locations(20, 30, seed = 16)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  withr::local_seed(4)
  ## error case
  expect_error(sim_distance(list()))
  ## full flows
  m_dist <- as.matrix(sim_distance(models, "full"))
  from_to <- sample(seq_along(models), 8)
  from <- from_to[1:4]
  to <- from_to[5:8]
  for (k in from) {
    ff_from <- as.vector(flows(models[[k]]))
    for (l in to) {
      ff_to <- as.vector(flows(models[[l]]))
      expect_equal(dist(rbind(ff_from, ff_to))[1], m_dist[k, l])
    }
  }
  ## destination flows
  m_dist <- as.matrix(sim_distance(models, "destination"))
  from_to <- sample(seq_along(models), 8)
  from <- from_to[1:4]
  to <- from_to[5:8]
  for (k in from) {
    ff_from <- destination_flow(models[[k]])
    for (l in to) {
      ff_to <- destination_flow(models[[l]])
      expect_equal(dist(rbind(ff_from, ff_to))[1], m_dist[k, l])
    }
  }
  ## full flows
  m_dist <- as.matrix(sim_distance(models, "attractiveness"))
  from_to <- sample(seq_along(models), 8)
  from <- from_to[1:4]
  to <- from_to[5:8]
  for (k in from) {
    ff_from <- attractiveness(models[[k]])
    for (l in to) {
      ff_to <- attractiveness(models[[l]])
      expect_equal(dist(rbind(ff_from, ff_to))[1], m_dist[k, l])
    }
  }
})
