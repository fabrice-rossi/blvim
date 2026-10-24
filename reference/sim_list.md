# Create a sim_list object from a list of spatial interaction models

The collection of `sim` objects represented by a `sim_list` object is
assumed to be homogeneous, that is to correspond to a fixed set of
origin and destination locations, associated with a fixed cost matrix.

## Usage

``` r
sim_list(sims, validate = TRUE)
```

## Arguments

- sims:

  a list of homogeneous spatial interaction models

- validate:

  should the function validate the homogeneity of the list of spatial
  interaction models (defaults to `TRUE`)

## Value

a `sim_list` object

## See also

[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md),
[`c.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/c.sim_list.md),
[`sim_df()`](https://fabrice-rossi.github.io/blvim/reference/sim_df.md),
[`summary.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/summary.sim_list.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
flows_1 <- blvim(distances, production, 1.5, 1, attractiveness)
flows_2 <- blvim(distances, production, 1.25, 2, attractiveness)
all_flows <- sim_list(list(flows_1, flows_2))
```
