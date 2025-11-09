# Get the collection of spatial interaction models from a sim data frame

Get the collection of spatial interaction models from a sim data frame

## Usage

``` r
sim_column(sim_df)
```

## Arguments

- sim_df:

  a data frame of spatial interaction models, an object of class
  `sim_df`

## Value

the collection of spatial interaction models in the `sim_df` object, as
a `sim_list` object

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
all_flows <- grid_blvim(distances, production, c(1.25, 1.5), c(1, 2, 3), attractiveness)
all_flows_df <- sim_df(all_flows)
sim_column(all_flows_df)
#> Collection of 6 spatial interaction models with 10 origin locations and 10
#> destination locations computed on the following grid:
#> • alpha: 1.25 and 1.5
#> • beta: 1, 2, and 3
```
