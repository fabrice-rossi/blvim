# Extract the attractivenesses from a spatial interaction model object

Extract the attractivenesses from a spatial interaction model object

## Usage

``` r
attractiveness(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object

- ...:

  additional parameters

## Value

a vector of attractivenesses at the destination locations

## See also

[`production()`](https://fabrice-rossi.github.io/blvim/reference/production.md),
[`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
attractiveness(model)
#>    75056    13055    69123    31555    06088    44109    34172    67482 
#> 4.657386 5.471989 3.870665 4.771153 4.301425 4.185492 4.044746 4.359355 
#>    33063    59350 
#> 3.907493 3.548148 
## the names of the attractiveness vector are set from the distance matrix
## we remove them for testing equality
all.equal(as.numeric(attractiveness(model)), attractiveness)
#> [1] TRUE
```
