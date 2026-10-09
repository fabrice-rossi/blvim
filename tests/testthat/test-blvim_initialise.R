test_that("blvim_initialise constructs a default initialisation specification", {
  initialise <- blvim_initialise()
  expect_s3_class(initialise, "blvim_initialise")
  expect_identical(initialise$generator, blvim_simplex_initialise)
  expect_identical(initialise$generator_label, "blvim_simplex_initialise")
  nl <- list()
  names(nl) <- character(0)
  expect_identical(initialise$args, nl)
})

test_that("blvim_initialise stores a generator, its label and arguments", {
  custom_initialise <- function(context, n = 1L) rep(context$C, n)
  initialise <- blvim_initialise(generator = custom_initialise, n = 4L, method = "custom")
  expect_s3_class(initialise, "blvim_initialise")
  expect_identical(initialise$generator, custom_initialise)
  expect_identical(initialise$generator_label, "custom_initialise")
  expect_identical(initialise$args, list(n = 4L, method = "custom"))
})

test_that("blvim_initialise captures namespace-qualified generator labels", {
  initialise <- blvim_initialise(generator = stats::runif, n = 2L)
  expect_identical(initialise$generator_label, "stats::runif")
  expect_identical(initialise$generator, stats::runif)
})

test_that("blvim_initialise detects error cases", {
  expect_error(blvim_initialise(generator = 1))
  expect_error(blvim_initialise(blvim_simplex_initialise, 10L))
  expect_error(blvim_initialise(n = 10L, 0.5))
  expect_error(blvim_initialise(n = 10L, n = 20L))
  expect_error(blvim_initialise(context = list()))
})

test_that("format.blvim_initialise formats a specification without arguments", {
  initialise <- blvim_initialise()
  output <- format(initialise)
  expect_type(output, "character")
  expect_match(paste(output, collapse = "\n"), "blvim_initialise")
  expect_match(paste(output, collapse = "\n"), "blvim_simplex_initialise")
  expect_match(paste(output, collapse = "\n"), "none")
})

test_that("format.blvim_initialise formats argument names and values", {
  initialise <- blvim_initialise(n = 10L, face_fraction = 0.75, include_centre = FALSE)
  output <- paste(format(initialise), collapse = "\n")
  expect_match(output, "Generator:")
  expect_match(output, "blvim_simplex_initialise")
  expect_match(output, "n")
  expect_match(output, "10")
  expect_match(output, "face_fraction")
  expect_match(output, "0.75")
  expect_match(output, "include_centre")
  expect_match(output, "FALSE")
})

test_that("print.blvim_initialise prints formatted output and returns invisibly", {
  initialise <- blvim_initialise(n = 3L)
  expect_output(returned <- print(initialise), "blvim_simplex_initialise")
  expect_identical(returned, initialise)
  expect_invisible(print(initialise))
})

test_that("print.blvim_initialise format is the one expected", {
  initialise <- blvim_initialise(
    n = 10L, face_fraction = 0.75,
    include_centre = FALSE
  )
  expect_snapshot(initialise)
})

test_that("blvim_simplex_initialise includes the centre and sampled points", {
  context <- list(C = 12, n_destinations = 3L, kappa = c(1, 2, 4))
  sampled <- list(
    Z = matrix(c(1, 2, 1.75, 2, 1, 2), nrow = 2L, byrow = TRUE),
    marker = "sampling diagnostics"
  )
  local_mocked_bindings(sample_weighted_simplex = function(kappa, C, n, face_fraction,
                                                           points_per_face, max_partial_attempts) {
    expect_identical(kappa, context$kappa)
    expect_identical(C, context$C)
    expect_identical(n, 2L)
    expect_identical(face_fraction, 0.7)
    expect_identical(points_per_face, 4L)
    expect_identical(max_partial_attempts, 123L)
    sampled
  })
  result <- blvim_simplex_initialise(context,
    n = 3L, face_fraction = 0.7,
    points_per_face = 4L, max_partial_attempts = 123L
  )
  expected_centre <- c(4, 2, 1)
  expect_identical(result$Z[1L, ], expected_centre)
  expect_identical(result$Z[-1L, , drop = FALSE], sampled$Z)
  expect_identical(result$sampling, sampled)
})

test_that("blvim_simplex_initialise can omit the centre", {
  context <- list(C = 6, n_destinations = 2L, kappa = c(1, 2))
  sampled_Z <- matrix(c(2, 2, 4, 1), nrow = 2L, byrow = TRUE)
  local_mocked_bindings(sample_weighted_simplex = function(kappa, C, n, face_fraction,
                                                           points_per_face, max_partial_attempts) {
    list(Z = sampled_Z)
  })
  result <- blvim_simplex_initialise(context, n = 2L, include_centre = FALSE)
  expect_identical(result$Z, sampled_Z)
  expect_identical(result$sampling, list(Z = sampled_Z))
})

test_that("blvim_simplex_initialise returns only the centre when n is one", {
  context <- list(C = 12, n_destinations = 3L, kappa = c(1, 2, 4))
  result <- blvim_simplex_initialise(context, n = 1L, include_centre = TRUE)
  expect_identical(result$Z, matrix(c(4, 2, 1), nrow = 1L))
  expect_null(result$sampling)
})

test_that("blvim_simplex_initialise samples one point when centre is omitted", {
  context <- list(C = 4, n_destinations = 2L, kappa = c(1, 1))
  sampled_Z <- matrix(c(1, 3), nrow = 1L)
  local_mocked_bindings(sample_weighted_simplex = function(kappa, C, n, face_fraction,
                                                           points_per_face, max_partial_attempts) {
    expect_identical(n, 1L)
    list(Z = sampled_Z)
  })
  result <- blvim_simplex_initialise(context, n = 1L, include_centre = FALSE)
  expect_identical(result$Z, sampled_Z)
})

test_that("blvim_simplex_initialise rejects invalid n values", {
  invalid_n <- list("text", numeric(), c(1, 2), NA_real_, NaN, Inf, -Inf, 0, -1, 1.5)
  for (n in invalid_n) {
    expect_error(blvim_simplex_initialise(list(), n = n), "finite positive integer")
  }
})

test_that("blvim_simplex_initialise accepts integer-valued numeric n", {
  context <- list(C = 4, n_destinations = 2L, kappa = c(1, 1))
  result <- blvim_simplex_initialise(context, n = 1, include_centre = TRUE)
  expect_identical(result$Z, matrix(c(2, 2), nrow = 1L))
})

test_that("blvim_simplex_initialise rejects invalid include_centre values", {
  context <- list(C = 4, n_destinations = 2L, kappa = c(1, 1))
  invalid <- list(1, "yes", logical(), c(TRUE, FALSE), NA)
  for (include_centre in invalid) {
    expect_error(
      blvim_simplex_initialise(context, include_centre = include_centre),
      "non-missing logical scalar"
    )
  }
})

test_that("normalise_generated_Z extracts Z from a list", {
  Z <- matrix(1:6, nrow = 2L)
  result <- normalise_generated_Z(list(Z = Z, diagnostics = "retained elsewhere"), 3L)
  expect_identical(result, Z)
})

test_that("normalise_generated_Z accepts a numeric vector", {
  Z <- c(1, 2, 3)
  expect_identical(normalise_generated_Z(Z, 3L), Z)
})

test_that("normalise_generated_Z accepts a numeric matrix", {
  Z <- matrix(1:6, nrow = 2L)
  expect_identical(normalise_generated_Z(Z, 3L), Z)
})

test_that("normalise_generated_Z converts a numeric data frame", {
  Z <- data.frame(a = c(1, 2), b = c(3, 4))
  result <- normalise_generated_Z(Z, 2L)
  expect_identical(result, as.matrix(Z))
})

test_that("normalise_generated_Z rejects a list without Z", {
  expect_error(normalise_generated_Z(list(values = 1:3), 3L))
})

test_that("normalise_generated_Z rejects non-numeric values", {
  expect_error(normalise_generated_Z(c("a", "b"), 2L))
})

test_that("normalise_generated_Z rejects non-numeric data frames", {
  Z <- data.frame(a = c("a", "b"), b = c("c", "d"))
  expect_error(normalise_generated_Z(Z, 2L))
})

test_that("normalise_generated_Z rejects arrays with more than two dimensions", {
  Z <- array(1:8, dim = c(2L, 2L, 2L))
  expect_error(normalise_generated_Z(Z, 2L))
})

test_that("normalise_generated_Z rejects a matrix without configurations", {
  Z <- matrix(numeric(), nrow = 0L, ncol = 3L)
  expect_error(normalise_generated_Z(Z, 3L))
})

test_that("normalise_generated_Z rejects a matrix with the wrong number of columns", {
  Z <- matrix(1:4, nrow = 2L)
  expect_error(normalise_generated_Z(Z, 3L))
})

test_that("normalise_generated_Z rejects a vector with the wrong length", {
  expect_error(normalise_generated_Z(c(1, 2), 3L))
})

test_that("normalise_generated_Z rejects missing values", {
  expect_error(normalise_generated_Z(c(1, NA, 3), 3L))
})

test_that("normalise_generated_Z rejects positive infinity", {
  expect_error(normalise_generated_Z(c(1, Inf, 3), 3L))
})

test_that("normalise_generated_Z rejects negative infinity", {
  expect_error(normalise_generated_Z(c(1, -Inf, 3), 3L))
})

test_that("resolve_blvim_initialise resolves an initialisation specification", {
  context <- list(C = 10, n_destinations = 2L)
  generator <- function(context, n, scale) {
    list(
      Z = matrix(rep(context$C / scale, n * context$n_destinations), nrow = n),
      n = n, scale = scale
    )
  }
  initialise <- blvim_initialise(generator = generator, n = 3L, scale = 2)
  result <- resolve_blvim_initialise(initialise, context)
  expect_identical(result$Z, matrix(5, nrow = 3L, ncol = 2L))
  expect_identical(result$generation$n, 3L)
  expect_identical(result$generation$scale, 2)
})

test_that("resolve_blvim_initialise resolves a raw generator function", {
  context <- list(C = 12, n_destinations = 3L)
  generator <- function(context) context$C / seq_len(context$n_destinations)
  result <- resolve_blvim_initialise(generator, context)
  expect_identical(result$Z, c(12, 6, 4))
  expect_identical(result$generation, c(12, 6, 4))
})

test_that("resolve_blvim_initialise leaves explicit vectors unchanged", {
  context <- list(n_destinations = 3L)
  Z <- c(1, 2, 3)
  result <- resolve_blvim_initialise(Z, context)
  expect_identical(result, list(Z = Z, generation = NULL))
})

test_that("resolve_blvim_initialise leaves explicit matrices unchanged", {
  context <- list(n_destinations = 3L)
  Z <- matrix(1:6, nrow = 2L)
  result <- resolve_blvim_initialise(Z, context)
  expect_identical(result, list(Z = Z, generation = NULL))
})

test_that("resolve_blvim_initialise reports invalid specification results", {
  context <- list(n_destinations = 3L)
  initialise <- blvim_initialise(generator = function(context) c(1, 2))
  expect_error(resolve_blvim_initialise(initialise, context), "incompatible length")
})

test_that("resolve_blvim_initialise reports invalid raw generator results", {
  context <- list(n_destinations = 3L)
  generator <- function(context) list(values = c(1, 2, 3))
  expect_error(resolve_blvim_initialise(generator, context), "without a.*Z.*component")
})


test_that("blvim passes the complete model context to an initialiser", {
  costs <- matrix(c(0, 1, 2, 3, 4, 5), nrow = 2L, byrow = TRUE)
  X <- c(4, 6)
  received_context <- NULL
  generator <- function(context, scale) {
    received_context <<- context
    context$C / context$n_destinations / context$kappa * scale
  }
  initialise <- blvim_initialise(generator = generator, scale = 1)
  local_mocked_bindings(
    check_configuration = function(...) invisible(NULL),
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      make_blvim_test_result(Z)
    },
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(Y = Y, Z = Z, initial_Z = initial_Z)
    }
  )
  result <- blvim(costs, X, alpha = 1.5, beta = 0.25, Z = initialise, kappa = c(1, 2, 4))
  expect_identical(received_context$costs, costs)
  expect_identical(received_context$X, X)
  expect_identical(received_context$alpha, 1.5)
  expect_identical(received_context$beta, 0.25)
  expect_identical(received_context$kappa, c(1, 2, 4))
  expect_identical(received_context$C, 10)
  expect_true(received_context$bipartite)
  expect_identical(received_context$n_origins, 2L)
  expect_identical(received_context$n_destinations, 3L)
  expect_equal(result$initial_Z, c(10 / 3, 5 / 3, 5 / 6))
})

test_that("blvim forwards stored arguments to the initialiser", {
  costs <- matrix(c(0, 1, 1, 0), nrow = 2L)
  received <- NULL
  generator <- function(context, n, concentration, include_centre) {
    received <<- list(
      n = n, concentration = concentration,
      include_centre = include_centre
    )
    rep(context$C / context$n_destinations, context$n_destinations)
  }
  initialise <- blvim_initialise(
    generator = generator, n = 20L,
    concentration = 25, include_centre = FALSE
  )
  local_mocked_bindings(
    check_configuration = function(...) invisible(NULL),
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      make_blvim_test_result(Z)
    },
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(initial_Z = initial_Z)
    }
  )
  blvim(costs, c(2, 2), 1, 1, Z = initialise)
  expect_identical(received, list(
    n = 20L, concentration = 25,
    include_centre = FALSE
  ))
})

test_that("a vector generated by blvim_initialise produces one run", {
  costs <- matrix(c(0, 1, 1, 0), nrow = 2L)
  generated_Z <- c(1, 3)
  run_count <- 0L
  initialise <- blvim_initialise(generator = function(context) generated_Z)
  local_mocked_bindings(
    check_configuration = function(costs, X, alpha, beta, Z, kappa, bipartite) {
      expect_identical(Z, generated_Z)
    },
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      run_count <<- run_count + 1L
      expect_identical(Z, generated_Z)
      make_blvim_test_result(Z, iter = 4L)
    },
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(
        iteration = iteration, converged = converged, logs = logs,
        runs = runs, initial_Z = initial_Z
      )
    }
  )
  result <- blvim(costs, c(2, 2), 1, 1, Z = initialise, iter_max = 10L)
  expect_identical(run_count, 1L)
  expect_identical(result$initial_Z, generated_Z)
  expect_identical(result$iteration, 5L)
  expect_true(result$converged)
  expect_null(result$logs)
  expect_null(result$runs)
})

test_that("a matrix generated by blvim_initialise produces one run per row", {
  costs <- matrix(c(0, 1, 1, 0), nrow = 2L)
  generated_Z <- rbind(c(1, 3), c(2, 2), c(3, 1))
  received_Z <- list()
  initialise <- blvim_initialise(generator = function(context) generated_Z)
  local_mocked_bindings(
    check_configuration = function(costs, X, alpha, beta, Z, kappa, bipartite) {
      expect_identical(Z, generated_Z)
    },
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      received_Z[[length(received_Z) + 1L]] <<- Z
      make_blvim_test_result(Z)
    },
    internal_sim_potential = function(costs, X, alpha, beta, Z, kappa) Z[1],
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(Z = Z, logs = logs, runs = runs, initial_Z = initial_Z)
    }
  )
  result <- blvim(costs, c(2, 2), 1, 1, Z = initialise)
  expect_identical(received_Z, list(
    generated_Z[1L, ], generated_Z[2L, ],
    generated_Z[3L, ]
  ))
  expect_identical(result$initial_Z, generated_Z[3L, ])
  expect_equal(result$logs$potential, c(1, 2, 3))
  expect_null(result$runs)
})

test_that("blvim selects the first generated run when potentials are tied", {
  costs <- matrix(c(0, 1, 1, 0), nrow = 2L)
  generated_Z <- rbind(c(1, 3), c(3, 1))
  initialise <- blvim_initialise(generator = function(context) generated_Z)
  local_mocked_bindings(
    check_configuration = function(...) invisible(NULL),
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      make_blvim_test_result(Z)
    },
    internal_sim_potential = function(...) 10,
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(initial_Z = initial_Z, logs = logs)
    }
  )
  result <- blvim(costs, c(2, 2), 1, 1, Z = initialise)
  expect_identical(result$initial_Z, generated_Z[1L, ])
  expect_equal(result$logs$potential, c(10, 10))
})

test_that("keep_runs retains all models generated from an initialiser", {
  costs <- matrix(c(0, 1, 1, 0), nrow = 2L)
  generated_Z <- rbind(c(1, 3), c(3, 1))
  initialise <- blvim_initialise(generator = function(context) generated_Z)
  local_mocked_bindings(
    check_configuration = function(...) invisible(NULL),
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      make_blvim_test_result(Z)
    },
    internal_sim_potential = function(costs, X, alpha, beta, Z, kappa) Z[1],
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(initial_Z = initial_Z, logs = logs, runs = runs)
    },
    sim_list = function(x, validate) {
      expect_false(validate)
      structure(x, class = "sim_list")
    }
  )
  result <- blvim(costs, c(2, 2), 1, 1, Z = initialise, keep_runs = TRUE)
  expect_s3_class(result$runs, "sim_list")
  expect_length(result$runs, 2L)
  expect_identical(result$runs[[1L]]$initial_Z, generated_Z[1L, ])
  expect_identical(result$runs[[2L]]$initial_Z, generated_Z[2L, ])
  expect_identical(result$initial_Z, generated_Z[2L, ])
})

test_that("generated multiple runs record gradient diagnostics", {
  costs <- matrix(c(0, 1, 1, 0), nrow = 2L)
  generated_Z <- rbind(c(1, 3), c(3, 1))
  initialise <- blvim_initialise(generator = function(context) generated_Z)
  run <- 0L
  local_mocked_bindings(
    check_configuration = function(...) invisible(NULL),
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      run <<- run + 1L
      make_blvim_test_result(Z,
        iter = run,
        diagnostic = list(
          status = paste0("status-", run),
          duality_gap = run / 100, eval = 10L * run
        )
      )
    },
    internal_sim_potential = function(costs, X, alpha, beta, Z, kappa) Z[1],
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(logs = logs, initial_Z = initial_Z)
    }
  )
  result <- blvim(costs, c(2, 2), 1, 1,
    Z = initialise,
    algorithm = "gradient", iter_max = 10L
  )
  expect_identical(result$logs$iterations, c(2L, 3L))
  expect_identical(result$logs$converged, c(TRUE, TRUE))
  expect_identical(result$logs$status, c("status-1", "status-2"))
  expect_equal(result$logs$gap, c(0.01, 0.02))
  expect_identical(result$logs$evaluations, c(10L, 20L))
})

test_that("generated multiple runs record non-convergence at iter_max", {
  costs <- matrix(c(0, 1, 1, 0), nrow = 2L)
  generated_Z <- rbind(c(1, 3), c(3, 1))
  initialise <- blvim_initialise(generator = function(context) generated_Z)
  local_mocked_bindings(
    check_configuration = function(...) invisible(NULL),
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      make_blvim_test_result(Z, iter = iter_max)
    },
    internal_sim_potential = function(costs, X, alpha, beta, Z, kappa) Z[1],
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(logs = logs)
    }
  )
  result <- blvim(costs, c(2, 2), 1, 1, Z = initialise, iter_max = 5L)
  expect_identical(result$logs$iterations, c(6L, 6L))
  expect_identical(result$logs$converged, c(FALSE, FALSE))
  expect_true(all(is.na(result$logs$status)))
  expect_true(all(is.na(result$logs$gap)))
  expect_true(all(is.na(result$logs$evaluations)))
})

test_that("blvim expands scalar kappa before calling the initialiser", {
  costs <- matrix(seq_len(6), nrow = 2L)
  received_kappa <- NULL
  generator <- function(context) {
    received_kappa <<- context$kappa
    context$C / context$n_destinations / context$kappa
  }
  initialise <- blvim_initialise(generator = generator)
  local_mocked_bindings(
    check_configuration = function(...) invisible(NULL),
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      expect_identical(all_kappa, c(1, 1, 1))
      expect_false(with_kappa)
      make_blvim_test_result(Z)
    },
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(initial_Z = initial_Z)
    }
  )
  blvim(costs, c(4, 6), 1, 1, Z = initialise, kappa = 1)
  expect_identical(received_kappa, c(1, 1, 1))
})

test_that("blvim passes destination-specific kappa to the initialiser", {
  costs <- matrix(seq_len(6), nrow = 2L)
  received_kappa <- NULL
  generator <- function(context) {
    received_kappa <<- context$kappa
    context$C / context$n_destinations / context$kappa
  }
  initialise <- blvim_initialise(generator = generator)
  local_mocked_bindings(
    check_configuration = function(...) invisible(NULL),
    one_blvim = function(costs, X, alpha, beta, Z, all_kappa, epsilon, iter_max,
                         conv_check, precision, algorithm, control, with_kappa) {
      expect_identical(all_kappa, c(1, 2, 4))
      expect_true(with_kappa)
      make_blvim_test_result(Z)
    },
    new_sim_blvim = function(Y, Z, costs, alpha, beta, bipartite, origin_data,
                             destination_data, iteration, converged, kappa, algorithm, diagnostic,
                             logs, runs, initial_Z) {
      list(initial_Z = initial_Z)
    }
  )
  blvim(costs, c(4, 6), 1, 1, Z = initialise, kappa = c(1, 2, 4))
  expect_identical(received_kappa, c(1, 2, 4))
})
