# Extract all the attractivenesses from a collection of spatial interaction models

The function extract attractivenesses from all the spatial interaction
models of the collection and returns them in a matrix in which each row
corresponds to a model and each column to a destination location.

## Usage

``` r
grid_attractiveness(sim_list, ...)
```

## Arguments

- sim_list:

  a collection of spatial interaction models, an object of class
  `sim_list`

- ...:

  additional parameters for the
  [`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)
  function

## Value

a matrix of attractivenesses at the destination locations

## See also

[`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)
and
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)

## Examples

``` r
positions <- matrix(rnorm(15 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 15)
attractiveness <- rep(1, 15)
all_flows <- grid_blvim(distances,
  production,
  c(1.1, 1.25, 1.5),
  c(1, 2, 3),
  attractiveness,
  epsilon = 0.1
)
g_Z <- grid_attractiveness(all_flows)
## should be 9 rows (3 times 3 parameter pairs) and 15 columns (15 destination
## locations)
dim(g_Z)
#> [1]  9 15
```
