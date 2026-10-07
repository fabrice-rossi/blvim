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
  ## wrong kappa
  expect_error(blvim(config$costs, config$X, 1.5, 1, config$Z, -2))
  expect_error(blvim(config$costs, config$X, 1.5, 1, config$Z, "A"))
  ## wrong X
  expect_error(blvim(config$costs, c(1, 2, 3 - 4), 1.5, 1, config$Z))
  expect_error(blvim(config$costs, c(1, 2, Inf, 1), 1.5, 1, config$Z))
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

test_that("blvim fulfills its contracts with kappas", {
  config <- create_locations(40, 50, seed = 0)
  for (rep in 1:10) {
    kappas <- runif(length(config$Z), min = 0.5, max = 2)
    model <- blvim(config$costs, config$X, 1.5, 10, config$Z,
      kappa = kappas,
      precision = (.Machine$double.eps^0.5),
      epsilon = 0.1,
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
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z, algorithm = "quadratic")
  r_model <- r_blvim(config$costs, config$X, 1.5, 1, config$Z, quadratic = TRUE)
  expect_equal(flows(model), flows(r_model))
  expect_equal(production(model), production(r_model))
  expect_equal(attractiveness(model), attractiveness(r_model))
})

test_that("blvim obeys to iteration control", {
  config <- create_locations(40, 50, seed = 2)
  for (k in seq(500L, 5000L, by = 500L)) {
    model <- blvim(config$costs, config$X, 1.5, 1, config$Z, iter_max = k)
    expect_lte(sim_iterations(model), k + 1L)
    expect_true(sim_converged(model) == (sim_iterations(model) <= k))
  }
})

test_that("blvim reports consistently the logs and the runs", {
  config <- create_locations(40, 50, seed = 1)
  kappas <- runif(length(config$Z), min = 0.5, max = 2)
  withr::local_seed(12)
  sample <- sample_weighted_simplex(kappas, C = sum(config$X), n = 75)
  model <- blvim(config$costs, config$X, 1.5, 20, sample$Z,
    algorithm = "gradient_unit", keep_runs = TRUE
  )
  all_runs <- sim_runs(model)
  expect_length(all_runs, nrow(sample$Z))
  ## check consistency with logs
  expect_equal(sim_logs(model)$run, 1:nrow(sample$Z))
  expect_equal(sim_potential(all_runs), sim_logs(model)$potential)
  expect_equal(sim_iterations(all_runs), sim_logs(model)$iteration)
  expect_equal(sim_converged(all_runs), sim_logs(model)$converged)
  all_diags <- lapply(all_runs, sim_diagnostic)
  expect_equal(sapply(all_diags, function(x) x$cd$status), sim_logs(model)$status)
  expect_equal(sapply(all_diags, function(x) x$cd$duality_gap), sim_logs(model)$gap)
  expect_equal(sapply(all_diags, function(x) x$cd$eval), sim_logs(model)$evaluation)
  ## if we do not keep the runs AND have multiple of thems, sim_runs returns NULL
  model <- blvim(config$costs, config$X, 1.5, 20, sample$Z,
    algorithm = "gradient_unit", keep_runs = FALSE
  )
  expect_null(sim_runs(model))
})

test_that("blvim selects the best model", {
  config <- create_locations(40, 50, seed = 12)
  kappas <- runif(length(config$Z), min = 0.5, max = 2)
  withr::local_seed(12)
  sample <- sample_weighted_simplex(kappas, C = sum(config$X), n = 75)
  model <- blvim(config$costs, config$X, 1.5, 20, sample$Z,
    algorithm = "gradient_unit", keep_runs = TRUE
  )
  all_runs <- sim_runs(model)
  expect_all_true(sim_potential(all_runs) <= sim_potential(model))
})

test_that("blvim fills run information with a single starting point", {
  config <- create_locations(40, 50, seed = 12)
  kappas <- runif(length(config$Z), min = 0.5, max = 2)
  withr::local_seed(12)
  model <- blvim(config$costs, config$X, 1.5, 20, config$Z,
    algorithm = "gradient_unit"
  )
  all_runs <- sim_runs(model)
  expect_length(all_runs, 1)
  expect_equal(flows(all_runs[[1]]), flows(model))
  expect_equal(attractiveness(all_runs[[1]]), attractiveness(model))
  expect_equal(sim_potential(model), sim_logs(model)$potential)
  expect_equal(sim_iterations(model), sim_logs(model)$iteration)
  expect_equal(sim_converged(model), sim_logs(model)$converged)
  all_diags <- sim_diagnostic(model)
  expect_equal(all_diags$cd$status, sim_logs(model)$status)
  expect_equal(all_diags$cd$duality_gap, sim_logs(model)$gap)
  expect_equal(all_diags$cd$eval, sim_logs(model)$evaluation)
})

test_that("reporting error cases", {
  expect_error(sim_runs(list()))
  expect_error(sim_logs(list()))
})
