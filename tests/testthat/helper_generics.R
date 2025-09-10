s3_method_exists <- function(method) {
  !inherits(
    try(sloop::s3_get_method({{ method }}), silent = TRUE),
    "try-error"
  )
}

is_sim_df <- function(x) {
  sim_df_class <- inherits(x, "data.frame") && inherits(x, "sim_df")
  if (sim_df_class) {
    sim_column <- attr(x, "sim_column")
    if (!is.null(sim_column)) {
      return(inherits(x[[sim_column]], "sim_list") && inherits(x[[sim_column]], "AsIs"))
    }
  }
  FALSE
}

is_df_not_sim_df <- function(x) {
  inherits(x, "data.frame") && (!inherits(x, "sim_df"))
}
