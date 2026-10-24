# Compute a collection of Boltzmann-Lotka-Volterra model solutions

This function computes a collection of flows between origin locations
and destination locations using
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md) on
a grid of parameters. The flows use the same costs, the same production
constraints and the same initial attractivenesses. One model is computed
for each combination of an alpha value from `alphas` and a beta value
from `betas`. The function returns an object of class `sim_list` which
contains the resulting models.

## Usage

``` r
grid_blvim(
  costs,
  X,
  alphas,
  betas,
  Z = NULL,
  kappa = 1,
  bipartite = TRUE,
  origin_data = NULL,
  destination_data = NULL,
  epsilon = 0.01,
  iter_max = 50000,
  conv_check = 100,
  precision = 1e-06,
  algorithm = c("linear", "quadratic", "gradient", "gradient_unit"),
  control = blvim_gradient_control(),
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

  a vector of inverse cost scale parameters

- Z:

  Initial destination attractivenesses. This can be `NULL` for automatic
  single-point initialisation, a numeric vector with one value per
  destination, a numeric matrix with one starting point per row, or an
  object created by
  [`blvim_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_initialise.md).
  The number of columns of a matrix must equal `ncol(costs)`.

- kappa:

  A strictly positive numeric vector of conversion factors between
  destination attractivenesses and incoming flows. A scalar is recycled
  to all destinations. The default `1` gives the standard balance
  equations without destination-specific conversion factors.

- bipartite:

  when `TRUE` (default value), the origin and destination locations are
  considered to be distinct. When `FALSE`, a single set of locations
  plays both roles. This only affects functions specific to this latter
  case, such as
  [`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md).

- origin_data:

  `NULL` or a list of additional data about the origin locations (see
  details)

- destination_data:

  `NULL` or a list of additional data about the destination locations
  (see details)

- epsilon:

  A positive numeric scalar giving the update intensity for the
  `"linear"` and `"quadratic"` algorithms. It is not used by the
  gradient algorithms.

- iter_max:

  A positive integer giving the maximum number of iterations for each
  run.

- conv_check:

  A positive integer giving the number of iterations between convergence
  checks for the `"linear"` and `"quadratic"` algorithms. It is not used
  by the gradient algorithms.

- precision:

  A positive numeric scalar giving the convergence tolerance. It is used
  in the attractiveness-based convergence test for `"linear"` and
  `"quadratic"`, and in the duality-gap stopping criterion for
  `"gradient"` and `"gradient_unit"`.

- algorithm:

  A character string selecting the equilibrium algorithm. It must be one
  of `"linear"`, `"quadratic"`, `"gradient"`, or `"gradient_unit"`.
  Partial matching is supported.

- control:

  A list of parameters for the gradient algorithms, normally produced by
  [`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md).
  It is not used by `"linear"` or `"quadratic"`.

- progress:

  if `TRUE`, a progress bar is shown during the calculation (defaults to
  `FALSE`)

## Value

an object of class `sim_list` containing one spatial interaction model
per pair of parameters

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
Names are taken by default from the names of the cost matrix `costs`.
More precisely, `rownames(costs)` is used for origin location names and
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
interpreted except for the following ones:

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

## See also

[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
for the underlying model,
[`sim_df()`](https://fabrice-rossi.github.io/blvim/reference/sim_df.md)
to turn the result into a data frame, and
[`grid_attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/grid_attractiveness.md),
[`grid_sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/grid_sim_converged.md)
or
[`grid_diversity()`](https://fabrice-rossi.github.io/blvim/reference/grid_diversity.md)
for extracting information from the collection.

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
