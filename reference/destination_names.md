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
positions <- matrix(rnorm(10 * 2), ncol = 2)
rownames(positions) <- LETTERS[11:20]
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- rep(1, 10)
## the row/column names of the cost matrix are used for the location
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
destination_names(model)
#>  [1] "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T"
destination_names(model) <- letters[1:10]
destination_names(model)
#>  [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j"
```
