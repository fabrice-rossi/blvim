#' @exportS3Method dplyr::dplyr_row_slice
dplyr_row_slice.sim_df <- function(data, i, ...) {
  pre <- NextMethod()
  if ("sim" %in% names(pre)) {
    pre$sim <- new_sim_list(pre$sim, common = attr(data$sim, "common"))
  }
  pre
}

#' @exportS3Method dplyr::dplyr_reconstruct
dplyr_reconstruct.sim_df <- function(data, template) {
  pre <- NextMethod()
  if ("sim" %in% names(pre)) {
    pre$sim <- new_sim_list(pre$sim, common = attr(template$sim, "common"))
  }
  pre
}

#' @exportS3Method dplyr::group_by
group_by.sim_df <- function(.data, ..., add = FALSE, .drop = dplyr::group_by_drop_default(.data)) {
  pre <- NextMethod()
  if (!inherits(pre, "sim_df")) {
    class(pre) <- c("sim_df", class(pre))
  }
  pre
}

#' @exportS3Method dplyr::ungroup
ungroup.sim_df <- function(x, ...) {
  pre <- NextMethod()
  if (!inherits(pre, "sim_df")) {
    class(pre) <- c("sim_df", class(pre))
  }
  pre
}

#' @exportS3Method dplyr::distinct
distinct.sim_df <- function(x, ...) {
  pre <- NextMethod()
  if ("sim" %in% names(pre)) {
    if (!inherits(pre, "sim_df")) {
      class(pre) <- c("sim_df", class(pre))
    }
  }
  pre
}
