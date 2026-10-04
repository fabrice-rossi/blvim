# Returns a full diagnostic of the algorithm used to build a spatial interaction model

Some spatial interaction models are the result of an iterative
calculation, see for instance
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).
This function returns a diagnostic object that gives details about the
behaviour of the iterative algorithm.

## Usage

``` r
sim_diagnostic(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`)

- ...:

  additional parameters

## Value

a diagnostic object of class deriving from `sim_diagnostic`

## See also

[`sim_iterations()`](https://fabrice-rossi.github.io/blvim/reference/sim_iterations.md),
[`sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/sim_converged.md),
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_diagnostic(model)
#> Static spatial interaction model
```
