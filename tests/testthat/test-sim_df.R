test_that("sim_df constructor error detection", {
  expect_error(sim_df(1:5))
})

test_that("sim_df creation obeys to its documentation", {
  config <- create_locations(25, 20, seed = 64)
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
  models_df <- sim_df(models)
  ## classes
  expect_s3_class(models_df, "data.frame")
  expect_s3_class(models_df, "sim_df")
  ## column names
  expect_named(models_df, c("alpha", "beta", "diversity", "iterations", "converged", "sim"), ignore.order = TRUE)
  ## sim is the last one
  expect_equal(names(models_df)[6], "sim")
  ## models (low level, maybe implemented in a more abstract way)
  expect_equal(models_df$sim$sims, models$sims)
  ## parameters
  params <- expand.grid(alpha = alphas, beta = betas)
  expect_equal(models_df$alpha, params$alpha)
  expect_equal(models_df$beta, params$beta)
  ## characteristics
  expect_equal(models_df$diversity, grid_diversity(models))
  expect_equal(models_df$iterations, sapply(models, sim_iterations))
  expect_equal(models_df$converged, sapply(models, sim_converged))
})

test_that("sim_df modifications remove or keep the sim_df class", {
  config <- create_locations(25, 20, seed = 48)
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
  models_df <- sim_df(models)
  names_before <- names(models_df)
  ## standard modification data.frame style
  models_df$renyi <- grid_diversity(models, "renyi", 3)
  expect_s3_class(models_df, "data.frame")
  expect_s3_class(models_df, "sim_df")
  expect_equal(models_df$renyi, grid_diversity(models, "renyi", 3))
  expect_equal(names(models_df), c(names_before, "renyi"))
  ## extraction without the sim column
  models_df_nosim <- models_df[c(1:3)]
  expect_s3_class(models_df_nosim, "data.frame")
  expect_false(inherits(models_df_nosim, "sim_df"))
  ## extraction with the sim column
  models_df_sim <- models_df[c("sim", "alpha")]
  expect_s3_class(models_df_sim, "data.frame")
  expect_s3_class(models_df_sim, "sim_df")
  ## replacing sim by a non sim_list
  models_df_nosim <- models_df
  models_df_nosim$sim <- NULL
  expect_s3_class(models_df_nosim, "data.frame")
  expect_false(inherits(models_df_nosim, "sim_df"))
  models_df_nosim <- models_df
  models_df_nosim$sim <- grid_diversity(models, "renyi", 1.5)
  expect_s3_class(models_df_nosim, "data.frame")
  expect_false(inherits(models_df_nosim, "sim_df"))
  ## replacing sim by a sim_list
  models_df_sim <- models_df
  models_df_sim$sim <- models
  expect_s3_class(models_df_sim, "data.frame")
  expect_s3_class(models_df_sim, "sim_df")
})
