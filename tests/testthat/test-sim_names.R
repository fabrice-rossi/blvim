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
  ## and remove them
  origin_names(model) <- NULL
  destination_names(model) <- NULL
  expect_null(origin_names(model))
  expect_null(destination_names(model))
  ## and set them again with the location_names function
  location_names(model) <- list(origin = on, destination = dn)
  expect_equal(destination_names(model), dn)
  expect_equal(origin_names(model), on)
  expect_equal(location_names(model), list(origin = on, destination = dn))
  ## finally test automatic names
  config <- create_locations(40, 50, seed = 25)
  colnames(config$costs) <- as.character(1:50)
  rownames(config$costs) <- as.character(1:40)
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z,
    origin_data = list(positions = config$pp),
    destination_data = list(positions = config$pd)
  )
  expect_equal(origin_names(model), rownames(config$costs))
  expect_equal(destination_names(model), colnames(config$costs))
})

test_that("names are correctly set in sim calculation functions", {
  config <- create_locations(40, 50, seed = 0)
  ## add names to costs that will be replaced by the specified ones
  colnames(config$costs) <- 1:50
  rownames(config$costs) <- 1:40
  on <- paste(sample(letters, 40, replace = TRUE), 1:40, sep = "_")
  dn <- paste(sample(letters, 50, replace = TRUE), 1:50, sep = "_")
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z,
    origin_data = list(names = on),
    destination_data = list(names = dn)
  )
  expect_equal(origin_names(model), on)
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
  ## same thing with the dynamic model
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z,
    origin_data = list(names = on),
    destination_data = list(names = dn)
  )
  expect_equal(origin_names(model), on)
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
