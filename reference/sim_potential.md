# Compute the potential of a spatial interaction model

The potential is a measure of stability introduced by Osawa, Akamatsu,
and Kogure. It is only defined for spatial interaction models produced
by BLV framework. The function returns `NA` when applied to spatial
interaction models for which a potential cannot be computed.

## Usage

``` r
sim_potential(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model, an object of class `sim`

- ...:

  additional parameters

## Value

the scalar value of the potential

## Details

The potential of a spatial interaction model is given by

\$\$\frac{1}{\alpha}\sum\_{i=1}^n X_i \log\left(\sum\_{j=1}^p
Z_j^{\alpha}\\ \exp(-\beta c\_{ij})\right)-\sum\_{j=1}^p\kappa_jZ_j,\$\$

where:

- \\c\\ is the cost matrix
  [`costs()`](https://fabrice-rossi.github.io/blvim/reference/costs.md)

- \\X\\ is the production constraint vector
  ([`production()`](https://fabrice-rossi.github.io/blvim/reference/production.md))

- \\\alpha\\ is the return to scale parameter
  ([`return_to_scale()`](https://fabrice-rossi.github.io/blvim/reference/return_to_scale.md))

- \\\beta\\ is the inverse of a cost scale parameter
  ([`inverse_cost()`](https://fabrice-rossi.github.io/blvim/reference/inverse_cost.md))

- \\Z\\ is the attractiveness vector
  ([`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md))

- \\\kappa\\ is the conversion factor vector
  ([`sim_conversion()`](https://fabrice-rossi.github.io/blvim/reference/sim_conversion.md))

## References

Osawa, M., Akamatsu, T., & Kogure, Y. (2025). "Most likely retail
agglomeration patterns: Potential maximization and stochastic stability
of spatial equilibria". <https://arxiv.org/abs/2011.06778v2>

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_conversion(model) ## must NA
#> [1] NA
```
