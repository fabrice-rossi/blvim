test_that("autoplot.sim works as expected", {
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
