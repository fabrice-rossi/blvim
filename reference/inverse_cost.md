# Extract the inverse cost scale parameter used to compute this model

Extract the inverse cost scale parameter used to compute this model

## Usage

``` r
inverse_cost(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model with a inverse cost scale parameter

- ...:

  additional parameters

## Value

the inverse cost scale parameter

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
inverse_cost(model) ## should be 1
#> [1] 1
```
