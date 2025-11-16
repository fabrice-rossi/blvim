test_that("sim_list handles positions correctly", {
  config <- create_locations(20, 30, seed = 4)
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
  ## no positions by construction
  expect_null(origin_positions(models))
  expect_null(destination_positions(models))
  full_positions <- location_positions(models)
  expect_named(full_positions, c("origin", "destination"))
  expect_null(full_positions$origin)
  expect_null(full_positions$destination)
  ## set positions
  origin_positions(models) <- config$pp
  expect_equal(origin_positions(models), config$pp)
  destination_positions(models) <- config$pd
  expect_equal(destination_positions(models), config$pd)
  full_positions <- location_positions(models)
  expect_equal(full_positions$origin, config$pp)
  expect_equal(full_positions$destination, config$pd)
  expect_named(full_positions, c("origin", "destination"))
  ## and remove them
  origin_positions(models) <- NULL
  destination_positions(models) <- NULL
  expect_null(origin_positions(models))
  expect_null(destination_positions(models))
  ## add then again
  location_positions(models) <- list(origin = config$pp, destination = config$pd)
  expect_equal(origin_positions(models), config$pp)
  expect_equal(destination_positions(models), config$pd)
})

test_that("sim_list detects erros", {
  config <- create_locations(20, 30, seed = 4)
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
  expect_error(origin_positions(models) <- matrix(runif(30 * 2), ncol = 2))
  expect_error(origin_positions(models) <- matrix(runif(20 * 4), ncol = 4))
  expect_error(destination_positions(models) <- matrix(runif(20 * 2), ncol = 2))
  expect_error(destination_positions(models) <- matrix(runif(30 * 1), ncol = 1))
  expect_error(location_positions(models) <- list())
})

test_that("sim_list handles positions correctly, non bipartite case", {
  config <- create_locations(30, 30, symmetric = TRUE, seed = 84)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  ## set positions
  ## random reorder for testing purposes
  config$pd <- config$pd[sample(nrow(config$pd)), ]
  origin_positions(models) <- config$pp
  expect_equal(origin_positions(models), config$pp)
  expect_equal(destination_positions(models), config$pp)
  destination_positions(models) <- config$pd
  expect_equal(destination_positions(models), config$pd)
  expect_equal(origin_positions(models), config$pd)
  full_positions <- location_positions(models)
  expect_equal(full_positions$origin, config$pd)
  expect_equal(full_positions$destination, config$pd)
  expect_named(full_positions, c("origin", "destination"))
  ## and remove them
  origin_positions(models) <- NULL
  expect_null(origin_positions(models))
  expect_null(destination_positions(models))
  ## add then again
  location_positions(models) <- list(origin = config$pp, destination = config$pp)
  expect_equal(origin_positions(models), config$pp)
  expect_equal(destination_positions(models), config$pp)
  ## error case
  expect_error(location_positions(models) <- list(origin = config$pp, destination = config$pd))
})
