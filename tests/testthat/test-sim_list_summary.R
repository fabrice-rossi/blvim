test_that("summary calculation bipartite", {
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
  model_summary <- summary(models)
  expect_s3_class(model_summary, c("list", "summary_sim_list"))
  expect_named(model_summary, c("median", "distortion", "withinss", "nb_sims"))
  expect_equal(model_summary$nb_sims, length(models))
  model_median <- median(models, return_distances = TRUE)
  expect_equal(model_summary$median, model_median)
  expect_equal(model_summary$distortion, attr(model_median, "distortion"))
  expect_equal(model_summary$withinss, sum(attr(model_median, "distances")))
  expect_snapshot(model_summary)
})

test_that("summary calculation non bipartite", {
  config <- create_locations(20, 20, seed = 120)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    bipartite = FALSE,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  model_summary <- summary(models)
  expect_s3_class(model_summary, c("list", "summary_sim_list"))
  expect_named(model_summary, c(
    "median", "distortion", "withinss", "nb_sims",
    "nb_configurations"
  ))
  expect_equal(model_summary$nb_sims, length(models))
  model_median <- median(models, return_distances = TRUE)
  expect_equal(model_summary$median, model_median)
  expect_equal(model_summary$distortion, attr(model_median, "distortion"))
  expect_equal(model_summary$withinss, sum(attr(model_median, "distances")))
  expect_equal(
    model_summary$nb_configurations,
    length(unique(lapply(models, terminals, definition = "RW")))
  )
  expect_snapshot(model_summary)
})
