# Compute the Jacobian of the fixed-point map G

The function computes the Jacobian matrix of the fixed-point map with
respect to the attractivenesses. The function returns `NA` when applied
to spatial interaction models for which the map is not defined.

## Usage

``` r
sim_fp_jacobian(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model, an object of class `sim`

- ...:

  additional parameters

## Value

a p x p matrix or NA

## Details

The fixed point map \\\mathbf{G}\\ is given by

\$\$G_j=D_j-\kappa_j Z_j,\$\$

where \\D_j\\ is the destination flow
([`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)),
\\Z_j\\ the attractiveness
([`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md))
and \\\kappa_j\\ the conversion factor
([`sim_conversion()`](https://fabrice-rossi.github.io/blvim/reference/sim_conversion.md)),
all attached to destination \\j\\.

The derivatives of \\\mathbf{G}\\ w.r.t. \\\mathbf{Z}\\ can be used to
analyse the stability of the solutions, among other applications.

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 250, attractiveness)
sim_fp_jacobian(model) ## must NA
#> [1] NA
```
