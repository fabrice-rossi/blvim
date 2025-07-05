#' @export
location_positions.sim_list <- function(sim) {
  list(
    origin = sim$common$origin[["positions"]],
    destination = sim$common$destination[["positions"]]
  )
}

#' @export
`location_positions<-.sim_list` <- function(sim, value) {
  check_location_positions(sim$sims[[1]], value)
  sim$common$origin[["positions"]] <- value$origin
  sim$common$destination[["positions"]] <- value$destination
  sim
}

#' @export
origin_positions.sim_list <- function(sim) {
  sim$common$origin[["positions"]]
}


#' @export
`origin_positions<-.sim_list` <- function(sim, value) {
  check_positions(value, nrow(sim$sims[[1]]$Y))
  sim$common$origin[["positions"]] <- value
  if (!sim_is_bipartite(sim$sims[[1]])) {
    sim$common$destination[["positions"]] <- value
  }
  sim
}

#' @export
destination_positions.sim_list <- function(sim) {
  sim$common$destination[["positions"]]
}

#' @export
`destination_positions<-.sim_list` <- function(sim, value) {
  check_positions(value, ncol(sim$sims[[1]]$Y))
  sim$common$destination[["positions"]] <- value
  if (!sim_is_bipartite(sim$sims[[1]])) {
    sim$common$origin[["positions"]] <- value
  }
  sim
}
