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
#> 1        1           1 8.345262e-01
#> 2        2           1 3.786439e-03
#> 3        3           1 9.329546e-04
#> 4        4           1 6.202561e-03
#> 5        5           1 1.572457e-02
#> 6        6           1 1.612974e-05
#> 7        7           1 2.858734e-06
#> 8        8           1 4.175079e-04
#> 9        9           1 1.281295e-03
#> 10      10           1 1.904526e-04
#> 11       1           2 8.214941e-14
#> 12       2           2 1.361817e-11
#> 13       3           2 1.219442e-13
#> 14       4           2 6.623670e-13
#> 15       5           2 1.304502e-13
#> 16       6           2 1.326952e-17
#> 17       7           2 2.853338e-15
#> 18       8           2 4.716991e-17
#> 19       9           2 1.504729e-13
#> 20      10           2 6.730139e-14
#> 21       1           3 1.646589e-01
#> 22       2           3 9.920023e-01
#> 23       3           3 9.990026e-01
#> 24       4           3 9.934088e-01
#> 25       5           3 9.840745e-01
#> 26       6           3 1.045220e-04
#> 27       7           3 2.954279e-03
#> 28       8           3 8.532038e-05
#> 29       9           3 9.985677e-01
#> 30      10           3 5.615293e-03
#> 31       1           4 6.580945e-15
#> 32       2           4 3.239235e-14
#> 33       3           4 5.972008e-15
#> 34       4           4 6.664989e-14
#> 35       5           4 1.088782e-14
#> 36       6           4 1.158366e-18
#> 37       7           4 2.244660e-17
#> 38       8           4 3.326938e-18
#> 39       9           4 5.983706e-15
#> 40      10           4 2.900437e-16
#> 41       1           5 1.094476e-13
#> 42       2           5 4.185031e-14
#> 43       3           5 3.880884e-14
#> 44       4           5 7.142514e-14
#> 45       5           5 3.064699e-12
#> 46       6           5 3.114464e-16
#> 47       7           5 3.523668e-16
#> 48       8           5 9.842273e-17
#> 49       9           5 1.130976e-13
#> 50      10           5 3.161379e-16
#> 51       1           6 2.093717e-05
#> 52       2           6 7.939120e-07
#> 53       3           6 7.687299e-07
#> 54       4           6 1.417161e-06
#> 55       5           6 5.808265e-05
#> 56       6           6 9.998741e-01
#> 57       7           6 1.594164e-07
#> 58       8           6 5.065358e-06
#> 59       9           6 3.043017e-06
#> 60      10           6 7.403170e-09
#> 61       1           7 3.693117e-06
#> 62       2           7 1.699023e-04
#> 63       3           7 2.162449e-05
#> 64       4           7 2.733082e-05
#> 65       5           7 6.540135e-05
#> 66       6           7 1.586578e-07
#> 67       7           7 9.970395e-01
#> 68       8           7 2.178399e-09
#> 69       9           7 1.007573e-04
#> 70      10           7 3.139840e-06
#> 71       1           8 5.423186e-04
#> 72       2           8 2.824109e-06
#> 73       3           8 6.279394e-07
#> 74       4           8 4.073027e-06
#> 75       5           8 1.836782e-05
#> 76       6           8 5.068848e-06
#> 77       7           8 2.190322e-09
#> 78       8           8 9.994913e-01
#> 79       9           8 9.613065e-07
#> 80      10           8 8.074028e-07
#> 81       1           9 4.421111e-16
#> 82       2           9 2.393134e-15
#> 83       3           9 1.952248e-15
#> 84       4           9 1.945966e-15
#> 85       5           9 5.606709e-15
#> 86       6           9 8.089022e-19
#> 87       7           9 2.691161e-17
#> 88       8           9 2.553609e-19
#> 89       9           9 1.216857e-14
#> 90      10           9 1.225139e-17
#> 91       1          10 2.478982e-04
#> 92       2          10 4.037728e-03
#> 93       3          10 4.141275e-05
#> 94       4          10 3.558219e-04
#> 95       5          10 5.912015e-05
#> 96       6          10 7.423583e-09
#> 97       7          10 3.163550e-06
#> 98       8          10 8.090716e-07
#> 99       9          10 4.621570e-05
#> 100     10          10 9.941903e-01
ggplot2::fortify(flows, flows = "destination")
#>   destination         flow
#> A           1 8.630810e-01
#> B           2 1.483577e-11
#> C           3 5.140474e+00
#> D           4 1.287837e-13
#> E           5 3.440407e-12
#> F           6 9.999644e-01
#> G           7 9.974315e-01
#> H           8 1.000066e+00
#> I           9 2.454896e-14
#> J          10 9.989825e-01
ggplot2::fortify(flows, flows = "attractiveness")
#>   destination attractiveness
#> A           1   8.630829e-01
#> B           2   6.044673e-08
#> C           3   5.140472e+00
#> D           4   3.753013e-09
#> E           5   2.516982e-08
#> F           6   9.999644e-01
#> G           7   9.974316e-01
#> H           8   1.000066e+00
#> I           9   1.464137e-09
#> J          10   9.989825e-01
## positions
ggplot2::fortify(flows, flows = "attractiveness", with_positions = TRUE)
#>              x          y attractiveness
#> 1   0.07003485  0.8620865      0.8630829
#> 3  -0.04996490 -0.2060872      5.1404722
#> 6   2.75541758  0.5498275      0.9999644
#> 7   0.04653138 -2.2741149      0.9974316
#> 8   0.57770907  2.6825572      1.0000663
#> 10 -1.91172049  0.2133557      0.9989825
## names and positions
ggplot2::fortify(flows,
  flows = "destination", with_positions = TRUE,
  with_names = TRUE
)
#>              x          y destination name
#> 1   0.07003485  0.8620865   0.8630810    A
#> 3  -0.04996490 -0.2060872   5.1404743    C
#> 6   2.75541758  0.5498275   0.9999644    F
#> 7   0.04653138 -2.2741149   0.9974315    G
#> 8   0.57770907  2.6825572   1.0000663    H
#> 10 -1.91172049  0.2133557   0.9989825    J
ggplot2::fortify(flows, with_positions = TRUE, cut_off = 0.1)
#>               x        xend           y       yend      flow
#> 1    0.07003485  0.07003485  0.86208648  0.8620865 0.8345262
#> 21   0.07003485 -0.04996490  0.86208648 -0.2060872 0.1646589
#> 22  -0.63912332 -0.04996490 -0.24323674 -0.2060872 0.9920023
#> 23  -0.04996490 -0.04996490 -0.20608719 -0.2060872 0.9990026
#> 24  -0.25148344 -0.04996490  0.01917759 -0.2060872 0.9934088
#> 25   0.44479712 -0.04996490  0.02956075 -0.2060872 0.9840745
#> 29   0.11819487 -0.04996490 -0.36122126 -0.2060872 0.9985677
#> 56   2.75541758  2.75541758  0.54982754  0.5498275 0.9998741
#> 67   0.04653138  0.04653138 -2.27411486 -2.2741149 0.9970395
#> 78   0.57770907  0.57770907  2.68255718  2.6825572 0.9994913
#> 100 -1.91172049 -1.91172049  0.21335575  0.2133557 0.9941903
```
