test_that("sim_wpc helpers work as expected", {
  config <- create_locations(40, 50, seed = 0)
  for (alpha in c(0.5, 1.5, 2)) {
    for (beta in c(1, 2, 3)) {
      model <- static_blvim(config$costs, config$X, alpha, beta, config$Z)
      expect_equal(return_to_scale(model), alpha)
      expect_equal(inverse_cost(model), beta)
    }
  }
  expect_equal(costs(model), config$costs)
})
