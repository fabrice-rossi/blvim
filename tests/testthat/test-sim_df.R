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
  names_before <- names(models_df)
  ## standard modification data.frame style
  models_df$renyi <- grid_diversity(models, "renyi", 3)
  expect_true(is_sim_df(models_df))
  expect_equal(models_df$renyi, grid_diversity(models, "renyi", 3))
  expect_equal(names(models_df), c(names_before, "renyi"))
  ## extraction without the sim column
  models_df_nosim <- models_df[c(1:3)]
  expect_true(is_df_not_sim_df(models_df_nosim))
  ## extraction with the sim column
  models_df_sim <- models_df[c("sim", "alpha")]
  expect_true(is_sim_df(models_df_sim))
  ## replacing sim by a non sim_list
  models_df_nosim <- models_df
  models_df_nosim$sim <- NULL
  expect_true(is_df_not_sim_df(models_df_nosim))
  models_df_nosim <- models_df
  models_df_nosim$sim <- grid_diversity(models, "renyi", 1.5)
  expect_true(is_df_not_sim_df(models_df_nosim))
  ## same thing with [[
  models_df_nosim <- models_df
  models_df_nosim[["sim"]] <- NULL
  expect_s3_class(models_df_nosim, "data.frame")
  expect_false(inherits(models_df_nosim, "sim_df"))
  models_df_nosim <- models_df
  models_df_nosim[[6]] <- NULL
  expect_true(is_df_not_sim_df(models_df_nosim))
  models_df_nosim <- models_df
  models_df_nosim[[6]] <- grid_diversity(models, "renyi", 1.5)
  expect_true(is_df_not_sim_df(models_df_nosim))
  ## replacing sim by a sim_list
  models_df_sim <- models_df
  models_df_sim$sim <- models
  expect_true(is_sim_df(models_df_sim))
  ## internal modifications
  models_df_sim <- models_df
  models_df_sim[2, 5] <- 12
  expect_true(is_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, 6] <- models
  expect_true(is_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, "sim"] <- models
  expect_true(is_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, 6] <- models_df$alpha
  expect_true(is_df_not_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, "sim"] <- models_df$beta
  expect_true(is_df_not_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, 6] <- NULL
  expect_true(is_df_not_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, "sim"] <- NULL
  expect_true(is_df_not_sim_df(models_df_sim))
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
  expect_equal(sim_column(models_df), models)
  models_df$truc <- models_df$alpha + models_df$beta
  new_names <- paste(names(models_df), "_", sample(letters, ncol(models_df)), sep = "")
  names(models_df) <- new_names
  expect_equal(names(models_df), new_names)
  expect_true(is_sim_df(models_df))
  expect_equal(sim_column(models_df), models)
  models_df_nosim <- models_df
  names(models_df_nosim) <- NULL
  expect_true(is_df_not_sim_df(models_df_nosim))
  models_df_nosim <- models_df
  names(models_df_nosim) <- c(1:5, NA, 7)
  expect_true(is_df_not_sim_df(models_df_nosim))
})
