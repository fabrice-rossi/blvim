test_that("sim_list is a list", {
  config <- create_locations(20, 30, seed = 4)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    precision = .Machine$double.eps^0.5
  )
  expect_length(models, length(alphas) * length(betas))
  expect_s3_class(models, "sim_list")
  for (k in seq_along(models)) {
    expect_s3_class(models[k], "sim_list")
    expect_s3_class(models[[k]], "sim_blvim")
    expect_equal(models[k][[1]], models[[k]])
  }
  params <- expand.grid(alpha = alphas, beta = betas)
  expect_equal(params$alpha, sapply(models, return_to_scale))
  expect_equal(params$beta, sapply(models, inverse_cost))
})

test_that("sim_list prints as expected", {
  config <- create_locations(20, 30, seed = 5)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    precision = .Machine$double.eps^0.5
  )
  expect_snapshot(models)
})
