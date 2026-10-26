# Return the iteration histories of a collection of spatial interaction models

The function gathers the iteration histories (see
[`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md))
of the spatial interaction models of its `sim_list` parameter in a
single data frame. The first column, `sim`, gives the index of the model
in the `sim_list`, while the other columns are those described in
[`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md).
Models without history do not contribute any row.

## Usage

``` r
grid_sim_history(sim, ...)
```

## Arguments

- sim:

  a collection of spatial interaction models, an object of class
  `sim_list`

- ...:

  additional parameters

## Value

a data frame describing the iterations of the algorithms, or `NULL` if
no model has a recorded history.

## Details

Note that
[`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md)
is generic and can be applied directly to `sim_list` objects. The
current function is provided to be explicit in R code about what is a
single model and what is a collection of models (using function names
that start with `"grid_"`).

## See also

[`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md),
[`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md),
[`grid_sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/grid_sim_converged.md)
and
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)

## Examples

``` r
distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
production <- log(french_cities$population[1:15])
attractiveness <- log(french_cities$area[1:15])
all_flows <- grid_blvim(
  distances, production, c(1.1, 1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness,
  bipartite = FALSE,
  algorithm = "gradient",
  control = blvim_gradient_control(history = TRUE)
)
histories <- grid_sim_history(all_flows)
head(histories)
#>   sim iteration      gap potential step step_norm line_search_reductions
#> 1   1         0 28.11114  596.5415  0.5 0.9636615                      0
#> 2   1         1  0.00000  641.8845  0.0 0.0000000                      0
#> 3   2         0 29.32113  560.3039  0.5 0.9636615                      0
#> 4   2         1  0.00000  662.1504  0.0 0.0000000                      0
#> 5   3         0 31.33944  516.0221  0.5 0.9636615                      0
#> 6   3         1  0.00000  686.9198  0.0 0.0000000                      0
#>   n_active      min_U
#> 1       15 0.06324113
#> 2        1 0.00000000
#> 3       15 0.06324113
#> 4        1 0.00000000
#> 5       15 0.06324113
#> 6        1 0.00000000
table(histories$sim) ## number of iterations per model
#> 
#>   1   2   3   4   5   6   7   8   9  10  11  12 
#>   2   2   2  11   2   2   7  12   2 113   9  16 
```
