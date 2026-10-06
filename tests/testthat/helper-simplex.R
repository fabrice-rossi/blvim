check_simplex_sample <- function(x, kappa, C, n, n_face_points) {
  expect_type(x, "list")
  expect_named(
    x,
    c(
      "Z", "codim", "zero", "face_id", "faces", "n_interior",
      "n_face_points", "selected_face_count", "points_per_face",
      "layer_count", "partial_codim", "max_constraint_error"
    )
  )
  expect_true(is.matrix(x$Z))
  expect_equal(dim(x$Z), c(n, length(kappa)))
  expect_true(all(is.finite(x$Z)))
  expect_true(all(x$Z >= 0))
  expect_equal(drop(x$Z %*% kappa), rep(C, n), tolerance = 1e-12)
  expect_lte(x$max_constraint_error, 1e-12 * max(1, abs(C)))

  expect_length(x$codim, n)
  expect_length(x$zero, n)
  expect_length(x$face_id, n)
  expect_equal(sum(x$face_id == 0L), n - n_face_points)
  expect_equal(sum(x$face_id > 0L), n_face_points)
  expect_equal(rowSums(x$Z == 0), x$codim)

  boundary <- which(x$face_id > 0L)
  if (length(boundary)) {
    expect_true(all(x$codim[boundary] > 0L))
    for (i in boundary) {
      expect_equal(which(x$Z[i, ] == 0), x$zero[[i]])
      expect_equal(x$zero[[i]], x$faces$zero[[x$face_id[i]]])
    }
    expect_equal(tabulate(x$face_id[boundary]), x$faces$count)
    expect_equal(x$faces$codim, lengths(x$faces$zero))
    keys <- vapply(x$faces$zero, paste, collapse = ",", FUN.VALUE = "")
    expect_false(anyDuplicated(keys) > 0L)
  } else {
    expect_length(x$faces$count, 0L)
  }
  invisible(x)
}
