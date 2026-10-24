# Compute the Jacobian of the residual map G

The function computes the Jacobian matrix of the residual map with
respect to the attractivenesses. The function returns `NA` when applied
to spatial interaction models for which the map is not defined.

## Usage

``` r
sim_residual_jacobian(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model, an object of class `sim`

- ...:

  additional parameters

## Value

a \\p\times p\\ matrix, where \\p\\ is the number of destination
locations, or `NA` when the residual map is not defined

## Details

The residual map \\\mathbf{G}\\ is given by

\$\$G_j=D_j-\kappa_j Z_j,\$\$

where \\D_j\\ is the destination flow
([`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)),
\\Z_j\\ the attractiveness
([`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md))
and \\\kappa_j\\ the conversion factor
([`sim_conversion()`](https://fabrice-rossi.github.io/blvim/reference/sim_conversion.md)),
all attached to destination \\j\\. The equilibria of the Harris and
Wilson model (see
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md))
are the zeros of \\\mathbf{G}\\.

The derivatives of \\\mathbf{G}\\ w.r.t. \\\mathbf{Z}\\ can be used to
analyse the stability of the solutions, among other applications.

## See also

[`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md),
[`sim_conversion()`](https://fabrice-rossi.github.io/blvim/reference/sim_conversion.md),
[`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_residual_jacobian(model) ## must be NA
#> [1] NA
dyn_model <- blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_residual_jacobian(dyn_model)
#>               75056         13055         69123         31555         06088
#> 75056 -6.453756e-01 -3.354732e-01 -2.088890e-08 -9.584645e-08 -2.917354e-09
#> 13055 -3.546244e-01 -6.645268e-01 -2.924378e-08 -1.748035e-07 -1.515684e-08
#> 69123 -1.814987e-23 -2.403702e-23 -9.999999e-01 -3.578083e-30 -2.359241e-31
#> 31555 -1.328065e-21 -2.291305e-21 -5.706055e-29 -9.999997e-01 -2.001951e-29
#> 06088 -6.644647e-25 -3.265733e-24 -6.184393e-32 -3.290734e-31 -1.000000e+00
#> 44109 -6.550514e-23 -1.784382e-23 -9.765843e-31 -8.666127e-30 -1.444311e-31
#> 34172 -3.886997e-23 -1.036094e-22 -2.775735e-30 -2.355295e-29 -1.087673e-30
#> 67482 -6.342707e-23 -2.242871e-23 -1.974129e-30 -2.068131e-30 -1.866761e-31
#> 33063 -1.101044e-22 -9.478708e-23 -3.507725e-30 -4.752046e-29 -7.786579e-31
#> 59350 -3.967008e-24 -6.683150e-25 -4.751822e-32 -1.656159e-31 -5.662556e-33
#>               44109         34172         67482         33063         59350
#> 75056 -5.486513e-08 -2.056465e-08 -5.079729e-08 -5.986225e-08 -1.657012e-08
#> 13055 -1.579864e-08 -5.794515e-08 -1.898808e-08 -5.447638e-08 -2.950901e-09
#> 69123 -7.107039e-31 -1.275977e-30 -1.373724e-30 -1.657035e-30 -1.724570e-31
#> 31555 -1.005749e-28 -1.726616e-28 -2.295025e-29 -3.579912e-28 -9.585351e-30
#> 06088 -2.755272e-32 -1.310654e-31 -3.405160e-32 -9.642237e-32 -5.387136e-33
#> 44109 -9.999999e-01 -1.357036e-30 -7.862847e-31 -6.737055e-30 -5.010579e-31
#> 34172 -2.148351e-30 -9.999999e-01 -1.608159e-30 -7.554412e-30 -3.021291e-31
#> 67482 -8.223087e-31 -1.062356e-30 -9.999999e-01 -9.312525e-31 -8.100000e-31
#> 33063 -1.037870e-29 -7.351220e-30 -1.371782e-30 -9.999999e-01 -7.768129e-31
#> 59350 -1.004723e-31 -3.826810e-32 -1.553060e-31 -1.011119e-31 -1.000000e+00
```
