# Control parameters for the blvim gradient algorithms

This function returns a list of parameters used to tune the gradient
algorithms of
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).
Most of these parameters control the line search algorithm, which is a
standard backtracking method with the Armijo stopping criterion. The
`preconditioner` parameter changes the geometry used for the gradient
steps.

## Usage

``` r
blvim_gradient_control(
  rho_init = 0.5,
  shrink = 0.5,
  sufficient_increase = 1e-05,
  ls_iter_max = 50,
  preconditioner = NULL,
  history = FALSE
)
```

## Arguments

- rho_init:

  Initial value of the gradient step in the line search. The step is
  applied to the rescaled attractivenesses \\U_j\\, which sum to one,
  and has the same meaning for the `"gradient"` and `"gradient_unit"`
  algorithms; see
  [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).

- shrink:

  Shrink factor for the gradient step in the line search.

- sufficient_increase:

  Relative sufficient increase in the line search.

- ls_iter_max:

  Maximum number of iterations of the line search.

- preconditioner:

  `NULL` (default) or a vector of strictly positive values with one
  value per destination location. The gradient of the potential with
  respect to the variables of the algorithm (the attractivenesses
  \\Z_j\\ for `"gradient"` and the rescaled attractivenesses \\U_j\\ for
  `"gradient_unit"`) is multiplied component-wise by this vector, and
  trial points are projected onto the simplex using the corresponding
  weighted Euclidean norm. The resulting preconditioner is rescaled to a
  unit mean in the \\U_j\\ variables, so that `rho_init` keeps its
  meaning. Only the relative values of the `preconditioner` matter. The
  preconditioner does not change the solutions of the problem, but it
  changes the path followed by the algorithm, and therefore possibly the
  local maximum it converges to.

- history:

  A logical scalar. If `TRUE`, the gradient algorithms record the
  history of their iterations, which can be retrieved with
  [`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md).
  When multiple starting points are used in
  [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
  the history is kept only for the retained models (the selected one, or
  all of them when `keep_runs = TRUE`).

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
[`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md),
[`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md)

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
#> $preconditioner
#> NULL
#> 
#> $history
#> [1] FALSE
#> 
## favour moves of the first destination
blvim_gradient_control(preconditioner = c(10, rep(1, 9)))
#> $rho_init
#> [1] 0.5
#> 
#> $shrink
#> [1] 0.5
#> 
#> $sufficient_increase
#> [1] 1e-05
#> 
#> $ls_iter_max
#> [1] 50
#> 
#> $preconditioner
#>  [1] 10  1  1  1  1  1  1  1  1  1
#> 
#> $history
#> [1] FALSE
#> 
```
