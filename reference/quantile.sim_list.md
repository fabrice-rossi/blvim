# Compute quantiles of the flows in a collection of spatial interaction models

The function computes the specified quantiles for individual or
aggregated flows in a collection of spatial interaction models.

## Usage

``` r
# S3 method for class 'sim_list'
quantile(
  x,
  flows = c("full", "destination", "attractiveness"),
  probs = seq(0, 1, 0.25),
  normalisation = c("none", "origin", "full"),
  ...
)
```

## Arguments

- x:

  a collection of spatial interaction models, a `sim_list`

- flows:

  `"full"` (default), `"destination"` or `"attractiveness"`, see
  details.

- probs:

  numeric vector of probabilities with values in \\\[0,1\]\\.

- normalisation:

  when `flows="full"`, the flows are used as is, that without
  normalisation (`normalisation="none"`, default case) or they can be
  normalised prior the calculation of the quantiles, either to sum to
  one for each origin location (`normalisation="origin"`) or to sum to
  one globally (`normalisation="full"`). This is useful for
  [`autoplot.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_list.md).

- ...:

  additional parameters, not used currently

## Value

a date frame, see details

## Details

The exact behaviour depends on the value of `flows`. In all cases, the
function returns a data frame. The data frame has one column per
quantile, named after the quantile using a percentage based named, as in
the default
[`stats::quantile()`](https://rdrr.io/r/stats/quantile.html). For a
graphical representation of those quantiles, see
[`autoplot.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_list.md).

- if `flows="full"`: this is the default case in which the function
  computes for each pair of origin \\o\\ and destination \\d\\ locations
  the quantiles of the distribution of the flow from \\o\\ to \\d\\ in
  the collection of models (the flows maybe normalised before quantile
  calculations, depending on the value of `normalisation`). In addition
  to the quantiles, the data frame has two columns:

  - `origin_idx`: identifies the origin location by its index from 1 to
    the number of origin locations;

  - `destination_idx`: identifies the destination location by its index
    from 1 to the number of destination locations.

- if `flows="destination"`, the function computes quantiles for each
  destination \\d\\ location of the distribution of its incoming flow
  ([`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md))
  in the collection of models. In addition to the quantiles, the data
  frame has one column `destination` that identifies the destination
  location by its index from 1 to the number of destination locations.

- if `flows="attractiveness"`, the function computes quantiles for each
  destination \\d\\ location of the distribution of its attractiveness
  ([`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md))
  in the collection of models. In addition to the quantiles, the data
  frame has one column `destination` that identifies the destination
  location by its index from 1 to the number of destination locations.

## See also

[`fortify.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/fortify.sim_list.md)
[`autoplot.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_list.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
all_flows <- grid_blvim(distances, production, seq(1.05, 1.45, by = 0.1),
  seq(1, 3, by = 0.5) / 400,
  attractiveness,
  bipartite = FALSE,
  epsilon = 0.1, iter_max = 1000
)
head(quantile(all_flows))
#>   origin_idx destination_idx           0%         25%        50%        75%
#> 1          1               1 0.7243813443 0.791508067 0.86872582 0.94540077
#> 2          2               1 0.0005096627 0.004080883 0.01547892 0.06524731
#> 3          3               1 0.0259905430 0.068413565 0.24311397 0.31257755
#> 4          4               1 0.0047697000 0.013247367 0.10571429 0.18820630
#> 5          5               1 0.0006900334 0.003163334 0.01883933 0.06524736
#> 6          6               1 0.0527184836 0.107513229 0.65084792 0.80560083
#>        100%
#> 1 0.9778068
#> 2 0.1306230
#> 3 0.3955416
#> 4 0.3243445
#> 5 0.1327188
#> 6 0.9492135
head(quantile(all_flows, flows = "destination"))
#>   destination           0%          25%          50%          75%      100%
#> 1           1 1.064013e+00 1.357607e+00 3.537690e+00 4.500767e+00 4.9076303
#> 2           2 2.644311e-27 1.577667e+00 4.302950e+00 5.092370e+00 5.4992328
#> 3           3 8.720603e-63 5.864564e-44 1.334964e-27 1.336506e-07 0.9023744
#> 4           4 9.558027e-62 2.082119e-34 3.105876e-22 7.298803e-03 0.9637403
#> 5           5 2.036938e-64 5.148087e-50 3.168389e-36 2.590305e-27 0.8184971
#> 6           6 1.055197e-63 1.217695e-29 3.518563e-20 8.580367e-01 0.9752023
head(quantile(all_flows,
  flows = "attractiveness",
  probs = c(0.1, 0.3, 0.6, 0.9)
))
#>   destination          10%          30%          60%       90%
#> 1           1 1.149829e+00 2.054336e+00 3.932103e+00 4.8717817
#> 2           2 1.600450e-05 2.129355e+00 4.417651e+00 5.1455216
#> 3           3 3.233102e-40 2.556690e-29 5.300175e-18 0.6943906
#> 4           4 2.602864e-36 2.740750e-23 5.120037e-15 0.9254629
#> 5           5 1.136226e-42 1.796658e-34 3.319068e-26 0.3598985
#> 6           6 1.088399e-35 2.998592e-21 9.137419e-08 0.9542375
```
