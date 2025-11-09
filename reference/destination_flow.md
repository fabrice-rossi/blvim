# Compute the flows incoming at each destination location

Compute the flows incoming at each destination location

## Usage

``` r
destination_flow(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object

- ...:

  additional parameters

## Value

a vector of flows incoming at destination locations

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
destination_flow(model)
#>         1         2         3         4         5         6         7         8 
#> 1.7804164 0.8087637 0.9256436 0.9871814 1.0142576 0.8435905 1.0515386 0.9100896 
#>         9        10 
#> 0.8088468 0.8696718 
```
