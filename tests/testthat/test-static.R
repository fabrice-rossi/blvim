test_that("static_blvim fulfills detects errors", {
  config <- create_locations(4, 5, seed = 2)
  ## not a cost matrix
  expect_error(static_blvim(config$X, c(config$X, 2), 1.5, 1, config$Z))
  ## not enough rows
  expect_error(static_blvim(config$costs, c(config$X, 2), 1.5, 1, config$Z))
  ## not enough columns
  expect_error(static_blvim(config$costs, config$X, 1.5, 1, c(config$Z, 1)))
})

test_that("static_blvim fulfills its contracts", {
  config <- create_locations(40, 50, seed = 0)
  flows <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  ## correct dimensions
  expect_equal(dim(flows), c(length(config$X), length(config$Z)))
  ## production constraints
  expect_equal(rowSums(flows), config$X)
})

test_that("static_blvim fulfills computes Wilson's equation", {
  config <- create_locations(40, 50, seed = 1)
  ## we compare the C++ implementation with a R one
  alpha <- 1.5
  beta <- 2
  exp_costs <- exp(-beta * config$costs)
  XZeC <- outer(config$X, config$Z**alpha) * exp_costs
  Y_norm <- exp_costs %*% config$Z**alpha
  Y <- sweep(XZeC, 1, Y_norm[, 1], "/")
  flows <- static_blvim(config$costs, config$X, alpha, beta, config$Z)
  expect_equal(flows, Y, ignore_attr = TRUE)
})
