test_that("static_blvim detects errors", {
  config <- create_locations(4, 5, seed = 2)
  ## not a cost matrix
  expect_error(static_blvim(config$X, c(config$X, 2), 1.5, 1, config$Z))
  ## not enough rows
  expect_error(static_blvim(config$costs, c(config$X, 2), 1.5, 1, config$Z))
  ## not enough columns
  expect_error(static_blvim(config$costs, config$X, 1.5, 1, c(config$Z, 1)))
  ## negative return to scale
  expect_error(static_blvim(config$costs, config$X, -1.5, 1, config$Z))
  ## negative inverse cost
  expect_error(static_blvim(config$costs, config$X, 1.5, -1, config$Z))
})

test_that("static_blvim fulfills its contracts", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  ## correct dimensions
  expect_equal(dim(flows(model)), c(length(config$X), length(config$Z)))
  ## production constraints
  expect_equal(rowSums(flows(model)), config$X)
  expect_equal(production(model), config$X)
  ## attractiveness
  expect_equal(attractiveness(model), config$Z)
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
  model <- static_blvim(config$costs, config$X, alpha, beta, config$Z)
  expect_equal(flows(model), Y, ignore_attr = TRUE)
})

test_that("static_blvim use names from the cost matrix", {
  config <- create_locations(20, 25, seed = 12308)
  rownames(config$costs) <- letters[1:20]
  colnames(config$costs) <- LETTERS[1:25]
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_equal(origin_names(model), letters[1:20])
  expect_equal(destination_names(model), LETTERS[1:25])
})
