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
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
all_flows <- grid_blvim(
  distances, production, c(1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness
)
## should be TRUE
identical(distances, costs(all_flows))
#> [1] TRUE
```
