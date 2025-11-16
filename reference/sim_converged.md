# Reports whether the spatial interaction model construction converged

Some spatial interaction models are the result of an iterative
calculation, see for instance
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).
This calculation may have been interrupted before convergence. The
present function returns `TRUE` if the calculation converged, `FALSE` if
this was not the case and `NA` if the spatial interaction model is not
the result of an iterative calculation. The function applies also to a
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
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
destination_flow(model)
#>     75056     13055     69123     31555     06088     44109     34172     67482 
#> 16.732020 19.146917 11.465220 14.885136 11.003105 11.776545 12.625408 11.752380 
#>     33063     59350 
#> 10.985307  9.743067 
sim_converged(model) ## must be NA
#> [1] NA
```
