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
#> 1        1           1 9.997707e-01
#> 2        2           1 9.989630e-01
#> 3        3           1 9.911611e-01
#> 4        4           1 1.007465e-04
#> 5        5           1 2.845141e-03
#> 6        6           1 8.219895e-05
#> 7        7           1 9.995040e-01
#> 8        8           1 5.445487e-03
#> 9        9           1 2.074567e-02
#> 10      10           1 9.985474e-01
#> 11       1           2 1.862255e-12
#> 12       2           2 2.088362e-11
#> 13       3           2 3.416977e-12
#> 14       4           2 3.478987e-16
#> 15       5           2 6.735779e-15
#> 16       6           2 9.987186e-16
#> 17       7           2 1.866217e-12
#> 18       8           2 8.764208e-14
#> 19       9           2 1.506882e-13
#> 20      10           2 2.957732e-12
#> 21       1           3 2.750948e-11
#> 22       2           3 5.087336e-11
#> 23       3           3 2.186362e-09
#> 24       4           3 2.126294e-13
#> 25       5           3 2.403616e-13
#> 26       6           3 6.716250e-14
#> 27       7           3 8.018225e-11
#> 28       8           3 2.171495e-13
#> 29       9           3 3.055293e-11
#> 30      10           3 3.611212e-11
#> 31       1           4 7.978645e-07
#> 32       2           4 1.477959e-06
#> 33       3           4 6.067144e-05
#> 34       4           4 9.995140e-01
#> 35       5           4 1.592233e-07
#> 36       6           4 5.061104e-06
#> 37       7           4 3.158879e-06
#> 38       8           4 7.445668e-09
#> 39       9           4 3.839020e-04
#> 40      10           4 1.560742e-06
#> 41       1           5 2.247376e-05
#> 42       2           5 2.854107e-05
#> 43       3           5 6.840677e-05
#> 44       4           5 1.588106e-07
#> 45       5           5 9.971505e-01
#> 46       6           5 2.179451e-09
#> 47       7           5 1.047321e-04
#> 48       8           5 3.162044e-06
#> 49       9           5 1.021307e-06
#> 50      10           5 9.389121e-04
#> 51       1           6 6.516276e-07
#> 52       2           6 4.247042e-06
#> 53       3           6 1.918324e-05
#> 54       4           6 5.066164e-06
#> 55       5           6 2.187299e-09
#> 56       6           6 9.984824e-01
#> 57       7           6 9.977387e-07
#> 58       8           6 8.118999e-07
#> 59       9           6 1.445629e-03
#> 60      10           6 6.699731e-07
#> 61       1           7 3.870823e-12
#> 62       2           7 3.876959e-12
#> 63       3           7 1.118816e-11
#> 64       4           7 1.544730e-15
#> 65       5           7 5.134835e-14
#> 66       6           7 4.874189e-16
#> 67       7           7 2.413131e-11
#> 68       8           7 2.353879e-14
#> 69       9           7 1.676647e-13
#> 70      10           7 1.070538e-11
#> 71       1           8 4.275206e-05
#> 72       2           8 3.690993e-04
#> 73       3           8 6.142440e-05
#> 74       4           8 7.381162e-09
#> 75       5           8 3.142795e-06
#> 76       6           8 8.040621e-07
#> 77       7           8 4.771838e-05
#> 78       8           8 9.945417e-01
#> 79       9           8 8.887747e-06
#> 80      10           8 3.429502e-04
#> 81       1           9 1.626241e-04
#> 82       2           9 6.336462e-04
#> 83       3           9 8.629232e-03
#> 84       4           9 3.799956e-04
#> 85       5           9 1.013542e-06
#> 86       6           9 1.429489e-03
#> 87       7           9 3.393754e-04
#> 88       8           9 8.874192e-06
#> 89       9           9 9.774149e-01
#> 90      10           9 1.684927e-04
#> 91       1          10 1.055029e-11
#> 92       2          10 1.676350e-11
#> 93       3          10 1.374708e-11
#> 94       4          10 2.082225e-15
#> 95       5          10 1.255881e-12
#> 96       6          10 8.929349e-16
#> 97       7          10 2.920647e-11
#> 98       8          10 4.615369e-13
#> 99       9          10 2.271011e-13
#> 100     10          10 5.663349e-10
ggplot2::fortify(flows, flows = "destination")
#>   destination         flow
#> A           1 5.017165e+00
#> B           2 3.123321e-11
#> C           3 2.412330e-09
#> D           4 9.999708e-01
#> E           5 9.983180e-01
#> F           6 9.999597e-01
#> G           7 5.401723e-11
#> H           8 9.954184e-01
#> I           9 9.891676e-01
#> J          10 6.385497e-10
ggplot2::fortify(flows, flows = "attractiveness")
#>   destination attractiveness
#> A           1   5.017162e+00
#> B           2   1.683549e-07
#> C           3   1.952025e-06
#> D           4   9.999708e-01
#> E           5   9.983180e-01
#> F           6   9.999597e-01
#> G           7   2.254209e-07
#> H           8   9.954185e-01
#> I           9   9.891680e-01
#> J          10   9.018186e-07
## positions
ggplot2::fortify(flows, flows = "attractiveness", with_positions = TRUE)
#>             x           y attractiveness
#> 1 -0.04996490 -0.20608719   5.017162e+00
#> 3  0.44479712  0.02956075   1.952025e-06
#> 4  2.75541758  0.54982754   9.999708e-01
#> 5  0.04653138 -2.27411486   9.983180e-01
#> 6  0.57770907  2.68255718   9.999597e-01
#> 8 -1.91172049  0.21335575   9.954185e-01
#> 9  0.86208648  1.07434588   9.891680e-01
## names and positions
ggplot2::fortify(flows,
  flows = "destination", with_positions = TRUE,
  with_names = TRUE
)
#>             x          y destination name
#> 1 -0.04996490 -0.2060872   5.0171654    A
#> 4  2.75541758  0.5498275   0.9999708    D
#> 5  0.04653138 -2.2741149   0.9983180    E
#> 6  0.57770907  2.6825572   0.9999597    F
#> 8 -1.91172049  0.2133557   0.9954184    H
#> 9  0.86208648  1.0743459   0.9891676    I
ggplot2::fortify(flows, with_positions = TRUE, cut_off = 0.1)
#>              x        xend           y       yend      flow
#> 1  -0.04996490 -0.04996490 -0.20608719 -0.2060872 0.9997707
#> 2  -0.25148344 -0.04996490  0.01917759 -0.2060872 0.9989630
#> 3   0.44479712 -0.04996490  0.02956075 -0.2060872 0.9911611
#> 7   0.11819487 -0.04996490 -0.36122126 -0.2060872 0.9995040
#> 10 -0.24323674 -0.04996490 -0.66508825 -0.2060872 0.9985474
#> 34  2.75541758  2.75541758  0.54982754  0.5498275 0.9995140
#> 45  0.04653138  0.04653138 -2.27411486 -2.2741149 0.9971505
#> 56  0.57770907  0.57770907  2.68255718  2.6825572 0.9984824
#> 78 -1.91172049 -1.91172049  0.21335575  0.2133557 0.9945417
#> 89  0.86208648  0.86208648  1.07434588  1.0743459 0.9774149
```
