# Reports whether the spatial interaction model construction converged

Some spatial interaction models are the result of an iterative
calculation, see for instance
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).
This calculation may have been interrupted before convergence. The
present function returns `TRUE` if the calculation converged, `FALSE` if
this was not the case and `NA` if the spatial interaction model is not
the result of an iterative calculation. The function applies also to a
collection of spatial interaction models as represented by a `sim_list`.

## Usage

``` r
sim_converged(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`) or a
  collection of spatial interaction models (an object of class
  `sim_list`)

- ...:

  additional parameters

## Value

`TRUE`, `FALSE` or `NA`, as described above. In the case of a `sim_list`
the function returns a logical vector with one value per model.

## See also

[`sim_iterations()`](https://fabrice-rossi.github.io/blvim/reference/sim_iterations.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
sim_converged(model) ## must be NA
#> [1] NA
```
