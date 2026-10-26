synthetic_history <- function(n = 30, rate = 0.5, min_U = 0.01,
                              n_active = rep(5L, n)) {
  iteration <- seq.int(0L, n - 1L)
  blvim:::new_blvim_history(data.frame(
    iteration = iteration,
    gap = rate^iteration,
    potential = -1 - rate^iteration,
    step = c(rep(0.1, n - 1L), 0),
    step_norm = c(rep(0.01, n - 1L), 0),
    line_search_reductions = rep(1L, n),
    n_active = n_active,
    min_U = rep_len(min_U, n)
  ))
}

test_that("sim_history returns blvim_history objects", {
  config <- create_locations(15, 15, seed = 23)
  control <- blvim_gradient_control(history = TRUE)
  model <- blvim(config$costs, config$X, 1.5, 10, config$Z,
    algorithm = "gradient", control = control
  )
  expect_s3_class(sim_history(model), "blvim_history")
  expect_s3_class(sim_history(model), "data.frame")
  grid <- grid_blvim(config$costs, config$X, c(1.2, 1.5), 10, config$Z,
    algorithm = "gradient", control = control
  )
  expect_s3_class(sim_history(grid), "blvim_history")
  expect_s3_class(summary(sim_history(model)), "summary_blvim_history")
})

test_that("summary.blvim_history estimates the convergence rate", {
  result <- summary(synthetic_history(rate = 0.3))
  expect_s3_class(result, "summary_blvim_history")
  expect_false(result$collection)
  runs <- result$runs
  expect_equal(runs$sim, 1L)
  expect_equal(runs$iterations, 30L)
  expect_equal(runs$rate, 0.3)
  expect_equal(runs$final_gap, 0.3^29)
  expect_equal(runs$reductions, 30L)
  expect_equal(runs$min_step, 0.1)
  expect_false(runs$on_face)
  expect_equal(runs$face_changes, 0L)
  expect_true(is.na(runs$last_change))
  expect_false(runs$vanishing)
  expect_true(summary(synthetic_history(min_U = 0))$runs$on_face)
  expect_true(is.na(summary(synthetic_history(n = 4))$runs$rate))
})

test_that("summary.blvim_history describes the face changes", {
  active <- c(5L, 4L, 4L, 3L, 4L, rep(3L, 25))
  runs <- summary(synthetic_history(n_active = active))$runs
  expect_equal(runs$initial_active, 5L)
  expect_equal(runs$final_active, 3L)
  expect_equal(runs$face_changes, 4L)
  expect_equal(runs$last_change, 5L)
  ## an interior run whose smallest U keeps decreasing
  dying <- synthetic_history(min_U = 10^-seq(1, 4, length.out = 30))
  expect_true(summary(dying)$runs$vanishing)
  expect_snapshot(summary(dying))
  expect_snapshot(summary(synthetic_history(n_active = active, min_U = 0)))
  ## histories without the number of active destinations
  old <- synthetic_history()
  old$n_active <- NULL
  expect_true(is.na(summary(old)$runs$final_active))
  expect_equal(summary(old)$runs$face_changes, 0L)
})

test_that("summary.blvim_history summarises each run of a collection", {
  history <- rbind(
    cbind(sim = 1L, as.data.frame(synthetic_history(rate = 0.5))),
    cbind(sim = 3L, as.data.frame(synthetic_history(n = 10, min_U = 0)))
  )
  result <- summary(blvim:::new_blvim_history(history))
  expect_true(result$collection)
  expect_equal(result$runs$sim, c(1L, 3L))
  expect_equal(result$runs$iterations, c(30L, 10L))
  expect_equal(result$runs$on_face, c(FALSE, TRUE))
})

test_that("summary.blvim_history prints a text summary", {
  expect_snapshot(summary(synthetic_history(rate = 0.3)))
  expect_snapshot(summary(synthetic_history(min_U = 0)))
  history <- rbind(
    cbind(sim = 1L, as.data.frame(synthetic_history(rate = 0.5))),
    cbind(sim = 2L, as.data.frame(synthetic_history(n = 10, min_U = 0)))
  )
  expect_snapshot(summary(blvim:::new_blvim_history(history)))
})

test_that("summary.blvim_history prints a summary of many runs", {
  history <- do.call(rbind, lapply(seq_len(22), function(k) {
    min_U <- if (k == 2L) 10^-seq(1, 4, length.out = 10) else 0.01
    cbind(sim = k, as.data.frame(synthetic_history(n = 10, min_U = min_U)))
  }))
  history <- blvim:::new_blvim_history(history)
  expect_equal(sum(summary(history)$runs$vanishing), 1L)
  expect_snapshot(summary(history))
})

test_that("summary.blvim_history rejects incomplete histories", {
  expect_error(summary(synthetic_history()[, 1:3]), "min_U")
})

test_that("autoplot.blvim_history shows the selected quantities", {
  skip_if_not_installed("ggplot2")
  history <- synthetic_history()
  plot <- ggplot2::autoplot(history)
  expect_s3_class(plot, "ggplot")
  expect_equal(
    levels(plot$data$quantity),
    c(
      "duality gap", "distance to the final potential", "accepted step",
      "active destinations"
    )
  )
  expect_true(all(plot$data$value > 0))
  expect_no_warning(ggplot2::ggplot_build(plot))
  plot <- ggplot2::autoplot(history, c("gap", "potential"))
  expect_equal(nlevels(plot$data$quantity), 2L)
  ## the distance to the final potential vanishes at the last iteration
  expect_equal(sum(plot$data$quantity == "duality gap"), 30L)
  distance <- plot$data$quantity == "distance to the final potential"
  expect_equal(sum(distance), 29L)
  expect_error(ggplot2::autoplot(history, "speed"))
  plot <- ggplot2::autoplot(synthetic_history(min_U = c(0.1, rep(0, 29))),
    what = "min_U"
  )
  expect_equal(nrow(plot$data), 1L)
  expect_no_warning(ggplot2::ggplot_build(plot))
  collection <- rbind(
    cbind(sim = 1L, as.data.frame(synthetic_history())),
    cbind(sim = 2L, as.data.frame(synthetic_history(n = 10, min_U = 0)))
  )
  plot <- ggplot2::autoplot(blvim:::new_blvim_history(collection))
  expect_equal(levels(plot$data$sim), c("1", "2"))
  expect_no_warning(ggplot2::ggplot_build(plot))
})

test_that("autoplot.blvim_history draws the expected figures", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("vdiffr")
  active <- c(5L, 4L, 4L, 3L, 4L, rep(3L, 25))
  history <- synthetic_history(n_active = active)
  vdiffr::expect_doppelganger(
    "History default",
    \() print(ggplot2::autoplot(history))
  )
  vdiffr::expect_doppelganger(
    "History gap and min_U",
    \() {
      print(ggplot2::autoplot(
        synthetic_history(min_U = 10^-seq(1, 4, length.out = 30)),
        c("gap", "min_U")
      ))
    }
  )
  runs <- function(n) {
    blvim:::new_blvim_history(do.call(rbind, lapply(seq_len(n), function(k) {
      cbind(sim = k, as.data.frame(synthetic_history(
        n = 10L + 2L * k, rate = 0.3 + 0.05 * k,
        n_active = rep(c(6L, 5L, 4L), c(k, 2L, 8L + k))
      )))
    })))
  }
  vdiffr::expect_doppelganger(
    "History of a few runs",
    \() print(ggplot2::autoplot(runs(3)))
  )
  vdiffr::expect_doppelganger(
    "History of many runs",
    \() print(ggplot2::autoplot(runs(10)))
  )
})
