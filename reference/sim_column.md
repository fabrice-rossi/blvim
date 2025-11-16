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
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.2),
  seq(1, 3, by = 0.5) / 400,
  attractiveness,
  bipartite = FALSE,
  epsilon = 0.1, iter_max = 1000,
)
all_flows_df <- sim_df(all_flows, sim_colum = "my_col")
names(all_flows_df)
#> [1] "alpha"      "beta"       "diversity"  "iterations" "converged" 
#> [6] "my_col"    
sim_column(all_flows_df)
#> Collection of 15 spatial interaction models with 10 origin locations and 10
#> destination locations computed on the following grid:
#> • alpha: 1.05, 1.25, and 1.45
#> • beta: 0.0025, 0.00375, 0.005, 0.00625, and 0.0075
```
