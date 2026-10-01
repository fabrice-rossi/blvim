test_that("Simplex projection returns a point in the specified simplex", {
  withr::local_seed(121)
  ## sample in [-1;1]^20 and then project on the unit simplex
  for (k in 1:20) {
    y <- stats::runif(20, min = -1, max = 1)
    yp <- R_project_simplex(y)
    expect_all_true(yp >= 0)
    expect_equal(sum(yp), 1)
  }
  ## more general case
  for (k in 1:20) {
    kappas <- stats::runif(20, min = 0.5, max = 1.5)
    y <- stats::runif(20, min = -1, max = 1)
    C_tot <- sum(kappas)
    yp <- R_project_weighted_simplex(y, kappas, C_tot)
    expect_all_true(yp >= 0)
    expect_equal(sum(yp * kappas), C_tot)
  }
})

test_that("Simplex projection returns the expect projection (central)", {
  withr::local_seed(122)
  for (k in 1:30) {
    ## sample in the simplex
    y <- sample_simplex(rep(1, 20), 1)
    ## move away
    repeat {
      y_ext <- y + sample(c(1, -1), 1) * runif(1, 10 * .Machine$double.eps^0.5, 10)
      ## this should not be necessary
      if (abs(sum(y_ext) - 1) > 10 * .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- R_project_simplex(y_ext)
    expect_equal(yp, y)
  }
  ## weighted case
  for (k in 1:30) {
    ## sample in the simplex
    kappas <- stats::runif(20, min = 0.5, max = 1.5)
    C_tot <- sum(kappas)
    y <- sample_simplex(kappas, C_tot)
    ## move away
    repeat {
      y_ext <- y + sample(c(1, -1), 1) * runif(1, 10 * .Machine$double.eps^0.5, 10) * kappas
      ## this should not be necessary
      if (abs(sum(y_ext * kappas) - C_tot) > 10 * .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- R_project_weighted_simplex(y_ext, kappas, C_tot)
    expect_equal(yp, y)
  }
})

test_that("Simplex projection returns the expect projection (faces)", {
  withr::local_seed(123)
  for (k in 1:30) {
    ## sample in the faces of the simplex
    repeat {
      active <- sample(c(TRUE, FALSE), 20, replace = TRUE)
      sa <- sum(active)
      if (sa > 0 && sa < 20) {
        break
      }
    }
    y <- sample_simplex(rep(1, 20), 1, which(active))
    ## move away
    repeat {
      y_ext <- y + sample(c(1, -1), 1) * runif(1, 0, 10)
      ## this should not be necessary
      if (abs(sum(y_ext) - 1) > 10 * .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- R_project_simplex(y_ext)
    expect_equal(yp, y)
  }
  ## weighted
  for (k in 1:30) {
    ## sample in the faces of the simplex
    kappas <- stats::runif(20, min = 0.5, max = 1.5)
    C_tot <- sum(kappas)
    repeat {
      active <- sample(c(TRUE, FALSE), 20, replace = TRUE)
      sa <- sum(active)
      if (sa > 0 && sa < 20) {
        break
      }
    }
    y <- sample_simplex(kappas, C_tot, which(active))
    ## move away
    repeat {
      y_ext <- y + sample(c(1, -1), 1) * runif(1, 0, 10) * kappas
      ## this should not be necessary
      if (abs(sum(y_ext * kappas) - C_tot) > 10 * .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- R_project_weighted_simplex(y_ext, kappas, C_tot)
    expect_equal(yp, y)
  }
})

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
                   precision = (.Machine$double.eps^0.5),
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
      precision = (.Machine$double.eps^0.5),
      algorithm = "gradient_unit",
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
  expect_equal(attractiveness(g_model), attractiveness(u_model))
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
