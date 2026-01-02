# Extract or replace parts of a SIM data frame

Extract or replace subsets of SIM data frames. The behaviour of the
functions is very close to the one of the corresponding `data.frame`
functions, see
[`[.data.frame`](https://rdrr.io/r/base/Extract.data.frame.html).
However, modifications of the SIM columns or suppression of core columns
will turn the object into a standard `data.frame` to void issues in e.g.
graphical representations, see below for details.

## Usage

``` r
# S3 method for class 'sim_df'
x$name <- value

# S3 method for class 'sim_df'
x[[i, j]] <- value

# S3 method for class 'sim_df'
x[i, j, ..., drop]

# S3 method for class 'sim_df'
x[i, j] <- value
```

## Arguments

- x:

  data frame of spatial interaction models, an object of class `sim_df`

- name:

  a literal character string

- value:

  a suitable replacement value: it will be repeated a whole number of
  times if necessary and it may be coerced: see the Coercion section in
  [`[.data.frame`](https://rdrr.io/r/base/Extract.data.frame.html). If
  NULL, deletes the column if a single column is selected.

- i, j, ...:

  elements to extract or replace. For `[` and `[[`, these are numeric or
  character or, for `[` only, empty or logical. Numeric values are
  coerced to integer as if by as.integer. For replacement by `[`, a
  logical matrix is allowed.

- drop:

  If `TRUE` the result is coerced to the lowest possible dimension. The
  default is to drop if only one column is left, but not to drop if only
  one row is left.

## Value

For `[` a `sim_df`, a `data.frame` or a single column depending on the
values of `i` and `j`.

For `[[` a column of the `sim_df` (or `NULL`) or an element of a column
when two indices are used.

For `$` a column of the `sim_df` (or `NULL`).

For `[<-`, `[[<-`, and `$<-` a `sim_df` or a data frame (see details).

## Details

In a `sim_df`, the core columns are derived from the `sim_list` column.
Replacement functions maintain this property by updating the columns
after any modification of the `sim_list` column. Modifications of the
core columns are rejected (removing a core column is accepted but this
turns the `sim_df` into a standard `data.frame`).

In addition, the `sim_list` column obeys to restriction on `sim_list`
modifications (i.e, a `sim_list` contains a homogeneous collection of
spatial interaction models).

Extraction functions keep the `sim_df` class only if the result is a
data frame with a `sim_list` column, the core columns and potentially
additional columns.

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
## the models as a sim_list
all_flows_df[, "sim"]
#> Collection of 15 spatial interaction models with 10 origin locations and 10
#> destination locations computed on the following grid:
#> • alpha: 1.05, 1.25, and 1.45
#> • beta: 0.0025, 0.00375, 0.005, 0.00625, and 0.0075
## sub data frame, a sim_df
all_flows_df[1:5, ]
#>   alpha    beta diversity iterations converged          sim
#> 1  1.05 0.00250  1.967999       1000      TRUE c(0.8172....
#> 2  1.25 0.00250  1.999659        800      TRUE c(0.8687....
#> 3  1.45 0.00250  1.990039       1001     FALSE c(0.8383....
#> 4  1.05 0.00375  2.672869       1001     FALSE c(0.8971....
#> 5  1.25 0.00375  1.999562        500      TRUE c(0.9454....
## sub data frame, not a sim_df (alpha is missing)
all_flows_df[6:10, 2:6]
#>       beta diversity iterations converged          sim
#> 6  0.00375  1.999209        500      TRUE c(0.9438....
#> 7  0.00500  6.385427       1001     FALSE c(0.7890....
#> 8  0.00500  3.195527       1000      TRUE c(0.9488....
#> 9  0.00500  1.999114        400      TRUE c(0.9778....
#> 10 0.00625  9.691171       1001     FALSE c(0.7243....
all_flows_2 <- grid_blvim(distances, log(french_cities$population[1:10]),
  seq(1.05, 1.45, by = 0.2),
  seq(1, 3, by = 0.5) / 400,
  attractiveness,
  bipartite = FALSE,
  epsilon = 0.1, iter_max = 1000,
)
## replace the sim_list column by the new models
## before
all_flows_df$diversity
#>  [1] 1.967999 1.999659 1.990039 2.672869 1.999562 1.999209 6.385427 3.195527
#>  [9] 1.999114 9.691171 3.984711 3.355835 9.938952 6.741682 4.725279
all_flows_df$sim <- all_flows_2
## after (all core columns have been updated)
all_flows_df$diversity
#>  [1] 1.971704 1.999842 1.996445 2.484213 1.999639 1.999358 6.191392 2.684352
#>  [9] 1.999157 9.400831 3.889657 3.254730 9.842626 6.659397 3.964254
```
