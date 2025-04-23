#' Compute terminals for a spatial interaction model
#'
#' This function identifies terminals in the locations underlying the given
#' spatial interaction model. Terminals are locally dominating locations that
#' essentially send less to other locations than they receive (see details for
#' formal definitions). As we compare incoming flows to outgoing flows, terminal
#' computation is restricted to interaction models in which origin and
#' destination locations are identical.
#'
#' The notion of terminal used in this function is based on seminal work by J.
#' D. Nystuen and M. F. Dacey (Nystuen & Dacey, 1961), as well as on the follow
#' up variation from Rihll & Wislon (1987 and 1991). We assume given a square
#' flow matrix \eqn{(Y_{ij})_{1\leq i\leq n, 1\leq j\leq n}}. The incoming flow
#' at location \eqn{j} is given by
#'
#' \deqn{D_j=\sum_{j=i}^{p}Y_{ij},}
#'
#' and is used as a measure of importance of this location. Then in Nystuen &
#' Dacey (1961), location \eqn{j} is a "terminal point" (or a "central city") if
#'
#' \deqn{D_j \geq D_{m(j)},}
#'
#' where \eqn{m(j)} is such that
#'
#' \deqn{\forall l,\quad Y_{jl}\leq Y_{jm(j)}.}
#'
#' In words, \eqn{j} is a terminal if the location \eqn{m(j)} to which it sends
#' its largest flow is less important than \eqn{j} itself, in terms of incoming
#' flows. This is the definition used by the function when `definition` is
#' `"ND"`.
#'
#' Rihll & Wilson (1987) use a modified version of this definition described in
#' details in Rihll and Wilson (1991). With this relaxed version, location
#' \eqn{j} is a terminal if
#'
#' \deqn{\forall i,\quad D_j \geq Y_{ij}.}
#'
#' In words, \eqn{j} is a terminal if it receives more flows than it is sending
#' to each other location. It is easy to see that each Nystuen & Dacey terminal
#' is a Rihll & Wilson terminal, but the reverse is false in general. The
#' function use the Rihll & Wilson definition when `definition` is `"RW"`
#'
#' @param sim a spatial interaction model object
#' @param definition terminal definition, either `"ND"` (for Nystuen & Dacey,
#'   default) or `"RW"` (for Rihll & Wilson), see details.
#' @param ... additional parameters
#'
#' @returns a vector containing the indexes of the terminals identified from the
#'   flow matrix of the interaction model.
#' @export
#'
#' @examples
#' positions <- matrix(rnorm(10 * 2), ncol = 2)
#' distances <- as.matrix(dist(positions))
#' production <- rep(1, 10)
#' attractiveness <- rep(1, 10)
#' model <- blvim(distances, production, 1.3, 2, attractiveness)
#' terminals(model)
#' @references Nystuen, J.D. and Dacey, M.F. (1961), "A graph theory
#'   interpretation of nodal regions", Papers and Proceedings of the Regional
#'   Science Association 7: 29–42. \doi{10.1007/bf01969070}
#'
#'   Rihll, T.E., and Wilson, A.G. (1987). "Spatial interaction and structural
#'   models in historical analysis: some possibilities and an example", Histoire
#'   & Mesure 2: 5–32. \doi{10.3406/hism.1987.1300}
#'
#'   Rihll, T., and Wilson, A. (1991), "Modelling settlement structures in
#'   ancient Greece: new approaches to the polis", In City and Country in the
#'   Ancient World, Vol. 3, Edited by J. Rich and A. Wallace-Hadrill, 58–95.
#'   London: Routledge.
terminals <- function(sim, definition = c("ND", "RW"), ...) {
  UseMethod("terminals")
}

#' @export
terminals.sim <- function(sim, definition = c("ND", "RW"), ...) {
  definition <- rlang::arg_match(definition, c("ND", "RW"))
  Y <- flows(sim)
  if (nrow(Y) != ncol(Y)) {
    cli::cli_abort(c("Terminals can only be extracted when origin and destination match",
      "x" = "This spatial interaction model has {.val {nrow(Y)}} origin locations and {.val {ncol(Y)}} destination locations"
    ))
  }
  if (definition == "ND") {
    # Nystuen and Dacey definition
    # maximum output
    to_max_flow <- apply(Y, 1, which.max)
    # inputs
    inputs <- destination_flow(sim)
    # subordination is when the max flow from A to B is such that B has a
    # larger total inflow that A
    is_terminal <- inputs >= inputs[to_max_flow]
    which(is_terminal)
  } else {
    # Rihll and Wilson definition
    # maximum output
    max_flow <- apply(Y, 1, max)
    # inputs
    inputs <- destination_flow(sim)
    # subordination is when the max flow from A to B is larger than the
    # inflow of A
    is_terminal <- inputs >= max_flow
    which(is_terminal)
  }
}
