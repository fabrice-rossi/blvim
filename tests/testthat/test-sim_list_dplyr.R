test_that("sim_df are supported by dplyr select and slice", {
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
  ## basic type preservation in select and slice
  expect_s3_class(
    dplyr::pull(dplyr::select(models_df, sim), sim),
    class(models)
  )
  expect_s3_class(
    dplyr::pull(dplyr::slice(models_df, 1:3), sim),
    class(models)
  )
  ## location data preservation in splice
  some_models <- dplyr::pull(dplyr::slice_sample(models_df, n = 8), sim)
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
  expect_s3_class(
    models_df_joined$sim,
    class(models)
  )
  expect_equal(location_names(models_df_joined$sim), location_names(models_df$sim))
  expect_equal(location_positions(models_df_joined$sim), location_positions(models_df$sim))
})
