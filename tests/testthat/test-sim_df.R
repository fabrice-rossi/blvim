test_that("sim_df constructor error detection", {
  expect_error(sim_df(1:5))
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
  expect_error(sim_df(models, sim_column = "alpha"))
  expect_error(sim_column(models))
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
  expect_true(is_sim_df(models_df))
  ## column names
  expect_named(models_df, c("alpha", "beta", "diversity", "iterations", "converged", "sim"), ignore.order = TRUE)
  ## sim is the last one
  expect_equal(names(models_df)[6], "sim")
  ## models (low level, maybe implemented in a more abstract way)
  expect_equal(as.list(models_df$sim), as.list(models))
  models_df <- sim_df(models, sim_column = "my_sims")
  expect_true(is_sim_df(models_df))
  expect_named(models_df, c("alpha", "beta", "diversity", "iterations", "converged", "my_sims"), ignore.order = TRUE)
  expect_equal(names(models_df)[6], "my_sims")
  expect_equal(as.list(models_df$my_sims), as.list(models))
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
  test_sim_df_modifications(models_df, models)
})

test_that("sim_df names handling", {
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
  models_df <- sim_df(models, sim_column = "a column")
  test_sim_df_names(models_df, models)
})

test_that("sim_df modifications keep the data frame consistent", {
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
  alphas_2 <- seq(1.5, 2.25, by = 0.25)
  betas_2 <- 1 / seq(0.15, 0.6, length.out = 4)
  models_2 <- grid_blvim(config$costs,
    config$X,
    alphas_2,
    betas_2,
    config$Z,
    iter_max = 10000,
    precision = .Machine$double.eps^0.5
  )
  models_df_2 <- sim_df(models_2)
  ## name based
  models_df_1_to_2 <- models_df
  models_df_1_to_2$sim <- models_2
  expect_equal(models_df_2, models_df_1_to_2)
  ## bracket based
  models_df_1_to_2 <- models_df
  models_df_1_to_2[["sim"]] <- models_2
  expect_equal(models_df_2, models_df_1_to_2)
  models_df_1_to_2 <- models_df
  models_df_1_to_2[, 6] <- models_2
  expect_equal(models_df_2, models_df_1_to_2)
  models_df_1_to_2 <- models_df
  models_df_1_to_2[, "sim"] <- models_2
  expect_equal(models_df_2, models_df_1_to_2)
  ## core column modification are forbidden
  expect_no_condition(models_df$alpha <- models_df$alpha)
  expect_error(models_df$alpha <- models_df_2$alpha)
  for (col in c(
    "alpha", "beta", "diversity", "iterations",
    "converged"
  )) {
    ## ok
    expect_no_condition(models_df[[col]] <- models_df[[col]])
    ## ko
    new_val <- sample(models_df[[col]][-1], nrow(models_df), replace = TRUE)
    expect_false(identical(new_val, models_df[[col]]))
    expect_error(models_df[[col]] <- new_val)
  }
})
