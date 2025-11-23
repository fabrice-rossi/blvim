test_that("grid_var_autoplot works as expected", {
  config <- create_locations(15, 15, seed = 2828, symmetric = TRUE)
  alphas <- seq(1.25, 1.5, by = 0.125)
  betas <- 1 / seq(0.1, 0.5, length.out = 6)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 750,
    precision = .Machine$double.eps^0.5,
  )
  destination_positions(models) <- config$pd
  models_df <- sim_df(models)
  models_df$group <- as.factor(sample(c(0, 1, 2), nrow(models_df), replace = TRUE))
  vdiffr::expect_doppelganger(
    "Default flow matrices iter",
    \() print(grid_var_autoplot(models_df, iterations,
      normalisation = "origin"
    ))
  )
  vdiffr::expect_doppelganger(
    "Default flow matrices conv",
    \() print(grid_var_autoplot(models_df, converged,
      normalisation = "origin"
    ))
  )
  vdiffr::expect_doppelganger(
    "Default flow matrices group",
    \() print(grid_var_autoplot(models_df, group,
      normalisation = "origin"
    ))
  )
  vdiffr::expect_doppelganger(
    "Default flow matrices conv nfull",
    \() print(grid_var_autoplot(models_df, converged, normalisation = "full"))
  )
  vdiffr::expect_doppelganger(
    "Default flow matrices iter names",
    \() print(grid_var_autoplot(models_df, iterations,
      with_names = TRUE,
      normalisation = "origin"
    ))
  )
  destination_names(models_df$sim) <- sample(letters, 15)
  vdiffr::expect_doppelganger(
    "Default flow matrices conv null names",
    \() print(grid_var_autoplot(models_df, converged,
      with_names = TRUE,
      normalisation = "origin"
    ))
  )
  vdiffr::expect_doppelganger(
    "Default destination iter",
    \() print(grid_var_autoplot(models_df, iterations, flow = "destination"))
  )
  vdiffr::expect_doppelganger(
    "Default attr iter",
    \() print(grid_var_autoplot(models_df, converged, flow = "attractiveness"))
  )
  vdiffr::expect_doppelganger(
    "Default destination iter names",
    \() print(grid_var_autoplot(models_df, iterations,
      flow = "destination",
      with_names = TRUE
    ))
  )
  destination_names(models_df$sim) <- NULL
  vdiffr::expect_doppelganger(
    "Default attr conv names",
    \() print(grid_var_autoplot(models_df, converged,
      flow = "attractiveness",
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Default destination iter pos",
    \() print(grid_var_autoplot(models_df, iterations,
      flow = "destination",
      with_positions = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Default att iter pos ct",
    \() print(grid_var_autoplot(models_df, iterations,
      flow = "attractiveness", with_positions = TRUE, cut_off = 0.5
    ))
  )
  vdiffr::expect_doppelganger(
    "Default att iter pos ct qt",
    \() print(grid_var_autoplot(models_df, iterations,
      flow = "attractiveness", with_positions = TRUE, cut_off = 1, qmin = 0,
      qmax = 1
    ))
  )
  vdiffr::expect_doppelganger(
    "Default att iter pos ct qt limits",
    \() print(grid_var_autoplot(models_df, iterations,
      flow = "attractiveness", with_positions = TRUE, cut_off = 1, qmin = 0,
      qmax = 1,
      adjust_limits = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Default att iter pos ct qt limits fw",
    \() print(grid_var_autoplot(models_df, iterations,
      flow = "attractiveness", with_positions = TRUE, cut_off = 1, qmin = 0,
      qmax = 1,
      adjust_limits = TRUE, fw_params = list(ncol = 1),
    ))
  )
})

test_that("grid_var_autoplot works as expected with names (ggrepel)", {
  config <- create_locations(15, 15, seed = 2842, symmetric = TRUE)
  alphas <- seq(1.25, 1.5, by = 0.125)
  betas <- 1 / seq(0.1, 0.5, length.out = 6)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 750,
    precision = .Machine$double.eps^0.5,
  )
  destination_positions(models) <- config$pd
  destination_names(models) <- sample(letters, 15)
  models_df <- sim_df(models)
  models_df$group <- as.factor(sample(c(0, 1, 2), nrow(models_df),
    replace = TRUE
  ))
  skip_on_os("mac")
  vdiffr::expect_doppelganger(
    "Default destination iter names pos",
    \() print(grid_var_autoplot(models_df, iterations,
      flow = "destination",
      with_positions = TRUE, with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Default attr conv names pos",
    \() print(grid_var_autoplot(models_df, converged,
      flow = "attractiveness",
      with_positions = TRUE, with_names = TRUE,
      with_labels = TRUE
    ))
  )
  destination_names(models_df$sim) <- NULL
  vdiffr::expect_doppelganger(
    "Default attr conv null names pos",
    \() print(grid_var_autoplot(models_df, converged,
      flow = "attractiveness",
      with_positions = TRUE, with_names = TRUE,
      with_labels = TRUE
    ))
  )
})

test_that("grid_var_autoplot works as expected with names (base ggplot)", {
  config <- create_locations(15, 15, seed = 2842, symmetric = TRUE)
  alphas <- seq(1.25, 1.5, by = 0.125)
  betas <- 1 / seq(0.1, 0.5, length.out = 6)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 750,
    precision = .Machine$double.eps^0.5,
  )
  destination_positions(models) <- config$pd
  destination_names(models) <- sample(letters, 15)
  models_df <- sim_df(models)
  models_df$group <- as.factor(sample(c(0, 1, 2), nrow(models_df), replace = TRUE))
  local_mocked_bindings(has_ggrepel = function() FALSE)
  vdiffr::expect_doppelganger(
    "Default dest iter names pos base ggplot",
    \() print(grid_var_autoplot(models_df, iterations,
      flow = "destination",
      with_positions = TRUE, with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Default attr conv names pos base ggplot",
    \() print(grid_var_autoplot(models_df, converged,
      flow = "attractiveness",
      with_positions = TRUE, with_names = TRUE,
      with_labels = TRUE
    ))
  )
})


test_that("grid_var_autoplot errors and warnings are triggered", {
  config <- create_locations(15, 15, seed = 4242, symmetric = TRUE)
  alphas <- seq(1.25, 1.5, by = 0.125)
  betas <- 1 / seq(0.1, 0.5, length.out = 6)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 750,
    precision = .Machine$double.eps^0.5,
  )
  destination_positions(models) <- config$pd
  models_df <- sim_df(models)
  expect_error(grid_var_autoplot(models, iterations, with_positions = TRUE))
  expect_error(grid_var_autoplot(models_df))
  expect_warning(grid_var_autoplot(models_df, iterations,
    with_positions = TRUE
  ))
  destination_positions(models_df$sim) <- NULL
  expect_error(grid_var_autoplot(models_df, iterations,
    flows = "destination",
    with_positions = TRUE
  ))
})
