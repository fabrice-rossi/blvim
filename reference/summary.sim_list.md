# Summary of a collection of spatial interaction models

Summary of a collection of spatial interaction models

## Usage

``` r
# S3 method for class 'sim_list'
summary(object, ...)
```

## Arguments

- object:

  a collection of spatial interaction models, an object of class
  `sim_list`

- ...:

  additional parameters (not used currently)

## Value

a list with a set of summary statistics computed on the collection of
spatial interaction models

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
  epsilon = 0.1,
  bipartite = FALSE,
)
summary(all_flows)
#> $median
#> Spatial interaction model with 15 origin locations and 15 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.25 and inverse cost scale (beta) = 2
#> ℹ The BLV model converged after 1800 iterations.
#> 
#> $distortion
#> [1] 2.0984
#> 
#> $withinss
#> [1] 94.26478
#> 
#> $nb_configurations
#> [1] 7
#> 
```
