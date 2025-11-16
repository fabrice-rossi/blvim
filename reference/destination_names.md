# Names of destination locations in a spatial interaction model

Functions to get or set the names of the destination locations in a
spatial interaction model (or in a collection of spatial interaction
models).

## Usage

``` r
destination_names(sim)

destination_names(sim) <- value
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`) or a
  collection of spatial interaction models (an object of class
  `sim_list`)

- value:

  a character vector of length equal to the number of destination
  locations, or `NULL` (vectors of adapted length are converted to
  character vectors)

## Value

for `destination_names` `NULL` or a character vector with one name per
destination locations in the model. for `destination_names<-` the
modified `sim` object or `sim_list` object.

## See also

[`location_names()`](https://fabrice-rossi.github.io/blvim/reference/location_names.md),
[`origin_names()`](https://fabrice-rossi.github.io/blvim/reference/origin_names.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10]
production <- rep(1, 10)
attractiveness <- rep(1, 10)
## the row/column names of the cost matrix are used for the location
model <- static_blvim(distances, production, 1.5, 1 / 250000, attractiveness)
destination_names(model)
#>  [1] "75056" "13055" "69123" "31555" "06088" "44109" "34172" "67482" "33063"
#> [10] "59350"
destination_names(model) <- french_cities$name[1:10]
destination_names(model)
#>  [1] "Paris"       "Marseille"   "Lyon"        "Toulouse"    "Nice"       
#>  [6] "Nantes"      "Montpellier" "Strasbourg"  "Bordeaux"    "Lille"      
```
