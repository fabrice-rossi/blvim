test_that("positions are reported and modified as expected", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  ## no positions by construction
  expect_null(origin_positions(model))
  expect_null(destination_positions(model))
  ## set them
  origin_positions(model) <- config$pp
  expect_equal(origin_positions(model), config$pp)
  destination_positions(model) <- config$pd
  expect_equal(destination_positions(model), config$pd)
  full_positions <- location_positions(model)
  expect_equal(full_positions$origin, config$pp)
  expect_equal(full_positions$destination, config$pd)
  expect_named(full_positions, c("origin", "destination"))
  ## and remove them
  origin_positions(model) <- NULL
  destination_positions(model) <- NULL
  expect_null(origin_positions(model))
  expect_null(destination_positions(model))
  ## and set them in the reverse order (for test coverage)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  pd <- matrix(rnorm(50 * 3), nrow = 50)
  pp <- matrix(rnorm(40 * 3), nrow = 40)
  destination_positions(model) <- pd
  expect_equal(destination_positions(model), pd)
  origin_positions(model) <- pp
  expect_equal(origin_positions(model), pp)
  pd <- matrix(rnorm(50 * 3), nrow = 50)
  pp <- matrix(rnorm(40 * 3), nrow = 40)
  location_positions(model) <- list(origin = pp, destination = pd)
  expect_equal(destination_positions(model), pd)
  expect_equal(origin_positions(model), pp)
})

test_that("positions are correctly set in sim calculation functions", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z,
    origin_data = list(positions = config$pp),
    destination_data = list(positions = config$pd)
  )
  expect_equal(origin_positions(model), config$pp)
  expect_equal(destination_positions(model), config$pd)
  full_positions <- location_positions(model)
  expect_equal(full_positions$origin, config$pp)
  expect_equal(full_positions$destination, config$pd)
  expect_named(full_positions, c("origin", "destination"))
  ## and remove the positions
  origin_positions(model) <- NULL
  destination_positions(model) <- NULL
  expect_null(origin_positions(model))
  expect_null(destination_positions(model))
  ## do that again for dynamic models
  config <- create_locations(40, 50, seed = 12)
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z,
    origin_data = list(positions = config$pp),
    destination_data = list(positions = config$pd)
  )
  expect_equal(origin_positions(model), config$pp)
  expect_equal(destination_positions(model), config$pd)
  full_positions <- location_positions(model)
  expect_equal(full_positions$origin, config$pp)
  expect_equal(full_positions$destination, config$pd)
  expect_named(full_positions, c("origin", "destination"))
  ## and remove the positions
  origin_positions(model) <- NULL
  destination_positions(model) <- NULL
  expect_null(origin_positions(model))
  expect_null(destination_positions(model))
})

test_that("erroneous position settings are detected", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  ## not enough positions
  expect_error(origin_positions(model) <- matrix(rnorm(30 * 2), ncol = 2))
  expect_error(destination_positions(model) <- matrix(rnorm(40 * 2), ncol = 2))
  ## too many positions
  expect_error(origin_positions(model) <- matrix(rnorm(50 * 2), ncol = 2))
  expect_error(destination_positions(model) <- matrix(rnorm(60 * 2), ncol = 2))
  ## too many columns
  expect_error(origin_positions(model) <- matrix(rnorm(40 * 4), ncol = 4))
  expect_error(destination_positions(model) <- matrix(rnorm(50 * 5), ncol = 5))
  ## not enough columns
  expect_error(origin_positions(model) <- matrix(rnorm(40 * 1), ncol = 1))
  expect_error(destination_positions(model) <- matrix(rnorm(50 * 1), ncol = 1))
  ## wrong object type
  expect_error(origin_positions(config))
  expect_error(origin_positions(model) <- list())
  expect_error(origin_positions(config) <- matrix(rnorm(40 * 2), ncol = 2))
  expect_error(destination_positions(config))
  expect_error(destination_positions(model) <- 1:50)
  expect_error(destination_positions(config) <- matrix(rnorm(50 * 2), ncol = 2))
  ## wrong parameter to names.sim()<-
  expect_error(location_positions(model) <- 1:5)
  expect_error(location_positions(model) <- list())
  expect_error(location_positions(model) <- list(origin = 5, destination = 12, foo = 1:5))
  expect_error(location_positions(model) <- list(origin = 1:20, destination = 1:50))
  expect_error(location_positions(model) <- list(
    origin = matrix(rnorm(40 * 3), nrow = 40),
    destination = 1:50
  ))
  expect_error(location_positions(model) <- list(
    origin = 1:40,
    destination = matrix(rnorm(50 * 3), nrow = 50)
  ))
  expect_error(location_positions(model) <- list(
    origin = matrix(rnorm(40 * 5), nrow = 40),
    destination = matrix(rnorm(40 * 3), nrow = 40)
  ))
  expect_error(location_positions(model) <- list(
    origin = matrix(rnorm(40 * 2), nrow = 40),
    destination = matrix(rnorm(50 * 5), nrow = 50)
  ))
  expect_error(location_positions(model) <- list(
    origin = matrix(rnorm(30 * 2), nrow = 30),
    destination = matrix(rnorm(40 * 2), nrow = 40)
  ))
  expect_error(location_positions(model) <- list(
    origin = matrix(rnorm(40 * 2), nrow = 40),
    destination = matrix(rnorm(40 * 2), nrow = 40)
  ))
})

test_that("positions are handled consistantly in the non bipartite case", {
  config <- create_locations(40, 40, symmetric = TRUE, seed = 420)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z, bipartite = FALSE)
  ## arbitrary reorder for testing purposes
  config$pd <- config$pd[sample(nrow(config$pd)), ]
  ## set positions
  origin_positions(model) <- config$pp
  expect_equal(origin_positions(model), config$pp)
  expect_equal(destination_positions(model), config$pp)
  destination_positions(model) <- config$pd
  expect_equal(destination_positions(model), config$pd)
  expect_equal(origin_positions(model), config$pd)
  full_positions <- location_positions(model)
  expect_equal(full_positions$origin, config$pd)
  expect_equal(full_positions$destination, config$pd)
  expect_named(full_positions, c("origin", "destination"))
  ## and remove them
  origin_positions(model) <- NULL
  expect_null(origin_positions(model))
  expect_null(destination_positions(model))
  location_positions(model) <- list(origin = config$pd, destination = config$pd)
  expect_equal(location_positions(model), list(origin = config$pd, destination = config$pd))
  expect_error(location_positions(model) <- list(origin = config$pp, destination = config$pd))
})
