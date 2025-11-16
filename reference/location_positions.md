# Positions of origin and destination locations in a spatial interaction model

These functions provide low level access to origin and destination local
positions. It is recommended to use
[`origin_positions()`](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md)
and
[`destination_positions()`](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md)
instead of `location_positions` and `location_positions<-`.

## Usage

``` r
location_positions(sim)

location_positions(sim) <- value
```

## Arguments

- sim:

  a spatial interaction model object

- value:

  a list with two components (see the returned value) or `NULL`

## Value

for `location_positions` `NULL` or a list with two components: `origin`
for the origin location positions and `destination` for the destination
location positions. For `location_positions<-()` the modified `sim`
object.

## Positions

Location positions are given by numeric matrices with 2 or 3 columns.
The first two columns are assumed to be geographical coordinates while
the 3rd column can be used for instance to store altitude. Coordinates
are interpreted as is in graphical representations (see
[`autoplot.sim()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim.md)).
They are not matched to the costs as those can be derived from complex
movement models and other non purely geographic considerations.

## See also

[`origin_positions()`](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md),
[`destination_positions()`](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md)

## Examples

``` r
positions <- as.matrix(french_cities[1:10, c("th_longitude", "th_latitude")])
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
## No positions
location_positions(model) <- list(
  origin = positions,
  destination = positions
)
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
origin_positions(model)
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
