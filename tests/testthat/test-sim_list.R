test_that("sim_list is a list", {
  config <- create_locations(20, 30, seed = 4)
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
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  expect_snapshot(models)
})

test_that("sim_list is converted correctly to a data frame", {
  config <- create_locations(25, 25, seed = 10)
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
  models_df <- as.data.frame(models)
  expect_equal(nrow(models_df), length(models))
  for (k in seq_along(models)) {
    a_model <- models[[k]]
    expect_equal(a_model, models_df$model[[k]])
    ## redundant
    expect_equal(return_to_scale(a_model), models_df$alpha[k])
    expect_equal(inverse_cost(a_model), models_df$beta[k])
    expect_equal(diversity(a_model), models_df$diversity[k])
    expect_equal(terminals(a_model), models_df$terminals[[k]])
  }
  models_df_nm <- as.data.frame(models, models = FALSE)
  expect_null(models_df_nm$model)
  ## no terminal
  config <- create_locations(25, 30, seed = 10)
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
  models_df <- as.data.frame(models)
  expect_null(models_df$terminals)
})
