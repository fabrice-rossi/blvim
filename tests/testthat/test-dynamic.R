test_that("blvim detects errors", {
  config <- create_locations(4, 5, seed = 2)
  ## not a cost matrix
  expect_error(blvim(config$X, c(config$X, 2), 1.5, 1, config$Z))
  ## not enough rows
  expect_error(blvim(config$costs, c(config$X, 2), 1.5, 1, config$Z))
  ## not enough columns
  expect_error(blvim(config$costs, config$X, 1.5, 1, c(config$Z, 1)))
  ## negative return to scale
  expect_error(blvim(config$costs, config$X, -1.5, 1, config$Z))
  ## negative inverse cost
  expect_error(blvim(config$costs, config$X, 1.5, -1, config$Z))
})

test_that("blvim fulfills its contracts", {
  config <- create_locations(40, 50, seed = 0)
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z, precision = .Machine$double.eps^0.5)
  ## correct dimensions
  expect_equal(dim(flows(model)), c(length(config$X), length(config$Z)))
  ## production constraints
  expect_equal(rowSums(flows(model)), config$X)
  expect_equal(production(model), config$X)
  ## attractiveness should equal to the destination flows
  ## as testthat comparison model is different from ours, we set at relatively
  ## high value of tolerance
  expect_equal(destination_flow(model), attractiveness(model),
    tolerance = 10 * (.Machine$double.eps^0.5)
  )
})

test_that("blvim computes the BLV model", {
  config <- create_locations(40, 50, seed = 1)
  ## we compare the C++ implementation with a R one
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z)
  r_model <- r_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_equal(flows(model), flows(r_model))
  expect_equal(production(model), production(r_model))
  expect_equal(attractiveness(model), attractiveness(r_model))
})

test_that("blvim computes the quadratic BLV model", {
  config <- create_locations(40, 50, seed = 2)
  ## we compare the C++ implementation with a R one
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z, quadratic = TRUE)
  r_model <- r_blvim(config$costs, config$X, 1.5, 1, config$Z, quadratic = TRUE)
  expect_equal(flows(model), flows(r_model))
  expect_equal(production(model), production(r_model))
  expect_equal(attractiveness(model), attractiveness(r_model))
})

test_that("blvim obeys to iteration control", {
  config <- create_locations(40, 50, seed = 2)
  for (k in seq(500, 5000, by = 500)) {
    model <- blvim(config$costs, config$X, 1.5, 1, config$Z, iter_max = k)
    expect_lte(model$iteration, k + 1)
    expect_true(model$converged == (model$iteration <= k))
  }
})
