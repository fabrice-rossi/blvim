#' Compute the diversity of the destination locations in a spatial interaction
#' model
#'
#' This function computes the diversity of the destination locations according
#' to different definitions that all aim at estimating a number of active
#' destinations, i.e., the number of destination locations that receive a
#' "significant fraction" of the total flow or that are attractive enough. The
#' function applies also to a collection of spatial interaction models as
#' represented by a `sim_list`.
#'
#'
#' In general, the activity of a destination location is measured by its
#' incoming flow a.k.a. its destination flow. If \eqn{Y} is a flow matrix, the
#' destination flows are computed as follows
#'
#' \deqn{\forall j,\quad D_j=\sum_{i=1}^{n}Y_{ij},}
#'
#' for each destination \eqn{j} (see [destination_flow()]). This is the default
#' calculation mode in this function (when the parameter `activity` is set
#' to `"destination"`).
#'
#' For dynamic models produced by [blvim()], the destination attractivenesses
#' can be also considered as activity measures. When convergence occurs,
#' the values are identical, but prior convergence they can be quite different.
#' When `activity` is set to `"attractiveness"`, the diversity measures are
#' computed using the same formula as below but with \eqn{D_j} replaced by
#' \eqn{Z_j} (as given by [attractiveness()]).
#'
#' To compute their
#' diversity using entropy based definitions, the activities are first normalised to
#' be interpreted as a probability distribution over the destination locations.
#' For instance for destination flows, we use
#'
#' \deqn{\forall j,\quad p_j=\frac{D_j}{\sum_{k=1}^n D_k}.}
#'
#' The most classic diversity index is given by the exponential of Shannon's
#' entropy (parameter `definition="shannon"`). This gives
#'
#' \deqn{\text{diversity}(p, \text{Shannon})=\exp\left(-\sum_{k=1}^n p_k\ln
#' p_k\right).}
#'
#' Rényi generalized entropy can be used to define a collection of other
#' diversity metrics. The Rényi diversity of order \eqn{\gamma} is the
#' exponential of the Rényi entropy of order \eqn{\gamma} of the \eqn{p}
#' distribution, that is
#'
#' \deqn{\text{diversity}(p, \text{Rényi},
#' \gamma)=\exp\left(\frac{1}{1-\gamma}\ln
#' \left(\sum_{k=1}^np_k^\gamma\right)\right).}
#'
#' This is defined directly only for \eqn{\gamma\in]0,1[\cup ]1,\infty[}, but
#' extensions to the limit case are straightforward:
#'
#'  - \eqn{\gamma=1} is Shannon's entropy/diversity
#'  - \eqn{\gamma=0} is the max-entropy, here \eqn{\ln(n)} and thus the
#' corresponding diversity is the number of locations
#'  - \eqn{\gamma=\infty} is the min-entropy, here \eqn{-\log \max_{k}p_k} and
#' thhe corresponding diversity is \eqn{\frac{1}{\max_{k}p_k}}
#'
#' The `definition` parameter specifies the diversity used for calculation. The
#' default value is `shannon` for Shannon's entropy (in this case the `order`
#' parameter is not used). Using `renyi` gives access to all Rényi diversities
#' as specified by the `order` parameter. Large values of `order` tend to
#' generate underflows in the calculation that will trigger the use of the
#' min-entropy instead of the exact Rényi entropy.
#'
#' In addition to those entropy based definition, terminal based calculations
#' are also provided. Using any definition supported by the [terminals()]
#' function, the diversity is the number of terminals identified. Notice this
#' applies only to interaction models in which origin and destination locations
#' are identical, i.e. when the model is not bipartite. In addition, the notion
#' of terminals is based on destination flows and cannot be used with activities
#' based on attractivenesses. `definition` can be:
#'
#'   - `"ND"` for the original Nystuen and Dacey definition
#'   - `"RW"` for the variant by Rihll and Wilson
#'
#' See [terminals()] for details.
#'
#' When applied to a collection of spatial interaction  models (an object of
#' class `sim_list`) the function uses the same parameters (`definition` and
#' `order`) for all models and returns a vector of diversities. This is
#' completely equivalent to [grid_diversity()].
#'
#' @param sim a spatial interaction model object (an object of class `sim`) or a
#'   collection of spatial interaction  models (an object of class `sim_list`)
#' @param definition diversity definition `"shannon"` (default), `"renyi"` (see
#'   details) or a definition supported by  [terminals()]
#' @param order order of the Rényi entropy, used only when `definition="renyi"`
#' @param activity specifies whether the diversity is computed based on the
#' destination flows (for `activity="destination"`, the default case) or on
#' the attractivenesses (for `activity="attractiveness"`).
#' @param ... additional parameters
#'
#' @returns the diversity of destination flows (one value per spatial
#'   interaction model)
#' @seealso [destination_flow()], [attractiveness()], [terminals()],
#'   [sim_is_bipartite()]
#' @export
#'
#' @references Jost, L. (2006), "Entropy and diversity", Oikos, 113: 363-375.
#'   \doi{10.1111/j.2006.0030-1299.14714.x}
#' @examples
#' distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
#' production <- log(french_cities$population[1:15])
#' attractiveness <- rep(1, 15)
#' flows <- blvim(distances, production, 1.5, 1 / 100, attractiveness,
#'   bipartite = FALSE
#' )
#' diversity(flows)
#' sim_converged(flows)
#' ## should be identical because of convergence
#' diversity(flows, activity = "attractiveness")
#' diversity(flows, "renyi", 2)
#' diversity(flows, "RW")
diversity <- function(sim, definition = c("shannon", "renyi", "ND", "RW"),
                      order = 1L, activity = c("destination", "attractiveness"),
                      ...) {
  UseMethod("diversity")
}

#' @export
#' @rdname diversity
diversity.sim <- function(sim, definition = c("shannon", "renyi", "ND", "RW"),
                          order = 1L,
                          activity = c("destination", "attractiveness"),
                          ...) {
  definition <- rlang::arg_match(definition)
  activity <- rlang::arg_match(activity)
  if (activity == "attractiveness" && (definition == "ND" || definition == "RW")) {
    cli::cli_abort(c("{.arg activity}={.str attractiveness} is not compatible
with terminal based diversity definition",
      "x" = "{.arg definition} is {.val {definition}}"
    ))
  }
  if (definition == "renyi" && order < 0) {
    cli::cli_abort(c("{.arg order} must be non negative",
      "x" = "{.arg order} is {.val {order}}"
    ))
  }
  if (definition == "shannon" || definition == "renyi") {
    if (activity == "destination") {
      D <- destination_flow(sim)
    } else {
      D <- attractiveness(sim)
    }
    D <- D / sum(D)
    if (definition == "shannon" || (definition == "renyi" && order == 1L)) {
      exp(-sum(ifelse(D > 0, D * log(D), 0)))
    } else {
      D_sum <- sum(D^order)
      if (D_sum == 0) {
        ## approximate by min entropy
        1 / max(D)
      } else {
        D_sum^(1 / (1 - order))
      }
    }
  } else {
    length(terminals(sim, definition = definition))
  }
}

#' @export
#' @rdname diversity
diversity.sim_list <- function(sim,
                               definition = c("shannon", "renyi", "ND", "RW"),
                               order = 1L,
                               activity = c("destination", "attractiveness"),
                               ...) {
  sapply(sim, diversity, definition, order, activity, ...)
}
