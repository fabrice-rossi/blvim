% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sim.R
\name{attractiveness}
\alias{attractiveness}
\title{Extract the attractivenesses from a spatial interaction model object}
\usage{
attractiveness(sim, ...)
}
\arguments{
\item{sim}{a spatial interaction model object}

\item{...}{additional parameters}
}
\value{
a vector of attractivenesses at the destination locations
}
\description{
Extract the attractivenesses from a spatial interaction model object
}
\examples{
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
attractiveness(model)
}
