# Extract all the destination flows from a collection of spatial interaction models

The function extract destination flows from all the spatial interaction
models of the collection and returns them in a matrix in which each row
corresponds to a model and each column to a destination location.

## Usage

``` r
grid_destination_flow(sim_list, ...)
```

## Arguments

- sim_list:

  a collection of spatial interaction models, an object of class
  `sim_list`

- ...:

  additional parameters for the
  [`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)
  function

## Value

a matrix of destination flows at the destination locations

## See also

[`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)
and
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
all_flows <- grid_blvim(
  distances, production, c(1.1, 1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness,
  epsilon = 0.1
)
g_df <- grid_destination_flow(all_flows)
## should be 12 rows (3 times 4 parameter pairs) and 10 columns (10
## destination locations)
dim(g_df)
#> [1] 12 10
```
