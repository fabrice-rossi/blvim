#' Compute the diversity of the destination flows in a spatial interaction model
#'
#' This function computes the diversity of the destination flows according to
#' different definitions that all aim at estimating a number of active
#' destinations, i.e., the number of destination locations that receive a
#' "significant fraction" of the total flow. The function applies also to a
#' collection of spatial interaction models as represented by a `sim_list`.
#'
#' If \eqn{Y} is a flow matrix, the destination flows are computed as follows
#'
#' \deqn{\forall j,\quad D_j=\sum_{i=1}^{n}Y_{ij},}
#'
#' for each destination \eqn{j} (see [destination_flow()]). To compute their
#' diversity using entropy based definitions, the flows are first normalised to
#' be interpreted as a probability distribution over the destination locations.
#' We use
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
#'  - \eqn{\gamma=0} is the max-entropy, here \eqn{\ln(n)} and thus the corresponding
#' diversity is the number of locations
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
#' are also provided. Using any definition supported by the [terminals()] function,
#' the diversity is the number of terminals identified. Notice this applies only
#' to interaction models in which origin and destination locations are identical,
#' i.e. when the model is not bipartite. Current values of definitions are:
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
#' @param definition diversity definition `"shannon"` (default),
#'   `"renyi"` (see details) or a definition supported by  [terminals()]
#' @param order order of the Rényi entropy, used only when `definition="renyi"`
#' @param ... additional parameters
#'
#' @returns the diversity of destination flows (one value per spatial
#'   interaction model)
#' @seealso [destination_flow()], [terminals()], [sim_is_bipartite()]
#' @export
#'
#' @references Jost, L. (2006), "Entropy and diversity", Oikos, 113: 363-375.
#'   \doi{10.1111/j.2006.0030-1299.14714.x}
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' flows <- blvim(distances, production, 1.5, 3, attractiveness, bipartite = FALSE)
#' diversity(flows)
#' diversity(flows, "renyi", 2)
#' diversity(flows, "RW")
diversity <- function(sim, definition = c("shannon", "renyi", "ND", "RW"), order = 1L, ...) {
  UseMethod("diversity")
}

#' @export
#' @rdname diversity
diversity.sim <- function(sim, definition = c("shannon", "renyi", "ND", "RW"), order = 1L, ...) {
  definition <- rlang::arg_match(definition)
  if (definition == "renyi" && order < 0) {
    cli::cli_abort(c("{.arg order} must be non negative",
      "x" = "{.arg order} is {.val {order}}"
    ))
  }
  if (definition == "shannon" || definition == "renyi") {
    D <- destination_flow(sim)
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
diversity.sim_list <- function(sim, definition = c("shannon", "renyi", "ND", "RW"), order = 1L, ...) {
  sapply(sim, diversity, definition, order, ...)
}
