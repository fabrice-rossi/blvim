# Compute a collection of Boltzmann-Lotka-Volterra model solutions

This function computes a collection of flows between origin locations
and destination locations using
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md) on
a grid of parameters. The flows use the same costs, same production
constraints and same attractivenesses. Each flow is computed using one
of all the pairwise combinations between the alpha values given by
`alphas` and the beta values given by `betas`. The function returns an
object of class `sim_list` which contains the resulting flows.

## Usage

``` r
grid_blvim(
  costs,
  X,
  alphas,
  betas,
  Z,
  bipartite = TRUE,
  origin_data = NULL,
  destination_data = NULL,
  epsilon = 0.01,
  iter_max = 50000,
  conv_check = 100,
  precision = 1e-06,
  quadratic = FALSE,
  progress = FALSE
)
```

## Arguments

- costs:

  a cost matrix

- X:

  a vector of production constraints

- alphas:

  a vector of return to scale parameters

- betas:

  a vector of cost inverse scale parameters

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

- progress:

  if TRUE, a progress bar is shown during the calculation (defaults to
  FALSE)

## Value

an object of class `sim_list`

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

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
all_flows <- grid_blvim(
  distances, production, c(1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness
)
all_flows
#> Collection of 8 spatial interaction models with 10 origin locations and 10
#> destination locations computed on the following grid:
#> • alpha: 1.25 and 1.5
#> • beta: 0.002, 0.004, 0.006, and 0.008
length(all_flows)
#> [1] 8
all_flows[[2]]
#> Spatial interaction model with 10 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.5 and inverse cost scale (beta) =
#> 0.002
#> ℹ The BLV model converged after 3200 iterations.
```
