test_that("autoplot.sim_list works as expected (destination without names)", {
  config <- create_locations(20, 30, seed = 20)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  ## introducing names
  on <- paste(sample(letters, 20, replace = TRUE), 1:20, sep = "_")
  dn <- paste(sample(LETTERS, 30, replace = TRUE), 1:30, sep = "_")
  rownames(config$costs) <- on
  colnames(config$costs) <- dn
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  vdiffr::expect_doppelganger(
    "Destination no names",
    \() print(ggplot2::autoplot(models, flow = "destination"))
  )
  vdiffr::expect_doppelganger(
    "Destination no names set quantiles",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      qmin = 0.1,
      qmax = 0.7
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness no names",
    \() print(ggplot2::autoplot(models, flow = "attractiveness"))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness no names set quantiles",
    \() print(ggplot2::autoplot(models,
      flow = "attractiveness",
      qmin = 0.2,
      qmax = 1
    ))
  )
})


test_that("autoplot.sim_list works as expected (destination with names)", {
  config <- create_locations(25, 15, seed = 50)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  ## introducing names
  on <- paste(sample(letters, 25, replace = TRUE), 1:25, sep = "_")
  dn <- paste(sample(LETTERS, 15, replace = TRUE), 1:15, sep = "_")
  rownames(config$costs) <- on
  colnames(config$costs) <- dn
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  vdiffr::expect_doppelganger(
    "Destination names",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination names set quantiles",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      qmin = 0.1,
      qmax = 0.7,
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness names",
    \() print(ggplot2::autoplot(models,
      flow = "attractiveness",
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness names set quantiles",
    \() print(ggplot2::autoplot(models,
      flow = "attractiveness",
      qmin = 0.2,
      qmax = 1,
      with_names = TRUE
    ))
  )
  ## empty names
  destination_names(models) <- NULL
  vdiffr::expect_doppelganger(
    "Destination empty names",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination empty names set quantiles",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      qmin = 0.1,
      qmax = 0.7,
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness empty names",
    \() print(ggplot2::autoplot(models,
      flow = "attractiveness",
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness empty names set quantiles",
    \() print(ggplot2::autoplot(models,
      flow = "attractiveness",
      qmin = 0.2,
      qmax = 1,
      with_names = TRUE
    ))
  )
})

test_that("autoplot.sim_list works as expected (destination with positions)", {
  config <- create_locations(20, 30, seed = 20)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  origin_positions(models) <- config$pp
  destination_positions(models) <- config$pd
  vdiffr::expect_doppelganger(
    "Destination pos",
    \() print(ggplot2::autoplot(models, flow = "destination", with_positions = TRUE))
  )
  vdiffr::expect_doppelganger(
    "Destination pos cut off",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      cut_off = 4
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination pos cut off zoom",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      cut_off = 4,
      adjust_limits = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination pos set quantiles",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      qmin = 0.1,
      qmax = 0.7,
      with_positions = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness pos",
    \() print(ggplot2::autoplot(models,
      flow = "attractiveness",
      with_positions = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness pos set quantiles",
    \() print(ggplot2::autoplot(models,
      flow = "attractiveness",
      qmin = 0.2,
      qmax = 1,
      with_positions = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness pos cut off",
    \() print(ggplot2::autoplot(models,
      flow = "attractiveness",
      with_positions = TRUE,
      cut_off = 4
    ))
  )
  vdiffr::expect_doppelganger(
    "Attractiveness pos cut off zoom",
    \() print(ggplot2::autoplot(models,
      flow = "attractiveness",
      with_positions = TRUE,
      cut_off = 4,
      adjust_limits = TRUE
    ))
  )
})

test_that("autoplot.sim_list works as expected (destination with named positions)", {
  config <- create_locations(20, 30, seed = 20)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  origin_positions(models) <- config$pp
  colnames(config$pd) <- c("A", "B")
  destination_positions(models) <- config$pd
  vdiffr::expect_doppelganger(
    "Destination pos named",
    \() print(ggplot2::autoplot(models, flow = "destination", with_positions = TRUE))
  )
  colnames(config$pd) <- c("My first coordinate", "My second coordinate")
  destination_positions(models) <- config$pd
  vdiffr::expect_doppelganger(
    "Destination pos named 2",
    \() print(ggplot2::autoplot(models, flow = "destination", with_positions = TRUE))
  )
})

test_that("autoplot.sim_list works as expected (destination with positions and names) ggrepel", {
  config <- create_locations(15, 15, seed = 200)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  origin_positions(models) <- config$pp
  destination_positions(models) <- config$pd
  destination_names(models) <- sample(letters, 15, replace = TRUE)
  vdiffr::expect_doppelganger(
    "Destination pos names",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination pos labels",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      with_names = TRUE,
      with_labels = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination pos cut off names",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      cut_off = 4,
      with_names = TRUE
    ))
  )
  ## null names
  destination_names(models) <- NULL
  vdiffr::expect_doppelganger(
    "Destination pos cut off null names",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      cut_off = 2,
      with_names = TRUE
    ))
  )
})

test_that("autoplot.sim_list works as expected (destination with positions and names) base ggplot", {
  config <- create_locations(15, 15, seed = 200)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  origin_positions(models) <- config$pp
  destination_positions(models) <- config$pd
  destination_names(models) <- sample(letters, 15, replace = TRUE)
  local_mocked_bindings(has_ggrepel = function() FALSE)
  vdiffr::expect_doppelganger(
    "Destination pos names ggplot",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination pos labels ggplot",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      with_names = TRUE,
      with_labels = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Destination pos cut off names ggplot",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      cut_off = 4,
      with_names = TRUE
    ))
  )
  ## null names
  destination_names(models) <- NULL
  vdiffr::expect_doppelganger(
    "Destination pos cut off null names ggplot",
    \() print(ggplot2::autoplot(models,
      flow = "destination",
      with_positions = TRUE,
      cut_off = 2,
      with_names = TRUE
    ))
  )
})


test_that("autoplot.sim_list works as expected (full flows no names)", {
  config <- create_locations(20, 18, seed = 50)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  ## introducing names
  on <- paste(sample(letters, 20, replace = TRUE), 1:20, sep = "_")
  dn <- paste(sample(LETTERS, 18, replace = TRUE), 1:18, sep = "_")
  rownames(config$costs) <- on
  colnames(config$costs) <- dn
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  vdiffr::expect_doppelganger(
    "Full no names",
    \() print(ggplot2::autoplot(models))
  )
  vdiffr::expect_doppelganger(
    "Full no names set quantiles",
    \() print(ggplot2::autoplot(models,
      qmin = 0,
      qmax = 0.7
    ))
  )
  vdiffr::expect_doppelganger(
    "Full no names set quantiles no norm",
    \() print(ggplot2::autoplot(models,
      qmin = 0,
      qmax = 0.7,
      normalisation = "none"
    ))
  )
  vdiffr::expect_doppelganger(
    "Full no names set quantiles full norm",
    \() print(ggplot2::autoplot(models,
      qmin = 0,
      qmax = 0.7,
      normalisation = "full"
    ))
  )
})

test_that("autoplot.sim_list works as expected (full flows with names)", {
  config <- create_locations(20, 18, seed = 50)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  ## introducing names
  on <- paste(sample(letters, 20, replace = TRUE), 1:20, sep = "_")
  dn <- paste(sample(LETTERS, 18, replace = TRUE), 1:18, sep = "_")
  rownames(config$costs) <- on
  colnames(config$costs) <- dn
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  vdiffr::expect_doppelganger(
    "Full names",
    \() print(ggplot2::autoplot(models, with_names = TRUE))
  )
  vdiffr::expect_doppelganger(
    "Full names set quantiles",
    \() print(ggplot2::autoplot(models,
      qmin = 0,
      qmax = 0.7,
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Full names set quantiles no norm",
    \() print(ggplot2::autoplot(models,
      qmin = 0,
      qmax = 0.7,
      normalisation = "none",
      with_names = TRUE
    ))
  )
  vdiffr::expect_doppelganger(
    "Full names set quantiles full norm",
    \() print(ggplot2::autoplot(models,
      qmin = 0,
      qmax = 0.7,
      normalisation = "full",
      with_names = TRUE
    ))
  )
})

test_that("autoplot.sim_list errors and warnings are triggered", {
  config <- create_locations(20, 18, seed = 50)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  expect_warning(ggplot2::autoplot(models, with_positions = TRUE))
  expect_error(ggplot2::autoplot(models, flows = "destination", with_positions = TRUE))
})

test_that("autoplot.sim_list tolerates duplicate names", {
  config <- create_locations(20, 18, seed = 50)
  alphas <- seq(1.25, 2.25, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 5)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  destination_names(models) <- sample(letters[1:10], 18, replace = TRUE)
  origin_names(models) <- sample(LETTERS[1:10], 20, replace = TRUE)
  expect_no_error(ggplot2::autoplot(models, with_names = TRUE))
  expect_no_error(ggplot2::autoplot(models, flow = "destination", with_names = TRUE))
})
