s3_method_exists <- function(method) {
  !inherits(
    try(sloop::s3_get_method({{ method }}), silent = TRUE),
    "try-error"
  )
}
