# Summary of a collection of spatial interaction models

This function computes summary statistics on a collection of spatial
interaction models (in a `sim_list`).

## Usage

``` r
# S3 method for class 'sim_list'
summary(object, ...)

# S3 method for class 'summary_sim_list'
print(x, ...)
```

## Arguments

- object:

  a collection of spatial interaction models, an object of class
  `sim_list` `summary.sim_list()`

- ...:

  additional parameters (not used currently)

- x:

  an object of class `summary_sim_list` produced by

## Value

an object of class `summary_sim_list` and `list` with a set of summary
statistics computed on the collection of spatial interaction models

## Details

The list returned by the function contains the following elements:

- `median`: the median of the collection, as return by the
  [`median.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/median.sim_list.md)
  function

- `distortion`: the average distance of all elements of the collection
  to the median model

- `withinss`: the sum of all pairwise distances between the elements of
  the collection

- `nb_sims`: the size of the collection

In addition, if the collection contains non bipartite models, the result
has another element, `nb_configurations` which gives the number of
distinct terminal sets in the collection, where the terminals are
computed by
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md),
using the `"RW"` definition.

## See also

[`median.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/median.sim_list.md),
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)

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
#> 
#> ── Summary of a collection of 9 spatial interaction models ──
#> 
#> All models have 15 origin locations and 15 destination locations.
#> 
#> ── Median representation ──
#> 
#> ── Median spatial interaction model 
#> Spatial interaction model with 15 origin locations and 15 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.25 and inverse cost scale (beta) = 2
#> ℹ The BLV model converged after 900 iterations.
#> 
#> ── Homogeneity 
#> distortion: 2.559
#> within variance: 111.523
#> 
#> ── Terminals ──
#> 
#> The list has 7 different terminal configurations
```
