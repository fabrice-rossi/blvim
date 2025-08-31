#' @export
location_positions.sim_list <- function(sim) {
  list(
    origin = attr(sim, "common")$origin[["positions"]],
    destination = attr(sim, "common")$destination[["positions"]]
  )
}

#' @export
`location_positions<-.sim_list` <- function(sim, value) {
  check_location_positions(sim[[1]], value)
  attr(sim, "common")$origin[["positions"]] <- value$origin
  attr(sim, "common")$destination[["positions"]] <- value$destination
  sim
}

#' @export
origin_positions.sim_list <- function(sim) {
  attr(sim, "common")$origin[["positions"]]
}


#' @export
`origin_positions<-.sim_list` <- function(sim, value) {
  check_positions(value, nrow(sim[[1]]$Y))
  attr(sim, "common")$origin[["positions"]] <- value
  if (!sim_is_bipartite(sim[[1]])) {
    attr(sim, "common")$destination[["positions"]] <- value
  }
  sim
}

#' @export
destination_positions.sim_list <- function(sim) {
  attr(sim, "common")$destination[["positions"]]
}

#' @export
`destination_positions<-.sim_list` <- function(sim, value) {
  check_positions(value, ncol(sim[[1]]$Y))
  attr(sim, "common")$destination[["positions"]] <- value
  if (!sim_is_bipartite(sim[[1]])) {
    attr(sim, "common")$origin[["positions"]] <- value
  }
  sim
}
