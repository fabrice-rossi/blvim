# Extract the production constraints from a spatial interaction model object

Extract the production constraints from a spatial interaction model
object

## Usage

``` r
production(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object

- ...:

  additional parameters

## Value

a vector of production constraints at the origin locations

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
all.equal(production(model), production)
#> [1] "names for target but not for current"
```
