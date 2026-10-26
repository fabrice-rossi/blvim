# Plot the runs of a multiple start blvim

Displays the runs of
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
described by
[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md).

## Usage

``` r
# S3 method for class 'blvim_logs'
autoplot(object, type = c("staircase", "scatter"), ...)
```

## Arguments

- object:

  a data frame of class `blvim_logs` produced by
  [`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md)

- type:

  the type of graphical representation, `"staircase"` or `"scatter"`

- ...:

  additional parameters (not used currently)

## Value

a ggplot object

## Details

With `type = "staircase"` (default), the final potentials of the runs
are shown by decreasing value as a function of their rank. Each plateau
corresponds to a final configuration, and its width to the number of
runs that reach it.

With `type = "scatter"`, the final potential of each run is shown as a
function of its number of evaluations (for the gradient algorithms) or
iterations (for the other algorithms).

In both cases, the colour gives the status of the run (see
[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md)).

## See also

[`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md),
[`summary.blvim_logs()`](https://fabrice-rossi.github.io/blvim/reference/summary.blvim_logs.md)

## Examples

``` r
distances <- french_cities_distances[1:15, 1:15] / 1000
production <- rep(1, 15)
set.seed(1)
starts <- blvim_initialise(n = 20)
model <- blvim(distances, production, 1.5, 1 / 50, starts,
  algorithm = "gradient", bipartite = FALSE
)
ggplot2::autoplot(sim_logs(model))

ggplot2::autoplot(sim_logs(model), "scatter")
```
