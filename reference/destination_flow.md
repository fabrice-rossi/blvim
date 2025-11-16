# Compute the flows incoming at each destination location

Compute the flows incoming at each destination location

## Usage

``` r
destination_flow(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object

- ...:

  additional parameters

## Value

a vector of flows incoming at destination locations

## See also

[`production()`](https://fabrice-rossi.github.io/blvim/reference/production.md),
[`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)

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
## should be different from the attractiveness as the model is static
attractiveness(model)
#>    75056    13055    69123    31555    06088    44109    34172    67482 
#> 4.657386 5.471989 3.870665 4.771153 4.301425 4.185492 4.044746 4.359355 
#>    33063    59350 
#> 3.907493 3.548148 
```
