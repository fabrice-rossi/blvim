test_that("diversity detects errors", {
  config <- create_locations(4, 5, seed = 2)
  model <- static_blvim(config$costs, config$X, 1.5, 3, config$Z)
  ## not a definition
  expect_error(diversity(model, "something"))
  ## negative order
  expect_error(diversity(model, "renyi", -1))
})

test_that("diversity computes what is expected", {
  config <- create_locations(40, 50, seed = 3)
  model <- blvim(config$costs, config$X, 1.5, 6, config$Z, precision = .Machine$double.eps^0.5)
  D <- destination_flow(model)
  D <- D / sum(D)
  ## Shannon
  expect_equal(-sum(D * log(D)), log(diversity(model)))
  ## Some Rényi
  orders <- c(0.5, 1.5, 3)
  for (gamma in orders) {
    expect_equal(log(sum(D^gamma)) / (1 - gamma), log(diversity(model, "renyi", order = gamma)))
  }
  ## special Rényi
  ## Shannon
  expect_equal(-sum(D * log(D)), log(diversity(model, "renyi", order = 1)))
  ## min
  expect_equal(-log(max(D)), log(diversity(model, "renyi", order = Inf)))
  ## max
  expect_equal(length(D), diversity(model, "renyi", order = 0))
})
