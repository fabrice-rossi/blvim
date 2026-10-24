# Extract the initial attractivenesses from a spatial interaction model object

Extracts the destination attractivenesses used to initialise the
construction of a spatial interaction model. For static models, this is
identical to their
[`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md).
For a spatial interaction model produced by an iterative algorithm, this
function returns the attractivenesses used to initialise the algorithm.
[`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)
returns the final attractivenesses.

## Usage

``` r
initial_attractiveness(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object

- ...:

  additional parameters

## Value

a vector containing the initial destination attractivenesses

## See also

[`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md),
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md),
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
initial_attractiveness(model)
#>    75056    13055    69123    31555    06088    44109    34172    67482 
#> 4.657386 5.471989 3.870665 4.771153 4.301425 4.185492 4.044746 4.359355 
#>    33063    59350 
#> 3.907493 3.548148 
identical(
  initial_attractiveness(model),
  attractiveness(model)
)
#> [1] TRUE
```
