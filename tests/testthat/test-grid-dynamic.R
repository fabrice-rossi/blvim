test_that("grid_blvim computes the models it is expected to compute", {
  config <- create_locations(25, 20, seed = 8)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.05, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 10000,
    precision = .Machine$double.eps^0.5
  )
  params <- expand.grid(alpha = alphas, beta = betas)
  for (k in 1:nrow(params)) {
    a_model <- blvim(config$costs,
      config$X,
      params$alpha[k],
      params$beta[k],
      config$Z,
      iter_max = 10000,
      precision = .Machine$double.eps^0.5
    )
    expect_equal(flows(models[[k]]), flows(a_model))
    expect_equal(attractiveness(models[[k]]), attractiveness(a_model))
  }
})

test_that("grid_blvim obeys to iteration control", {
  config <- create_locations(25, 20, seed = 8)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.05, 0.5, length.out = 4)
  for (k in seq(500, 5000, by = 500)) {
    models <- grid_blvim(config$costs,
      config$X,
      alphas,
      betas,
      config$Z,
      iter_max = k,
      precision = .Machine$double.eps^0.5
    )
    all_iterations <- sapply(models, sim_iterations)
    expect_true(all(all_iterations <= k + 1))
    all_converged <- sapply(models, function(x) x$converged)
    expect_true(all(all_converged == (all_iterations <= k)))
  }
})
