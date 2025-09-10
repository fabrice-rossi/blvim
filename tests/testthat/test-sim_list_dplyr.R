test_that("sim_df are supported by dplyr select, slice and pull", {
  config <- create_locations(20, 30, seed = 18)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  origin_positions(models) <- config$pp
  destination_positions(models) <- config$pd
  on <- paste(sample(letters, 20, replace = TRUE), 1:20, sep = "_")
  origin_names(models) <- on
  dn <- paste(sample(letters, 30, replace = TRUE), 1:30, sep = "_")
  destination_names(models) <- dn
  models_df <- sim_df(models)
  ## basic type preservation or suppression in select
  models_df_select <- dplyr::select(models_df, sim)
  expect_true(is_sim_df(models_df_select))
  models_df_select <- dplyr::select(models_df, alpha | sim)
  expect_true(is_sim_df(models_df_select))
  models_df_select <- dplyr::select(models_df, alpha | beta)
  expect_true(is_df_not_sim_df(models_df_select))
  ## pull keeps the AsIs class (as $)
  expect_equal(dplyr::pull(models_df, sim), models, ignore_attr = TRUE)

  ## basic type preservation in slice
  models_df_slice <- dplyr::slice(models_df, 1:3)
  expect_true(is_sim_df(models_df_slice))
  some_models <- dplyr::slice_sample(models_df, n = 8)
  expect_true(is_sim_df(some_models))
  ## location data preservation in slice
  some_models <- dplyr::pull(some_models, sim)
  expect_equal(location_names(some_models), location_names(models_df$sim))
  expect_equal(location_positions(some_models), location_positions(models_df$sim))
})

test_that("sim_df are supported by dplyr joins", {
  config <- create_locations(20, 30, seed = 52)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  origin_positions(models) <- config$pp
  destination_positions(models) <- config$pd
  on <- paste(sample(letters, 20, replace = TRUE), 1:20, sep = "_")
  origin_names(models) <- on
  dn <- paste(sample(letters, 30, replace = TRUE), 1:30, sep = "_")
  destination_names(models) <- dn
  models_df <- sim_df(models)
  to_add <- data.frame(iterations = unique(models_df$iterations))
  to_add$val <- runif(nrow(to_add))
  models_df_joined <- dplyr::inner_join(models_df, to_add, by = "iterations")
  expect_true(is_sim_df(models_df_joined))
  expect_equal(location_names(models_df_joined$sim), location_names(models_df$sim))
  expect_equal(location_positions(models_df_joined$sim), location_positions(models_df$sim))
})

test_that("sim_df are supported by dplyr mutate, distinct and group_by", {
  config <- create_locations(20, 30, seed = 38)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  origin_positions(models) <- config$pp
  destination_positions(models) <- config$pd
  on <- paste(sample(letters, 20, replace = TRUE), 1:20, sep = "_")
  origin_names(models) <- on
  dn <- paste(sample(letters, 30, replace = TRUE), 1:30, sep = "_")
  destination_names(models) <- dn
  models_df <- sim_df(models)
  models_df_mutated <- dplyr::mutate(models_df, X = iterations / 10)
  expect_true(is_sim_df(models_df_mutated))
  expect_equal(location_names(models_df_mutated$sim), location_names(models_df$sim))
  expect_equal(location_positions(models_df_mutated$sim), location_positions(models_df$sim))
  models_df_subset <- dplyr::distinct(models_df, iterations, .keep_all = TRUE)
  expect_true(is_sim_df(models_df_subset))
  models_df_subset <- dplyr::distinct(dplyr::group_by(models_df, iterations), beta, .keep_all = TRUE)
  expect_true(is_sim_df(models_df_subset))
  models_df_grp <- dplyr::group_by(models_df, iterations)
  expect_true(is_sim_df(models_df_grp))
  models_df_ungrp <- dplyr::ungroup(models_df_grp)
  expect_true(is_sim_df(models_df_ungrp))
  ## group and mutate
  models_df_grp_mut <- dplyr::mutate(models_df_grp, iterations = 10 * iterations)
  expect_true(is_sim_df(models_df_grp_mut))
  models_df_grp_mut_slice <- dplyr::slice_sample(models_df_grp_mut, n = 1)
  expect_true(is_sim_df(models_df_grp_mut_slice))
})
