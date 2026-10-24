# Control parameters for the blvim gradient algorithms

This function returns a list of parameters used to tune the gradient
algorithms of
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).
These parameters control the line search algorithm, which is a standard
backtracking method with the Armijo stopping criterion.

## Usage

``` r
blvim_gradient_control(
  rho_init = 0.5,
  shrink = 0.5,
  sufficient_increase = 1e-05,
  ls_iter_max = 50
)
```

## Arguments

- rho_init:

  Initial value of the gradient step in the line search.

- shrink:

  Shrink factor for the gradient step in the line search.

- sufficient_increase:

  Relative sufficient increase in the line search.

- ls_iter_max:

  Maximum number of iterations of the line search.

## Value

a list containing the values of the parameters, to be used as the
`control` argument of
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md) or
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)

## References

Armijo, Larry (1966), "Minimization of functions having Lipschitz
continuous first partial derivatives", Pacific J. Math. 16 (1): 1–3
[doi:10.2140/pjm.1966.16.1](https://doi.org/10.2140/pjm.1966.16.1)

## See also

[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)

## Examples

``` r
blvim_gradient_control(0.5, 0.7, 1e-4, 25)
#> $rho_init
#> [1] 0.5
#> 
#> $shrink
#> [1] 0.7
#> 
#> $sufficient_increase
#> [1] 1e-04
#> 
#> $ls_iter_max
#> [1] 25
#> 
```
