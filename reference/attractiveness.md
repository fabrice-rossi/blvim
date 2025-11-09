# Extract the attractivenesses from a spatial interaction model object

Extract the attractivenesses from a spatial interaction model object

## Usage

``` r
attractiveness(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object

- ...:

  additional parameters

## Value

a vector of attractivenesses at the destination locations

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
attractiveness(model)
#>  1  2  3  4  5  6  7  8  9 10 
#>  2  1  1  1  1  1  1  1  1  1 
```
