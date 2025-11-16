#' Compute the Nystuen and Dacey graph for a spatial interaction model
#'
#' This function computes the most important flows in a spatial interaction
#' model according to the approach outlined by J. D. Nystuen and M. F. Dacey
#' (Nystuen & Dacey, 1961. In this work, a *nodal flow* is the largest flow sent
#' from a non terminal location (based on the definition of terminals recalled
#' in [terminals()]). The *nodal structure* is the collection of those flows.
#' They form an oriented graph that has interesting properties. In particular
#' each weakly connected component contains a single terminal location which can
#' be seen as the dominant location of the component. Notice that because nodal
#' flows are based on terminals, this function applies only to the non bipartite
#' setting.
#'
#' In practice, the function computes first the terminals and non terminals
#' according to either Nystuen & Dacey (1961) or Rihll and Wilson (1991). Then
#' it extracts the nodal flows. The result of the analysis is returned as a data
#' frame with three columns:
#' -  `from`: the index of the non terminal origin location
#' -  `to`: the index of destination location of the nodal flow of `from`
#' -   `flow`: the value of the nodal flow
#'
#' An important aspect of the node structure is that is does not contain
#' isolated terminals. If a location is a terminal but is never the receiver of
#' a nodal flow it will not appear in the collection of nodal flows. It
#' constitutes a a trivial connected component in itself.
#'
#' @inheritParams terminals
#'
#' @returns a data frame describing the Nystuen and Dacey graph a.k.a. the nodal
#'   structure of a spatial interaction model
#' @references Nystuen, J.D. and Dacey, M.F. (1961), "A graph theory
#'   interpretation of nodal regions", Papers and Proceedings of the Regional
#'   Science Association 7: 29-42. \doi{10.1007/bf01969070}
#'
#'   Rihll, T., and Wilson, A. (1991), "Modelling settlement structures in
#'   ancient Greece: new approaches to the polis", In City and Country in the
#'   Ancient World, Vol. 3, Edited by J. Rich and A. Wallace-Hadrill, 58-95.
#'   London: Routledge.
#' @export
#'
#' @seealso [sim_is_bipartite()], [is_terminal()], [terminals()]
#' @examples
#' distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' model <- blvim(distances, production, 1.3, 1 / 250, attractiveness,
#'   bipartite = FALSE
#' )
#' destination_names(model) <- french_cities$name[1:10]
#' nd_graph(model)
#' dist_times <- french_cities_times[1:15, 1:15]
#' tmodel <- blvim(dist_times, rep(1, 15), 1.3, 1 / 5000, rep(1, 15),
#'   bipartite = FALSE
#' )
#' destination_names(tmodel) <- french_cities$name[1:15]
#' terminals(tmodel, definition = "RW")
#' nd_graph(tmodel, "RW")
nd_graph <- function(sim, definition = c("ND", "RW"), ...) {
  UseMethod("nd_graph")
}

#' @export
nd_graph.sim <- function(sim, definition = c("ND", "RW"), ...) {
  definition <- rlang::arg_match(definition, c("ND", "RW"))
  if (sim_is_bipartite(sim)) {
    cli::cli_abort("Nystuen & Dacey graph can only be extracted when the spatial interactive model is not bipartite")
  }
  Y <- flows(sim)
  to_max_flow <- apply(Y, 1, which.max)
  max_flow <- apply(Y, 1, max)
  inputs <- destination_flow(sim)
  if (definition == "ND") {
    is_dominated <- inputs < inputs[to_max_flow]
  } else {
    is_dominated <- inputs < max_flow
  }
  links <- data.frame(from = seq_len(nrow(Y))[is_dominated], to = to_max_flow[is_dominated])
  links$flow <- Y[as.matrix(links)]
  links
}
