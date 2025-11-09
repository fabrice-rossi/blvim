# Returns the number of iterations used to produce this spatial interaction model

Returns the number of iterations used to produce this spatial
interaction model

## Usage

``` r
sim_iterations(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`) or a
  collection of spatial interaction models (an object of class
  `sim_list`)

- ...:

  additional parameters

## Value

a number of iterations that may be one if the spatial interaction model
has been obtained using a static model (see
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md)).
In the case of a `sim_list` the function returns a vector with iteration
number per model.

## See also

[`sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/sim_converged.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
sim_iterations(model) ## must be one
#> [1] 1
```
