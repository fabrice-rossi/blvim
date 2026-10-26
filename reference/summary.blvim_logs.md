# Summary of the runs of a multiple start blvim

Summarises the runs of
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
described by
[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md):
convergence of the runs, cost of the runs, and distinct final
configurations reached by the runs.

## Usage

``` r
# S3 method for class 'blvim_logs'
summary(object, ...)

# S3 method for class 'summary_blvim_logs'
print(x, ...)
```

## Arguments

- object:

  a data frame of class `blvim_logs` produced by
  [`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md)

- ...:

  additional parameters (not used currently)

- x:

  an object of class `summary_blvim_logs` produced by
  `summary.blvim_logs()`

## Value

an object of class `summary_blvim_logs` and `list` with the following
elements:

- `n_runs`: number of runs;

- `n_converged`: number of runs that converged;

- `status`: number of runs for each status reported by the gradient
  algorithms (`NULL` for the other algorithms);

- `iterations`, `evaluations`: minimum, median and maximum number of
  iterations and of evaluations of the runs (`evaluations` is `NULL` for
  algorithms that do not report it);

- `max_gap`: largest final duality gap of the converged runs (`NA` when
  not reported);

- `configurations`: a data frame with one row per final configuration,
  by decreasing potential, with columns `configuration`, `potential`
  (best potential of its runs), `n_active`, `runs` (number of runs
  reaching it), `share` (proportion of the runs) and `converged` (number
  of converged runs reaching it);

- `selected_converged`: whether the selected run converged.

## Details

The final configurations are identified as explained in
[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md).
The number of runs that reach the configuration of the selected run (the
best one) measures the reliability of the multiple starts. When this
configuration is reached by a single run, a better one might have been
missed and more starting points are advisable.

## See also

[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md),
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
[`autoplot.blvim_logs()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.blvim_logs.md)

## Examples

``` r
distances <- french_cities_distances[1:15, 1:15] / 1000
production <- rep(1, 15)
set.seed(1)
starts <- blvim_initialise(n = 20)
model <- blvim(distances, production, 1.5, 1 / 50, starts,
  algorithm = "gradient", bipartite = FALSE
)
summary(sim_logs(model))
#> 
#> ── Summary of 20 runs of blvim ──
#> 
#> • 20 of 20 runs converged.
#> • Status: converged (20).
#> • Iterations: median 22, range [16, 68].
#> • Evaluations: median 34, range [25, 91].
#> • Largest duality gap of the converged runs: 1.574e-05.
#> 
#> ── Final configurations 
#> 16 distinct configurations. The best one (potential -13.42567, 13 active
#> destinations) was reached by 3 of 20 runs.
#> The second best potential is -13.42744 (difference 0.001761).
#>  configuration potential n_active runs share converged
#>              1  -13.4257       13    3  0.15         3
#>              2  -13.4274       13    1  0.05         1
#>              3  -13.4328       13    2  0.10         2
#>              4  -13.4334       13    1  0.05         1
#>              5  -13.6183       12    1  0.05         1
#> ... and 11 more.
```
