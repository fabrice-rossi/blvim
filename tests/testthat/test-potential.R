test_that("potential is NA when it cannot be computed", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_true(is.na(sim_potential(model)))
})

test_that("potential is correctly computed", {
  for (k in 1:5) {
    config <- create_locations(35 + k, 45 + k, seed = k)
    withr::local_seed(2 * k)
    kappas <- runif(45 + k, min = 0.5, max = 1.5)
    model <- blvim(config$costs, config$X, 1.5, 1, config$Z,
      kappa = kappas,
      precision = .Machine$double.eps^0.5
    )
    exp_c <- exp(-inverse_cost(model) * costs(model))
    z_alpha <- attractiveness(model)^(return_to_scale(model))
    the_potential <- as.numeric(production(model) %*% log(exp_c %*% z_alpha)) / return_to_scale(model) - sum(kappas * attractiveness(model))
    expect_equal(sim_potential(model), the_potential)
  }
})

test_that("Jacobian is NA when it cannot be computed", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_true(is.na(sim_fp_jacobian(model)))
})

test_that("Jacobian is correctly computed", {
  for (k in 1:5) {
    config <- create_locations(35 + k, 45 + k, seed = k)
    withr::local_seed(2 * k)
    kappas <- runif(45 + k, min = 0.5, max = 1.5)
    model <- blvim(config$costs, config$X, 1.5, 25, config$Z,
      kappa = kappas,
      precision = .Machine$double.eps^0.5
    )
    expect_equal(sim_fp_jacobian(model),
      fp_jacobian_non_zero(model),
      tolerance = 1e-5
    )
  }
})
