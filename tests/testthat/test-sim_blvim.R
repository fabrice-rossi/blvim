test_that("sim_blvim objects prints as expected", {
  config <- create_locations(40, 50, seed = 0)
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z, precision = .Machine$double.eps^0.5)
  expect_snapshot(model)
  model_noconv <- blvim(config$costs, config$X, 1, 1, config$Z, iter_max = 1000)
  expect_snapshot(model_noconv)
})
