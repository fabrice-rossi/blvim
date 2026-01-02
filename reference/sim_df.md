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

The resulting object behaves mostly like a `data.frame` and support
standard extraction and replacement operators. The object tries to keep
its `sim_df` class during modifications. In particular,
`names<-.sim_df()` tracks name change for the `sim_list` column. If a
modification or an extraction operation changes the type of the
`sim_list` column or drops it, the resulting object is a standard
`data.frame`. See
[`[.sim_df`](https://fabrice-rossi.github.io/blvim/reference/sim_df_extract.md)
and
[`names<-.sim_df()`](https://fabrice-rossi.github.io/blvim/reference/names-set-.sim_df.md)
for details.

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
all_flows_df$converged
#>  [1]  TRUE  TRUE FALSE FALSE  TRUE  TRUE FALSE  TRUE  TRUE FALSE FALSE  TRUE
#> [13]  TRUE  TRUE FALSE
## change the name of the sim column
names(all_flows_df)[6] <- "models"
## still a sim_df
class(all_flows_df)
#> [1] "sim_df"     "data.frame"
## get the models
sim_column(all_flows_df)
#> Collection of 15 spatial interaction models with 10 origin locations and 10
#> destination locations computed on the following grid:
#> • alpha: 1.05, 1.25, and 1.45
#> • beta: 0.0025, 0.00375, 0.005, 0.00625, and 0.0075
```
