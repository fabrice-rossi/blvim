# Names of origin and destination locations in a spatial interaction model

Those functions provide low level access to origin and destination local
names. It is recommended to use
[`origin_names()`](https://fabrice-rossi.github.io/blvim/reference/origin_names.md)
and
[`destination_names()`](https://fabrice-rossi.github.io/blvim/reference/destination_names.md)
instead of `location_names` and `location_names<-`.

## Usage

``` r
location_names(sim)

location_names(sim) <- value
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`) or a
  collection of spatial interaction models (an object of class
  `sim_list`)

- value:

  a list with two components (see the returned value) or `NULL`

## Value

for `location_names` `NULL` or a list with two components: `origin` for
the origin location names and `destination` for the destination location
names. For `location_names<-()` the modified `sim` object or `sim_list`
object.

## See also

[`origin_names()`](https://fabrice-rossi.github.io/blvim/reference/origin_names.md),
[`destination_names()`](https://fabrice-rossi.github.io/blvim/reference/destination_names.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10]
production <- rep(1, 10)
attractiveness <- rep(1, 10)
## the row/column names of the cost matrix are used for the location
model <- static_blvim(distances, production, 1.5, 1 / 250000, attractiveness)
location_names(model)
#> $origin
#>  [1] "75056" "13055" "69123" "31555" "06088" "44109" "34172" "67482" "33063"
#> [10] "59350"
#> 
#> $destination
#>  [1] "75056" "13055" "69123" "31555" "06088" "44109" "34172" "67482" "33063"
#> [10] "59350"
#> 
location_names(model) <- NULL
location_names(model)
#> $origin
#> NULL
#> 
#> $destination
#> NULL
#> 
location_names(model) <- list(
  origin = french_cities$name[1:10],
  destination = LETTERS[1:10]
)
destination_names(model)
#>  [1] "A" "B" "C" "D" "E" "F" "G" "H" "I" "J"
origin_names(model)
#>  [1] "Paris"       "Marseille"   "Lyon"        "Toulouse"    "Nice"       
#>  [6] "Nantes"      "Montpellier" "Strasbourg"  "Bordeaux"    "Lille"      
```
