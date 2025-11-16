# positions of destination locations in a spatial interaction model

Functions to get or set the positions of the destination locations in a
spatial interaction model.

## Usage

``` r
destination_positions(sim)

destination_positions(sim) <- value
```

## Arguments

- sim:

  a spatial interaction model object

- value:

  a matrix with as many rows as the number of destination locations and
  2 or 3 columns, or `NULL`

## Value

for `destination_positions` `NULL` or coordinate matrix for the
destination locations. for `destination_positions<-` the modified `sim`
object

## Positions

Location positions are given by numeric matrices with 2 or 3 columns.
The first two columns are assumed to be geographical coordinates while
the 3rd column can be used for instance to store altitude. Coordinates
are interpreted as is in graphical representations (see
[`autoplot.sim()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim.md)).
They are not matched to the costs as those can be derived from complex
movement models and other non purely geographic considerations.

## See also

[`location_positions()`](https://fabrice-rossi.github.io/blvim/reference/location_positions.md),
[`origin_positions()`](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md)

## Examples

``` r
positions <- as.matrix(french_cities[1:10, c("th_longitude", "th_latitude")])
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
destination_positions(model) <- positions
destination_positions(model)
#>    th_longitude th_latitude
#> 1        2.3525     48.8564
#> 2        5.3699     43.2966
#> 3        4.8350     45.7676
#> 4        1.4442     43.6046
#> 5        7.2715     43.6960
#> 6       -1.5543     47.2184
#> 7        3.8968     43.5985
#> 8        7.7520     48.5733
#> 9       -0.5794     44.8379
#> 10       3.0713     50.6305
```
