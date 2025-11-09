# Names of origin locations in a spatial interaction model

Functions to get or set the names of the origin locations in a spatial
interaction model (or in a collection of spatial interaction models).

## Usage

``` r
origin_names(sim)

origin_names(sim) <- value
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`) or a
  collection of spatial interaction models (an object of class
  `sim_list`)

- value:

  a character vector of length equal to the number of origin locations,
  or `NULL` (vectors of adapted length are converted to character
  vectors)

## Value

for `origin_names` `NULL` or a character vector with one name per origin
locations in the model. for `origin_names<-` the modified `sim` object
or `sim_list` object.

## See also

[`location_names()`](https://fabrice-rossi.github.io/blvim/reference/location_names.md),
[`destination_names()`](https://fabrice-rossi.github.io/blvim/reference/destination_names.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
rownames(positions) <- LETTERS[1:10]
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- rep(1, 10)
## the row/column names of the cost matrix are used for the location
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
origin_names(model)
#>  [1] "A" "B" "C" "D" "E" "F" "G" "H" "I" "J"
origin_names(model) <- letters[11:20]
origin_names(model)
#>  [1] "k" "l" "m" "n" "o" "p" "q" "r" "s" "t"
```
