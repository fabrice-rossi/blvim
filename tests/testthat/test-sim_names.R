test_that("names are reported and modified as expected", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  ## no names by construction
  expect_null(origin_names(model))
  expect_null(destination_names(model))
  ## set them
  on <- paste(sample(letters, 40, replace = TRUE), 1:40, sep = "_")
  origin_names(model) <- on
  expect_equal(origin_names(model), on)
  dn <- paste(sample(letters, 50, replace = TRUE), 1:50, sep = "_")
  destination_names(model) <- dn
  expect_equal(destination_names(model), dn)
  full_names <- location_names(model)
  expect_equal(full_names$origin, on)
  expect_equal(full_names$destination, dn)
  expect_named(full_names, c("origin", "destination"))
  ## and remove them
  origin_names(model) <- NULL
  destination_names(model) <- NULL
  expect_null(origin_names(model))
  expect_null(destination_names(model))
  ## and set them in the reverse order (for test coverage)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  destination_names(model) <- dn
  expect_equal(destination_names(model), dn)
  origin_names(model) <- on
  expect_equal(origin_names(model), on)
})

test_that("erroneous name settings are detected", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  ## not enough names
  expect_error(origin_names(model) <- letters[1:10])
  expect_error(destination_names(model) <- letters[1:20])
  ## too many names
  expect_error(origin_names(model) <- rep(letters[1:10], 5))
  expect_error(destination_names(model) <- rep(letters[1:20], 3))
  ## wrong object type
  expect_error(origin_names(config))
  expect_error(origin_names(config) <- rep(letters[1:10], 4))
  expect_error(destination_names(config))
  expect_error(destination_names(config) <- rep(letters[1:10], 5))
  ## wrong parameter to names.sim()<-
  expect_error(location_names(model) <- 1:5)
  expect_error(location_names(model) <- list())
  expect_error(location_names(model) <- list(origin = 5, destination = 12, foo = 1:5))
  expect_error(location_names(model) <- list(origin = 1:20, destination = 1:50))
  expect_error(location_names(model) <- list(origin = as.character(1:40), destination = 1:50))
  expect_error(location_names(model) <- list(origin = as.character(1:40), destination = as.character(1:40)))
  expect_error(location_names(model) <- list(origin = as.character(1:20), destination = as.character(1:50)))
})
