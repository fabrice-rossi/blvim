% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/terminals.R
\name{is_terminal}
\alias{is_terminal}
\title{Report whether locations are terminal sites or not}
\usage{
is_terminal(sim, definition = c("ND", "RW"), ...)
}
\arguments{
\item{sim}{a spatial interaction model object}

\item{definition}{terminal definition, either \code{"ND"} (for Nystuen & Dacey,
default) or \code{"RW"} (for Rihll & Wilson), see details.}

\item{...}{additional parameters}
}
\value{
a logical vector with \code{TRUE} at the positions of locations that are
terminals and \code{FALSE} for other locations.
}
\description{
This function returns a logical vector whose length equals the number of
locations. The value in position \code{i} is \code{TRUE} if location number \code{i} is
a terminal and \code{FALSE} if it is not. For the definition of terminals,
see \code{\link[=terminals]{terminals()}}.
}
\examples{
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- blvim(distances, production, 1.3, 2, attractiveness, bipartite = FALSE)
is_terminal(model)
}
\seealso{
\code{\link[=terminals]{terminals()}}
}
