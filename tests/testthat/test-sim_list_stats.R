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
      attr(median(models, flows = the_flows, return_distances = TRUE), "distances"),
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
