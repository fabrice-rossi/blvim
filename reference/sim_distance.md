# Compute all pairwise distances between the spatial interaction models in a collection

This function extracts from each spatial interaction model of the
collection a vector representation derived from its flow matrix (see
details). This vector is then used to compute distances between the
models.

## Usage

``` r
sim_distance(
  sim_list,
  flows = c("full", "destination", "attractiveness"),
  method = c("euclidean"),
  ...
)
```

## Arguments

- sim_list:

  a collection of spatial interaction models, an object of class
  `sim_list`

- flows:

  `"full"` (default), `"destination"` or `"attractiveness"`, see
  details.

- method:

  the distance measure to be used. Currently only `"euclidean"` is
  supported

- ...:

  additional parameters (not used currently)

## Value

an object of class `"dist"`

## Details

The vector representation is selected using the `flows` parameters.
Possible values are

- `"full"` (default value): the representation is obtained by
  considering the matrix of
  [`flows()`](https://fabrice-rossi.github.io/blvim/reference/flows.md)
  as a vector (with the standard
  [`as.vector()`](https://rdrr.io/r/base/vector.html) function);

- `"destination"`: the representation is the
  [`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)
  vector associated to each spatial interaction model;

- `"attractiveness"`: the representation is the
  [`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)
  vector associated to each spatial interaction model.

## See also

[`dist()`](https://rdrr.io/r/stats/dist.html)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
all_flows <- grid_blvim(
  distances, production, c(1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness,
  epsilon = 0.1
)
flows_distances <- sim_distance(all_flows)
inflows_distances <- sim_distance(all_flows, "destination")
```
