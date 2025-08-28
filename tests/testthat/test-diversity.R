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
  ## terminals (error because non squared)
  expect_error(diversity(model, "RW"))
  expect_error(diversity(model, "ND"))
  ## squared version
  config <- create_locations(40, 40, seed = 3, symmetric = TRUE)
  model <- blvim(config$costs, config$X, 1.5, 6, config$Z,
    bipartite = FALSE,
    precision = .Machine$double.eps^0.5
  )
  expect_equal(diversity(model, "RW"), length(terminals(model, "RW")))
  expect_equal(diversity(model, "ND"), length(terminals(model, "ND")))
})

test_that("diversity computes what is expected on sim lists", {
  config <- create_locations(25, 25, seed = 8, symmetric = TRUE)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.05, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    precision = .Machine$double.eps^0.5
  )
  orders <- c(0, 0.5, 1, 1.5, 3, Inf)
  for (gamma in orders) {
    divs <- grid_diversity(models, "renyi", order = gamma)
    ddivs <- diversity(models, "renyi", order = gamma)
    expect_equal(divs, ddivs)
    expect_length(divs, length(models))
    for (k in seq_along(models)) {
      expect_equal(divs[k], diversity(models[[k]], "renyi", order = gamma))
    }
  }
  for (term_def in c("ND", "RW")) {
    divs <- grid_diversity(models, term_def)
    ddivs <- diversity(models, term_def)
    expect_equal(divs, ddivs)
    for (k in seq_along(models)) {
      expect_equal(divs[k], diversity(models[[k]], term_def))
    }
  }
})
