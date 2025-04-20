testthat::skip_on_cran()
test_that("test .onLoad", {
  skip_if_not_installed("ggplot2")
  if (testthat:::in_rcmd_check() || testthat:::in_covr()) {
    callr::r(function() {
      library(blvim)
      library(ggplot2)
      blvim:::.onLoad()
      testthat::expect_true(sloop::is_s3_method("autoplot.sim_list"))
    })
    callr::r(function() {
      library(blvim)
      blvim:::.onLoad()
      testthat::expect_false(sloop::is_s3_method("autoplot.sim_list"))
    })
  } else if (!testthat:::in_rcmd_check()) {
    callr::r(function() {
      pkgload::load_all()
      library(ggplot2)
      blvim:::.onLoad()
      testthat::expect_true(sloop::is_s3_method("autoplot.sim_list"))
    })
    callr::r(function() {
      pkgload::load_all()
      blvim:::.onLoad()
      testthat::expect_false(sloop::is_s3_method("autoplot.sim_list"))
    })
  }
})
