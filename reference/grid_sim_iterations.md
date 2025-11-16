# Returns the number of iterations used to produce of a collection of spatial interaction models

The function reports for each spatial interaction model of its
`sim_list` parameter the number of iterations used to produce it (see
[`sim_iterations()`](https://fabrice-rossi.github.io/blvim/reference/sim_iterations.md))

## Usage

``` r
grid_sim_iterations(sim, ...)
```

## Arguments

- sim:

  a collection of spatial interaction models, an object of class
  `sim_list`

- ...:

  additional parameters

## Value

a vector of numbers of iteration, one per spatial interaction model

## Details

Notice that
[`sim_iterations()`](https://fabrice-rossi.github.io/blvim/reference/sim_iterations.md)
is generic and can be applied directly to `sim_list` objects. The
current function is provided to be explicit in R code about what is a
unique model and what is a collection of models (using function names
that start with `"grid_"`)

## See also

[`sim_iterations()`](https://fabrice-rossi.github.io/blvim/reference/sim_iterations.md),
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
grid_sim_iterations(all_flows)
#>  [1] 751 400 300 600 300 400 751 600 300 751 600 751
```
