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
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
destination_positions(model) <- positions
destination_positions(model)
#>             [,1]        [,2]
#>  [1,] -1.0985089  0.55851442
#>  [2,] -0.6331782  0.41540640
#>  [3,] -2.0636545 -1.45229977
#>  [4,]  2.6489320  0.94120612
#>  [5,] -1.1533984 -0.33893587
#>  [6,] -0.3406379 -0.07557425
#>  [7,]  0.7863626  0.04020439
#>  [8,] -1.2705131  0.12430107
#>  [9,]  0.5421415 -0.99843255
#> [10,]  0.0751059  1.23339006
```
