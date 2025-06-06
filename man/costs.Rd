% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sim_wpc.R
\name{costs}
\alias{costs}
\title{Extract the inverse cost matrix used to compute this model}
\usage{
costs(sim, ...)
}
\arguments{
\item{sim}{a spatial interaction model with a cost matrix}

\item{...}{additional parameters}
}
\value{
the cost matrix
}
\description{
Extract the inverse cost matrix used to compute this model
}
\examples{
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
costs(model) ## should be equal to distances above
}
