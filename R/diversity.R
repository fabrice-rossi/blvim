#' Compute the diversity of the destination flows in a spatial interaction model
#'
#' This function computes the diversity of the destination flows according to
#' different definitions that all aim at estimating a number of active destinations,
#' i.e., the number of destination locations that receive a "significant fraction"
#' of the total flow.
#'
#' If \eqn{Y} is a flow matrix, the destination flows are computed as follows
#'
#' \deqn{\forall j,\quad D_j=\sum_{i=1}^{n}Y_{ij},}
#'
#' for each destination \eqn{j} (see [destination_flow()]). To compute their
#' diversity, they are first normalised to be interpreted as a probability
#' distribution over the destination locations. We use
#'
#' \deqn{\forall j,\quad p_j=\frac{D_j}{\sum_{k=1}^n D_k}.}
#'
#' The most classic diversity index is given by the exponential of Shannon's
#' entropy (parameter `definition="shannon"`). This gives
#'
#' \deqn{\text{diversity}(p, \text{Shannon})=\exp\left(-\sum_{k=1}^n p_k\ln p_k\right).}
#'
#' Rényi generalized entropy can be used to define a collection of other diversity
#' metrics. The Rényi diversity of order \eqn{\gamma} is the exponential of the
#' Rényi entropy of order \eqn{\gamma} of the \eqn{p} distribution, that is
#'
#' \deqn{\text{diversity}(p, \text{Rényi}, \gamma)=\exp\left(\frac{1}{1-\gamma}\ln \left(\sum_{k=1}^np_k^\gamma\right)\right).}
#'
#' This is defined directly only for \eqn{\gamma\in]0,1[\cup ]1,\infty[}, but
#' extensions to the limit case are straightforward:
#'
#'  - \eqn{\gamma=1} is Shannon's entropy/diversity
#'  - \eqn{\gamma=0} is the max-entropy, here \eqn{\ln(n)} and thus the corresponding
#'    diversity is the number of locations
#'  - \eqn{\gamma=\infty} is the min-entropy, here \eqn{-\log \max_{k}p_k} and
#'    thhe corresponding diversity is \eqn{\frac{1}{\max_{k}p_k}}
#'
#' The `definition` parameter specifies the diversity used for calculation. The
#' default value is `shannon` for Shannon's entropy (in this case the `order`
#' parameter is not used). Using `renyi` gives access to all Rényi diversities
#' as specified by the `order` parameter. Large values of `order` tend to generate
#' underflows in the calculation that will trigger the use of the min-entropy instead
#' of the exact Rényi entropy.
#'
#' @param sim a spatial interaction model object
#' @param definition diversity definition either `"shannon"` (default) or `"renyi"` (see details)
#' @param order order of the Rényi entropy, used only when `defintion="renyi"`
#'
#' @returns the diversity of destination flows
#' @seealso [destination_flow()]
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- c(2, rep(1, 9))
#' flows <- blvim(distances, production, 1.5, 3, attractiveness)
#' diversity(flows)
#' diversity(flows, "renyi", 2)
diversity <- function(sim, definition = c("shannon", "renyi"), order = 1L) {
  definition <- rlang::arg_match(definition)
  if (definition == "renyi" && order < 0) {
    cli::cli_abort(c("{.var order} must be non negative",
      "x" = "{.var order} is {.val {order}}"
    ))
  }
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
}
