test_that("sim_list handles names correctly", {
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
  ## no names by construction
  expect_null(origin_names(models))
  expect_null(destination_names(models))
  full_names <- location_names(models)
  expect_named(full_names, c("origin", "destination"))
  expect_null(full_names$origin)
  expect_null(full_names$destination)
  ## set names
  on <- paste(sample(letters, 20, replace = TRUE), 1:20, sep = "_")
  origin_names(models) <- on
  expect_equal(origin_names(models), on)
  dn <- paste(sample(letters, 30, replace = TRUE), 1:30, sep = "_")
  destination_names(models) <- dn
  expect_equal(destination_names(models), dn)
  full_names <- location_names(models)
  expect_equal(full_names$origin, on)
  expect_equal(full_names$destination, dn)
  expect_named(full_names, c("origin", "destination"))
  ## and remove them
  origin_names(models) <- NULL
  destination_names(models) <- NULL
  expect_null(origin_names(models))
  expect_null(destination_names(models))
  ## add then again
  location_names(models) <- list(origin = on, destination = dn)
  expect_equal(origin_names(models), on)
  expect_equal(destination_names(models), dn)
})

test_that("sim_list detects errors", {
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
  expect_error(origin_names(models) <- sample(letters, 25))
  expect_error(destination_names(models) <- sample(letters, 25))
  expect_error(location_names(models) <- list(
    alice = sample(letters, 25),
    bob = sample(letters, 30, replace = TRUE)
  ))
})

test_that("sim_list handles names correctly, non bipartite case", {
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
  ## set names
  on <- paste(sample(letters, 30, replace = TRUE), 1:30, sep = "_")
  origin_names(models) <- on
  expect_equal(origin_names(models), on)
  expect_equal(destination_names(models), on)
  dn <- paste(sample(letters, 30, replace = TRUE), 1:30, sep = "_")
  destination_names(models) <- dn
  expect_equal(destination_names(models), dn)
  expect_equal(origin_names(models), dn)
  full_names <- location_names(models)
  expect_equal(full_names$origin, dn)
  expect_equal(full_names$destination, dn)
  expect_named(full_names, c("origin", "destination"))
  ## and remove them
  origin_names(models) <- NULL
  expect_null(origin_names(models))
  expect_null(destination_names(models))
  ## add then again
  location_names(models) <- list(origin = dn, destination = dn)
  expect_equal(origin_names(models), dn)
  expect_equal(destination_names(models), dn)
  ## error case
  expect_error(location_names(models) <- list(origin = on, destination = dn))
})
