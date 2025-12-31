test_that("grid_autoplot works as expected", {
  config <- create_locations(25, 25, seed = 2828, symmetric = TRUE)
  alphas <- seq(1.25, 1.5, by = 0.125)
  betas <- 1 / seq(0.1, 0.5, length.out = 6)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5,
  )
  destination_positions(models) <- config$pd
  models_df <- sim_df(models)
  vdiffr::expect_doppelganger(
    "Default flow matrices",
    \() print(grid_autoplot(models_df))
  )
  vdiffr::expect_doppelganger(
    "Flow matrices with alpha and 1/beta",
    \() print(grid_autoplot(models_df, paste(alpha, "~", round(1 / beta, 3))))
  )
  vdiffr::expect_doppelganger(
    "Default destination",
    \() print(ggplot2::autoplot(models_df, flows = "destination"))
  )
  vdiffr::expect_doppelganger(
    "Default attractiveness",
    \() print(ggplot2::autoplot(models_df, flows = "attractiveness"))
  )
  ## with positions
  vdiffr::expect_doppelganger(
    "Default flow graphs",
    \() print(grid_autoplot(models_df, with_positions = TRUE) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)))
  )
  vdiffr::expect_doppelganger(
    "Default flow graphs with dest",
    \() print(grid_autoplot(models_df,
      with_positions = TRUE,
      show_destination = TRUE
    ) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)))
  )
  vdiffr::expect_doppelganger(
    "Default flow graphs with att",
    \() print(grid_autoplot(models_df,
      with_positions = TRUE,
      show_attractiveness = TRUE
    ) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)))
  )
  vdiffr::expect_doppelganger(
    "Default flow graphs with prod",
    \() print(grid_autoplot(models_df,
      with_positions = TRUE,
      show_production = TRUE
    ) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)) +
      ggplot2::scale_size_continuous(range = c(0.5, 1.5)))
  )
  vdiffr::expect_doppelganger(
    "Flow graphs cut off",
    \() print(grid_autoplot(models_df, with_positions = TRUE, cut_off = 0.5) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)))
  )
  vdiffr::expect_doppelganger(
    "Flow graphs cut off arrow",
    \() print(grid_autoplot(models_df,
      with_positions = TRUE, cut_off = 0.5,
      arrow = ggplot2::arrow(length = ggplot2::unit(0.05, "npc"))
    ) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)))
  )
  vdiffr::expect_doppelganger(
    "Default destination dots",
    \() print(grid_autoplot(models_df, flows = "destination", with_positions = TRUE) +
      ggplot2::scale_size_continuous(range = c(0, 5)))
  )
  vdiffr::expect_doppelganger(
    "Default attractiveness dots",
    \() print(grid_autoplot(models_df, flows = "attractiveness", with_positions = TRUE) +
      ggplot2::scale_size_continuous(range = c(0, 5)))
  )
  vdiffr::expect_doppelganger(
    "Destination dots with alpha and beta",
    \() print(grid_autoplot(models_df, paste(alpha, "~", round(beta, 3)),
      flows = "destination", with_positions = TRUE
    ) +
      ggplot2::scale_size_continuous(range = c(0, 5)))
  )
  vdiffr::expect_doppelganger(
    "Destination bars with free scales",
    \() print(grid_autoplot(models_df, paste(alpha, "~", round(beta, 3)),
      flows = "destination", fw_params = list(scale = "free_y")
    ) +
      ggplot2::scale_size_continuous(range = c(0, 5)))
  )
})

test_that("grid_autoplot works as expected in the bipartite case", {
  config <- create_locations(10, 15, seed = 82)
  alphas <- seq(1.25, 1.5, by = 0.125)
  betas <- 1 / seq(0.1, 0.5, length.out = 6)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5,
  )
  destination_positions(models) <- config$pd
  origin_positions(models) <- config$pp
  models_df <- sim_df(models)
  vdiffr::expect_doppelganger(
    "Default biflow graphs with dest",
    \() print(grid_autoplot(models_df,
      with_positions = TRUE,
      show_destination = TRUE
    ) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)))
  )
  vdiffr::expect_doppelganger(
    "Default biflow graphs with att",
    \() print(grid_autoplot(models_df,
      with_positions = TRUE,
      show_attractiveness = TRUE
    ) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)))
  )
  vdiffr::expect_doppelganger(
    "Default biflow graphs with prod",
    \() print(grid_autoplot(models_df,
      with_positions = TRUE,
      show_production = TRUE
    ) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)) +
      ggplot2::scale_size_continuous(range = c(0.5, 1.5)))
  )
  vdiffr::expect_doppelganger(
    "Default biflow graphs with prod and dest",
    \() print(grid_autoplot(models_df,
      with_positions = TRUE,
      show_destination = TRUE,
      show_production = TRUE
    ) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)) +
      ggplot2::scale_size_continuous(range = c(0, 5)))
  )
  vdiffr::expect_doppelganger(
    "Default biflow graphs with prod and att",
    \() print(grid_autoplot(models_df,
      with_positions = TRUE,
      show_attractiveness = TRUE,
      show_production = TRUE
    ) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)) +
      ggplot2::scale_size_continuous(range = c(0, 5)))
  )
})

test_that("grid_autoplot works as expected in borderline cases", {
  config <- create_locations(25, 25, seed = 666, symmetric = TRUE)
  alphas <- seq(1.25, 1.75, by = 0.125)
  betas <- 1 / seq(0.1, 0.5, length.out = 8)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5,
  )
  destination_positions(models) <- config$pd
  models_df <- sim_df(models)
  ## too many sims
  expect_error(grid_autoplot(models_df))
  vdiffr::expect_doppelganger(
    "Default flow matrices (too many)",
    \() print(grid_autoplot(models_df, max_sims = 40))
  )
  ## a single sim
  vdiffr::expect_doppelganger(
    "Default flow matrix (single model)",
    \() print(grid_autoplot(models_df[1, ]))
  )
})


test_that("grid_autoplot detects errors", {
  expect_error(grid_autoplot(list()))
  config <- create_locations(25, 25, seed = 666, symmetric = TRUE)
  alphas <- seq(1.25, 1.75, by = 0.125)
  betas <- 1 / seq(0.1, 0.5, length.out = 8)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5,
  )
  expect_error(grid_autoplot(models, max_sims = TRUE))
})

test_that("grid_autoplot warns about unused parameters", {
  config <- create_locations(25, 25, seed = 28, symmetric = TRUE)
  alphas <- seq(1.25, 1.5, by = 0.125)
  betas <- 1 / seq(0.1, 0.5, length.out = 6)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5,
  )
  destination_positions(models) <- config$pd
  destination_names(models) <- letters[1:25]
  models_df <- sim_df(models)
  ## no position
  expect_warning(grid_autoplot(models_df, cut_off = 1))
  expect_warning(grid_autoplot(models_df, adjust_limits = FALSE))
  expect_warning(grid_autoplot(models_df, with_labels = FALSE))
  ## with names
  expect_warning(grid_autoplot(models_df, with_names = TRUE, cut_off = 1))
  expect_warning(grid_autoplot(models_df,
    with_names = TRUE,
    adjust_limits = FALSE
  ))
  expect_warning(grid_autoplot(models_df,
    with_names = TRUE,
    with_labels = FALSE
  ))
  ## with positions
  expect_warning(grid_autoplot(models_df,
    with_positions = TRUE,
    with_labels = TRUE
  ))
})
