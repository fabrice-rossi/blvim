test_that("Simplex projection returns a point in the specified simplex", {
  withr::local_seed(121)
  ## sample in [-1;1]^20 and then project on the unit simplex
  for (k in 1:20) {
    y <- stats::runif(20, min = -1, max = 1)
    yp <- R_project_simplex(y)
    expect_all_true(yp >= 0)
    expect_equal(sum(yp), 1)
  }
  ## more general case
  for (k in 1:20) {
    kappas <- stats::runif(20, min = 0.5, max = 1.5)
    y <- stats::runif(20, min = -1, max = 1)
    C_tot <- sum(kappas)
    yp <- R_project_weighted_simplex(y, kappas, C_tot)
    expect_all_true(yp >= 0)
    expect_equal(sum(yp * kappas), C_tot)
  }
})

test_that("Simplex projection returns the expect projection (central)", {
  withr::local_seed(122)
  for (k in 1:30) {
    ## sample in the simplex
    y <- sample_simplex(rep(1, 20), 1)
    ## move away
    repeat {
      y_ext <- y + sample(c(1, -1), 1) * runif(1, 10 * .Machine$double.eps^0.5, 10)
      ## this should not be necessary
      if (abs(sum(y_ext) - 1) > 10 * .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- R_project_simplex(y_ext)
    expect_equal(yp, y)
  }
  ## weighted case
  for (k in 1:30) {
    ## sample in the simplex
    kappas <- stats::runif(20, min = 0.5, max = 1.5)
    C_tot <- sum(kappas)
    y <- sample_simplex(kappas, C_tot)
    ## move away
    repeat {
      y_ext <- y + sample(c(1, -1), 1) * runif(1, 10 * .Machine$double.eps^0.5, 10) * kappas
      ## this should not be necessary
      if (abs(sum(y_ext * kappas) - C_tot) > 10 * .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- R_project_weighted_simplex(y_ext, kappas, C_tot)
    expect_equal(yp, y)
  }
})

test_that("Simplex projection returns the expect projection (faces)", {
  withr::local_seed(123)
  for (k in 1:30) {
    ## sample in the faces of the simplex
    repeat {
      active <- sample(c(TRUE, FALSE), 20, replace = TRUE)
      sa <- sum(active)
      if (sa > 0 && sa < 20) {
        break
      }
    }
    y <- sample_simplex(rep(1, 20), 1, which(active))
    ## move away
    repeat {
      y_ext <- y + sample(c(1, -1), 1) * runif(1, 0, 10)
      ## this should not be necessary
      if (abs(sum(y_ext) - 1) > 10 * .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- R_project_simplex(y_ext)
    expect_equal(yp, y)
  }
  ## weighted
  for (k in 1:30) {
    ## sample in the faces of the simplex
    kappas <- stats::runif(20, min = 0.5, max = 1.5)
    C_tot <- sum(kappas)
    repeat {
      active <- sample(c(TRUE, FALSE), 20, replace = TRUE)
      sa <- sum(active)
      if (sa > 0 && sa < 20) {
        break
      }
    }
    y <- sample_simplex(kappas, C_tot, which(active))
    ## move away
    repeat {
      y_ext <- y + sample(c(1, -1), 1) * runif(1, 0, 10) * kappas
      ## this should not be necessary
      if (abs(sum(y_ext * kappas) - C_tot) > 10 * .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- R_project_weighted_simplex(y_ext, kappas, C_tot)
    expect_equal(yp, y)
  }
})

test_that("Simplex projection in border cases", {
  expect_equal(R_project_simplex(numeric()), numeric())
  expect_equal(R_project_simplex(0.0), 1.0)
  expect_equal(R_project_simplex(rnorm(1)), 1.0)
  withr::local_seed(444)
  kappas <- runif(10, min = 0.1, max = 10)
  C <- runif(10, min = 5, max = 20)
  for (rep in seq_along(kappas)) {
    expect_equal(
      R_project_weighted_simplex(numeric(), kappas[rep], C[rep]),
      numeric()
    )
    expect_equal(
      R_project_weighted_simplex(c(rnorm(1)), kappas[rep], C[rep]),
      C[rep] / kappas[rep]
    )
  }
})

test_that("number_of_faces_capped handles zero, exact, and capped cases", {
  expect_identical(number_of_faces_capped(5L, 0L), 0L)
  expect_identical(number_of_faces_capped(5L, 100L), 30L)
  expect_identical(number_of_faces_capped(5L, 12L), 12L)
  expect_identical(number_of_faces_capped(31L, 100L), 100L)
})

test_that("number_of_nonvertex_faces_capped handles all branches", {
  expect_identical(number_of_nonvertex_faces_capped(5L, 0L), 0L)
  expect_identical(number_of_nonvertex_faces_capped(5L, 100L), 25L)
  expect_identical(number_of_nonvertex_faces_capped(5L, 12L), 12L)
  expect_identical(number_of_nonvertex_faces_capped(31L, 100L), 100L)
})

test_that("argument validation rejects malformed inputs", {
  expect_error(sample_weighted_simplex(1:3, n = -2))
  expect_error(sample_weighted_simplex(1:3, n = NA_real_))
  expect_error(
    sample_weighted_simplex(1:3, face_fraction = -1),
    "is -1"
  )
})

test_that("in dimension 2, the face points are the vertices", {
  withr::local_seed(1)
  kappa <- c(1, 2)
  x <- sample_weighted_simplex(kappa, n = 4, face_fraction = 0.5)
  expect_equal(x$n_face_points, 2L)
  expect_equal(x$faces$count, c(1L, 1L))
  ## the two vertices of the weighted simplex
  expect_equal(x$Z[3:4, ], rbind(c(0, 1 / kappa[2]), c(1 / kappa[1], 0)))
  expect_error(
    sample_weighted_simplex(kappa, n = 4, face_fraction = 1),
    "impossible in dimension 2"
  )
})

test_that("zero face fraction produces only interior points", {
  withr::local_seed(1)
  x <- sample_weighted_simplex(c(1, 2, 3),
    C = 2, n = 20L,
    face_fraction = 0,
    points_per_face = 0L
  )
  check_simplex_sample(x, c(1, 2, 3), 2, 20L, 0L)
  expect_identical(x$n_interior, 20L)
  expect_identical(x$n_face_points, 0L)
  expect_equal(x$selected_face_count, 0)
  expect_true(is.na(x$partial_codim))
})

test_that("points_per_face zero maximizes face coverage", {
  withr::local_seed(2)
  x <- sample_weighted_simplex(rep(1, 5),
    n = 100L,
    face_fraction = 1,
    points_per_face = 0L
  )
  check_simplex_sample(x, rep(1, 5), 1, 100L, 100L)
  expect_equal(x$selected_face_count, 30)
  expect_equal(sum(x$faces$count), 100L)
  expect_equal(sum(x$faces$codim == 4L), 5L)
  expect_true(all(x$faces$count[x$faces$codim == 4L] == 1L))
  expect_lte(max(x$faces$count[x$faces$codim < 4L]), 4L)
})

test_that("positive points_per_face is used when feasible", {
  withr::local_seed(3)
  x <- sample_weighted_simplex(rep(1, 5),
    n = 80L,
    face_fraction = 0.5,
    points_per_face = 4L
  )
  check_simplex_sample(x, rep(1, 5), 1, 80L, 40L)
  expect_equal(x$selected_face_count, 10)
  expect_true(all(x$faces$count <= 4L))
  expect_equal(x$faces$count, rep(4L, 10L))
  expect_equal(x$layer_count[1], 5L)
  expect_equal(x$layer_count[2], 5L)
  expect_equal(x$partial_codim, 2L)
})

test_that("too-small points_per_face is increased with a warning", {
  withr::local_seed(4)
  expect_warning(
    x <- sample_weighted_simplex(rep(1, 5),
      n = 100L,
      face_fraction = 1,
      points_per_face = 2L
    )
  )
  check_simplex_sample(x, rep(1, 5), 1, 100L, 100L)
  expect_identical(x$points_per_face, 4L)
  expect_equal(x$selected_face_count, 25)
  expect_true(all(x$faces$codim < 4L))
  expect_true(all(x$faces$count <= 4L))
})

test_that("vertex capacity is exactly one", {
  withr::local_seed(5)
  # All 14 faces in d=4 are selected. The four codimension-3 faces are vertices.
  x <- sample_weighted_simplex(rep(1, 4),
    n = 30L,
    face_fraction = 1,
    points_per_face = 0L
  )
  check_simplex_sample(x, rep(1, 4), 1, 30L, 30L)
  vertex <- x$faces$codim == 3L
  expect_equal(sum(vertex), 4L)
  expect_equal(x$faces$count[vertex], rep(1L, 4L))
  for (id in which(vertex)) {
    rows <- which(x$face_id == id)
    expect_length(rows, 1L)
    support <- setdiff(seq_len(4), x$faces$zero[[id]])
    expect_length(support, 1L)
    expect_equal(x$Z[rows, support], 1)
  }
})

test_that("dimension two rejects more boundary points than its vertices", {
  expect_error(
    sample_weighted_simplex(c(1, 1),
      n = 3L,
      face_fraction = 1,
      points_per_face = 0L
    )
  )
})

test_that("dimension two supports both vertices exactly once", {
  withr::local_seed(6)
  x <- sample_weighted_simplex(c(2, 4),
    C = 8, n = 2L,
    face_fraction = 1,
    points_per_face = 1L
  )
  check_simplex_sample(x, c(2, 4), 8, 2L, 2L)
  expect_equal(x$selected_face_count, 2)
  expect_equal(x$faces$count, c(1L, 1L))
  expect_equal(sort(x$Z[, 1]), c(0, 4))
  expect_equal(sort(x$Z[, 2]), c(0, 2))
})

test_that("fraction rounding and unequal fair allocation are correct", {
  withr::local_seed(7)
  x <- sample_weighted_simplex(c(1, 2, 3, 4),
    C = 3, n = 11L,
    face_fraction = 0.5,
    points_per_face = 4L
  )
  # round(5.5) uses IEC 60559 ties-to-even in R, hence 6.
  check_simplex_sample(x, c(1, 2, 3, 4), 3, 11L, 6L)
  expect_equal(x$n_interior, 5L)
  expect_equal(x$selected_face_count, 2)
  expect_equal(sort(x$faces$count), c(3L, 3L))
})

test_that("complete codimension layers are enumerated exactly", {
  withr::local_seed(8)
  # d=4: C(4,1)+C(4,2)=10 selected faces.
  x <- sample_weighted_simplex(rep(1, 4),
    n = 10L,
    face_fraction = 1,
    points_per_face = 1L
  )
  expect_equal(x$layer_count, c(4L, 6L, 0L))
  expect_true(is.na(x$partial_codim))
  x_table <- table(x$faces$codim)
  x_table_exp <- c(`1` = 4L, `2` = 6L)
  expect_equal(names(x_table), names(x_table_exp))
  expect_equal(as.numeric(x_table), as.numeric(x_table_exp))
})

test_that("partial layer proposal limit is enforced by C++", {
  # Direct low-level test intentionally bypasses the wrapper. With one allowed
  # proposal, selecting two distinct facets must fail deterministically.
  withr::local_seed(9)
  expect_error(
    sample_weighted_simplex_low_codim_cpp(
      rep(1, 5), 1, 2L, 2L, 2L, 1L, 1L
    ),
    "Could not obtain enough unique faces"
  )
})

test_that("the low-level function rejects too many selected faces", {
  expect_error(
    sample_weighted_simplex_low_codim_cpp(
      rep(1, 3), 1, 7L, 7L, 7L, 1L, 100L
    ),
    "exceeds the number of proper"
  )
})

test_that("random results are reproducible from the R seed", {
  withr::local_seed(10)
  x <- sample_weighted_simplex(rep(1, 6),
    n = 50L,
    face_fraction = 0.6,
    points_per_face = 3L
  )
  withr::local_seed(10)
  y <- sample_weighted_simplex(rep(1, 6),
    n = 50L,
    face_fraction = 0.6,
    points_per_face = 3L
  )
  expect_identical(x, y)
})

test_that("metric simplex projection with a unit metric is Euclidean", {
  withr::local_seed(130)
  for (k in 1:20) {
    y <- stats::runif(20, min = -1, max = 1)
    expect_equal(R_project_simplex_metric(y, rep(1, 20)), R_project_simplex(y))
  }
})

test_that("metric simplex projection is the projection for the weighted norm", {
  withr::local_seed(131)
  for (k in 1:30) {
    metric <- stats::runif(20, min = 0.1, max = 3)
    y <- stats::runif(20, min = -1, max = 1) * sample(c(0.1, 1, 10), 1)
    yp <- R_project_simplex_metric(y, metric)
    expect_all_true(yp >= 0)
    expect_equal(sum(yp), 1)
    ## v = u / sqrt(metric) turns the problem into a weighted simplex projection
    s <- sqrt(metric)
    expect_equal(yp, s * R_project_weighted_simplex(y / s, s, 1))
  }
})

test_that("metric simplex projection keeps zero metric coordinates", {
  withr::local_seed(132)
  for (k in 1:20) {
    u <- sample_simplex(rep(1, 10), 1)
    metric <- stats::runif(10, min = 0.1, max = 3)
    fixed <- sample(10, 3)
    metric[fixed] <- 0
    y <- u + stats::rnorm(10) * metric
    yp <- R_project_simplex_metric(y, metric)
    expect_equal(yp[fixed], u[fixed])
    expect_equal(sum(yp), 1)
    expect_all_true(yp >= 0)
  }
  expect_equal(R_project_simplex_metric(numeric(), numeric()), numeric())
  expect_equal(R_project_simplex_metric(rnorm(1), 2), 1)
})
