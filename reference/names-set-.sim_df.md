# Set the column names of a SIM data frame

Set the column names of a SIM data frame. Renaming the `sim_list` column
is supported and tracked, but renaming any core column turns the
`sim_df` into a standard `data.frame`.

## Usage

``` r
# S3 method for class 'sim_df'
names(x) <- value
```

## Arguments

- x:

  data frame of spatial interaction models, an object of class `sim_df`

- value:

  unique names for the columns of the data frame

## Value

a `sim_df` data frame if possible, a standard `data.frame` when this is
not possible.

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
all_flows_df <- sim_df(all_flows)
names(all_flows_df)
#> [1] "alpha"      "beta"       "diversity"  "iterations" "converged" 
#> [6] "sim"       
names(all_flows_df)[6] <- "my_sim"
names(all_flows_df)
#> [1] "alpha"      "beta"       "diversity"  "iterations" "converged" 
#> [6] "my_sim"    
## still a sim_df
class(all_flows_df)
#> [1] "sim_df"     "data.frame"
names(all_flows_df)[1] <- "return to scale"
names(all_flows_df)
#> [1] "return to scale" "beta"            "diversity"       "iterations"     
#> [5] "converged"       "my_sim"         
## not a sim_df
class(all_flows_df)
#> [1] "data.frame"
```
