test_that("autoplot.sim detects wrong parameters", {
  config <- create_locations(25, 25, seed = 25, symmetric = TRUE)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z)
  expect_error(ggplot2::autoplot(model, flows = "bla"))
  expect_error(ggplot2::autoplot(model, flows = "full", 1))
  expect_error(ggplot2::autoplot(model, flows = "full", FALSE, "bla"))
  expect_error(ggplot2::autoplot(model, flows = "full", FALSE, FALSE, -2))
  expect_error(ggplot2::autoplot(model, flows = "full", FALSE, FALSE, "ab"))
  expect_error(ggplot2::autoplot(model,
    flows = "full", FALSE, FALSE, 0.01,
    2.5
  ))
  expect_error(ggplot2::autoplot(model,
    flows = "full", FALSE, FALSE, 0.01,
    TRUE, 4
  ))
  expect_error(ggplot2::autoplot(model,
    flows = "full", FALSE, FALSE, 0.01,
    TRUE, FALSE, 4
  ))
  expect_error(ggplot2::autoplot(model,
    flows = "full", FALSE, FALSE, 0.01,
    TRUE, FALSE, foo = 4, 5
  ))
})

test_that("autoplot.sim warns about unused parameters", {
  config <- create_locations(25, 25, seed = 25, symmetric = TRUE)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z, bipartite = FALSE)
  destination_positions(model) <- config$pd
  destination_names(model) <- letters[1:25]
  ## no position
  expect_warning(ggplot2::autoplot(model, cut_off = 1))
  expect_warning(ggplot2::autoplot(model, adjust_limits = FALSE))
  expect_warning(ggplot2::autoplot(model, with_labels = FALSE))
  ## with names
  expect_warning(ggplot2::autoplot(model, with_names = TRUE, cut_off = 1))
  expect_warning(ggplot2::autoplot(model,
    with_names = TRUE,
    adjust_limits = FALSE
  ))
  expect_warning(ggplot2::autoplot(model,
    with_names = TRUE,
    with_labels = FALSE
  ))
  ## with positions
  expect_warning(ggplot2::autoplot(model,
    with_positions = TRUE,
    with_labels = TRUE
  ))
})

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

test_that("autoplot.sim tolerates duplicate names", {
  config <- create_locations(20, 15, seed = 12)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z)
  destination_names(model) <- sample(letters[1:10], 15, replace = TRUE)
  origin_names(model) <- sample(LETTERS[1:10], 20, replace = TRUE)
  expect_no_error(ggplot2::autoplot(model, with_names = TRUE))
  expect_no_error(ggplot2::autoplot(model, flow = "destination", with_names = TRUE))
})

test_that("autoplot.sim works pass parameters to geom_segment as expected", {
  config <- create_locations(20, 20, seed = 124, symmetric = TRUE)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z, bipartite = FALSE)
  origin_positions(model) <- config$pp
  vdiffr::expect_doppelganger(
    "Full flow graph non bipartite arrow",
    \() print(ggplot2::autoplot(model,
      with_positions = TRUE, cut_off = 0.05,
      arrow = ggplot2::arrow(length = ggplot2::unit(0.01, "npc"))
    ) +
      ggplot2::scale_linewidth(range = c(0, 2)))
  )
  ## ... params must be named
  expect_error(ggplot2::autoplot(model,
    flows = "full",
    with_names = FALSE,
    with_positions = TRUE,
    cut_off = 0.05,
    adjust_limits = FALSE,
    ggplot2::arrow(length = ggplot2::unit(0.01, "npc"))
  ))
})

test_that("autoplot.sim works as expected (with positions and names) ggrepel", {
  config <- create_locations(20, 15, seed = 123456)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z)
  origin_positions(model) <- config$pp
  destination_positions(model) <- config$pd
  destination_names(model) <- sample(letters, 15, replace = FALSE)
  origin_names(model) <- sample(LETTERS, 20, replace = FALSE)
  vdiffr::expect_doppelganger(
    "Destination dotplot label",
    \() print(ggplot2::autoplot(model, "destination",
      with_positions = TRUE,
      with_names = TRUE, cut_off = 0, with_labels = TRUE
    ))
  )
  skip_on_os("mac")
  ## subtle differences appear between linux figures and mac os figures.
  vdiffr::expect_doppelganger(
    "Destination dotplot text",
    \() print(ggplot2::autoplot(model, "destination",
      with_positions = TRUE,
      with_names = TRUE, cut_off = 0
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness dotplot text",
    \() print(ggplot2::autoplot(model, "attractiveness",
      with_positions = TRUE,
      with_names = TRUE, cut_off = 0
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination dotplot text filtered zoomed",
    \() print(ggplot2::autoplot(model, "destination",
      with_positions = TRUE, cut_off = 0.1,
      adjust_limits = TRUE, with_names = TRUE
    ))
  )
  dnames <- destination_names(model)
  destination_names(model) <- NULL
  vdiffr::expect_doppelganger(
    "Destination dotplot null text",
    \() print(ggplot2::autoplot(model, "destination",
      with_positions = TRUE,
      with_names = TRUE, cut_off = 0
    ))
  )
})

test_that("autoplot.sim works as expected (with positions and names) base ggplot", {
  config <- create_locations(20, 15, seed = 123456)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z)
  origin_positions(model) <- config$pp
  destination_positions(model) <- config$pd
  destination_names(model) <- sample(letters, 15, replace = FALSE)
  origin_names(model) <- sample(LETTERS, 20, replace = FALSE)
  local_mocked_bindings(has_ggrepel = function() FALSE)
  vdiffr::expect_doppelganger(
    "Destination dotplot text base",
    \() print(ggplot2::autoplot(model, "destination",
      with_positions = TRUE,
      with_names = TRUE, cut_off = 0
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness dotplot text base",
    \() print(ggplot2::autoplot(model, "attractiveness",
      with_positions = TRUE,
      with_names = TRUE, cut_off = 0
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness dotplot label base",
    \() print(ggplot2::autoplot(model, "attractiveness",
      with_positions = TRUE,
      with_names = TRUE, with_labels = TRUE, cut_off = 0
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination dotplot text filtered zoomed base",
    \() print(ggplot2::autoplot(model, "destination",
      with_positions = TRUE, cut_off = 0.1,
      adjust_limits = TRUE, with_names = TRUE
    ))
  )
})
