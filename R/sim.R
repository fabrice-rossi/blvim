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
#' [destination_flow()] for destination flows, [production()] and
#' [attractiveness()].
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
#'  - `flow`: the flow between the corresponding locations
#'
#'   In addition, if location information is available, it will be included in
#'   the data frame as follows:
#' - location names are included using columns `origin_name` or `destination_name`
#' - positions are included using 2 or 3 columns (per location type, origin or
#'   destination) depending on the number of dimensions used for the locations.
#'   The names of the columns are by default `origin_x`, `origin_y` and
#'   `origin_z` (and equivalent names for destination locations) unless
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
#' @seealso [flows()], [location_positions()], [location_names()],
#'   [fortify.sim()]
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
#' @seealso [attractiveness()], [destination_flow()], [flows()]
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
#' @seealso [initial_attractiveness()], [production()], [destination_flow()]
attractiveness <- function(sim, ...) {
  UseMethod("attractiveness")
}

#' @export
attractiveness.sim <- function(sim, ...) {
  pre <- sim$Z
  names(pre) <- destination_names(sim)
  pre
}

#' Extract the initial attractivenesses from a spatial interaction model object
#'
#' Extracts the destination attractivenesses used to initialise the construction
#' of a spatial interaction model. For static models, this is identical to their
#' [attractiveness()]. For a spatial interaction model produced by an iterative
#' algorithm, this function returns the attractivenesses used to initialise the
#' algorithm. [attractiveness()] returns the final attractivenesses.
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a vector containing the initial destination
#'   attractivenesses
#'
#' @seealso [attractiveness()], [static_blvim()], [blvim()]
#'
#' @export
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' initial_attractiveness(model)
#' identical(
#'   initial_attractiveness(model),
#'   attractiveness(model)
#' )
initial_attractiveness <- function(sim, ...) {
  UseMethod("initial_attractiveness")
}

#' @export
initial_attractiveness.sim <- function(sim, ...) {
  attractiveness(sim)
}

#' Compute the incoming flow at each destination location
#'
#' @param sim a spatial interaction model object
#' @param ... additional parameters
#'
#' @returns a vector of incoming flows, one per destination location
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
#' @seealso [flows()], [production()], [attractiveness()], [diversity()]
destination_flow <- function(sim, ...) {
  UseMethod("destination_flow")
}

#' @export
destination_flow.sim <- function(sim, ...) {
  colSums(flows(sim))
}

#' Return the number of iterations used to produce a spatial interaction model
#'
#' @param sim a spatial interaction model object (an object of class `sim`) or a
#'   collection of spatial interaction models (an object of class `sim_list`)
#' @param ... additional parameters
#'
#' @returns the number of iterations, which is one for a static model (see
#'   [static_blvim()]). In the case of a `sim_list` the function returns a
#'   vector with one number of iterations per model.
#' @export
#' @seealso [sim_converged()], [sim_diagnostic()], [blvim()],
#'   [grid_sim_iterations()]
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_iterations(model) ## must be one
#' dyn_model <- blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_iterations(dyn_model)
sim_iterations <- function(sim, ...) {
  UseMethod("sim_iterations")
}

#' @export
sim_iterations.sim <- function(sim, ...) {
  1L
}

#' Report whether the construction of a spatial interaction model converged
#'
#' Some spatial interaction models are the result of an iterative calculation,
#' see for instance [blvim()]. This calculation may have been interrupted before
#' convergence. This function returns `TRUE` if the calculation converged,
#' `FALSE` if this was not the case and `NA` if the spatial interaction model
#' is not the result of an iterative calculation. The function applies also to a
#' collection of spatial interaction models as represented by a `sim_list`.
#'
#' @param sim a spatial interaction model object (an object of class `sim`) or a
#'   collection of spatial interaction models (an object of class `sim_list`)
#' @param ... additional parameters
#'
#' @returns `TRUE`, `FALSE` or `NA`, as described above. In the case of a
#'   `sim_list` the function returns a logical vector with one value per model.
#' @export
#' @seealso [sim_iterations()], [sim_diagnostic()], [blvim()],
#'   [grid_sim_converged()]
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_converged(model) ## must be NA
#' dyn_model <- blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_converged(dyn_model)
sim_converged <- function(sim, ...) {
  UseMethod("sim_converged")
}

#' @export
sim_converged.sim <- function(sim, ...) {
  NA
}

#' Return a full diagnostic of the algorithm used to build a spatial
#' interaction model
#'
#' Some spatial interaction models are the result of an iterative calculation,
#' see for instance [blvim()]. This function returns a diagnostic object that
#' gives details about the behaviour of the iterative algorithm. For a
#' spatial interaction model that is not the result of an iterative
#' calculation, the diagnostic object is essentially empty.
#'
#' @param sim a spatial interaction model object (an object of class `sim`)
#' @param ... additional parameters
#'
#' @returns a diagnostic object whose class inherits from `sim_diagnostic`
#' @export
#' @seealso [sim_iterations()], [sim_converged()], [sim_logs()], [blvim()],
#'   [blvim_gradient_control()]
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_diagnostic(model)
#' dyn_model <- blvim(distances, production, 1.5, 1 / 250, attractiveness,
#'   algorithm = "gradient"
#' )
#' sim_diagnostic(dyn_model)
sim_diagnostic <- function(sim, ...) {
  UseMethod("sim_diagnostic")
}

#' @export
sim_diagnostic.sim <- function(sim, ...) {
  new_sim_diagnostic(...)
}


#' Report whether a spatial interaction model is bipartite
#'
#' The function returns `TRUE` if the spatial interaction model (SIM) is
#' bipartite, that is if the origin locations are distinct from the destination
#' locations (at least from the analysis point of view). The function returns
#' `FALSE` when the SIM uses the same locations for origin and destination.
#'
#' @param sim a spatial interaction model object
#'
#' @returns `TRUE` if the spatial interaction model is bipartite, `FALSE` if
#'   not.
#' @seealso [static_blvim()] and [blvim()] (parameter `bipartite`), and
#'   [terminals()] and [nd_graph()] for functions specific to non-bipartite
#'   models.
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
#' ## now we are explicit about the non-bipartite nature of the model
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

#' Return the conversion factors between attractivenesses and incoming flows
#'
#' Some spatial interaction models use conversion factors between
#' attractivenesses and incoming flows to check whether they are at equilibrium
#' (see for instance [blvim()]). This function returns the conversion factors
#' used to build the spatial interaction model when applicable, and `NA`
#' otherwise.
#'
#' @param sim a spatial interaction model object (an object of class `sim`)
#' @param ... additional parameters
#'
#' @returns `NA` or a vector of conversion factors (one per destination
#'   location), see above.
#' @export
#' @seealso [blvim()], [sim_potential()], [sim_fp_jacobian()]
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_conversion(model) ## must be NA
#' dyn_model <- blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_conversion(dyn_model) ## the default value 1, for each destination
sim_conversion <- function(sim, ...) {
  UseMethod("sim_conversion")
}

#' @export
sim_conversion.sim <- function(sim, ...) {
  NA
}

#' Compute the potential of a spatial interaction model
#'
#' The potential is a measure of stability introduced by Osawa, Akamatsu, and
#' Kogure. It is only defined for spatial interaction models produced by the
#' BLV framework. The function returns `NA` when applied to spatial interaction
#' models for which a potential cannot be computed. The function applies also to
#' a collection of spatial interaction models as represented by a `sim_list`.
#'
#' The potential of a spatial interaction model is given by
#'
#' \deqn{\frac{1}{\alpha}\sum_{i=1}^n X_i \log\left(\sum_{j=1}^p Z_j^{\alpha}\,
#' \exp(-\beta c_{ij})\right)-\sum_{j=1}^p\kappa_jZ_j,}
#'
#' where:
#' * \eqn{c} is the cost matrix ([costs()])
#' * \eqn{X} is the production constraint vector ([production()])
#' * \eqn{\alpha} is the return to scale parameter ([return_to_scale()])
#' * \eqn{\beta} is the inverse of a cost scale parameter ([inverse_cost()])
#' * \eqn{Z} is the attractiveness vector ([attractiveness()])
#' * \eqn{\kappa} is the conversion factor vector ([sim_conversion()])
#'
#'
#' @param sim a spatial interaction model object (an object of class `sim`) or a
#'   collection of spatial interaction models (an object of class `sim_list`)
#' @param ... additional parameters
#'
#' @references Osawa, M., Akamatsu, T., & Kogure, Y. (2025). "Most likely retail
#'   agglomeration patterns: Potential maximization and stochastic stability of
#'   spatial equilibria". <https://arxiv.org/abs/2011.06778v2>
#' @returns the scalar value of the potential, or `NA` when it cannot be
#'   computed. In the case of a `sim_list` the function returns a numeric
#'   vector with one value per model.
#' @seealso [blvim()], [grid_sim_potential()], [sim_fp_jacobian()],
#'   [sim_conversion()]
#' @export
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_potential(model) ## must be NA
#' dyn_model <- blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_potential(dyn_model)
sim_potential <- function(sim, ...) {
  UseMethod("sim_potential")
}

#' @export
sim_potential.sim <- function(sim, ...) {
  NA
}

#' Compute the Jacobian of the fixed-point map G
#'
#' The function computes the Jacobian matrix of the fixed-point map with respect
#' to the attractivenesses. The function returns `NA` when applied to spatial
#' interaction models for which the map is not defined.
#'
#' The fixed-point map \eqn{\mathbf{G}} is given by
#'
#' \deqn{G_j=D_j-\kappa_j Z_j,}
#'
#' where \eqn{D_j} is the destination flow ([destination_flow()]),
#' \eqn{Z_j} the attractiveness ([attractiveness()]) and \eqn{\kappa_j} the
#' conversion factor ([sim_conversion()]), all attached to destination \eqn{j}.
#'
#' The derivatives of \eqn{\mathbf{G}} w.r.t. \eqn{\mathbf{Z}} can be used to
#' analyse the stability of the solutions, among other applications.
#'
#' @param sim a spatial interaction model, an object of class `sim`
#' @param ... additional parameters
#'
#' @returns a \eqn{p\times p} matrix, where \eqn{p} is the number of destination
#'   locations, or `NA` when the fixed-point map is not defined
#' @seealso [sim_potential()], [sim_conversion()], [destination_flow()]
#' @export
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- log(french_cities$population[1:10])
#' attractiveness <- log(french_cities$area[1:10])
#' model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_fp_jacobian(model) ## must be NA
#' dyn_model <- blvim(distances, production, 1.5, 1 / 250, attractiveness)
#' sim_fp_jacobian(dyn_model)
sim_fp_jacobian <- function(sim, ...) {
  UseMethod("sim_fp_jacobian")
}

#' @export
sim_fp_jacobian.sim <- function(sim, ...) {
  NA
}
