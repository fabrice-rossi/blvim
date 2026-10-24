# Compute the potentials of a collection of spatial interaction models

The function reports the potential of each spatial interaction model of
its `sim_list` parameter (see
[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md)).

## Usage

``` r
grid_sim_potential(sim, ...)
```

## Arguments

- sim:

  a collection of spatial interaction models, an object of class
  `sim_list`

- ...:

  additional parameters

## Value

a numeric vector of potentials, one per spatial interaction model (`NA`
for models without a potential)

## Details

Note that
[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md)
is generic and can be applied directly to `sim_list` objects. The
current function is provided to be explicit in R code about what is a
single model and what is a collection of models (using function names
that start with `"grid_"`).

## See also

[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md),
[`grid_sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/grid_sim_converged.md)
and
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)

## Examples

``` r
distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
production <- log(french_cities$population[1:15])
attractiveness <- log(french_cities$area[1:15])
all_flows <- grid_blvim(
  distances, production, c(1.1, 1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness,
  epsilon = 0.1,
  bipartite = FALSE,
  iter_max = 750
)
grid_sim_potential(all_flows)
#>  [1] 647.6623 662.1504 686.9198 533.1884 550.9465 572.8724 447.2027 464.6454
#>  [9] 499.9672 395.3647 405.9855 432.1033
```
