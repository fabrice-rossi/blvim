# Extract the cost matrix used to compute a model

Extract the cost matrix used to compute a model

## Usage

``` r
costs(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model with a cost matrix

- ...:

  additional parameters

## Value

the cost matrix

## See also

[`return_to_scale()`](https://fabrice-rossi.github.io/blvim/reference/return_to_scale.md),
[`inverse_cost()`](https://fabrice-rossi.github.io/blvim/reference/inverse_cost.md),
[`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md),
[`costs.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/costs.sim_list.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
costs(model) ## should be equal to distances above
#>           1         2         3         4         5         6         7
#> 1  0.000000 1.7917806 1.7523144 1.1038849 1.0267901 1.4599417 1.3066191
#> 2  1.791781 0.0000000 0.1774772 0.8561007 1.2557201 2.2078298 2.1051070
#> 3  1.752314 0.1774772 0.0000000 0.7464683 1.3222666 2.0615683 1.9647797
#> 4  1.103885 0.8561007 0.7464683 0.0000000 1.1301611 1.3917277 1.2741534
#> 5  1.026790 1.2557201 1.3222666 1.1301611 0.0000000 2.2426117 2.0929632
#> 6  1.459942 2.2078298 2.0615683 1.3917277 2.2426117 0.0000000 0.1546392
#> 7  1.306619 2.1051070 1.9647797 1.2741534 2.0929632 0.1546392 0.0000000
#> 8  1.656248 3.3250116 3.2388879 2.4965704 2.6683415 1.6688169 1.6239861
#> 9  1.030426 0.8379205 0.7533717 0.1348868 0.9952855 1.4724176 1.3471051
#> 10 0.825724 1.2044893 1.2391743 0.9284433 0.2445496 1.9980658 1.8484366
#>           8         9        10
#> 1  1.656248 1.0304262 0.8257240
#> 2  3.325012 0.8379205 1.2044893
#> 3  3.238888 0.7533717 1.2391743
#> 4  2.496570 0.1348868 0.9284433
#> 5  2.668341 0.9952855 0.2445496
#> 6  1.668817 1.4724176 1.9980658
#> 7  1.623986 1.3471051 1.8484366
#> 8  0.000000 2.4892516 2.4808382
#> 9  2.489252 0.0000000 0.7947472
#> 10 2.480838 0.7947472 0.0000000
all.equal(costs(model), distances)
#> [1] TRUE
```
