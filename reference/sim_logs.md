# Extract summaries of individual algorithm runs

Extracts the summary information recorded for the individual algorithm
runs performed by
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).

## Usage

``` r
sim_logs(sim)
```

## Arguments

- sim:

  A spatial interaction model object produced by
  [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
  i.e. an object of class `sim` and `sim_blvim`

## Value

A data frame with one row per starting point and the following columns:

- `run`: index of the run from 1 to number of initial point;

- `potential`: final value of the potential;

- `iterations`: number of iterations;

- `converged`: whether the run converged;

- `status`: stopping status reported by a gradient algorithm;

- `gap`: final duality gap reported by a gradient algorithm;

- `evaluations`: number of evaluations reported by a gradient algorithm.

The gradient-specific columns are `NA` for the `"linear"` and
`"quadratic"` algorithms.

## Details

The rows are in the same order as the starting points supplied to
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).
Run summaries are retained independently of the value of `keep_runs`.

See
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
for details on how the nature of `Z` determines the number of runs. Use
[`sim_runs()`](https://fabrice-rossi.github.io/blvim/reference/sim_runs.md)
to extract the complete spatial interaction models produced by the runs
when they are available.

## See also

[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
[`sim_runs()`](https://fabrice-rossi.github.io/blvim/reference/sim_runs.md),
[`sim_diagnostic()`](https://fabrice-rossi.github.io/blvim/reference/sim_diagnostic.md)
