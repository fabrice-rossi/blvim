# Returns the conversion factors between attractivenesses and incoming flows

Some spatial interaction models use conversion factors between
attractivenesses and incoming flows to check whether they are at
equilibrium (see for instance
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)).
This function returns the conversion factors used to build this sim is
applicable, and `NA` when not applicable.

## Usage

``` r
sim_conversion(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`)

- ...:

  additional parameters

## Value

NA or a vector of conversion factors, see above.

## See also

[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_conversion(model) ## must NA
#> [1] NA
```
