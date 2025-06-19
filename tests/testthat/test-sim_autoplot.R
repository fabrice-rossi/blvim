test_that("autoplot.sim works as expected (without names)", {
  config <- create_locations(25, 25, seed = 25, symmetric = TRUE)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z)
  vdiffr::expect_doppelganger(
    "Destination barplot",
    \() print(ggplot2::autoplot(model, "destination"))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness barplot",
    \() print(ggplot2::autoplot(model, "attractiveness"))
  )
  vdiffr::expect_doppelganger(
    "Full matrix plot",
    \() print(ggplot2::autoplot(model))
  )
})

test_that("autoplot.sim works as expected (with names)", {
  config <- create_locations(20, 15, seed = 124)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z)
  ## null names
  vdiffr::expect_doppelganger(
    "Destination barplot wnn",
    \() print(ggplot2::autoplot(model, "destination", with_names = TRUE))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness barplot wnn",
    \() print(ggplot2::autoplot(model, "attractiveness", with_names = TRUE))
  )
  vdiffr::expect_doppelganger(
    "Full matrix plot wnn",
    \() print(ggplot2::autoplot(model, with_names = TRUE))
  )
  ## specific names
  withr::local_seed(42)
  destination_names(model) <- sample(letters, 15, replace = TRUE)
  origin_names(model) <- sample(LETTERS, 20, replace = TRUE)
  vdiffr::expect_doppelganger(
    "Destination barplot wn",
    \() print(ggplot2::autoplot(model, "destination", with_names = TRUE))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness barplot wn",
    \() print(ggplot2::autoplot(model, "attractiveness", with_names = TRUE))
  )
  vdiffr::expect_doppelganger(
    "Full matrix plot wn",
    \() print(ggplot2::autoplot(model, with_names = TRUE))
  )
})
