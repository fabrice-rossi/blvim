#' @exportS3Method dplyr::dplyr_row_slice
dplyr_row_slice.sim_df <- function(data, i, ...) {
  sim_column <- attr(data, "sim_column")
  pre <- NextMethod()
  if (!is.null(sim_column) && sim_column %in% names(pre)) {
    pre[[sim_column]] <- new_sim_list(pre[[sim_column]], common = attr(data[[sim_column]], "common"))
    attr(pre, "sim_column") <- sim_column
  }
  pre
}

#' @exportS3Method dplyr::dplyr_reconstruct
dplyr_reconstruct.sim_df <- function(data, template) {
  sim_column <- attr(template, "sim_column")
  pre <- NextMethod()
  if (sim_column %in% names(pre)) {
    pre[[sim_column]] <- new_sim_list(sim_column(pre), common = attr(template[[sim_column]], "common"))
    attr(pre, "sim_column") <- sim_column
  }
  pre
}

#' @exportS3Method dplyr::group_by
group_by.sim_df <- function(.data, ..., add = FALSE, .drop = dplyr::group_by_drop_default(.data)) {
  pre <- NextMethod()
  if (!inherits(pre, "sim_df")) {
    class(pre) <- c("sim_df", class(pre))
    attr(pre, "sim_column") <- attr(.data, "sim_column")
  }
  pre
}

#' @exportS3Method dplyr::ungroup
ungroup.sim_df <- function(x, ...) {
  pre <- NextMethod()
  if (!inherits(pre, "sim_df")) {
    class(pre) <- c("sim_df", class(pre))
    attr(pre, "sim_column") <- attr(x, "sim_column")
  }
  pre
}
