# Create a complete ggplot for spatial interaction models in a data frame

This function combines spatial interaction model representations similar
to the ones produced by
[`autoplot.sim()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim.md)
into a single ggplot. It provides an alternative graphical
representation to the one produced by
[`autoplot.sim_df()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_df.md)
for collection of spatial interaction models in a `sim_df` object.

## Usage

``` r
grid_autoplot(
  sim_df,
  key,
  flows = c("full", "destination", "attractiveness"),
  with_names = FALSE,
  with_positions = FALSE,
  show_destination = FALSE,
  show_attractiveness = FALSE,
  show_production = FALSE,
  cut_off = 100 * .Machine$double.eps^0.5,
  adjust_limits = FALSE,
  with_labels = FALSE,
  max_sims = 25,
  fw_params = NULL,
  ...
)
```

## Arguments

- sim_df:

  a data frame of spatial interaction models, an object of class
  `sim_df`

- key:

  the wrapping variable which acts as an identifier for spatial
  interaction models

- flows:

  `"full"` (default), `"destination"` or `"attractiveness"`, see
  details.

- with_names:

  specifies whether the graphical representation includes location names
  (`FALSE` by default)

- with_positions:

  specifies whether the graphical representation is based on location
  positions (`FALSE` by default)

- show_destination:

  specifies whether the position based `"full"` flow figure includes a
  representation of the destination flows (`FALSE` by default)

- show_attractiveness:

  specifies whether the position based `"full"` flow figure includes a
  representation of the attractivenesses (`FALSE` by default)

- show_production:

  specifies whether the position based `"full"` flow figure includes a
  representation of the productions (`FALSE` by default)

- cut_off:

  cut off limit for inclusion of a graphical primitive when
  `with_positions = TRUE`. In the full flow matrix representation,
  segments are removed when their flow is smaller than the cut off. In
  the attractiveness or destination representation, disks are removed
  when the corresponding value is below the cut off.

- adjust_limits:

  if `FALSE` (default value), the limits of the position based graph are
  not adjusted after removing graphical primitives. This eases
  comparison between graphical representations with different cut off
  value. If `TRUE`, limits are adjusted to the data using the standard
  ggplot2 behaviour.

- with_labels:

  if `FALSE` (default value) names are displayed using plain texts. If
  `TRUE`, names are shown using labels.

- max_sims:

  the maximum number of spatial interaction models allowed in the
  `sim_df` data frame

- fw_params:

  parameters for the
  [ggplot2::facet_wrap](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
  call (if non `NULL`)

- ...:

  additional (named) parameters passed to
  [`autoplot.sim()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim.md)

## Value

a ggplot object

## Details

The rationale of
[`autoplot.sim_df()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_df.md)
is to display a single value for each spatial interaction model (SIM) in
the `sim_df` data frame. On the contrary, this function produces a full
graphical representation of each SIM. It is therefore limited to small
collection of SIMs (as specified by the `max_sims` parameter which
default to 25).

Under the hood, the function uses
[`fortify.sim()`](https://fabrice-rossi.github.io/blvim/reference/fortify.sim.md)
and shares code with
[`autoplot.sim()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim.md)
to have identical representations. It is simply based on facet wrapping
facility of ggplot2. In particular the `key` parameter is used as the
wrapping variable in the call to
[`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html).
If not specified, the function generates an `id` variable which ranges
from 1 to the number of SIMs in the `sim_df` data frame. If specified,
it is evaluated in the context of the data frame and used for wrapping.
Notice that if the expression evaluates to identical values for
different SIMs, they will be drawn on the same panel of the final
figure, which may end up with meaningless representations. Parameters of
[`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
can be set using the `fw_params` parameter (in a list).

## Examples

``` r
positions <- as.matrix(french_cities[1:10, c("th_longitude", "th_latitude")])
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
all_flows <- grid_blvim(distances, production, seq(1.05, 1.35, by = 0.1),
  seq(1, 2.5, by = 0.5) / 400,
  attractiveness,
  bipartite = FALSE,
  epsilon = 0.1, iter_max = 1000,
  destination_data = list(
    names = french_cities$name[1:10],
    positions = positions
  ),
  origin_data = list(
    names = french_cities$name[1:10],
    positions = positions
  )
)
all_flows_df <- sim_df(all_flows)
## default display: flows as matrices
grid_autoplot(all_flows_df)

## custom wrapping variable
grid_autoplot(all_flows_df, paste(alpha, "~", beta))

## bar plots
grid_autoplot(all_flows_df, flows = "attractiveness")

## with positions
grid_autoplot(all_flows_df, with_positions = TRUE, show_destination = TRUE) +
  ggplot2::scale_linewidth_continuous(range = c(0, 1)) +
  ggplot2::scale_size_continuous(range = c(0, 2)) +
  ggplot2::coord_sf(crs = "epsg:4326")
```
