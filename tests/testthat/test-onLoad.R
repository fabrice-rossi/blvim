skip_on_cran()
test_that("test .onLoad", {
  ## first we test without loading ggplot2
  autoplot_sim_list_registered <- FALSE
  if (pkgload::is_dev_package("blvim")) {
    autoplot_sim_list_registered <- callr::r(function() {
      pkgload::load_all()
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      sloop::is_s3_method("autoplot.sim_list")
    })
  } else {
    autoplot_sim_list_registered <- callr::r(function() {
      library(blvim)
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      sloop::is_s3_method("autoplot.sim_list")
    })
  }
  expect_false(autoplot_sim_list_registered)
  ## then we test only if ggplot2 is installed
  skip_if_not_installed("ggplot2")
  autoplot_sim_list_registered <- FALSE
  if (pkgload::is_dev_package("blvim")) {
    autoplot_sim_list_registered <- callr::r(function() {
      pkgload::load_all()
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      library(ggplot2)
      sloop::is_s3_method("autoplot.sim_list")
    })
  } else {
    autoplot_sim_list_registered <- callr::r(function() {
      library(blvim)
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      library(ggplot2)
      sloop::is_s3_method("autoplot.sim_list")
    })
  }
  expect_true(autoplot_sim_list_registered)
})
