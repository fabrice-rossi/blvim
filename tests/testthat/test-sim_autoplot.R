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

test_that("autoplot.sim works as expected (with positions)", {
  config <- create_locations(20, 15, seed = 124)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z)
  origin_positions(model) <- config$pp
  destination_positions(model) <- config$pd
  vdiffr::expect_doppelganger(
    "Destination dotplot",
    \() print(ggplot2::autoplot(model, "destination", with_positions = TRUE))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness dotplot",
    \() print(ggplot2::autoplot(model, "attractiveness", with_positions = TRUE))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness dotplot filtered",
    \() print(ggplot2::autoplot(model, "attractiveness", with_positions = TRUE, cut_off = 0.1))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness dotplot filtered zoomed",
    \() print(ggplot2::autoplot(model, "attractiveness",
      with_positions = TRUE, cut_off = 0.1,
      adjust_limits = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Full flow graph",
    \() print(ggplot2::autoplot(model, with_positions = TRUE))
  )
  vdiffr::expect_doppelganger(
    "Full flow graph custom cut off",
    \() print(ggplot2::autoplot(model, with_positions = TRUE, cut_off = 0.01))
  )
  vdiffr::expect_doppelganger(
    "Full flow graph custom cut off zoomed",
    \() print(ggplot2::autoplot(model,
      with_positions = TRUE, cut_off = 0.5,
      adjust_limits = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Full flow graph custom lines",
    \() print(ggplot2::autoplot(model,
      with_positions = TRUE, lineend = "butt",
      linejoin = "bevel"
    ))
  )
  vdiffr::expect_doppelganger(
    "Full flow graph no arrow",
    \() print(ggplot2::autoplot(model, with_positions = TRUE, cut_off = 0.01, arrow = NULL) +
      ggplot2::scale_linewidth_continuous(range = c(0, 2)))
  )
  ## error cases
  origin_positions(model) <- NULL
  expect_error(ggplot2::autoplot(model, with_positions = TRUE))
  destination_positions(model) <- NULL
  expect_error(ggplot2::autoplot(model, with_positions = TRUE))
  expect_error(ggplot2::autoplot(model, "attractiveness", with_positions = TRUE))
  expect_error(ggplot2::autoplot(model, "destination", with_positions = TRUE))
})

test_that("autoplot.sim works as expected (with positions, non bipartite)", {
  config <- create_locations(20, 20, seed = 124, symmetric = TRUE)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z, bipartite = FALSE)
  origin_positions(model) <- config$pp
  vdiffr::expect_doppelganger(
    "Full flow graph non bipartite",
    \() print(ggplot2::autoplot(model, with_positions = TRUE, cut_off = 0.05) +
      ggplot2::scale_linewidth(range = c(0, 2)))
  )
})
