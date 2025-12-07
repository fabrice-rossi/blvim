test_that("median calculation works as expected", {
  config <- create_locations(25, 20, seed = 28928)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.05, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 10000,
    precision = .Machine$double.eps^0.5
  )
  for (the_flows in c("full", "destination", "attractiveness")) {
    f_median <- median(models, flows = the_flows)
    expect_s3_class(f_median, "sim")
    ## no distance
    expect_null(attr(f_median, "distances"))
    ## attributes
    f_median_pos <- attr(f_median, "index")
    f_median_distortion <- attr(f_median, "distortion")
    expect_type(f_median_pos, "integer")
    expect_type(f_median_distortion, "double")
    ## remove the attributes for further comparison
    attr(f_median, "index") <- NULL
    attr(f_median, "distortion") <- NULL
    ## the median is one of the models
    median_vs_models <- sapply(models, identical, f_median)
    median_idx <- which(median_vs_models)
    expect_equal(f_median_pos, median_idx)
    ## exactly one match (as objects in models are all different)
    expect_equal(sum(median_vs_models), 1L)
    ## minimal distance
    distances_d <- sim_distance(models, flows = the_flows)
    distances_m <- as.matrix(distances_d)
    min_dist <- min(colSums(distances_m))
    expect_lte(sum(distances_m[median_idx, ]), min_dist)
    expect_equal(f_median_distortion, min_dist / length(models))
    ## distance saving
    expect_equal(
      attr(
        median(models, flows = the_flows, return_distances = TRUE),
        "distances"
      ),
      distances_d
    )
  }
})

test_that("median calculation works a single model", {
  config <- create_locations(25, 20, seed = 28928)
  alphas <- 1.5
  betas <- 2
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 10000,
    precision = .Machine$double.eps^0.5
  )
  for (the_flows in c("full", "destination", "attractiveness")) {
    f_median <- median(models, flows = the_flows)
    expect_equal(attr(f_median, "index"), 1L)
    expect_equal(attr(f_median, "distortion"), 0)
    attr(f_median, "index") <- NULL
    attr(f_median, "distortion") <- NULL
    expect_equal(f_median, models[[1]])
  }
})

test_that("quantile calculation works as expected", {
  config <- create_locations(20, 15, seed = 2892)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.05, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 10000,
    precision = .Machine$double.eps^0.5
  )
  f_quant <- quantile.sim_list(models, flows = "full", probs = c(0, 0.5, 1))
  f_vals <- fortify.sim_list(models, flows = "full")
  expect_equal(dim(f_quant), c(20L * 15L, 5L))
  all_equal <- TRUE
  for (i in 1:20) {
    for (j in 1:15) {
      the_vals <- f_vals$flow[f_vals$origin_idx == i &
        f_vals$destination_idx == j]
      the_quants <- stats::quantile(the_vals,
        probs = c(0, 0.5, 1),
        names = FALSE
      )
      if (!identical(
        as.numeric(f_quant[f_quant$origin_idx == i &
          f_quant$destination_idx == j, 3:5]),
        the_quants
      )) {
        all_equal <- FALSE
        break
      }
    }
    if (!all_equal) {
      break
    }
  }
  expect_true(all_equal)
  all_equal <- TRUE
  f_quant <- quantile.sim_list(models,
    flows = "destination",
    probs = c(0.1, 0.65, 0.8, 0.9)
  )
  f_vals <- fortify.sim_list(models, flows = "destination")
  expect_equal(dim(f_quant), c(15L, 5L))
  for (j in 1:15) {
    the_vals <- f_vals$flow[f_vals$destination == j]
    the_quants <- stats::quantile(the_vals,
      probs = c(0.1, 0.65, 0.8, 0.9),
      names = FALSE
    )
    if (!identical(
      as.numeric(f_quant[f_quant$destination == j, 2:5]),
      the_quants
    )) {
      all_equal <- FALSE
      break
    }
  }
  all_equal <- TRUE
  f_quant <- quantile.sim_list(models,
    flows = "attractiveness",
    probs = seq(0, 1, by = 0.1)
  )
  f_vals <- fortify.sim_list(models, flows = "attractiveness")
  expect_equal(dim(f_quant), c(15L, 12L))
  for (j in 1:15) {
    the_vals <- f_vals$attractiveness[f_vals$destination == j]
    the_quants <- stats::quantile(the_vals,
      probs = seq(0, 1, by = 0.1),
      names = FALSE
    )
    if (!identical(
      as.numeric(f_quant[f_quant$destination == j, 2:12]),
      the_quants
    )) {
      all_equal <- FALSE
      break
    }
  }
  expect_true(all_equal)
})

test_that("quantile warns about unused parameters", {
  config <- create_locations(20, 15, seed = 2892)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.05, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 10000,
    precision = .Machine$double.eps^0.5
  )
  expect_warning(quantile.sim_list(models,
    flows = "attractiveness",
    normalisation = "none"
  ))
  expect_warning(quantile.sim_list(models,
    flows = "destination",
    normalisation = "none"
  ))
})
