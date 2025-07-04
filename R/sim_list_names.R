#' @export
location_names.sim_list <- function(sim) {
  list(
    origin = sim$common$origin[["names"]],
    destination = sim$common$destination[["names"]]
  )
}

#' @export
`location_names<-.sim_list` <- function(sim, value) {
  check_location_names(sim$sims[[1]], value)
  sim$common$origin[["names"]] <- value$origin
  sim$common$destination[["names"]] <- value$destination
  sim
}

#' @export
origin_names.sim_list <- function(sim) {
  sim$common$origin[["names"]]
}


#' @export
`origin_names<-.sim_list` <- function(sim, value) {
  sim$common$origin[["names"]] <- check_names(value, nrow(sim$sims[[1]]$Y))
  if (!sim_is_bipartite(sim$sims[[1]])) {
    sim$common$destination[["names"]] <- sim$common$origin[["names"]]
  }
  sim
}

#' @export
destination_names.sim_list <- function(sim) {
  sim$common$destination[["names"]]
}

#' @export
`destination_names<-.sim_list` <- function(sim, value) {
  sim$common$destination[["names"]] <- check_names(value, ncol(sim$sims[[1]]$Y))
  if (!sim_is_bipartite(sim$sims[[1]])) {
    sim$common$origin[["names"]] <- sim$common$destination[["names"]]
  }
  sim
}
