test_that("projected ascent converges to a point with a small duality gap", {
  for (fixture in list(fixture_ascent(), fixture_ascent(p = 5, n = 12))) {
    ## the duality gap cannot be reduced much below 1e-8 on some fixtures,
    ## with a platform dependent floor
    precision <- 1e-7
    result <- run_ascent(fixture, precision = precision)
    reference <- reference_ascent(fixture, result$Z)

    expect_true(result$converged)
    expect_equal(result$status, "converged")
    expect_equal(sum(reference$U), 1)
    expect_equal(result$gap, reference$gap, tolerance = 1e-6)
    expect_lte(reference$gap, precision * (1 + reference$gap_scale))
  }
})

test_that("projected ascent returns the flows of its solution", {
  fixture <- fixture_ascent(p = 5, n = 12)
  result <- run_ascent(fixture)
  reference <- reference_ascent(fixture, result$Z)

  expect_equal(dim(result$Y), c(12L, 5L))
  expect_equal(result$Y, reference$flows)
  expect_equal(rowSums(result$Y), fixture$X)
})

test_that("projected ascent stops at iter_max without converging", {
  fixture <- fixture_ascent(alpha = 1.05, beta = 10)
  result <- run_ascent(fixture, iter_max = 3L, precision = 1e-12)

  expect_false(result$converged)
  expect_equal(result$status, "maximum iteration reached")
  expect_identical(result$iter, 3L)
  expect_gt(result$gap, 0)
})

test_that("projected ascent with no iteration only evaluates the start", {
  fixture <- fixture_ascent()
  result <- run_ascent(fixture, iter_max = 0L)
  reference <- reference_ascent(fixture, result$Z)

  expect_identical(result$iter, 0L)
  expect_identical(result$eval, 1L)
  expect_equal(result$gap, reference$gap)
})

test_that("projected ascent reports a stalled projection", {
  # A large beta drives some destinations to the boundary, where projected
  # steps vanish before the requested precision is reached.
  fixture <- fixture_ascent(p = 8, beta = 30, seed = 1)
  result <- run_ascent(fixture, precision = 1e-14)

  expect_equal(result$status, "stalled")
  expect_false(result$converged)
  expect_true(any(result$Z == 0))
})

test_that("projected ascent handles a single destination", {
  fixture <- fixture_ascent(p = 1, n = 4)
  result <- run_ascent(fixture)

  expect_true(result$converged)
  expect_identical(result$iter, 0L)
  expect_equal(c(result$Z), sum(fixture$X) / fixture$kappa)
})

test_that("projected ascent records an increasing potential", {
  fixture <- fixture_ascent()
  result <- run_ascent(fixture, record_history = TRUE)
  history <- result$history

  expect_equal(result$solver_status$code, "converged")
  expect_s3_class(history, "data.frame")
  expect_equal(nrow(history), result$iter + 1L)
  expect_equal(history$iteration, seq_len(nrow(history)) - 1L)
  expect_equal(history$residual[nrow(history)], result$gap)
  expect_true(all(diff(history$merit) <= 0))
})

test_that("projected ascent output is unchanged without history", {
  result <- run_ascent(fixture_ascent())

  expect_named(
    result, c("Z", "Y", "iter", "eval", "gap", "status", "converged")
  )
})

test_that("projected ascent with a metric converges to a small duality gap", {
  for (fixture in list(fixture_ascent(), fixture_ascent(p = 5, n = 12))) {
    ## the duality gap cannot be reduced much below 1e-8 on some fixtures,
    ## with a platform dependent floor
    precision <- 1e-7
    result <- run_ascent(fixture,
      metric = fixture$kappa^2, precision = precision
    )
    reference <- reference_ascent(fixture, result$Z)

    expect_true(result$converged)
    expect_equal(sum(reference$U), 1)
    expect_equal(result$gap, reference$gap, tolerance = 1e-6)
    expect_lte(reference$gap, precision * (1 + reference$gap_scale))
    expect_equal(result$Y, reference$flows)
  }
})

test_that("projected ascent does not depend on the scale of the metric", {
  fixture <- fixture_ascent()
  metric <- fixture$kappa^2
  result <- run_ascent(fixture, metric = metric, record_history = TRUE)
  scaled <- run_ascent(fixture, metric = 1000 * metric, record_history = TRUE)

  expect_equal(scaled$Z, result$Z)
  expect_identical(scaled$iter, result$iter)
  expect_equal(scaled$history$accepted_scale, result$history$accepted_scale)
})

test_that("projected ascent with a constant metric is the Euclidean ascent", {
  fixture <- fixture_ascent()
  euclidean <- run_ascent(fixture, record_history = TRUE)
  constant <- run_ascent(fixture,
    metric = rep(3, length(fixture$Z)), record_history = TRUE
  )

  expect_equal(constant$Z, euclidean$Z)
  expect_identical(constant$iter, euclidean$iter)
  expect_equal(constant$history$merit, euclidean$history$merit)
})

test_that("projected ascent with a metric records an increasing potential", {
  fixture <- fixture_ascent(p = 8, beta = 6)
  result <- run_ascent(fixture, metric = fixture$kappa^2, record_history = TRUE)

  expect_equal(nrow(result$history), result$iter + 1L)
  expect_true(all(diff(result$history$merit) <= 0))
})

test_that("projected ascent rejects invalid metrics", {
  fixture <- fixture_ascent()
  p <- length(fixture$Z)
  expect_error(run_ascent(fixture, metric = rep(1, p - 1)), "metric")
  expect_error(run_ascent(fixture, metric = c(0, rep(1, p - 1))), "metric")
  expect_error(run_ascent(fixture, metric = c(NA, rep(1, p - 1))), "metric")
})
