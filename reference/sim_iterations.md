# Returns the number of iterations used to produce this spatial interaction model

Returns the number of iterations used to produce this spatial
interaction model

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

a number of iterations that may be one if the spatial interaction model
has been obtained using a static model (see
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md)).
In the case of a `sim_list` the function returns a vector with iteration
number per model.

## See also

[`sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/sim_converged.md)

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
sim_iterations(model) ## must be one
#> [1] 1
```
