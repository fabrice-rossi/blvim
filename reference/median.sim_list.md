# Compute the "median" of a collection of spatial interaction models

This function computes all pairwise distances between spatial
interaction models (SIMs) of its `x` parameter, using
[`sim_distance()`](https://fabrice-rossi.github.io/blvim/reference/sim_distance.md)
with the specified distance parameters. Then it returns the "median" of
the collection defined as the SIM that is in average the closest to all
the other SIMs. Tie breaking uses the order of the SIMs in the
collection.

## Usage

``` r
# S3 method for class 'sim_list'
median(
  x,
  na.rm = FALSE,
  flows = c("full", "destination", "attractiveness"),
  method = c("euclidean"),
  return_distances = FALSE,
  ...
)
```

## Arguments

- x:

  a collection of spatial interaction models, an object of class
  `sim_list`

- na.rm:

  not used

- flows:

  `"full"` (default), `"destination"` or `"attractiveness"`, see
  details.

- method:

  the distance measure to be used. Currently only `"euclidean"` is
  supported

- return_distances:

  should the distances computed to find the median be returned as a
  `distances` attribute of the resulting object? (defaults to `FALSE`)

- ...:

  additional parameters (not used currently)

## Value

a spatial interaction model, an object of class `sim` with additional
attributes

## Details

As distance calculation can be slow in a large collection of SIMs, the
distance object can be returned as a `distances` attribute of the median
SIM by setting the `return_distances` parameter to `TRUE`. In addition,
the returned SIM has always two attributes:

- `index` gives the index of the mode in the original `sim_list`

- `distortion` gives the mean of the distances from the median SIM to
  all the other SIMs

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.1),
  seq(1, 3, by = 0.5) / 400,
  attractiveness,
  bipartite = FALSE,
  epsilon = 0.1, iter_max = 1000,
)
all_flows_median <- median(all_flows)
attr(all_flows_median, "index")
#> [1] 13
attr(all_flows_median, "distortion")
#> [1] 1.581661
median(all_flows, flows = "destination")
#> Spatial interaction model with 10 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.25 and inverse cost scale (beta) =
#> 0.005
#> ℹ The BLV model converged after 1000 iterations.
median(all_flows, flows = "attractiveness")
#> Spatial interaction model with 10 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.25 and inverse cost scale (beta) =
#> 0.005
#> ℹ The BLV model converged after 1000 iterations.
```
