test_that("sim_list are supported by basic vctrs functions", {
  config <- create_locations(20, 30, seed = 18)
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
  ## recognized as a list
  expect_true(vctrs::obj_is_list(models))
  ## slicing
  expect_equal(vctrs::vec_slice(models, 1), models[1])
  expect_equal(vctrs::vec_slice(models, 4:10), models[4:10])
})
