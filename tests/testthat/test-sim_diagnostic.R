test_that("sim_diagnostic objects prints as expected", {
  config <- create_locations(40, 50, seed = 0)
  ## static
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_snapshot(sim_diagnostic(model))
  ## linear
  model <- blvim(config$costs, config$X, 1.5, 1, config$Z, precision = .Machine$double.eps^0.5)
  expect_snapshot(sim_diagnostic(model))
  model_noconv <- blvim(config$costs, config$X, 1, 1, config$Z, iter_max = 1000)
  expect_snapshot(sim_diagnostic(model_noconv))
  ## gradient
  skip_on_ci() ## to fragile w.r.t. duality gap reporting
  model <- blvim(config$costs, config$X, 1.1, 10, config$Z,
    precision = .Machine$double.eps^0.5,
    algorithm = "gradient"
  )
  expect_snapshot(sim_diagnostic(model))
  model <- blvim(config$costs, config$X, 1.1, 10, config$Z,
    precision = 1e-6,
    algorithm = "gradient"
  )
  expect_snapshot(sim_diagnostic(model))
  model_noconv <- blvim(config$costs, config$X, 1, 10, config$Z,
    iter_max = 100,
    algorithm = "gradient"
  )
  expect_snapshot(sim_diagnostic(model_noconv))
})
