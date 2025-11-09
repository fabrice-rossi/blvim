# Compute diversities for a collection of spatial interaction models

The function computes for each spatial interaction model of its
`sim_list` parameter the
[`diversity()`](https://fabrice-rossi.github.io/blvim/reference/diversity.md)
of the corresponding destination flows and returns the values as a
vector. The type of diversity and the associated parameters are
identical for all models.

## Usage

``` r
grid_diversity(
  sim,
  definition = c("shannon", "renyi", "ND", "RW"),
  order = 1L,
  ...
)
```

## Arguments

- sim:

  a collection of spatial interaction models, an object of class
  `sim_list`

- definition:

  diversity definition `"shannon"` (default), `"renyi"` (see details) or
  a definition supported by
  [`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)

- order:

  order of the Rényi entropy, used only when `definition="renyi"`

- ...:

  additional parameters

## Value

a vector of diversities, one per spatial interaction model

## Details

See
[`diversity()`](https://fabrice-rossi.github.io/blvim/reference/diversity.md)
for the definition of the diversities. Notice that
[`diversity()`](https://fabrice-rossi.github.io/blvim/reference/diversity.md)
is generic and can be applied directly to `sim_list` objects. The
current function is provided to be explicit in R code about what is a
unique model and what is a collection of models (using function names
that start with `"grid_"`)

## See also

[`diversity()`](https://fabrice-rossi.github.io/blvim/reference/diversity.md)
and
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)

## Examples

``` r
positions <- matrix(rnorm(15 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 15)
attractiveness <- rep(1, 15)
all_flows <- grid_blvim(distances,
  production,
  c(1.1, 1.25, 1.5),
  c(1, 2, 3),
  attractiveness,
  bipartite = FALSE,
  epsilon = 0.1
)
diversities <- grid_diversity(all_flows)
diversities ## should be a length 9 vector
#> [1]  1.983502  1.901702  1.000000  6.961644  4.174735  2.661917 10.363274
#> [8]  8.139205  6.331496
grid_diversity(all_flows, "renyi", 3)
#> [1] 1.952206 1.755958 1.000000 4.878591 3.586610 2.396639 7.398064 5.726087
#> [9] 4.659825
```
