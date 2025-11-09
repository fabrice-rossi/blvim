# Positions of origin locations in a spatial interaction model

Functions to get or set the positions of the origin locations in a
spatial interaction model.

## Usage

``` r
origin_positions(sim)

origin_positions(sim) <- value
```

## Arguments

- sim:

  a spatial interaction model object

- value:

  a matrix with as many rows as the number of origin locations and 2 or
  3 columns, or `NULL`

## Value

for `origin_positions` `NULL` or the coordinate matrix for the origin
locations. for `origin_positions<-` the modified `sim` object

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
[`destination_positions()`](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
origin_positions(model) <- positions
origin_positions(model)
#>              [,1]        [,2]
#>  [1,] -1.07806726  0.41626080
#>  [2,] -1.14356572  0.11402961
#>  [3,] -0.52964368  0.06391875
#>  [4,] -0.68127316 -0.91933224
#>  [5,] -0.20244756  0.90133529
#>  [6,]  1.68449572 -0.79772830
#>  [7,] -1.03377324  0.66822120
#>  [8,] -0.15597667  0.15521430
#>  [9,] -0.04640064  0.12868809
#> [10,] -0.95362873 -1.53306545
```
