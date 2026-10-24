# Report whether the construction of a spatial interaction model converged

Some spatial interaction models are the result of an iterative
calculation, see for instance
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).
This calculation may have been interrupted before convergence. This
function returns `TRUE` if the calculation converged, `FALSE` if this
was not the case and `NA` if the spatial interaction model is not the
result of an iterative calculation. The function applies also to a
collection of spatial interaction models as represented by a `sim_list`.

## Usage

``` r
sim_converged(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`) or a
  collection of spatial interaction models (an object of class
  `sim_list`)

- ...:

  additional parameters

## Value

`TRUE`, `FALSE` or `NA`, as described above. In the case of a `sim_list`
the function returns a logical vector with one value per model.

## See also

[`sim_iterations()`](https://fabrice-rossi.github.io/blvim/reference/sim_iterations.md),
[`sim_diagnostic()`](https://fabrice-rossi.github.io/blvim/reference/sim_diagnostic.md),
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
[`grid_sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/grid_sim_converged.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_converged(model) ## must be NA
#> [1] NA
dyn_model <- blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_converged(dyn_model)
#> [1] TRUE
```
