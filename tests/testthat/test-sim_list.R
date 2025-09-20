test_that("sim_list construction", {
  config <- create_locations(20, 30, seed = 120)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  model_list <- as.list(models)
  models_2 <- sim_list(model_list)
  expect_equal(models, models_2)
  ## error detection
  expect_error(sim_list(12))
  expect_error(sim_list(list(model_list[[1]], "foo")))
  model_list_bug <- model_list
  model_list_bug[[2]]$costs <- model_list_bug[[2]]$costs + 1
  expect_error(sim_list(model_list_bug))
  model_list_bug <- model_list
  origin_names(model_list_bug[[2]]) <- letters[1:20]
  expect_error(sim_list(model_list_bug))
  model_list_bug <- model_list
  destination_positions(model_list_bug[[2]]) <- config$pd
  expect_error(sim_list(model_list_bug))
})

test_that("sim_list is a list", {
  config <- create_locations(20, 30, seed = 4)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  expect_length(models, length(alphas) * length(betas))
  expect_s3_class(models, "sim_list")
  for (k in seq_along(models)) {
    expect_s3_class(models[k], "sim_list")
    expect_s3_class(models[[k]], "sim_blvim")
    expect_mapequal(unclass(models[k][[1]]), unclass(models[[k]]))
  }
  params <- expand.grid(alpha = alphas, beta = betas)
  expect_equal(params$alpha, sapply(models, return_to_scale))
  expect_equal(params$beta, sapply(models, inverse_cost))
  expect_equal(config$costs, costs(models))
})

test_that("sim_list prints as expected", {
  config <- create_locations(20, 30, seed = 5)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  expect_snapshot(models)
})

test_that("sim_list attractivenesses extraction works", {
  config <- create_locations(20, 30, seed = 4)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  grid_Z <- grid_attractiveness(models)
  expect_true(inherits(grid_Z, "matrix"))
  expect_equal(dim(grid_Z), c(length(alphas) * length(betas), length(config$Z)))
  for (k in seq_along(models)) {
    expect_equal(grid_Z[k, ], attractiveness(models[[k]]))
  }
})

test_that("sim_list destination flows extraction works", {
  config <- create_locations(20, 30, seed = 4)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  grid_Z <- grid_destination_flow(models)
  expect_true(inherits(grid_Z, "matrix"))
  expect_equal(dim(grid_Z), c(length(alphas) * length(betas), length(config$Z)))
  for (k in seq_along(models)) {
    expect_equal(grid_Z[k, ], destination_flow(models[[k]]))
  }
})

test_that("sim_list is_terminal extraction works", {
  config <- create_locations(20, 20, seed = 42, symmetric = TRUE)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    epsilon = 0.1,
    iter_max = 5000,
    precision = .Machine$double.eps^0.5
  )
  grid_term <- grid_is_terminal(models)
  expect_true(inherits(grid_term, "matrix"))
  expect_equal(dim(grid_term), c(length(alphas) * length(betas), length(config$Z)))
  for (k in seq_along(models)) {
    expect_equal(grid_term[k, ], is_terminal(models[[k]]))
  }
})

test_that("sim_list grid_* redundant functions work as expected", {
  config <- create_locations(20, 30, seed = 4)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    epsilon = 0.1,
    iter_max = 400,
    precision = .Machine$double.eps^0.5
  )
  expect_equal(grid_sim_converged(models), sim_converged(models))
  expect_equal(grid_sim_iterations(models), sim_iterations(models))
  expect_equal(grid_diversity(models), diversity(models))
})

test_that("sim_list extraction functions detect errors", {
  expect_error(grid_destination_flow(list()))
  expect_error(grid_attractiveness(2))
  expect_error(grid_is_terminal(data.frame(x = 1:10)))
})

test_that("sim_list common information restoration works", {
  config <- create_locations(20, 30, seed = 20)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  ## introduction names
  on <- paste(sample(letters, 20, replace = TRUE), 1:20, sep = "_")
  dn <- paste(sample(LETTERS, 30, replace = TRUE), 1:30, sep = "_")
  rownames(config$costs) <- on
  colnames(config$costs) <- dn
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  expect_equal(costs(models), config$costs)
  for (k in seq_along(models)) {
    expect_equal(origin_names(models[[k]]), on)
    expect_equal(destination_names(models[[k]]), dn)
    expect_equal(costs(models[[k]]), config$costs)
  }
})

test_that("sim_list modifications are prohibited", {
  config <- create_locations(20, 30, seed = 120)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  expect_error(models[[1]] <- models[[2]])
  expect_error(models[1:3] <- models[5:7])
})

test_that("sim_list out of range access tentative are detected", {
  config <- create_locations(20, 30, seed = 480)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  expect_error(models[c(1, 5, 20)], regexp = "out of range value")
  expect_error(models[[14:18]], regexp = "out of range value")
})
