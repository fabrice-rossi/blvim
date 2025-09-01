.onLoad <- function(libname, pkgname) {
  s3_register("dplyr::dplyr_row_slice", "sim_df")
  s3_register("dplyr::dplyr_reconstruct", "sim_df")
  s3_register("dplyr::group_by", "sim_df")
  s3_register("dplyr::ungroup", "sim_df")
  s3_register("dplyr::distinct", "sim_df")
  s3_register("ggplot2::autoplot", "sim")
  s3_register("ggplot2::autoplot", "sim_df")
  invisible()
}
