# Compute an equilibrium solution of the Harris and Wilson model

This function computes flows between origin locations and destination
locations at an equilibrium solution of Harris and Wilson interaction
model. The model is initialised with the production constraints at the
origin locations and the initial values of the the attractivenesses of
destination locations. At convergence, attractivenesses fulfil the
balance equations \$\$\forall j,\quad \kappa_j
Z_j=\sum\_{i=1}^{n}Y\_{ij},\$\$ where the flows are computed according
to Wilson's production constrained entropy maximising model
([`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md)).
The function implements several algorithms that all aim to reach an
equilibrium.

## Usage

``` r
blvim(
  costs,
  X,
  alpha,
  beta,
  Z,
  kappa = 1,
  bipartite = TRUE,
  origin_data = NULL,
  destination_data = NULL,
  epsilon = 0.01,
  iter_max = 50000,
  conv_check = 100,
  precision = 1e-06,
  algorithm = c("linear", "quadratic", "gradient", "gradient_unit"),
  control = blvim_gradient_control()
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

  A vector of initial destination attractivenesses.

- kappa:

  A vector of conversion factors between attractivenesses and incoming
  flows. Values must be positive. Defaults to 1 for all destinations.

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

  Update intensity used by the `"linear"` and `"quadratic"` algorithms.

- iter_max:

  Maximum number of iterations.

- conv_check:

  Number of iterations between convergence checks for the `"linear"` and
  `"quadratic"` algorithms.

- precision:

  Convergence threshold.

- algorithm:

  Character string selecting the algorithm used to compute the
  equilibrium. One of `"linear"`, `"quadratic"`, `"gradient"` or
  `"gradient_unit"`. Defaults to `"linear"`. Partial matching is
  supported.

- control:

  List of internal parameters for the gradient algorithms as produced by
  [`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md).

## Value

an object of class `sim`(and `sim_blvim`) for spatial interaction model
that contains the matrix of flows between the origin and the destination
locations as well as the final attractivenesses computed by the model.

## Details

All algorithms are initialised with user supplied attractivenesses and
proceed iteratively by updating them until convergence. Two algorithms
are instances of A. Wilson's Boltzmann-Lotka-Volterra (BLV) interaction
model, while the other two algorithms are based on gradient ascent.

### Boltzmann-Lotka-Volterra (BLV) iterations

In a step of the BLV model, flows are computed according to the
production constrained entropy maximising model proposed by A. Wilson
and implemented in
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md).
Then the flows received at a destination are computed as follows

\$\$\forall j,\quad D_j=\sum\_{i=1}^{n}Y\_{ij},\$\$

for destination \\j\\. This enables the attractivenesses to be updated
by making them closer to the received flows, i.e. by trying to reduce
\\\|D_j-\kappa_j Z_j\|\\, where \\\kappa_j\\ is a conversion factor
between the attractiveness and the destination flow.

Two algorithms of this family are available through the `algorithm`
parameter:

1.  `"linear"` uses the original update rule proposed in Harris & Wilson
    (1978):

    \$\$ Z_j^{t+1} = Z_j^t + \epsilon \left( \frac{D_j^t}{\kappa_j} -
    Z_j^t \right). \$\$

2.  `"quadratic"` uses the update rule proposed in Wilson (2008):

    \$\$ Z_j^{t+1} = Z_j^t + \epsilon \left( \frac{D_j^t}{\kappa_j} -
    Z_j^t \right) Z_j^t. \$\$

For these algorithms(`"linear"` and `"quadratic"`), \\\epsilon\\ is
given by the `epsilon` parameter and should generally be smaller than 1.

Updates are performed until convergence or for a maximum of `iter_max`
iterations. Convergence is checked every `conv_check` iterations. The
algorithm is considered to have converged if

\$\$ \\Z^{t+1}-Z^t\\ \< \delta \left(\\Z^{t+1}\\+\delta\right), \$\$

where \\\delta\\ is given by the `precision` parameter.

### Gradient algorithms

Finding an equilibrium with the BLV approach is equivalent to looking
for a maximum of the potential function (see
[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md)).
The gradient algorithms use a direct approach of optimising the
potential via a projected gradient ascent. The `"gradient"` algorithm
optimises directly the potential while `"gradient_unit"` rescales the
problem in order to work with \\U_j\\ instead of \\Z_j\\ in such a way
that \\\sum\_{j=1}^p U_j=1\\. This can accelerate convergence in some
settings. Results should be identical from both gradient approaches, but
they can be different from solutions obtained by the `"linear"` and
`"quadratic"` algorithms.

The `epsilon` and `conv_check` parameters are not used by the
`"gradient"` algorithm. Convergence is assessed using the duality gap
and the `precision` parameter. The gradient ascent runs for a maximum of
`iter_max` iterations. Both algorithms use a standard backtracking line
search with Armijo stopping criterion. Its parameters can be modified
using the `control` parameter and the associated
[`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md)
function.

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
Soc. Interface.5865-871
[doi:10.1098/rsif.2007.1288](https://doi.org/10.1098/rsif.2007.1288)

## See also

[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)
for systematic exploration of parameter influence,
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md)
for the static model,
[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md)
for the potential function.

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])

# Rescale attractivenesses to total production
attractiveness <- attractiveness / sum(attractiveness) * sum(production)

# Original Harris-Wilson update rule
flows <- blvim(
  distances,
  production,
  1.5,
  1 / 250,
  attractiveness,
  algorithm = "linear"
)
flows
#> Spatial interaction model with 10 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.5 and inverse cost scale (beta) =
#> 0.004
#> ℹ The BLV model converged after 3500 iterations.

# Wilson's quadratic update rule
quadratic_flows <- blvim(
  distances,
  production,
  1.5,
  1 / 250,
  attractiveness,
  algorithm = "quadratic"
)

# Gradient-based algorithm
gradient_flows <- blvim(
  distances,
  production,
  1.5,
  1 / 250,
  attractiveness,
  algorithm = "gradient"
)
```
