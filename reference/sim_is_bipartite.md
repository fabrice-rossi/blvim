# Report whether a spatial interaction model is bipartite

The function returns `TRUE` if the spatial interaction model (SIM) is
bipartite, that is if the origin locations are distinct from the
destination locations (at least from the analysis point of view). The
function returns `FALSE` when the SIM uses the same locations for origin
and destination.

## Usage

``` r
sim_is_bipartite(sim)
```

## Arguments

- sim:

  a spatial interaction model object

## Value

`TRUE` if the spatial interaction model is bipartite, `FALSE` if not.

## See also

[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md)
and
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
(parameter `bipartite`), and
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)
and
[`nd_graph()`](https://fabrice-rossi.github.io/blvim/reference/nd_graph.md)
for functions specific to non-bipartite models.

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
## returns TRUE despite the use of a single set of positions
sim_is_bipartite(model)
#> [1] TRUE
## now we are explicit about the non-bipartite nature of the model
model <- static_blvim(distances, production, 1.5, 1, attractiveness,
  bipartite = FALSE
)
sim_is_bipartite(model)
#> [1] FALSE
```
