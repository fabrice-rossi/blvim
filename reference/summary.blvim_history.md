# Summary of the iteration history of blvim

Summarises the iteration history of the gradient algorithms of
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
as returned by
[`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md),
for one model or for a collection of models.

## Usage

``` r
# S3 method for class 'blvim_history'
summary(object, ...)

# S3 method for class 'summary_blvim_history'
print(x, ...)
```

## Arguments

- object:

  a data frame of class `blvim_history` produced by
  [`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md)

- ...:

  additional parameters (not used currently)

- x:

  an object of class `summary_blvim_history` produced by
  `summary.blvim_history()`

## Value

an object of class `summary_blvim_history` and `list` with the following
elements:

- `runs`: a data frame with one row per run and columns `sim` (index of
  the model in the collection, 1 for a single model), `iterations`,
  `initial_potential`, `final_potential`, `final_gap`, `rate`,
  `reductions`, `min_step`, `initial_active` and `final_active` (number
  of active destinations), `face_changes` (number of changes of the
  number of active destinations), `last_change` (iteration of the last
  face change, `NA` without change), `final_min_U` (smallest rescaled
  attractiveness of the final configuration), `vanishing` (whether a
  destination may be slowly vanishing) and `on_face` (whether the final
  configuration is on a face of the simplex);

- `collection`: whether the history describes a collection of models.

## Details

For each run, the summary gives the number of iterations, the initial
and final potentials, the final duality gap, the estimated convergence
rate of the duality gap, the total number of step reductions in the line
search, the smallest accepted step, and the evolution of the active
destinations. The convergence rate is the factor by which the gap is
multiplied at each iteration, estimated on the last iterations (at most
20): a rate close to one denotes a slow linear convergence.

The projected gradient ascent moves on the faces of the simplex: a
destination vanishes when its rescaled attractiveness becomes zero, and
can come back later. Each change of the number of active destinations is
a face change. The duality gap often decreases quickly only once the
ascent stays on the face of its final configuration, that is after the
last face change. A final configuration whose smallest rescaled
attractiveness is below \\10^{-5}\\ is on a face of the simplex.
Conversely, when the final configuration is not on a face but its
smallest rescaled attractiveness decreased by more than a factor 10 over
the last half of the iterations, a destination may be slowly vanishing,
which slows down the convergence.

## See also

[`sim_history()`](https://fabrice-rossi.github.io/blvim/reference/sim_history.md),
[`grid_sim_history()`](https://fabrice-rossi.github.io/blvim/reference/grid_sim_history.md),
[`autoplot.blvim_history()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.blvim_history.md)

## Examples

``` r
distances <- french_cities_distances[1:15, 1:15] / 1000
production <- rep(1, 15)
attractiveness <- rep(1, 15)
model <- blvim(distances, production, 1.5, 1 / 50, attractiveness,
  algorithm = "gradient", bipartite = FALSE,
  control = blvim_gradient_control(history = TRUE)
)
summary(sim_history(model))
#> 
#> ── Iteration history of a gradient ascent ──
#> 
#> • 37 iterations, potential from -13.88252 to -13.42567.
#> • Final duality gap: 1.425e-05.
#> • Convergence rate of the duality gap: 0.5295 per iteration.
#> • Line search: 15 step reductions, smallest accepted step 0.005049.
#> • Active destinations: from 15 to 13, 2 face changes, the last one at iteration
#> 26.
#> • The final configuration is on a face of the simplex.
```
