# Extract spatial interaction models produced by individual runs

Extracts the spatial interaction model objects produced by the
individual algorithm runs performed by
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).

## Usage

``` r
sim_runs(sim)
```

## Arguments

- sim:

  A spatial interaction model object produced by
  [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
  i.e. an object of class `sim` and `sim_blvim`

## Value

A `sim_list` containing the available spatial interaction models
produced by the algorithm runs.

For a single run, a one-element `sim_list` containing `sim` is returned.
For multiple runs retained with `keep_runs = TRUE`, the models are
returned in the same order as the starting points supplied to
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).

The function returns `NULL` when multiple runs were performed with
`keep_runs = FALSE`, because only the model associated with the largest
final potential was retained.

## Details

See
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
for details on how the `Z` and `keep_runs` arguments determine the
number of runs and whether the resulting spatial interaction models are
retained.

Use
[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md)
to extract the summary information recorded for multiple runs.

## See also

[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
for computing equilibrium spatial interaction models,
[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md)
for summaries of the individual runs, and
[`sim_list()`](https://fabrice-rossi.github.io/blvim/reference/sim_list.md)
for collections of spatial interaction models.

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
attractiveness <- attractiveness / sum(attractiveness) * sum(production)

# A single run produces a one-element sim_list
single <- blvim(
  distances,
  production,
  1.5,
  1 / 250,
  attractiveness,
  algorithm = "gradient"
)
length(sim_runs(single))
#> [1] 1

# Multiple runs, with all spatial interaction models retained
starts <- rbind(
  attractiveness,
  rev(attractiveness)
)

multiple <- blvim(
  distances,
  production,
  1.5,
  1 / 250,
  starts,
  algorithm = "gradient",
  keep_runs = TRUE
)

runs <- sim_runs(multiple)
length(runs)
#> [1] 2
```
