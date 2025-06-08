.onLoad <- function(libname, pkgname) {
  s3_register("ggplot2::autoplot", "sim")
  s3_register("ggplot2::autoplot", "sim_list")
  s3_register("ggplot2::autoplot", "sim_df")
  invisible()
}
