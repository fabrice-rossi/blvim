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

  - the first two columns are used for the coordinates of the origin
    locations (see below for the names of the columns)

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
colnames(positions) <- c("X", "Y")
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
flows <- blvim(distances, production, 1.5, 4, attractiveness,
  origin_data =
    list(names = LETTERS[1:10], positions = positions),
  destination_data =
    list(names = LETTERS[1:10], positions = positions)
)
ggplot2::fortify(flows)
#>     origin destination         flow
#> 1        1           1 8.684177e-18
#> 2        2           1 9.702844e-21
#> 3        3           1 6.143433e-23
#> 4        4           1 1.724254e-21
#> 5        5           1 5.298985e-19
#> 6        6           1 5.261332e-20
#> 7        7           1 3.029815e-19
#> 8        8           1 3.233885e-19
#> 9        9           1 3.958795e-22
#> 10      10           1 3.409610e-21
#> 11       1           2 4.829270e-04
#> 12       2           2 8.440174e-01
#> 13       3           2 4.913326e-03
#> 14       4           2 1.258475e-01
#> 15       5           2 2.965233e-04
#> 16       6           2 1.296874e-03
#> 17       7           2 1.409984e-03
#> 18       8           2 2.086181e-04
#> 19       9           2 1.929008e-06
#> 20      10           2 1.204128e-04
#> 21       1           3 2.788413e-06
#> 22       2           3 4.480630e-03
#> 23       3           3 9.777704e-01
#> 24       4           3 1.439862e-02
#> 25       5           3 1.608643e-06
#> 26       6           3 1.128710e-05
#> 27       7           3 8.172019e-06
#> 28       8           3 1.108237e-06
#> 29       9           3 2.427302e-08
#> 30      10           3 1.921207e-06
#> 31       1           4 9.363992e-05
#> 32       2           4 1.373162e-01
#> 33       3           4 1.722799e-02
#> 34       4           4 8.563877e-01
#> 35       5           4 8.068678e-05
#> 36       6           4 6.708754e-04
#> 37       7           4 4.407488e-04
#> 38       8           4 4.815093e-05
#> 39       9           4 1.322861e-06
#> 40      10           4 1.000840e-04
#> 41       1           5 7.486381e-21
#> 42       2           5 8.416969e-23
#> 43       3           5 5.007177e-25
#> 44       4           5 2.099046e-23
#> 45       5           5 7.865390e-20
#> 46       6           5 5.079861e-21
#> 47       7           5 1.926577e-20
#> 48       8           5 4.500911e-21
#> 49       9           5 5.641778e-23
#> 50      10           5 4.451267e-22
#> 51       1           6 2.316254e-03
#> 52       2           6 1.147111e-03
#> 53       3           6 1.094780e-05
#> 54       4           6 5.438417e-04
#> 55       5           6 1.582934e-02
#> 56       6           6 7.926377e-01
#> 57       7           6 6.356631e-02
#> 58       8           6 2.289801e-03
#> 59       9           6 1.108434e-03
#> 60      10           6 4.046669e-02
#> 61       1           7 3.507356e-16
#> 62       2           7 3.279408e-17
#> 63       3           7 2.084237e-19
#> 64       4           7 9.394963e-18
#> 65       5           7 1.578595e-15
#> 66       6           7 1.671477e-15
#> 67       7           7 9.727219e-15
#> 68       8           7 3.493964e-16
#> 69       9           7 5.053414e-18
#> 70      10           7 9.523541e-17
#> 71       1           8 9.969236e-01
#> 72       2           8 1.292132e-02
#> 73       3           8 7.527034e-05
#> 74       4           8 2.733268e-03
#> 75       5           8 9.821061e-01
#> 76       6           8 1.603410e-01
#> 77       7           8 9.304478e-01
#> 78       8           8 9.972900e-01
#> 79       9           8 7.851174e-04
#> 80      10           8 9.733613e-03
#> 81       1           9 1.793687e-05
#> 82       2           9 1.756043e-06
#> 83       3           9 2.423044e-08
#> 84       4           9 1.103667e-06
#> 85       5           9 1.809340e-04
#> 86       6           9 1.140783e-03
#> 87       7           9 1.977902e-04
#> 88       8           9 1.153934e-05
#> 89       9           9 9.865353e-01
#> 90      10           9 1.097400e-02
#> 91       1          10 1.628457e-04
#> 92       2          10 1.155479e-04
#> 93       3          10 2.021621e-06
#> 94       4          10 8.801902e-05
#> 95       5          10 1.504790e-03
#> 96       6          10 4.390144e-02
#> 97       7          10 3.929219e-03
#> 98       8          10 1.508024e-04
#> 99       9          10 1.156785e-02
#> 100     10          10 9.386033e-01
ggplot2::fortify(flows, flows = "destination")
#>   destination         flow
#> A           1 9.908353e-18
#> B           2 9.785955e-01
#> C           3 9.966766e-01
#> D           4 1.012367e+00
#> E           5 1.155940e-19
#> F           6 9.199165e-01
#> G           7 1.382011e-14
#> H           8 4.093357e+00
#> I           9 9.990612e-01
#> J          10 1.000026e+00
ggplot2::fortify(flows, flows = "attractiveness")
#>   destination attractiveness
#> A           1   5.728463e-12
#> B           2   9.785987e-01
#> C           3   9.966767e-01
#> D           4   1.012364e+00
#> E           5   2.886656e-13
#> F           6   9.199165e-01
#> G           7   6.246635e-10
#> H           8   4.093357e+00
#> I           9   9.990612e-01
#> J          10   1.000026e+00
## positions
ggplot2::fortify(flows, flows = "attractiveness", with_positions = TRUE)
#>             X           Y attractiveness
#> 2  -1.3260052  0.09034427      0.9785987
#> 3  -2.3622089  0.90235804      0.9966767
#> 4  -1.4099696  0.54942132      1.0123641
#> 6   0.2958703 -0.03921465      0.9199165
#> 8  -0.1026549 -0.91184962      4.0933570
#> 9   1.9519230  0.15031364      0.9990612
#> 10  0.8785660  0.44035545      1.0000258
## names and positions
ggplot2::fortify(flows,
  flows = "destination", with_positions = TRUE,
  with_names = TRUE
)
#>             X           Y destination name
#> 2  -1.3260052  0.09034427   0.9785955    B
#> 3  -2.3622089  0.90235804   0.9966766    C
#> 4  -1.4099696  0.54942132   1.0123674    D
#> 6   0.2958703 -0.03921465   0.9199165    F
#> 8  -0.1026549 -0.91184962   4.0933571    H
#> 9   1.9519230  0.15031364   0.9990612    I
#> 10  0.8785660  0.44035545   1.0000258    J
ggplot2::fortify(flows, with_positions = TRUE, cut_off = 0.1)
#>               X       xend           Y        yend      flow
#> 12  -1.32600521 -1.3260052  0.09034427  0.09034427 0.8440174
#> 14  -1.40996955 -1.3260052  0.54942132  0.09034427 0.1258475
#> 23  -2.36220890 -2.3622089  0.90235804  0.90235804 0.9777704
#> 32  -1.32600521 -1.4099696  0.09034427  0.54942132 0.1373162
#> 34  -1.40996955 -1.4099696  0.54942132  0.54942132 0.8563877
#> 56   0.29587030  0.2958703 -0.03921465 -0.03921465 0.7926377
#> 71  -0.21826025 -0.1026549 -1.30661693 -0.91184962 0.9969236
#> 75   0.25439714 -0.1026549 -0.86983920 -0.91184962 0.9821061
#> 76   0.29587030 -0.1026549 -0.03921465 -0.91184962 0.1603410
#> 77   0.05678979 -0.1026549 -0.51845168 -0.91184962 0.9304478
#> 78  -0.10265486 -0.1026549 -0.91184962 -0.91184962 0.9972900
#> 89   1.95192303  1.9519230  0.15031364  0.15031364 0.9865353
#> 100  0.87856596  0.8785660  0.44035545  0.44035545 0.9386033
```
