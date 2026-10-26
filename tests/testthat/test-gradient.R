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

test_that("gradient and gradient_unit agree for a constant kappa", {
  config <- create_locations(40, 50, seed = 3)
  kappas <- rep(2.5, length(config$Z))
  g_model <- blvim(config$costs, config$X, 1.5, 200, config$Z,
    kappa = kappas, algorithm = "gradient"
  )
  u_model <- blvim(config$costs, config$X, 1.5, 200, config$Z,
    kappa = kappas, algorithm = "gradient_unit"
  )
  expect_identical(attractiveness(g_model), attractiveness(u_model))
  expect_identical(sim_iterations(g_model), sim_iterations(u_model))
})

test_that("gradient follows the Euclidean geometry of the attractivenesses", {
  ## first step of the ascent in Z, computed directly in R
  fixture <- fixture_ascent(p = 6, beta = 2)
  X_tot <- sum(fixture$X)
  Z <- R_project_weighted_simplex(fixture$Z, fixture$kappa, X_tot)
  W <- exp(-fixture$beta * fixture$costs)
  A <- drop(W %*% Z^fixture$alpha)
  grad_Z <- Z^(fixture$alpha - 1) * drop(crossprod(W, fixture$X / A))
  ## rho_init is applied in U with a unit mean metric
  metric <- fixture$kappa^2
  rho_Z <- 1e-3 * X_tot^2 / mean(metric)
  Z_new <- R_project_weighted_simplex(Z + rho_Z * grad_Z, fixture$kappa, X_tot)
  result <- run_ascent(fixture,
    metric = metric, rho_init = 1e-3, iter_max = 1L,
    record_history = TRUE
  )
  ## the small initial step is accepted without line search reduction
  expect_identical(result$history$line_search_reductions[1], 0L)
  expect_equal(result$Z[, 1], Z_new)
})

test_that("blvim_gradient_control validates the preconditioner", {
  expect_null(blvim_gradient_control()$preconditioner)
  expect_identical(
    blvim_gradient_control(preconditioner = 1:3)$preconditioner,
    c(1, 2, 3)
  )
  for (wrong in list("a", numeric(), c(1, 0), c(1, -1), c(1, NA), c(1, Inf))) {
    expect_error(blvim_gradient_control(preconditioner = wrong), "preconditioner")
  }
})

test_that("blvim checks the length of the preconditioner", {
  config <- create_locations(10, 12, seed = 4)
  control <- blvim_gradient_control(preconditioner = rep(1, 11))
  for (algorithm in c("gradient", "gradient_unit")) {
    expect_error(
      blvim(config$costs, config$X, 1.5, 2, config$Z,
        algorithm = algorithm, control = control
      ),
      "preconditioner"
    )
  }
  ## not used by the other algorithms
  expect_no_error(
    blvim(config$costs, config$X, 1.5, 2, config$Z, control = control)
  )
})

test_that("a constant preconditioner has no effect", {
  config <- create_locations(20, 25, seed = 5)
  withr::local_seed(5)
  kappas <- runif(length(config$Z), min = 0.5, max = 2)
  control <- blvim_gradient_control(preconditioner = rep(7, length(config$Z)))
  for (algorithm in c("gradient", "gradient_unit")) {
    ref <- blvim(config$costs, config$X, 1.5, 20, config$Z,
      kappa = kappas, algorithm = algorithm
    )
    pre <- blvim(config$costs, config$X, 1.5, 20, config$Z,
      kappa = kappas, algorithm = algorithm, control = control
    )
    ## the rescaling of the preconditioner is exact only up to rounding
    expect_equal(attractiveness(pre), attractiveness(ref))
    expect_equal(sim_iterations(pre), sim_iterations(ref))
  }
})

test_that("preconditioners relate the two gradient algorithms", {
  config <- create_locations(20, 25, seed = 6)
  withr::local_seed(6)
  kappas <- runif(length(config$Z), min = 0.5, max = 2)
  g_model <- blvim(config$costs, config$X, 1.5, 20, config$Z,
    kappa = kappas, algorithm = "gradient"
  )
  u_model <- blvim(config$costs, config$X, 1.5, 20, config$Z,
    kappa = kappas, algorithm = "gradient_unit",
    control = blvim_gradient_control(preconditioner = kappas^2)
  )
  expect_identical(attractiveness(u_model), attractiveness(g_model))
  expect_identical(sim_iterations(u_model), sim_iterations(g_model))
  ## kappa^2 / kappa^2 is not exactly one, hence the tolerance
  g_model <- blvim(config$costs, config$X, 1.5, 20, config$Z,
    kappa = kappas, algorithm = "gradient",
    control = blvim_gradient_control(preconditioner = 1 / kappas^2)
  )
  u_model <- blvim(config$costs, config$X, 1.5, 20, config$Z,
    kappa = kappas, algorithm = "gradient_unit"
  )
  expect_equal(attractiveness(g_model), attractiveness(u_model))
})

test_that("a preconditioner changes the path of the algorithm", {
  config <- create_locations(20, 25, seed = 7)
  ref <- blvim(config$costs, config$X, 1.5, 20, config$Z,
    algorithm = "gradient_unit", precision = 1e-9
  )
  withr::local_seed(7)
  pre <- blvim(config$costs, config$X, 1.5, 20, config$Z,
    algorithm = "gradient_unit", precision = 1e-9,
    control = blvim_gradient_control(
      preconditioner = runif(length(config$Z), min = 0.1, max = 10)
    )
  )
  expect_true(sim_converged(pre))
  same_path <- identical(sim_iterations(pre), sim_iterations(ref)) &&
    identical(attractiveness(pre), attractiveness(ref))
  expect_false(same_path)
  expect_equal(destination_flow(pre), attractiveness(pre),
    tolerance = 10 * (.Machine$double.eps^0.5)
  )
})

test_that("grid_blvim uses the gradient control parameters", {
  config <- create_locations(15, 15, seed = 8)
  withr::local_seed(8)
  control <- blvim_gradient_control(
    rho_init = 0.1,
    preconditioner = runif(length(config$Z), min = 0.1, max = 10)
  )
  grid <- grid_blvim(config$costs, config$X, c(1.2, 1.5), 20, config$Z,
    algorithm = "gradient_unit", control = control
  )
  for (k in seq_along(grid)) {
    model <- blvim(config$costs, config$X, grid[[k]]$alpha, 20, config$Z,
      algorithm = "gradient_unit", control = control
    )
    expect_identical(attractiveness(grid[[k]]), attractiveness(model))
  }
})
