# Turn a spatial interaction model into a data frame

This function extracts from a spatial interaction model different types
of data frame that can be used to produce graphical representations.
[`autoplot.sim()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim.md)
leverages this function to produce its graphical representations.

## Usage

``` r
# S3 method for class 'sim'
fortify(
  model,
  data,
  flows = c("full", "destination", "attractiveness"),
  with_names = FALSE,
  with_positions = FALSE,
  cut_off = 100 * .Machine$double.eps^0.5,
  ...
)
```

## Arguments

- model:

  a spatial interaction model object

- data:

  not used

- flows:

  `"full"` (default), `"destination"` or `"attractiveness"`, see
  details.

- with_names:

  specifies whether the extracted data frame includes location names
  (`FALSE` by default)

- with_positions:

  specifies whether the extracted data frame is based on location
  positions (`FALSE` by default)

- cut_off:

  cut off limit for inclusion of a flow row in the final data frame.

- ...:

  additional parameters, not used currently

## Value

a data frame, see details

## Details

The data frame produced by the method depends on the values of `flows`
and `with_positions`. The general principal is to have one row per flow,
either a single flow from an origin location to a destination location,
or an aggregated flow to a destination location. Flows are stored in one
column of the data frame, while the other columns are used to identify
origin and destination.

If `with_position` is `FALSE` (default value), data frames are simple.
Depending on `flows`, the function extracts different data frames:

- `"full"`: this is the default case for which the full flow matrix is
  extracted. The data frame has three variables:

  - `origin`: identifies the origin location by its index from 1 to the
    number of origin locations

  - `destination`: identifies the destination location by its index from
    1 to the number of destination locations

  - `flow`: the flow between the corresponding location It is recommend
    to use
    [`flows_df()`](https://fabrice-rossi.github.io/blvim/reference/flows_df.md)
    for more control over the extraction outside of simple graphical
    representations.

- `"destination"`: the data frame has only two or three columns:

  - `destination`: identifies the destination location by its index from
    1 to the number of destination locations

  - `flow`: the incoming flows (see
    [`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md))

  - `name`: the name of the destination location if `with_names` is
    `TRUE`

- `"attractiveness"`: the data frame has also two ot three columns,
  `destination` and `name` as in the previous case and `attractiveness`
  which contains the attractivenesses of the destinations (see
  [`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)).

When the `with_positions` parameter is `TRUE`, the location positions
([`location_positions()`](https://fabrice-rossi.github.io/blvim/reference/location_positions.md))
are used to produce more "geographically informed" extractions. Notice
that if no positions are known for the locations, the use of
`with_positions = TRUE` is an error. Depending on `flows` we have the
following representations:

- `"full"`: this is the default case for which the full flow matrix is
  extracted. Positions for both origin and destination locations are
  needed. The data frame contains five columns:

  - `x` and `y` are used for the coordinates of the origin locations

  - `xend` and `yend` are used for the coordinates of the destination
    locations

  - `flow` is used for the flows

- `"destination"` and `"attractiveness"` produce both a data frame with
  three or four columns. As when `with_positions` is `FALSE`, one column
  is dedicated either to the incoming flows
  ([`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md))
  for `flows="destination"` (the name of the column is `destination`) or
  to the attractivenesses
  ([`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)),
  in which case its name is `attractiveness`. The other two columns are
  used for the positions of the destination locations. Their names are
  the names of the columns of the positions
  (`colnames(destination_location(object))`) or `"x"` and `"y"`, when
  such names are not specified. If `with_names` is `TRUE`, a `name`
  column is included and contains the names of the destination
  locations.

In the position based data frames, rows are excluded from the returned
data frames when the flow they represent are small, i.e. when they are
smaller than the `cut_off` value.

## See also

[`autoplot.sim()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim.md),
[`flows_df()`](https://fabrice-rossi.github.io/blvim/reference/flows_df.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
flows <- blvim(distances, production, 1.5, 4, attractiveness,
  origin_data =
    list(names = LETTERS[1:10], positions = positions), destination_data =
    list(names = LETTERS[1:10], positions = positions)
)
ggplot2::fortify(flows)
#>     origin destination         flow
#> 1        1           1 1.126276e-09
#> 2        2           1 1.005960e-11
#> 3        3           1 5.490404e-11
#> 4        4           1 1.083033e-11
#> 5        5           1 1.053250e-15
#> 6        6           1 2.265462e-13
#> 7        7           1 3.742235e-15
#> 8        8           1 1.241511e-11
#> 9        9           1 5.343271e-12
#> 10      10           1 4.033159e-13
#> 11       1           2 9.952979e-01
#> 12       2           2 9.997702e-01
#> 13       3           2 9.989596e-01
#> 14       4           2 9.911497e-01
#> 15       5           2 1.006464e-04
#> 16       6           2 2.845570e-03
#> 17       7           2 8.211700e-05
#> 18       8           2 9.995033e-01
#> 19       9           2 5.408414e-03
#> 20      10           2 2.071982e-02
#> 21       1           3 2.381601e-13
#> 22       2           3 4.379657e-14
#> 23       3           3 4.911402e-13
#> 24       4           3 8.035968e-14
#> 25       5           3 8.173771e-18
#> 26       6           3 1.584362e-16
#> 27       7           3 2.346449e-17
#> 28       8           3 4.388975e-14
#> 29       9           3 2.047138e-15
#> 30      10           3 3.539475e-15
#> 31       1           4 1.841630e-12
#> 32       2           4 1.703442e-12
#> 33       3           4 3.150172e-12
#> 34       4           4 1.353824e-10
#> 35       5           4 1.315337e-14
#> 36       6           4 1.488593e-14
#> 37       7           4 4.154693e-15
#> 38       8           4 4.965045e-12
#> 39       9           4 1.335480e-14
#> 40      10           4 1.889543e-12
#> 41       1           5 8.269245e-07
#> 42       2           5 7.986572e-07
#> 43       3           5 1.479423e-06
#> 44       4           5 6.073105e-05
#> 45       5           5 9.995140e-01
#> 46       6           5 1.594057e-07
#> 47       7           5 5.061084e-06
#> 48       8           5 3.162017e-06
#> 49       9           5 7.402329e-09
#> 50      10           5 3.838048e-04
#> 51       1           6 1.769986e-04
#> 52       2           6 2.247035e-05
#> 53       3           6 2.853665e-05
#> 54       4           6 6.839563e-05
#> 55       5           6 1.586289e-07
#> 56       6           6 9.971501e-01
#> 57       7           6 2.176948e-09
#> 58       8           6 1.047162e-04
#> 59       9           6 3.140042e-06
#> 60      10           6 1.019880e-06
#> 61       1           7 2.941053e-06
#> 62       2           7 6.522774e-07
#> 63       3           7 4.251265e-06
#> 64       4           7 1.920215e-05
#> 65       5           7 5.066182e-06
#> 66       6           7 2.189811e-09
#> 67       7           7 9.984821e-01
#> 68       8           7 9.987333e-07
#> 69       9           7 8.071770e-07
#> 70      10           7 1.445268e-03
#> 71       1           8 8.260835e-14
#> 72       2           8 6.721792e-14
#> 73       3           8 6.732429e-14
#> 74       4           8 1.942834e-13
#> 75       5           8 2.679804e-17
#> 76       6           8 8.918133e-16
#> 77       7           8 8.455731e-18
#> 78       8           8 4.190468e-13
#> 79       9           8 4.059750e-16
#> 80      10           8 2.907918e-15
#> 81       1           9 4.207747e-03
#> 82       2           9 4.304669e-05
#> 83       3           9 3.716420e-04
#> 84       4           9 6.184704e-05
#> 85       5           9 7.424653e-09
#> 86       6           9 3.164933e-06
#> 87       7           9 8.087967e-07
#> 88       8           9 4.804723e-05
#> 89       9           9 9.945788e-01
#> 90      10           9 8.937853e-06
#> 91       1          10 3.135954e-04
#> 92       2          10 1.628313e-04
#> 93       3          10 6.344517e-04
#> 94       4          10 8.640131e-03
#> 95       5          10 3.801020e-04
#> 96       6          10 1.014986e-06
#> 97       7          10 1.429884e-03
#> 98       8          10 3.398077e-04
#> 99       9          10 8.825010e-06
#> 100     10          10 9.774412e-01
ggplot2::fortify(flows, flows = "destination")
#>   destination         flow
#> A           1 1.220463e-09
#> B           2 5.013837e+00
#> C           3 9.031230e-13
#> D           4 1.489778e-10
#> E           5 9.999701e-01
#> F           6 9.975555e-01
#> G           7 9.999613e-01
#> H           8 8.347218e-13
#> I           9 9.993241e-01
#> J          10 9.893518e-01
ggplot2::fortify(flows, flows = "attractiveness")
#>   destination attractiveness
#> A           1   1.116694e-06
#> B           2   5.013836e+00
#> C           3   1.381035e-08
#> D           4   3.053216e-07
#> E           5   9.999700e-01
#> F           6   9.975555e-01
#> G           7   9.999613e-01
#> H           8   1.510636e-08
#> I           9   9.993241e-01
#> J          10   9.893520e-01
## positions
ggplot2::fortify(flows, flows = "attractiveness", with_positions = TRUE)
#>              x          y attractiveness
#> 2  -0.04996490 -0.2060872      5.0138355
#> 5   2.75541758  0.5498275      0.9999700
#> 6   0.04653138 -2.2741149      0.9975555
#> 7   0.57770907  2.6825572      0.9999613
#> 9  -1.91172049  0.2133557      0.9993241
#> 10  0.86208648  1.0743459      0.9893520
## names and positions
ggplot2::fortify(flows,
  flows = "destination", with_positions = TRUE,
  with_names = TRUE
)
#>              x          y destination name
#> 2  -0.04996490 -0.2060872   5.0138373    B
#> 5   2.75541758  0.5498275   0.9999701    E
#> 6   0.04653138 -2.2741149   0.9975555    F
#> 7   0.57770907  2.6825572   0.9999613    G
#> 9  -1.91172049  0.2133557   0.9993241    I
#> 10  0.86208648  1.0743459   0.9893518    J
ggplot2::fortify(flows, with_positions = TRUE, cut_off = 0.1)
#>               x        xend           y       yend      flow
#> 11  -0.63912332 -0.04996490 -0.24323674 -0.2060872 0.9952979
#> 12  -0.04996490 -0.04996490 -0.20608719 -0.2060872 0.9997702
#> 13  -0.25148344 -0.04996490  0.01917759 -0.2060872 0.9989596
#> 14   0.44479712 -0.04996490  0.02956075 -0.2060872 0.9911497
#> 18   0.11819487 -0.04996490 -0.36122126 -0.2060872 0.9995033
#> 45   2.75541758  2.75541758  0.54982754  0.5498275 0.9995140
#> 56   0.04653138  0.04653138 -2.27411486 -2.2741149 0.9971501
#> 67   0.57770907  0.57770907  2.68255718  2.6825572 0.9984821
#> 89  -1.91172049 -1.91172049  0.21335575  0.2133557 0.9945788
#> 100  0.86208648  0.86208648  1.07434588  1.0743459 0.9774412
```
