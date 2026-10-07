test_that("initial attractiveness is attractiveness for static models", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_identical(initial_attractiveness(model), attractiveness(model))
  expect_equal(initial_attractiveness(model), config$Z)
})

test_that("blvim uses the documented initial values when Z=NULL", {
  ## non bipartite case
  config <- create_locations(40, 50, seed = 2196)
  kappas <- runif(length(config$Z), min = 0.5, max = 2)
  model <- blvim(config$costs, config$X, 1.5, 20,
    kappa = kappas,
    algorithm = "gradient_unit"
  )
  expect_equal(
    initial_attractiveness(model),
    (sum(config$X) / length(config$Z)) / kappas
  )
  ## non bipartite case
  config <- create_locations(40, 40, seed = 2196, symmetric = TRUE)
  kappas <- runif(length(config$Z), min = 0.5, max = 2)
  model <- blvim(config$costs, config$X, 1.5, 20,
    kappa = kappas,
    algorithm = "gradient_unit", bipartite = FALSE
  )
  expect_equal(
    initial_attractiveness(model),
    config$X / kappas
  )
})

test_that("blvim keeps its initial attractiveness", {
  config <- create_locations(40, 50, seed = 96)
  model <- blvim(config$costs, config$X, 1.5, 20, config$Z,
    algorithm = "gradient_unit"
  )
  expect_equal(initial_attractiveness(model), config$Z)
})

test_that("blvim keeps all initial attractivenesses", {
  config <- create_locations(40, 50, seed = 128)
  kappas <- runif(length(config$Z), min = 0.5, max = 2)
  withr::local_seed(12)
  sample <- sample_weighted_simplex(kappas, C = sum(config$X), n = 75)
  model <- blvim(config$costs, config$X, 1.5, 20, sample$Z,
    algorithm = "gradient_unit", keep_runs = TRUE
  )
  all_initials <- sapply(sim_runs(model), initial_attractiveness)
  expect_equal(sample$Z, t(all_initials))
})
