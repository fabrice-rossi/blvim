test_that("sim objects print as expected", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_snapshot(model)
})

test_that("static sim objects are not produced by iterations", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_equal(sim_iterations(model), 1L)
  expect_equal(sim_converged(model), NA)
})

test_that("sim object validation detects errors", {
  Y <- matrix(1:(10 * 15), nrow = 10, ncol = 15)
  Z <- 1:15
  ## size mismatch
  expect_error(new_sim(Y, Z[-1]))
  expect_error(new_sim(Y[, -1], Z))
  ## name size mismatch
  expect_error(new_sim(Y, Z, origin_names = letters[1:9]))
  expect_error(new_sim(Y, Z, origin_names = letters[1:11]))
  expect_error(new_sim(Y, Z, destination_names = letters[1:10]))
  expect_error(new_sim(Y, Z, destination_names = letters[1:20]))
})
