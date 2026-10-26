# Compute an equilibrium solution of the Harris and Wilson model

`blvim()` computes equilibrium flows between origin and destination
locations in the Harris and Wilson spatial interaction model. At
equilibrium, destination attractivenesses satisfy \$\$ \forall j,\quad
\kappa_j Z_j = \sum\_{i=1}^{n} Y\_{ij}, \$\$ where \\Y\_{ij}\\ is the
flow from origin \\i\\ to destination \\j\\, \\Z_j\\ is the
attractiveness of destination \\j\\, and \\\kappa_j\\ converts
attractiveness into incoming flow. Flows are computed using the
production-constrained entropy-maximising model implemented by
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md).

## Usage

``` r
blvim(
  costs,
  X,
  alpha,
  beta,
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
  keep_runs = FALSE
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

- keep_runs:

  A logical scalar controlling whether complete fitted models are
  retained when multiple starting points are used. If `FALSE`, only the
  selected model and the run summaries are retained. If `TRUE`, all
  fitted models are stored in a `sim_list`. This argument has no effect
  for a single starting point.

## Value

An object inheriting from `sim` and `sim_blvim`. It contains the
equilibrium flow matrix, final destination attractivenesses, initial
attractivenesses of the selected run, and convergence information.

When multiple starting points are used, the returned object represents
the run with the largest final potential. Run summaries are available
through
[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md)
and contain:

- `run`: index of the starting point;

- `potential`: final potential;

- `iterations`: number of reported iterations;

- `converged`: whether the run stopped before `iter_max`;

- `status`: stopping status for a gradient algorithm;

- `gap`: final duality gap for a gradient algorithm;

- `evaluations`: number of evaluations for a gradient algorithm;

- `n_active`: number of active destinations of the final configuration;

- `configuration`: identifier of the final configuration, shared by the
  runs that reach the same configuration and numbered by decreasing
  potential;

- `selected`: whether the run is the returned one.

The `status`, `gap` and `evaluations` columns are `NA` for `"linear"`
and `"quadratic"`. If `keep_runs = TRUE`, the complete fitted models are
additionally available through
[`sim_runs()`](https://fabrice-rossi.github.io/blvim/reference/sim_runs.md),
in the same order as the starting points.

When the `history` parameter of
[`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md)
is `TRUE`, the iteration history of the gradient algorithms is available
through
[`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md)
for the returned model and, if `keep_runs = TRUE`, for each model
returned by
[`sim_runs()`](https://fabrice-rossi.github.io/blvim/reference/sim_runs.md).
It is not kept for the other runs.

## Details

Several iterative algorithms are available. The model can be run from a
single initial attractiveness vector or from several starting points. In
the latter case, the solution with the largest final potential is
returned (see
[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md)).

### Initialisation and multiple runs

Initial destination attractivenesses are specified through `Z`:

- If `Z` is `NULL`, one starting point is constructed automatically.

- If `Z` is a numeric vector, the algorithm is run once from that
  vector.

- If `Z` is a numeric matrix, each row is used as an independent
  starting point.

- If `Z` is an object created by
  [`blvim_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_initialise.md),
  its initialiser is evaluated using the model context. The resulting
  vector or matrix is then handled in the same way as an explicitly
  supplied `Z`.

In the bipartite case, automatic initialisation uses the centre of mass
of the weighted simplex:

\$\$ Z_j^0 = \frac{\sum_i X_i}{p\kappa_j}, \$\$

where \\p\\ is the number of destinations. In the non-bipartite case, it
uses

\$\$ Z_j^0 = \frac{X_j}{\kappa_j}. \$\$

Automatic initialisation therefore produces a single run. Use a matrix
or
[`blvim_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_initialise.md)
to perform multiple runs.

For multiple runs, all starting points use the same model parameters,
algorithm, convergence settings, and algorithm-specific controls. The
final potential is evaluated for each run, and the run with the strictly
largest potential is selected (see
[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md)).
If several runs have the same largest potential, the first is selected.

Summaries of all runs are stored in the returned model and can be
obtained with
[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md).
If `keep_runs = TRUE`, the complete fitted models are retained and can
be obtained with
[`sim_runs()`](https://fabrice-rossi.github.io/blvim/reference/sim_runs.md).

### Boltzmann-Lotka-Volterra algorithms

At each iteration of a Boltzmann-Lotka-Volterra (BLV) algorithm, flows
are computed with
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md).
The total flow received by destination \\j\\ is

\$\$ D_j = \sum\_{i=1}^{n} Y\_{ij}. \$\$

Attractivenesses are then updated to bring \\\kappa_j Z_j\\ closer to
\\D_j\\. Two BLV algorithms are available:

1.  `"linear"` uses the original update rule proposed by Harris and
    Wilson (1978):

    \$\$ Z_j^{t+1} = Z_j^t + \epsilon \left( \frac{D_j^t}{\kappa_j} -
    Z_j^t \right). \$\$

2.  `"quadratic"` uses the update rule proposed by Wilson (2008):

    \$\$ Z_j^{t+1} = Z_j^t + \epsilon \left( \frac{D_j^t}{\kappa_j} -
    Z_j^t \right) Z_j^t. \$\$

For both algorithms, \\\epsilon\\ is specified by `epsilon` and should
generally be smaller than one. Convergence is checked every `conv_check`
iterations and is attained when

\$\$ \lVert Z^{t+1} - Z^t \rVert \< \delta \left( \lVert Z^{t+1}
\rVert + \delta \right), \$\$

where \\\delta\\ is specified by `precision`. Iteration stops at
convergence or after `iter_max` iterations.

### Gradient algorithms

Computing an equilibrium is equivalent to maximising the potential
function; see
[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md).
The gradient algorithms optimise this potential directly using projected
gradient ascent.

Both algorithms work with rescaled variables \\U_j = \kappa_j Z_j /
\sum\_{i=1}^{n} X_i\\ satisfying

\$\$ \sum\_{j=1}^{p} U_j = 1, \$\$

and differ only by the geometry used for the gradient steps. The
`"gradient_unit"` algorithm uses the Euclidean geometry of the \\U_j\\.
The `"gradient"` algorithm uses the Euclidean geometry of the
attractivenesses \\Z_j\\, which amounts to preconditioning the gradient
in \\U_j\\ by \\\kappa_j^2\\. The preconditioner is rescaled to a unit
mean so that `rho_init` (see
[`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md))
has a similar meaning for both algorithms. When all the \\\kappa_j\\ are
equal, the two algorithms are identical (up to rounding errors).
Otherwise, as the potential is not concave in general, they can converge
to different local maxima from the same starting point. They can also
converge to solutions different from those obtained with the `"linear"`
and `"quadratic"` algorithms.

An arbitrary diagonal preconditioner can be specified with the
`preconditioner` parameter of
[`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md).
It multiplies the gradient with respect to the variables of the
algorithm, \\Z_j\\ for `"gradient"` and \\U_j\\ for `"gradient_unit"`.
For instance, `"gradient_unit"` with a preconditioner equal to
\\\kappa_j^2\\ is equivalent to `"gradient"` without preconditioner.

Both gradient algorithms use projected ascent with a backtracking line
search and an Armijo sufficient-increase condition. Convergence is
assessed using a duality gap with tolerance `precision`, and the number
of iterations is limited by `iter_max`. The `epsilon` and `conv_check`
arguments are not used. Line-search and other internal parameters can be
modified through `control`; see
[`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md).

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

## References

Harris, B., & Wilson, A. G. (1978). "Equilibrium Values and Dynamics of
Attractiveness Terms in Production-Constrained Spatial-Interaction
Models", Environment and Planning A: Economy and Space, 10(4), 371-388.
[doi:10.1068/a100371](https://doi.org/10.1068/a100371)

Wilson, A. (2008). "Boltzmann, Lotka and Volterra and spatial structural
evolution: an integrated methodology for some dynamical systems",
Journal of the Royal Society Interface, 5, 865-871.
[doi:10.1098/rsif.2007.1288](https://doi.org/10.1098/rsif.2007.1288)

Osawa, M., Akamatsu, T., & Kogure, Y. (2025). "Most likely retail
agglomeration patterns: Potential maximization and stochastic stability
of spatial equilibria". <https://arxiv.org/abs/2011.06778v2>

## See also

[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md)
for the underlying production-constrained interaction model,
[`blvim_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_initialise.md)
for generated starting points,
[`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md)
for gradient and line-search parameters,
[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md)
for the potential function, and
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)
for systematic exploration of parameter values. Multiple-run summaries
and fitted models can be obtained with
[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md)
and
[`sim_runs()`](https://fabrice-rossi.github.io/blvim/reference/sim_runs.md).

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])

# Rescale attractivenesses to total production
attractiveness <- attractiveness / sum(attractiveness) * sum(production)

# Original Harris-Wilson update rule
linear_flows <- blvim(
  distances, production, 1.5, 1 / 250, attractiveness,
  algorithm = "linear"
)
linear_flows
#> Spatial interaction model with 10 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.5 and inverse cost scale (beta) =
#> 0.004
#> ℹ The BLV model converged after 3500 iterations.

# Wilson's quadratic update rule
quadratic_flows <- blvim(
  distances, production, 1.5, 1 / 250, attractiveness,
  algorithm = "quadratic"
)

# Gradient ascent on the potential
gradient_flows <- blvim(
  distances, production, 1.5, 1 / 250, attractiveness,
  algorithm = "gradient"
)

# Gradient ascent using unit-simplex variables
unit_gradient_flows <- blvim(
  distances, production, 1.5, 1 / 250, attractiveness,
  algorithm = "gradient_unit"
)

# Automatic single-point initialisation
automatic_flows <- blvim(
  distances, production, 1.5, 1 / 250,
  algorithm = "gradient"
)

# Multiple explicitly supplied starting points
starts <- rbind(
  attractiveness,
  c(rep(0, 5), rep(sum(production) / 5, 5))
)
multistart_flows <- blvim(
  distances, production, 1.5, 1 / 250,
  Z = starts,
  algorithm = "gradient",
  keep_runs = TRUE
)

# Generate starting points when the model context is known
generated_flows <- blvim(
  distances, production, 1.5, 1 / 250,
  Z = blvim_initialise(n = 20, face_fraction = 0.5),
  algorithm = "gradient"
)
```
