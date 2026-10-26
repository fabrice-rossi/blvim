test_that("blvim_gradient_control validates history", {
  expect_false(blvim_gradient_control()$history)
  expect_true(blvim_gradient_control(history = TRUE)$history)
  for (wrong in list(NA, 1, "yes", c(TRUE, FALSE))) {
    expect_error(blvim_gradient_control(history = wrong), "history")
  }
})

test_that("no history is recorded by default", {
  config <- create_locations(10, 12, seed = 10)
  for (algorithm in c("linear", "gradient", "gradient_unit")) {
    model <- blvim(config$costs, config$X, 1.5, 2, config$Z,
      algorithm = algorithm
    )
    expect_null(sim_history(model))
  }
  static <- static_blvim(config$costs, config$X, 1.5, 2, config$Z)
  expect_null(sim_history(static))
})

test_that("the linear algorithms ignore the history parameter", {
  config <- create_locations(10, 12, seed = 11)
  model <- blvim(config$costs, config$X, 1.5, 2, config$Z,
    control = blvim_gradient_control(history = TRUE)
  )
  expect_null(sim_history(model))
})

test_that("sim_history describes the iterations of the gradient algorithms", {
  config <- create_locations(20, 25, seed = 12)
  withr::local_seed(12)
  kappas <- runif(length(config$Z), min = 0.5, max = 2)
  control <- blvim_gradient_control(history = TRUE)
  for (algorithm in c("gradient", "gradient_unit")) {
    model <- blvim(config$costs, config$X, 1.5, 20, config$Z,
      kappa = kappas, algorithm = algorithm, control = control
    )
    history <- sim_history(model)
    expect_s3_class(history, "data.frame")
    expect_named(history, c(
      "iteration", "gap", "potential", "step", "step_norm",
      "line_search_reductions", "min_U"
    ))
    expect_equal(nrow(history), sim_iterations(model))
    expect_equal(history$iteration, seq_len(nrow(history)) - 1L)
    expect_true(all(diff(history$potential) >= 0))
    final <- history[nrow(history), ]
    expect_equal(final$potential, sim_potential(model))
    expect_equal(final$gap, sim_diagnostic(model)$cd$duality_gap)
    expect_equal(
      final$min_U,
      min(kappas * attractiveness(model)) / sum(config$X)
    )
    ## the history does not change the result
    ref <- blvim(config$costs, config$X, 1.5, 20, config$Z,
      kappa = kappas, algorithm = algorithm
    )
    expect_identical(attractiveness(model), attractiveness(ref))
  }
})

test_that("the history starts at the potential of the initial point", {
  config <- create_locations(20, 25, seed = 13)
  ## initial point on the simplex, so that it is not changed by the projection
  Z <- config$Z / sum(config$Z) * sum(config$X)
  model <- blvim(config$costs, config$X, 1.5, 20, Z,
    algorithm = "gradient_unit",
    control = blvim_gradient_control(history = TRUE)
  )
  expect_equal(
    sim_history(model)$potential[1],
    internal_sim_potential(
      config$costs, config$X, 1.5, 20, Z, rep(1, length(Z))
    )
  )
})

test_that("history is kept only for the retained runs", {
  config <- create_locations(20, 25, seed = 14)
  withr::local_seed(14)
  starts <- t(replicate(4, config$Z * runif(length(config$Z), 0.5, 1.5)))
  control <- blvim_gradient_control(history = TRUE)
  model <- blvim(config$costs, config$X, 1.5, 20, starts,
    algorithm = "gradient", control = control
  )
  history <- sim_history(model)
  expect_s3_class(history, "data.frame")
  expect_equal(history$potential[nrow(history)], max(sim_logs(model)$potential))
  expect_null(sim_runs(model))
  expect_false("history" %in% names(sim_logs(model)))

  model <- blvim(config$costs, config$X, 1.5, 20, starts,
    algorithm = "gradient", control = control, keep_runs = TRUE
  )
  runs <- sim_runs(model)
  for (k in seq_along(runs)) {
    history <- sim_history(runs[[k]])
    expect_equal(nrow(history), sim_logs(model)$iterations[k])
    expect_equal(history$potential[nrow(history)], sim_logs(model)$potential[k])
  }
})

test_that("grid_blvim records histories", {
  config <- create_locations(15, 15, seed = 15)
  grid <- grid_blvim(config$costs, config$X, c(1.2, 1.5), c(5, 20), config$Z,
    algorithm = "gradient_unit",
    control = blvim_gradient_control(history = TRUE)
  )
  for (k in seq_along(grid)) {
    expect_equal(nrow(sim_history(grid[[k]])), sim_iterations(grid[[k]]))
  }
})

test_that("sim_diagnostic reports the history", {
  config <- create_locations(10, 12, seed = 16)
  model <- blvim(config$costs, config$X, 1.5, 2, config$Z,
    algorithm = "gradient",
    control = blvim_gradient_control(history = TRUE)
  )
  expect_match(
    format(sim_diagnostic(model)),
    "Iteration history", all = FALSE
  )
  model <- blvim(config$costs, config$X, 1.5, 2, config$Z,
    algorithm = "gradient"
  )
  expect_no_match(format(sim_diagnostic(model)), "Iteration history")
})

test_that("sim_history stacks the histories of a sim_list", {
  config <- create_locations(15, 15, seed = 17)
  grid <- grid_blvim(config$costs, config$X, c(1.2, 1.5), c(5, 20), config$Z,
    algorithm = "gradient",
    control = blvim_gradient_control(history = TRUE)
  )
  histories <- sim_history(grid)
  expect_s3_class(histories, "data.frame")
  expect_named(histories, c("sim", names(sim_history(grid[[1]]))))
  expect_identical(
    histories$sim,
    rep(seq_along(grid), grid_sim_iterations(grid))
  )
  expect_identical(
    rownames(histories),
    as.character(seq_len(nrow(histories)))
  )
  for (k in seq_along(grid)) {
    part <- histories[histories$sim == k, -1]
    rownames(part) <- NULL
    expect_identical(part, sim_history(grid[[k]]))
  }
  expect_identical(grid_sim_history(grid), histories)
})

test_that("sim_history skips models without history in a sim_list", {
  config <- create_locations(15, 15, seed = 18)
  with_history <- blvim(config$costs, config$X, 1.5, 10, config$Z,
    algorithm = "gradient_unit",
    control = blvim_gradient_control(history = TRUE)
  )
  without <- blvim(config$costs, config$X, 1.5, 10, config$Z,
    algorithm = "gradient_unit"
  )
  sims <- sim_list(list(without, with_history, without))
  histories <- sim_history(sims)
  expect_true(all(histories$sim == 2L))
  expect_equal(nrow(histories), sim_iterations(with_history))
  expect_null(sim_history(sim_list(list(without, without))))
})

test_that("sim_history works on the runs of a multi-start blvim", {
  config <- create_locations(20, 25, seed = 19)
  withr::local_seed(19)
  starts <- t(replicate(3, config$Z * runif(length(config$Z), 0.5, 1.5)))
  model <- blvim(config$costs, config$X, 1.5, 20, starts,
    algorithm = "gradient", keep_runs = TRUE,
    control = blvim_gradient_control(history = TRUE)
  )
  histories <- sim_history(sim_runs(model))
  expect_identical(
    as.vector(table(histories$sim)),
    sim_logs(model)$iterations
  )
})
