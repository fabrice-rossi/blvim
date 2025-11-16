# Extract all terminal status from a collection of spatial interaction models

The function extract terminal status from all the spatial interaction
models of the collection and returns them in a matrix in which each row
corresponds to a model and each column to a destination location. The
value at row `i` and column `j` is `TRUE` if destination `j` is a
terminal in model `i`. This function applies only to non bipartite
models.

## Usage

``` r
grid_is_terminal(sim_list, definition = c("ND", "RW"), ...)
```

## Arguments

- sim_list:

  a collection of non bipartite spatial interaction models, an object of
  class `sim_list`

- definition:

  terminal definition, either `"ND"` (for Nystuen & Dacey, default) or
  `"RW"` (for Rihll & Wilson), see details.

- ...:

  additional parameters for the
  [`is_terminal()`](https://fabrice-rossi.github.io/blvim/reference/is_terminal.md)
  function

## Value

a matrix of terminal status at the destination locations

## Details

See
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)
for the definition of terminal locations.

## See also

[`is_terminal()`](https://fabrice-rossi.github.io/blvim/reference/is_terminal.md)
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
  epsilon = 0.1,
  bipartite = FALSE
)
g_df <- grid_is_terminal(all_flows)
## should be 12 rows (3 times 4 parameter pairs) and 15 columns (15
## destination locations)
dim(g_df)
#> [1] 12 15
```
