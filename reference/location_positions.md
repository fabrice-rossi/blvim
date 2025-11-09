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
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
## No positions
location_positions(model) <- list(origin = positions, destination = positions)
destination_positions(model)
#>              [,1]       [,2]
#>  [1,]  0.88862899  0.1046622
#>  [2,]  0.01321448  0.7201865
#>  [3,]  0.22533951 -0.6110461
#>  [4,] -0.72991521 -1.1069141
#>  [5,] -1.22248707  0.5348033
#>  [6,]  0.40680517  0.7360680
#>  [7,] -0.75101222 -1.2225016
#>  [8,] -0.16211654  1.0214153
#>  [9,]  0.35201013  0.4651652
#> [10,] -0.28905830  0.7904727
origin_positions(model)
#>              [,1]       [,2]
#>  [1,]  0.88862899  0.1046622
#>  [2,]  0.01321448  0.7201865
#>  [3,]  0.22533951 -0.6110461
#>  [4,] -0.72991521 -1.1069141
#>  [5,] -1.22248707  0.5348033
#>  [6,]  0.40680517  0.7360680
#>  [7,] -0.75101222 -1.2225016
#>  [8,] -0.16211654  1.0214153
#>  [9,]  0.35201013  0.4651652
#> [10,] -0.28905830  0.7904727
```
