# Extract the common cost matrix from a collection of spatial interaction models

Extract the common cost matrix from a collection of spatial interaction
models

## Usage

``` r
# S3 method for class 'sim_list'
costs(sim, ...)
```

## Arguments

- sim:

  a collection of spatial interaction models, an object of class
  `sim_list`

- ...:

  additional parameters

## Value

the cost matrix

## See also

[`costs()`](https://fabrice-rossi.github.io/blvim/reference/costs.md),
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
## should be TRUE
identical(distances, costs(all_flows))
#> [1] TRUE
```
