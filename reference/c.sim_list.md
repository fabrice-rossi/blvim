# Combine multiple sim_list objects into a single one

This function combines the `sim_list` and `sim` objects use as arguments
in a single `sim_list`, provided they are compatible. Compatibility is
defined as in
[`sim_list()`](https://fabrice-rossi.github.io/blvim/reference/sim_list.md):
all spatial interaction models must share the same costs as well as the
same origin and destination data.

## Usage

``` r
# S3 method for class 'sim_list'
c(...)
```

## Arguments

- ...:

  `sim_list` and `sim` to be concatenated.

## Value

A combined object of class `sim_list`.

## Examples

``` r
distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
production <- log(french_cities$population[1:15])
attractiveness <- log(french_cities$area[1:15])
all_flows_log <- grid_blvim(
  distances, production, c(1.1, 1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness,
  epsilon = 0.1,
  bipartite = FALSE,
  iter_max = 750
)
production <- rep(1, 15)
attractiveness <- rep(1, 15)
all_flows_unit <- grid_blvim(
  distances, production, c(1.1, 1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness,
  epsilon = 0.1,
  bipartite = FALSE,
  iter_max = 750
)
all_flows <- c(all_flows_log, all_flows_unit)
```
