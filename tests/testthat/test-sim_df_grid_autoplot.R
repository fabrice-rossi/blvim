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
    "Flow graphs cut off",
    \() print(grid_autoplot(models_df, with_positions = TRUE, cut_off = 0.5) +
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
