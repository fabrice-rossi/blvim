synthetic_logs <- function() {
  blvim:::new_blvim_logs(data.frame(
    run = 1:6,
    potential = c(-2, -1, -1, -3, -1.5, -1),
    iterations = c(10L, 20L, 30L, 100L, 15L, 25L),
    converged = c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE),
    status = c(
      "converged", "converged", "converged", "max_iterations", "converged",
      "converged"
    ),
    gap = c(1e-7, 2e-7, 3e-7, 1e-2, 5e-7, 1e-7),
    evaluations = c(12L, 25L, 40L, 150L, 20L, 30L),
    n_active = c(3L, 4L, 4L, 2L, 3L, 4L),
    configuration = c(3L, 1L, 1L, 4L, 2L, 1L),
    selected = c(FALSE, TRUE, FALSE, FALSE, FALSE, FALSE)
  ))
}

test_that("run_configurations groups identical final configurations", {
  U <- rbind(
    c(0.5, 0.5, 0),
    c(0.2, 0.3, 0.5),
    c(0.5 + 1e-4, 0.5 - 1e-4, 0),
    c(0.5, 0.5 - 1e-6, 1e-6),
    c(0.21, 0.29, 0.5)
  )
  potential <- c(-1, -0.5, -1.1, -1.2, -0.6)
  conf <- run_configurations(U, potential)
  expect_equal(conf$n_active, c(2L, 3L, 2L, 2L, 3L))
  ## numbered by decreasing best potential, same support required
  expect_equal(conf$configuration, c(3L, 1L, 3L, 3L, 2L))
})

test_that("blvim logs describe the final configurations of the runs", {
  config <- create_locations(20, 25, seed = 21)
  withr::local_seed(21)
  sample <- sample_weighted_simplex(rep(1, 25), C = sum(config$X), n = 15)
  starts <- rbind(sample$Z, sample$Z[1:3, ])
  model <- blvim(config$costs, config$X, 1.5, 20, starts,
    algorithm = "gradient", keep_runs = TRUE
  )
  logs <- sim_logs(model)
  expect_s3_class(logs, "blvim_logs")
  expect_s3_class(logs, "data.frame")
  expect_named(logs, c(
    "run", "potential", "iterations", "converged", "status", "gap",
    "evaluations", "n_active", "configuration", "selected"
  ))
  expect_equal(sum(logs$selected), 1L)
  expect_equal(logs$potential[logs$selected], sim_potential(model))
  expect_equal(logs$configuration[logs$selected], 1L)
  ## repeated starts reach the same configuration
  expect_equal(logs$configuration[16:18], logs$configuration[1:3])
  ## configurations are numbered by decreasing best potential
  best <- tapply(logs$potential, logs$configuration, max)
  expect_true(all(diff(best) < 0))
  runs <- sim_runs(model)
  U <- grid_attractiveness(runs)
  U <- U / rowSums(U)
  expect_equal(logs$n_active, as.integer(rowSums(U > 1e-5)))
})

test_that("sim_logs describes a single run", {
  config <- create_locations(20, 25, seed = 22)
  for (algorithm in c("linear", "gradient")) {
    model <- blvim(config$costs, config$X, 1.5, 20, config$Z,
      algorithm = algorithm
    )
    logs <- sim_logs(model)
    expect_s3_class(logs, "blvim_logs")
    expect_equal(nrow(logs), 1L)
    expect_equal(logs$configuration, 1L)
    expect_true(logs$selected)
    U <- attractiveness(model) / sum(attractiveness(model))
    expect_equal(logs$n_active, sum(U > 1e-5))
    expect_s3_class(summary(logs), "summary_blvim_logs")
  }
})

test_that("summary.blvim_logs counts the runs and the configurations", {
  result <- summary(synthetic_logs())
  expect_s3_class(result, "summary_blvim_logs")
  expect_equal(result$n_runs, 6L)
  expect_equal(result$n_converged, 5L)
  expect_equal(
    as.vector(result$status[c("converged", "max_iterations")]),
    c(5L, 1L)
  )
  expect_equal(result$iterations, c(min = 10, median = 22.5, max = 100))
  expect_equal(result$max_gap, 5e-7)
  expect_equal(result$configurations$configuration, 1:4)
  expect_equal(result$configurations$potential, c(-1, -1.5, -2, -3))
  expect_equal(result$configurations$runs, c(3L, 1L, 1L, 1L))
  expect_equal(result$configurations$share, c(0.5, 1 / 6, 1 / 6, 1 / 6))
  expect_equal(result$configurations$converged, c(3L, 1L, 1L, 0L))
  expect_true(result$selected_converged)
})

test_that("summary.blvim_logs prints a text summary", {
  logs <- synthetic_logs()
  expect_snapshot(summary(logs))
  single_best <- logs
  single_best$configuration <- c(4L, 1L, 2L, 5L, 3L, 2L)
  single_best$potential[c(3, 6)] <- -1.1
  single_best$converged[2] <- FALSE
  single_best$status[2] <- "max_iterations"
  expect_snapshot(summary(single_best))
})

test_that("summary.blvim_logs selects the best run without a selected column", {
  logs <- synthetic_logs()
  logs$selected <- NULL
  logs$converged[2] <- FALSE
  ## the first run of largest potential is the selected one
  expect_false(summary(logs)$selected_converged)
  logs$converged[2] <- TRUE
  logs$converged[3] <- FALSE
  expect_true(summary(logs)$selected_converged)
})

test_that("summary.blvim_logs shows only the five best configurations", {
  logs <- blvim:::new_blvim_logs(data.frame(
    run = 1:8,
    potential = -(1:8),
    iterations = rep(10L, 8),
    converged = rep(TRUE, 8),
    status = rep("converged", 8),
    gap = rep(1e-7, 8),
    evaluations = rep(12L, 8),
    n_active = rep(3L, 8),
    configuration = 1:8,
    selected = seq_len(8) == 1L
  ))
  expect_equal(nrow(summary(logs)$configurations), 8L)
  expect_snapshot(summary(logs))
})

test_that("summary.blvim_logs rejects incomplete logs", {
  logs <- synthetic_logs()
  expect_error(summary(logs[, 1:4]), "configuration")
})

test_that("autoplot.blvim_logs shows the runs", {
  skip_if_not_installed("ggplot2")
  logs <- synthetic_logs()
  staircase <- ggplot2::autoplot(logs)
  expect_s3_class(staircase, "ggplot")
  expect_equal(
    staircase$data$potential,
    sort(logs$potential, decreasing = TRUE)
  )
  expect_equal(staircase$data$rank, 1:6)
  expect_no_warning(ggplot2::ggplot_build(staircase))
  scatter <- ggplot2::autoplot(logs, "scatter")
  expect_equal(scatter$data$cost, logs$evaluations)
  expect_no_warning(ggplot2::ggplot_build(scatter))
  logs$evaluations <- NA_integer_
  expect_equal(ggplot2::autoplot(logs, "scatter")$data$cost, logs$iterations)
  expect_error(ggplot2::autoplot(logs, "bars"))
})

test_that("autoplot.blvim_logs draws the expected figures", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("vdiffr")
  logs <- synthetic_logs()
  vdiffr::expect_doppelganger(
    "Logs staircase",
    \() print(ggplot2::autoplot(logs))
  )
  vdiffr::expect_doppelganger(
    "Logs scatter",
    \() print(ggplot2::autoplot(logs, "scatter"))
  )
  logs$status <- NA_character_
  logs$evaluations <- NA_integer_
  vdiffr::expect_doppelganger(
    "Logs scatter without gradient information",
    \() print(ggplot2::autoplot(logs, "scatter"))
  )
})
