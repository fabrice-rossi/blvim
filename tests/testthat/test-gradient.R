test_that("Simplex projection returns a point in the specified simplex", {
  withr::local_seed(121)
  ## sample in the unit square and then project on the simplex
  for (k in 1:20) {
    kappas <- rep(1, 20)
    y <- stats::runif(20)
    yp <- project(y, kappas, 1)
    expect_all_true(yp >= 0)
    expect_equal(sum(yp), 1)
  }
  ## more general case
  for (k in 1:20) {
    kappas <- stats::runif(20, min = 0.5, max = 1.5)
    y <- stats::runif(20)
    C_tot <- sum(kappas)
    yp <- project(y, kappas, C_tot)
    expect_all_true(yp >= 0)
    expect_equal(sum(yp * kappas), C_tot)
  }
})

test_that("Simplex projection returns the expect projection (central)", {
  withr::local_seed(122)
  for (k in 1:30) {
    ## sample in the simplex
    kappas <- stats::runif(20, min = 0.5, max = 1.5)
    C_tot <- sum(kappas)
    y <- sample_simplex(kappas, C_tot)
    ## move away
    repeat {
      y_ext <- y + runif(1, 0, 10) * kappas
      ## this should not be necessary
      if (abs(sum(y_ext * kappas) - C_tot) > .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- project(y_ext, kappas, C_tot)
    expect_equal(yp, y)
  }
})

test_that("Simplex projection returns the expect projection (faces)", {
  withr::local_seed(123)
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
      y_ext <- y + runif(1, 0, 10) * kappas
      ## this should not be necessary
      if (abs(sum(y_ext * kappas) - C_tot) > .Machine$double.eps^0.5) {
        break
      }
    }
    ## and come back ;-)
    yp <- project(y_ext, kappas, C_tot)
    expect_equal(yp, y)
  }
})
