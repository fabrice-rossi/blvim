check_location_data <- function(bipartite, origin_data, destination_data, Y) {
  if (is.null(origin_data)) {
    origin_data <- list()
  } else {
    if (rlang::has_name(origin_data, "names")) {
      origin_data$names <- check_names(origin_data$names, nrow(Y))
    }
    if (rlang::has_name(origin_data, "positions")) {
      check_positions(origin_data$positions, nrow(Y))
    }
  }
  if (is.null(destination_data)) {
    destination_data <- list()
  } else {
    if (rlang::has_name(destination_data, "names")) {
      destination_data$names <- check_names(destination_data$names, ncol(Y))
    }
    if (rlang::has_name(destination_data, "positions")) {
      check_positions(destination_data$positions, ncol(Y))
    }
  }
  if (!bipartite) {
    if (length(origin_data) > 0) {
      ## we keep only origin_data after checking that it is equal
      ## to destination_data
      if (length(destination_data) > 0) {
        if (!identical(origin_data, destination_data)) {
          cli::cli_abort("If {.arg bipartite} is {.val FALSE}, {.arg origin_data} and {.arg destination_data} must be identical.")
        }
      }
      destination_data <- origin_data
    } else {
      origin_data <- destination_data
    }
  }
  list(origin = origin_data, destination = destination_data)
}

## we make sure that the origin and destination members of a sim are lists which
## can be empty if no data has been provided for the corresponding locations
## if the sim is not bipartite, origin and location lists are identical and
## should remain like this.
new_sim <- function(Y,
                    Z,
                    bipartite,
                    origin_data,
                    destination_data,
                    ...,
                    class = character()) {
  location_data <- check_location_data(bipartite, origin_data, destination_data, Y)
  structure(
    list(
      Y = Y,
      Z = Z,
      bipartite = bipartite,
      origin = location_data$origin,
      destination = location_data$destination,
      ...
    ),
    class = c(class, "sim")
  )
}

sim_cli_rep <- function(sim, ...) {
  UseMethod("sim_cli_rep")
}

#' @export
sim_cli_rep.sim <- function(sim, ...) {
  cli::cli_text(
    "Spatial interaction model with ",
    "{.val {nrow(sim$Y)}} origin locations and ",
    "{.val {ncol(sim$Y)}} destination locations"
  )
}

#' @export
format.sim <- function(x, ...) {
  cli::cli_format_method({
    sim_cli_rep(x, ...)
  })
}

#' @export
print.sim <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' Extract the flow matrix from a spatial interaction model object
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a matrix of flows between origin locations and destination locations
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' ## rescale to production
#' attractiveness <- attractiveness / sum(attractiveness) * sum(production)
#' model <- static_blvim(distances, production, 1.5, 1 / 500, attractiveness)
#' flows(model)
#' @seealso [flows_df()] for a data frame version of the flows,
#' [destination_flow()] for destination flows.
flows <- function(sim, ...) {
  UseMethod("flows")
}

#' @export
flows.sim <- function(sim, ...) {
  pre <- sim$Y
  colnames(pre) <- destination_names(sim)
  rownames(pre) <- origin_names(sim)
  pre
}

#' Extract the flow matrix from a spatial interaction model object in data frame
#' format
#'
#' @details This function extracts the flow matrix in a long format. Each row
#'   contains the flow between an origin location and a destination location.
#'   The resulting data frame has at least three columns:
#'  - `origin_idx`: identifies the origin location by its index from 1 to the number
#'   of origin locations
#'  - `destination_idx`: identifies the destination location by its index from 1
#'   to the number of destination locations
#'  - `flow`: the flow between the corresponding location
#'
#'   In addition, if location information is available, it will be included in
#'   the data frame as follows:
#' - location names are included using columns `origin_name` or `destination_name`
#' - positions are included using 2 or 3 columns (per location type, origin or
#'   destination) depending on the number of dimensions used for the location.
#'   The names of the columns are by default `origin_x`, `origin_y` and
#'   `origin_z` ( and equivalent names for destination location) unless
#'   coordinate names are specified in the location positions. In this latter
#'   case, the names are prefixed by `origin_` or `destination_`. For instance,
#'   if the destination location position coordinates are named `"longitude"`
#'   and `"latitude"`, the resulting columns will be `destination_longitude` and
#'   `destination_latitude`.
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters (not used currently)
#'
#' @returns a data frame of flows between origin locations and destination
#'   locations with additional content if available (see Details).
#' @seealso [location_positions()],  [location_names()], [flows()]
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' ## rescale to production
#' attractiveness <- attractiveness / sum(attractiveness) * sum(production)
#' ## simple case (no positions and default names)
#' model <- static_blvim(distances, production, 1.5, 1 / 500, attractiveness)
#' head(flows_df(model))
#' ## with location data
#' positions <- as.matrix(french_cities[1:10, c("th_longitude", "th_latitude")])
#' model <- static_blvim(distances, production, 1.5, 1 / 500, attractiveness,
#'   origin_data = list(positions = positions),
#'   destination_data = list(positions = positions)
#' )
#' head(flows_df(model))
#' ## with names
#' origin_names(model) <- french_cities$name[1:10]
#' destination_names(model) <- french_cities$name[1:10]
#' head(flows_df(model))
flows_df <- function(sim, ...) {
  UseMethod("flows_df")
}

#' @export
flows_df.sim <- function(sim, ...) {
  indexes <- expand.grid(
    origin_idx = seq_len(nrow(sim$Y)),
    destination_idx = seq_len(ncol(sim$Y))
  )
  pre <- cbind(indexes, flow = as.vector(sim$Y))
  if (!is.null(origin_names(sim))) {
    pre <- cbind(pre,
      origin_name = origin_names(sim)[pre$origin_idx]
    )
  }
  if (!is.null(origin_positions(sim))) {
    pos_df <- positions_as_df(origin_positions(sim), "origin")
    pre <- cbind(
      pre,
      pos_df[pre$origin_idx, ]
    )
  }
  if (!is.null(destination_names(sim))) {
    pre <- cbind(pre,
      destination_name = destination_names(sim)[pre$destination_idx]
    )
  }
  if (!is.null(destination_positions(sim))) {
    pos_df <- positions_as_df(destination_positions(sim), "destination")
    pre <- cbind(
      pre,
      pos_df[pre$destination_idx, ]
    )
  }
  pre
}

#' Extract the production constraints from a spatial interaction model object
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a vector of production constraints at the origin locations
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' production(model)
#' ## the names of the production vector are set from the distance matrix
#' ## we remove them for testing equality
#' all.equal(as.numeric(production(model)), production)
#' @seealso [attractiveness()], [destination_flow()]
production <- function(sim, ...) {
  UseMethod("production")
}

#' @export
production.sim <- function(sim, ...) {
  rowSums(flows(sim))
}

#' Extract the attractivenesses from a spatial interaction model object
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a vector of attractivenesses at the destination locations
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' attractiveness(model)
#' ## the names of the attractiveness vector are set from the distance matrix
#' ## we remove them for testing equality
#' all.equal(as.numeric(attractiveness(model)), attractiveness)
#' @seealso [production()], [destination_flow()]
attractiveness <- function(sim, ...) {
  UseMethod("attractiveness")
}

#' @export
attractiveness.sim <- function(sim, ...) {
  pre <- sim$Z
  names(pre) <- destination_names(sim)
  pre
}

#' Compute the flows incoming at each destination location
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a vector of flows incoming at destination locations
#' @export
#'
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' destination_flow(model)
#' ## should be different from the attractiveness as the model is static
#' attractiveness(model)
#' @seealso [production()], [attractiveness()]
destination_flow <- function(sim, ...) {
  UseMethod("destination_flow")
}

#' @export
destination_flow.sim <- function(sim, ...) {
  colSums(flows(sim))
}


#' Returns the number of iterations used to produce this spatial interaction model
#'
#' @param sim a spatial interaction model object (an object of class `sim`) or a
#'   collection of spatial interaction  models (an object of class `sim_list`)
#' @param ... additional parameters
#'
#' @returns a number of iterations that may be one if the spatial interaction model
#'  has been obtained using a static model (see [static_blvim()]). In the case of a `sim_list`
#' the function returns a vector with iteration number per model.
#' @export
#' @seealso [sim_converged()]
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' destination_flow(model)
#' sim_iterations(model) ## must be one
sim_iterations <- function(sim, ...) {
  UseMethod("sim_iterations")
}

#' @export
sim_iterations.sim <- function(sim, ...) {
  1L
}

#' Reports whether the spatial interaction model construction converged
#'
#' Some spatial interaction models are the result of an iterative calculation,
#' see for instance [blvim()]. This calculation may have been interrupted before
#' convergence. The present function returns `TRUE` if the calculation converged,
#' `FALSE` if this was not the case and `NA` if the spatial interaction model
#' is not the result of an iterative calculation. The function applies also to a
#' collection of spatial interaction models as represented by a `sim_list`.
#'
#' @param sim a spatial interaction model object (an object of class `sim`) or a
#'   collection of spatial interaction  models (an object of class `sim_list`)
#' @param ... additional parameters
#'
#' @returns `TRUE`, `FALSE` or `NA`, as described above. In the case of a `sim_list`
#' the function returns a logical vector with one value per model.
#' @export
#' @seealso [sim_iterations()], [blvim()], [grid_blvim()]
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' destination_flow(model)
#' sim_converged(model) ## must be NA
sim_converged <- function(sim, ...) {
  UseMethod("sim_converged")
}

#' @export
sim_converged.sim <- function(sim, ...) {
  NA
}

#' Reports whether the spatial interaction model is bipartite
#'
#' The function returns `TRUE` is the spatial interaction model (SIM) is
#' bipartite, that is if the origin locations are distinct from the destination
#' locations (at least from the analysis point of view). The function return
#' `FALSE` when the SIM uses the same locations for origin and destination.
#'
#' @param sim a spatial interaction model object
#'
#' @returns `TRUE` if the spatial interaction model is bipartite, `FALSE` if
#'   not.
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness)
#' ## returns TRUE despite the use of a single set of positions
#' sim_is_bipartite(model)
#' ## now we are clear about the non bipartite nature of the model
#' model <- static_blvim(distances, production, 1.5, 1, attractiveness,
#'   bipartite = FALSE
#' )
#' sim_is_bipartite(model)
sim_is_bipartite <- function(sim) {
  UseMethod("sim_is_bipartite")
}

#' @export
sim_is_bipartite.sim <- function(sim) {
  sim$bipartite
}
