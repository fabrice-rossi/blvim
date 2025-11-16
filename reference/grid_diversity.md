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
distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
production <- log(french_cities$population[1:15])
attractiveness <- log(french_cities$area[1:15])
all_flows <- grid_blvim(
  distances, production, c(1.1, 1.25, 1.5),
  c(1, 2, 3, 4) / 500, attractiveness,
  epsilon = 0.1,
  bipartite = FALSE
)
diversities <- grid_diversity(all_flows)
diversities ## should be a length 12 vector
#>  [1] 1.891319 1.000000 1.000000 1.976166 1.968974 1.945845 5.027994 2.410876
#>  [9] 1.981744 6.907061 5.460118 2.458216
grid_diversity(all_flows, "renyi", 3)
#>  [1] 1.734908 1.000000 1.000000 1.931990 1.912744 1.854403 3.636500 2.165508
#>  [9] 1.947308 4.905153 4.077701 2.212184
```
