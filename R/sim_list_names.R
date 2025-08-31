#' @export
location_names.sim_list <- function(sim) {
  list(
    origin = attr(sim, "common")$origin[["names"]],
    destination = attr(sim, "common")$destination[["names"]]
  )
}

#' @export
`location_names<-.sim_list` <- function(sim, value) {
  check_location_names(sim[[1]], value)
  attr(sim, "common")$origin[["names"]] <- value$origin
  attr(sim, "common")$destination[["names"]] <- value$destination
  sim
}

#' @export
origin_names.sim_list <- function(sim) {
  attr(sim, "common")$origin[["names"]]
}


#' @export
`origin_names<-.sim_list` <- function(sim, value) {
  attr(sim, "common")$origin[["names"]] <- check_names(value, nrow(sim[[1]]$Y))
  if (!sim_is_bipartite(sim[[1]])) {
    attr(sim, "common")$destination[["names"]] <- attr(sim, "common")$origin[["names"]]
  }
  sim
}

#' @export
destination_names.sim_list <- function(sim) {
  attr(sim, "common")$destination[["names"]]
}

#' @export
`destination_names<-.sim_list` <- function(sim, value) {
  attr(sim, "common")$destination[["names"]] <- check_names(value, ncol(sim[[1]]$Y))
  if (!sim_is_bipartite(sim[[1]])) {
    attr(sim, "common")$origin[["names"]] <- attr(sim, "common")$destination[["names"]]
  }
  sim
}
