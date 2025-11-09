# Compute an equilibrium solution of the Boltzmann–Lotka–Volterra model

This function computes flows between origin locations and destination
locations at an equilibrium solution of A. Wilson's
Boltzmann–Lotka–Volterra (BLV) interaction model. The BLV dynamic model
is initialised with the production constraints at the origin locations
and the initial values of the the attractiveness of destination
locations. Iterations update the attractivenesses according the received
flows.

## Usage

``` r
blvim(
  costs,
  X,
  alpha,
  beta,
  Z,
  bipartite = TRUE,
  origin_data = NULL,
  destination_data = NULL,
  epsilon = 0.01,
  iter_max = 50000,
  conv_check = 100,
  precision = 1e-06,
  quadratic = FALSE
)
```

## Arguments

- costs:

  a cost matrix

- X:

  a vector of production constraints

- alpha:

  the return to scale parameter

- beta:

  the inverse cost scale parameter

- Z:

  a vector of initial destination attractivenesses

- bipartite:

  when `TRUE` (default value), the origin and destination locations are
  considered to be distinct. When `FALSE`, a single set of locations
  plays the both roles. This has only consequences in functions specific
  to this latter case such as
  [`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md).

- origin_data:

  `NULL` or a list of additional data about the origin locations (see
  details)

- destination_data:

  `NULL` or a list of additional data about the destination locations
  (see details)

- epsilon:

  the update intensity

- iter_max:

  the maximal number of steps of the BLV dynamic

- conv_check:

  number of iterations between to convergence test

- precision:

  convergence threshold

- quadratic:

  selects the update rule, see details.

## Value

an object of class `sim`(and `sim_blvim`) for spatial interaction model
that contains the matrix of flows between the origin and the destination
locations as well as the final attractivenesses computed by the model.

## Details

In a step of the BLV model, flows are computed according to the
production constrained entropy maximising model proposed by A. Wilson
and implemented in
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md).
Then the flows received at a destination are computed as follows

\$\$\forall j,\quad D_j=\sum\_{i=1}^{n}Y\_{ij},\$\$

for destination \\j\\. This enables updating the attractivenesses by
making them closer to the received flows, i.e. trying to reduce
\\\|D_j-Z_j\|\\.

A. Wilson and co-authors proposed two different update strategies:

1.  The original model proposed in Harris & Wilson (1978) updates the
    \\Z_j\\ as follows \$\$Z_j^{t+1} = Z_j^{t} + \epsilon
    (D^{t}\_j-Z^{t}\_j)\$\$

2.  In Wilson (2008), the update is given by \$\$Z_j^{t+1} = Z_j^{t} +
    \epsilon (D^{t}\_j-Z^{t}\_j)Z^{t}\_j\$\$

In both cases, \\\epsilon\\ is given by the `epsilon` parameter. It
should be smaller than 1. The first update is used when the `quadratic`
parameter is `FALSE` which is the default value. The second update is
used when `quadratic` is `TRUE`.

Updates are performed until convergence or for a maximum of `iter_max`
iterations. Convergence is checked every `conv_check` iterations. The
algorithm is considered to have converged if \$\$\\Z^{t+1}-Z^t\\\<\delta
(\\Z^{t+1}\\+\delta),\$\$ where \\\delta\\ is given by the `precision`
parameter.

## Location data

While models in this package do not use location data beyond `X` and
`Z`, additional data can be stored and used when analysing spatial
interaction models.

### Origin and destination location names

Spatial interaction models can store names for origin and destination
locations, using
[`origin_names<-()`](https://fabrice-rossi.github.io/blvim/reference/origin_names.md)
and
[`destination_names<-()`](https://fabrice-rossi.github.io/blvim/reference/destination_names.md).
Names are taken by default from names of the cost matrix `costs`. More
precisely, `rownames(costs)` is used for origin location names and
`colnames(costs)` for destination location names.

### Origin and destination location positions

Spatial interaction models can store the positions of the origin and
destination locations, using
[`origin_positions<-()`](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md)
and
[`destination_positions<-()`](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md).

### Specifying location data

In addition to the functions mentioned above, location data can be
specified directly using the `origin_data` and `destination_data`
parameters. Data are given by a list whose components are not
interpreted excepted the following ones:

- `names` is used to specify location names and its content has to
  follow the restrictions documented in
  [`origin_names<-()`](https://fabrice-rossi.github.io/blvim/reference/origin_names.md)
  and
  [`destination_names<-()`](https://fabrice-rossi.github.io/blvim/reference/destination_names.md)

- `positions` is used to specify location positions and its content has
  to follow the restrictions documented in
  [`origin_positions<-()`](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md)
  and
  [`destination_positions<-()`](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md)

## References

Harris, B., & Wilson, A. G. (1978). "Equilibrium Values and Dynamics of
Attractiveness Terms in Production-Constrained Spatial-Interaction
Models", Environment and Planning A: Economy and Space, 10(4), 371-388.
[doi:10.1068/a100371](https://doi.org/10.1068/a100371)

Wilson, A. (2008), "Boltzmann, Lotka and Volterra and spatial structural
evolution: an integrated methodology for some dynamical systems", J. R.
Soc. Interface.5865–871
[doi:10.1098/rsif.2007.1288](https://doi.org/10.1098/rsif.2007.1288)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
flows <- blvim(distances, production, 1.5, 1, attractiveness)
flows
#> Spatial interaction model with 10 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.5 and inverse cost scale (beta) = 1
#> ℹ The BLV model converged after 1700 iterations.
```
