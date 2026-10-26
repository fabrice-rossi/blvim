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
#>            1        2         3         4        5         6         7
#> 1  0.0000000 2.385241 2.6055516 0.5883748 2.576659 1.7548002 0.6654317
#> 2  2.3852410 0.000000 2.5383932 1.9875560 4.165255 1.7159622 1.8256848
#> 3  2.6055516 2.538393 0.0000000 2.0578799 2.318692 1.0183344 2.6790321
#> 4  0.5883748 1.987556 2.0578799 0.0000000 2.460238 1.1684657 0.7234066
#> 5  2.5766595 4.165255 2.3186924 2.4602384 0.000000 2.5217770 3.1294650
#> 6  1.7548002 1.715962 1.0183344 1.1684657 2.521777 0.0000000 1.6972788
#> 7  0.6654317 1.825685 2.6790321 0.7234066 3.129465 1.6972788 0.0000000
#> 8  2.6892313 1.962744 0.7387295 2.1018843 2.987591 0.9350521 2.5764344
#> 9  2.0324972 2.919325 1.0273593 1.6287222 1.366927 1.2117462 2.3492692
#> 10 1.5427366 3.626592 2.6041795 1.6669633 1.236257 2.2909146 2.1848527
#>            8        9       10
#> 1  2.6892313 2.032497 1.542737
#> 2  1.9627442 2.919325 3.626592
#> 3  0.7387295 1.027359 2.604180
#> 4  2.1018843 1.628722 1.666963
#> 5  2.9875907 1.366927 1.236257
#> 6  0.9350521 1.211746 2.290915
#> 7  2.5764344 2.349269 2.184853
#> 8  0.0000000 1.632833 3.068977
#> 9  1.6328329 0.000000 1.611301
#> 10 3.0689765 1.611301 0.000000
all.equal(costs(model), distances)
#> [1] TRUE
```
