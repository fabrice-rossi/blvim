.onLoad <- function(libname, pkgname) {
  s3_register("ggplot2::autoplot", "sim_list")
  invisible()
}
