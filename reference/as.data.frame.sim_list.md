# Coerce to a Data Frame

This function creates a data frame with a single column storing its
collection of spatial interaction models. The default name of the column
is `"sim"` (can be modified using the `sim_column` parameter). An more
flexible alternative is provided by the
[`sim_df()`](https://fabrice-rossi.github.io/blvim/reference/sim_df.md)
function.

## Usage

``` r
# S3 method for class 'sim_list'
as.data.frame(x, ..., sim_column = "sim")
```

## Arguments

- x:

  a collection of spatial interaction models, an object of class
  `sim_list`

- ...:

  additional parameters (not used currently)

- sim_column:

  the name of the `sim_list` column (default `"sim"`)

## Value

a data frame

## See also

[`sim_df()`](https://fabrice-rossi.github.io/blvim/reference/sim_df.md)

## Examples

``` r
distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
production <- log(french_cities$population[1:15])
attractiveness <- log(french_cities$area[1:15])
all_flows_log <- grid_blvim(
  distances, production, c(1.1, 1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness,
  epsilon = 0.1,
  bipartite = FALSE,
  iter_max = 750
)
as.data.frame(all_flows_log, sim_column = "log flows")
#>       log flows
#> 1  c(13.254....
#> 2  c(14.563....
#> 3  c(14.563....
#> 4  c(14.111....
#> 5  c(14.154....
#> 6  c(14.248....
#> 7  c(13.738....
#> 8  c(14.428....
#> 9  c(14.471....
#> 10 c(13.755....
#> 11 c(14.203....
#> 12 c(14.529....
```
