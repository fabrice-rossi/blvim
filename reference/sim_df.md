# Create a spatial interaction models data frame from a collection of interaction models

This function build a data frame from a collection of spatial
interaction models. The data frame has a list column `sim` of type
`sim_list` which stores the collection of models and classical columns
that contain characteristics of the models. The name of the list column
can be set to something else than `sim` (but not a name used by other
default columns). See details for the default columns.

## Usage

``` r
sim_df(x, sim_column = "sim")
```

## Arguments

- x:

  a collection of spatial interaction models, an object of class
  `sim_list`

- sim_column:

  the name of the `sim_list` column (default `"sim"`)

## Value

a data frame representation of the spatial interaction model collection
with classes `sim_df` and `data.frame`

## Details

The data frame has one row per spatial interaction model and the
following columns:

- `sim` (default name): the last column that contains the models

- `alpha`: the return to scale parameter used to build the model

- `beta`: the cost inverse scale parameter used to build the model

- `diversity`: model default
  [`diversity()`](https://fabrice-rossi.github.io/blvim/reference/diversity.md)
  (Shannon's diversity)

- `iterations`: the number of iterations used to produce the model (1
  for a static model)

- `converged`: `TRUE` is the iterative calculation of the model
  converged (for models produced by
  [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
  and related approaches), `FALSE` for no convergence and `NA` for
  static models

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
all_flows <- grid_blvim(distances, production, c(1.25, 1.5), c(1, 2, 3), attractiveness)
all_flows_df <- sim_df(all_flows)
all_flows_df$converged
#> [1] TRUE TRUE TRUE TRUE TRUE TRUE
```
