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
