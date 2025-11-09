# Extract the return to scale parameter used to compute this model

Extract the return to scale parameter used to compute this model

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
