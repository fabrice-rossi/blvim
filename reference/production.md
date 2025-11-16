# Extract the production constraints from a spatial interaction model object

Extract the production constraints from a spatial interaction model
object

## Usage

``` r
production(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object

- ...:

  additional parameters

## Value

a vector of production constraints at the origin locations

## See also

[`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md),
[`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
production(model)
#>    75056    13055    69123    31555    06088    44109    34172    67482 
#> 14.56395 13.68451 13.16307 13.14546 12.77621 12.69180 12.63493 12.58351 
#>    33063    59350 
#> 12.48872 12.38294 
## the names of the production vector are set from the distance matrix
## we remove them for testing equality
all.equal(as.numeric(production(model)), production)
#> [1] TRUE
```
