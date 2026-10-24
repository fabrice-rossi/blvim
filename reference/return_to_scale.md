# Extract the return to scale parameter used to compute a model

Extract the return to scale parameter used to compute a model

## Usage

``` r
return_to_scale(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model with a return to scale parameter

- ...:

  additional parameters

## Value

the return to scale parameter

## See also

[`inverse_cost()`](https://fabrice-rossi.github.io/blvim/reference/inverse_cost.md),
[`costs()`](https://fabrice-rossi.github.io/blvim/reference/costs.md),
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md),
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
return_to_scale(model) ## should be 1.5
#> [1] 1.5
```
