skip_on_cran()
test_that("test .onLoad no package", {
  ## first we test without loading ggplot2 or dplyr
  autoplot_s3_registered <- TRUE
  if (pkgload::is_dev_package("blvim")) {
    autoplot_s3_registered <- callr::r(function() {
      pkgload::load_all()
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      s3_method_exists("autoplot.sim") |
        s3_method_exists("fortify.sim") |
        s3_method_exists("autoplot.sim_df") |
        s3_method_exists("dplyr_row_slice.sim_df") |
        s3_method_exists("dplyr_reconstruct.sim_df") |
        s3_method_exists("dplyr_col_modify.sim_df") |
        s3_method_exists("group_by.sim_df") |
        s3_method_exists("ungroup.sim_df")
    })
  } else {
    autoplot_s3_registered <- callr::r(function() {
      library(blvim)
      s3_method_exists <- function(method) {
        !inherits(
          try(sloop::s3_get_method({{ method }}), silent = TRUE),
          "try-error"
        )
      }
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      s3_method_exists("autoplot.sim") |
        s3_method_exists("fortify.sim") |
        s3_method_exists("autoplot.sim_df") |
        s3_method_exists("dplyr_row_slice.sim_df") |
        s3_method_exists("dplyr_reconstruct.sim_df") |
        s3_method_exists("dplyr_col_modify.sim_df") |
        s3_method_exists("group_by.sim_df") |
        s3_method_exists("ungroup.sim_df")
    })
  }
  expect_false(autoplot_s3_registered)
})

test_that("test .onLoad ggplot2", {
  ## then we test only if ggplot2 is installed
  skip_if_not_installed("ggplot2")
  autoplot_s3_registered <- FALSE
  if (pkgload::is_dev_package("blvim")) {
    autoplot_s3_registered <- callr::r(function() {
      pkgload::load_all()
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      library(ggplot2)
      s3_method_exists("autoplot.sim") &
        s3_method_exists("fortify.sim") &
        s3_method_exists("autoplot.sim_df")
    })
  } else {
    autoplot_s3_registered <- callr::r(function() {
      library(blvim)
      s3_method_exists <- function(method) {
        !inherits(
          try(sloop::s3_get_method({{ method }}), silent = TRUE),
          "try-error"
        )
      }
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      library(ggplot2)
      s3_method_exists("autoplot.sim") &
        s3_method_exists("fortify.sim") &
        s3_method_exists("autoplot.sim_df")
    })
  }
  expect_true(autoplot_s3_registered)
})

test_that("test .onLoad dplyr", {
  ## then we test only if dplyr is installed
  skip_if_not_installed("dplyr")
  autoplot_s3_registered <- FALSE
  if (pkgload::is_dev_package("blvim")) {
    autoplot_s3_registered <- callr::r(function() {
      pkgload::load_all()
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      library(dplyr)
      s3_method_exists("dplyr_row_slice.sim_df") &
        s3_method_exists("dplyr_reconstruct.sim_df") &
        s3_method_exists("dplyr_col_modify.sim_df") &
        s3_method_exists("group_by.sim_df") &
        s3_method_exists("ungroup.sim_df")
    })
  } else {
    autoplot_s3_registered <- callr::r(function() {
      library(blvim)
      s3_method_exists <- function(method) {
        !inherits(
          try(sloop::s3_get_method({{ method }}), silent = TRUE),
          "try-error"
        )
      }
      if (covr::in_covr()) {
        ## should not be needed
        blvim:::.onLoad()
      }
      library(dplyr)
      s3_method_exists("dplyr_row_slice.sim_df") &
        s3_method_exists("dplyr_reconstruct.sim_df") &
        s3_method_exists("dplyr_col_modify.sim_df") &
        s3_method_exists("group_by.sim_df") &
        s3_method_exists("ungroup.sim_df")
    })
  }
  expect_true(autoplot_s3_registered)
})
