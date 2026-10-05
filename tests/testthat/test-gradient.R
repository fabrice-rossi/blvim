test_that("blvim fulfills its contracts", {
  config <- create_locations(40, 50, seed = 0)
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z,
    precision = .Machine$double.eps^0.5,
    algorithm = "gradient"
  )
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

test_that("blvim fulfills its contracts with kappas", {
  config <- create_locations(40, 50, seed = 0)
  withr::local_seed(12)
  for (rep in 1:10) {
    kappas <- runif(length(config$Z), min = 0.5, max = 2)
    model <- blvim(config$costs, config$X, 1.5, 200, config$Z,
      kappa = kappas,
      precision = 1e-7,
      algorithm = "gradient",
    )
    expect_equal(dim(flows(model)), c(length(config$X), length(config$Z)))
    ## production constraints
    expect_equal(rowSums(flows(model)), config$X)
    expect_equal(production(model), config$X)
    ## attractiveness times kappas should equal to the destination flows
    ## as testthat comparison model is different from ours, we set at relatively
    ## high value of tolerance
    expect_equal(destination_flow(model), attractiveness(model) * kappas,
      tolerance = 10 * (.Machine$double.eps^0.5)
    )
    expect_equal(kappas, sim_conversion(model))
  }
})

test_that("blvim fulfills its contracts with kappas", {
  config <- create_locations(40, 50, seed = 0)
  withr::local_seed(12)
  for (rep in 1:10) {
    kappas <- runif(length(config$Z), min = 0.5, max = 2)
    model <- blvim(config$costs, config$X, 1.5, 200, config$Z,
      kappa = kappas,
      precision = 1e-7,
      algorithm = "gradient_unit",
    )
    expect_equal(dim(flows(model)), c(length(config$X), length(config$Z)))
    ## production constraints
    expect_equal(rowSums(flows(model)), config$X)
    expect_equal(production(model), config$X)
    expect_equal(destination_flow(model), attractiveness(model) * kappas,
      tolerance = model$diagnostic$duality_gap
    )
    expect_equal(kappas, sim_conversion(model))
  }
})

test_that("blvim computes the BLV model", {
  config <- create_locations(40, 50, seed = 1)
  ## we compare the algorithms
  g_model <- blvim(config$costs, config$X, 1.5, 200, config$Z,
    algorithm = "gradient",
    precision = (.Machine$double.eps^0.5)
  )
  u_model <- blvim(config$costs, config$X, 1.5, 200, config$Z,
    precision = (.Machine$double.eps^0.5), algorithm = "gradient_unit"
  )
  expect_equal(flows(g_model), flows(u_model))
  expect_equal(production(g_model), production(u_model))
  expect_equal(attractiveness(g_model), attractiveness(u_model),
    tolerance = max(
      g_model$diagnostic$duality_gap,
      u_model$diagnostic$duality_gap
    )
  )
})

test_that("blvim obeys to iteration control", {
  config <- create_locations(40, 50, seed = 2)
  for (k in seq(20L, 100L, by = 10L)) {
    model <- blvim(config$costs, config$X, 1.5, 200, config$Z, iter_max = k, algorithm = "gradient")
    expect_lte(sim_iterations(model), k + 1L)
    expect_true(sim_converged(model) == (sim_iterations(model) <= k))
  }
  for (k in seq(20L, 100L, by = 10L)) {
    model <- blvim(config$costs, config$X, 1.5, 200, config$Z, iter_max = k, algorithm = "gradient_unit")
    expect_lte(sim_iterations(model), k + 1L)
    expect_true(sim_converged(model) == (sim_iterations(model) <= k))
  }
})
