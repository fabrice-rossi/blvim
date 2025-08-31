#' @exportS3Method dplyr::dplyr_row_slice
dplyr_row_slice.sim_df <- function(data, i, ...) {
  pre <- NextMethod()
  if ("sim" %in% names(pre)) {
    pre$sim <- new_sim_list(pre$sim, common = attr(data$sim, "common"))
  }
  pre
}
