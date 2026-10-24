# Return the number of iterations used to produce a spatial interaction model

Return the number of iterations used to produce a spatial interaction
model

## Usage

``` r
sim_iterations(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`) or a
  collection of spatial interaction models (an object of class
  `sim_list`)

- ...:

  additional parameters

## Value

the number of iterations, which is one for a static model (see
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md)).
In the case of a `sim_list` the function returns a vector with one
number of iterations per model.

## See also

[`sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/sim_converged.md),
[`sim_diagnostic()`](https://fabrice-rossi.github.io/blvim/reference/sim_diagnostic.md),
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
[`grid_sim_iterations()`](https://fabrice-rossi.github.io/blvim/reference/grid_sim_iterations.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_iterations(model) ## must be one
#> [1] 1
dyn_model <- blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_iterations(dyn_model)
#> [1] 3600
```
