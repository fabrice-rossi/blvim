# Generate initial attractivenesses from the weighted simplex

This is the default generator used by
[`blvim_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_initialise.md).
It samples initial attractivenesses from the weighted simplex \$\$
\sum_j \kappa_j Z_j = \sum_i X_i. \$\$

## Usage

``` r
blvim_simplex_initialise(
  context,
  n = 10L,
  face_fraction = 0.5,
  points_per_face = 0L,
  max_partial_attempts = 1000000L,
  include_centre = TRUE
)
```

## Arguments

- context:

  A model context created internally by
  [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).

- n:

  Number of initial configurations to generate. The default is
  deliberately modest because
  [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
  performs one complete optimisation from each generated configuration.

- face_fraction:

  Proportion of starting points generated on proper faces of the
  weighted simplex.

- points_per_face:

  Parameter controlling the allocation of points among simplex faces.
  See
  [`sample_weighted_simplex()`](https://fabrice-rossi.github.io/blvim/reference/sample_weighted_simplex.md).

- max_partial_attempts:

  Maximum number of proposals used when selecting distinct faces in a
  partial codimension layer. See
  [`sample_weighted_simplex()`](https://fabrice-rossi.github.io/blvim/reference/sample_weighted_simplex.md).

- include_centre:

  Whether to include the centre of the weighted simplex as the first
  starting point. If `TRUE`, `n - 1` points are sampled and the centre
  is prepended. Thus, the returned matrix always has `n` rows.

## Value

A list containing:

- `Z`: the matrix of initial attractivenesses;

- `sampling`: diagnostics returned by
  [`sample_weighted_simplex()`](https://fabrice-rossi.github.io/blvim/reference/sample_weighted_simplex.md),
  or `NULL` when no random point is requested.

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000
production <- rep(1, 10)
# Emphasise proper faces of the simplex
boundary_initialise <- blvim_initialise(
  generator = blvim_simplex_initialise,
  n = 100,
  face_fraction = 0.8,
  points_per_face = 5
)
multistart_flows <- blvim(
  distances, production, 1.5, 1 / 100,
  Z = boundary_initialise,
  algorithm = "gradient",
  keep_runs = TRUE
)
head(sim_logs(multistart_flows))
#>   run  potential iterations converged    status          gap evaluations
#> 1   1  -8.431680         40      TRUE converged 1.445288e-06          54
#> 2   2 -11.753690         53      TRUE converged 1.680213e-06          71
#> 3   3 -11.651135         16      TRUE converged 8.894206e-07          23
#> 4   4  -8.431680         27      TRUE converged 1.852890e-06          38
#> 5   5  -9.042293         38      TRUE converged 7.091518e-07          52
#> 6   6  -8.561907         46      TRUE converged 1.407509e-06          61
```
