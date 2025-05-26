test_that("autoplot.sim_list works as expected", {
  config <- create_locations(25, 25, seed = 25, symmetric = TRUE)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.05, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    precision = .Machine$double.eps^0.5
  )
  vdiffr::expect_doppelganger(
    "Default Shannon diversity",
    \() print(ggplot2::autoplot(models))
  )
  vdiffr::expect_doppelganger(
    "Default Shannon diversity, non inverted beta",
    \() print(ggplot2::autoplot(models, inverse = FALSE))
  )
  vdiffr::expect_doppelganger(
    "Renyi diversity, order 0.5",
    \() print(ggplot2::autoplot(models, "renyi", order = 0.5))
  )
  vdiffr::expect_doppelganger(
    "Renyi diversity, order 2",
    \() print(ggplot2::autoplot(models, "renyi", order = 2))
  )
  vdiffr::expect_doppelganger(
    "Terminal number",
    \() print(ggplot2::autoplot(models, "terminals"))
  )
  vdiffr::expect_doppelganger(
    "Iteration number",
    \() print(ggplot2::autoplot(models, "iterations"))
  )
})

test_that("autoplot.sim_list border cases", {
  config <- create_locations(25, 25, seed = 10, symmetric = TRUE)
  ## only one alpha
  alphas <- 1.25
  betas <- 1 / seq(0.05, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    precision = .Machine$double.eps^0.5
  )
  vdiffr::expect_doppelganger(
    "Default Shannon diversity one alpha",
    \() print(ggplot2::autoplot(models))
  )
  vdiffr::expect_doppelganger(
    "Renyi o. 0.25 div. one alpha non inv. beta",
    \() print(ggplot2::autoplot(models, "renyi", order = 0.25, inverse = FALSE))
  )
  ## only one beta, irregular alphas
  alphas <- c(1.05, 1.10, 1.35, 1.8, 2.5, 3, 4)
  betas <- 1 / 0.1
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    precision = .Machine$double.eps^0.5
  )
  vdiffr::expect_doppelganger(
    "Terminal number one beta",
    \() print(ggplot2::autoplot(models, "terminals"))
  )
  vdiffr::expect_doppelganger(
    "Renyi o. 4 div. one beta non inv. beta",
    \() print(ggplot2::autoplot(models, "renyi", order = 4, inverse = FALSE))
  )
  ## only one of each
  alphas <- 2
  betas <- 1 / 0.1
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    precision = .Machine$double.eps^0.5
  )
  vdiffr::expect_doppelganger(
    "Default Shannon diversity one alpha one beta",
    \() print(ggplot2::autoplot(models))
  )
})
