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

A data frame of class `blvim_logs` with one row per starting point and
the following columns:

- `run`: index of the run, from 1 to the number of starting points;

- `potential`: final value of the potential;

- `iterations`: number of iterations;

- `converged`: whether the run converged;

- `status`: stopping status reported by a gradient algorithm;

- `gap`: final duality gap reported by a gradient algorithm;

- `evaluations`: number of evaluations reported by a gradient algorithm;

- `n_active`: number of active destinations of the final configuration;

- `configuration`: identifier of the final configuration (see details);

- `selected`: whether the run is the one returned by
  [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).

The gradient-specific columns are `NA` for the `"linear"` and
`"quadratic"` algorithms.

## Details

The rows are in the same order as the starting points supplied to
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).
Run summaries are retained independently of the value of `keep_runs`.

The final configuration of a run is described by its rescaled
attractivenesses \\U_j = \kappa_j Z_j / \sum_k \kappa_k Z_k\\. A
destination is active when \\U_j \> 10^{-5}\\. Two runs reach the same
configuration when they have the same active destinations and their
rescaled attractivenesses differ by at most \\10^{-3}\\. The
configurations are numbered by decreasing best potential, so that
configuration 1 is the one of the selected run. The number of runs that
reach it measures the reliability of the multiple starts: when it is
reached by a single run, more starting points might find a better one.

The [`summary()`](https://rdrr.io/r/base/summary.html) and
[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
methods of the result (see
[`summary.blvim_logs()`](https://fabrice-rossi.github.io/blvim/reference/summary.blvim_logs.md)
and
[`autoplot.blvim_logs()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.blvim_logs.md))
describe and display these summaries.

See
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
for details on how the nature of `Z` determines the number of runs. Use
[`sim_runs()`](https://fabrice-rossi.github.io/blvim/reference/sim_runs.md)
to extract the complete spatial interaction models produced by the runs
when they are available.

## See also

[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md),
[`sim_runs()`](https://fabrice-rossi.github.io/blvim/reference/sim_runs.md),
[`sim_diagnostic()`](https://fabrice-rossi.github.io/blvim/reference/sim_diagnostic.md),
[`summary.blvim_logs()`](https://fabrice-rossi.github.io/blvim/reference/summary.blvim_logs.md),
[`autoplot.blvim_logs()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.blvim_logs.md)
