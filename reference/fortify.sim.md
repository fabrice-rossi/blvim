# Turn a spatial interaction model into a data frame

This function extracts from a spatial interaction model different types
of data frames that can be used to produce graphical representations.
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

  cut-off limit for inclusion of a flow row in the final data frame.

- ...:

  additional parameters, not used currently

## Value

a data frame, see details

## Details

The data frame produced by the method depends on the values of `flows`
and `with_positions`. The general principle is to have one row per flow,
either a single flow from an origin location to a destination location,
or an aggregated flow to a destination location. Flows are stored in one
column of the data frame, while the other columns are used to identify
origin and destination.

If `with_positions` is `FALSE` (default value), data frames are simple.
Depending on `flows`, the function extracts different data frames:

- `"full"`: this is the default case for which the full flow matrix is
  extracted. The data frame has three variables:

  - `origin`: identifies the origin location by its index from 1 to the
    number of origin locations

  - `destination`: identifies the destination location by its index from
    1 to the number of destination locations

  - `flow`: the flow between the corresponding locations It is
    recommended to use
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

- `"attractiveness"`: the data frame also has two or three columns,
  `destination` and `name` as in the previous case and `attractiveness`
  which contains the attractivenesses of the destinations (see
  [`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)).

When the `with_positions` parameter is `TRUE`, the location positions
([`location_positions()`](https://fabrice-rossi.github.io/blvim/reference/location_positions.md))
are used to produce more "geographically informed" extractions. Note
that if no positions are known for the locations, using
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

- `"destination"` and `"attractiveness"` both produce a data frame with
  three or four columns. As when `with_positions` is `FALSE`, one column
  is dedicated either to the incoming flows
  ([`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md))
  for `flows="destination"` (the name of the column is `destination`) or
  to the attractivenesses
  ([`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)),
  in which case its name is `attractiveness`. The other two columns are
  used for the positions of the destination locations. Their names are
  the names of the columns of the positions
  (`colnames(destination_positions(model))`) or `"x"` and `"y"`, when
  such names are not specified. If `with_names` is `TRUE`, a `name`
  column is included and contains the names of the destination
  locations.

In the position-based data frames, rows are excluded from the returned
data frames when the flows they represent are small, i.e. when they are
smaller than the `cut_off` value.

## See also

[`autoplot.sim()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim.md),
[`flows_df()`](https://fabrice-rossi.github.io/blvim/reference/flows_df.md),
[`fortify.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/fortify.sim_list.md)

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
#> 1        1           1 9.833097e-01
#> 2        2           1 6.848593e-01
#> 3        3           1 2.814692e-03
#> 4        4           1 1.124289e-01
#> 5        5           1 2.647889e-02
#> 6        6           1 6.331584e-02
#> 7        7           1 1.918370e-03
#> 8        8           1 8.898581e-01
#> 9        9           1 5.840842e-06
#> 10      10           1 1.445285e-02
#> 11       1           2 2.108188e-18
#> 12       2           2 1.413472e-16
#> 13       3           2 4.666087e-19
#> 14       4           2 7.657238e-18
#> 15       5           2 1.563171e-19
#> 16       6           2 1.549188e-18
#> 17       7           2 2.859948e-19
#> 18       8           2 4.194191e-18
#> 19       9           2 4.271217e-22
#> 20      10           2 3.223217e-19
#> 21       1           3 5.680374e-29
#> 22       2           3 3.059081e-27
#> 23       3           3 1.596299e-25
#> 24       4           3 4.150723e-28
#> 25       5           3 3.793469e-30
#> 26       6           3 1.357866e-27
#> 27       7           3 5.011693e-26
#> 28       8           3 9.078266e-29
#> 29       9           3 4.033729e-31
#> 30      10           3 1.801056e-29
#> 31       1           4 1.127036e-02
#> 32       2           4 2.493584e-01
#> 33       3           4 2.061757e-03
#> 34       4           4 8.638337e-01
#> 35       5           4 6.735341e-03
#> 36       6           4 2.751709e-03
#> 37       7           4 1.056518e-03
#> 38       8           4 6.763866e-02
#> 39       9           4 3.998591e-05
#> 40      10           4 3.183506e-02
#> 41       1           5 1.301624e-03
#> 42       2           5 2.496228e-03
#> 43       3           5 9.240091e-06
#> 44       4           5 3.302825e-03
#> 45       5           5 9.377852e-01
#> 46       6           5 8.437414e-05
#> 47       7           5 5.250892e-06
#> 48       8           5 2.725640e-02
#> 49       9           5 6.387212e-06
#> 50      10           5 2.995800e-02
#> 51       1           6 2.666700e-03
#> 52       2           6 2.119620e-02
#> 53       3           6 2.833823e-03
#> 54       4           6 1.156124e-03
#> 55       5           6 7.229119e-05
#> 56       6           6 9.090343e-01
#> 57       7           6 2.608776e-03
#> 58       8           6 2.424866e-03
#> 59       9           6 7.300925e-08
#> 60      10           6 5.778490e-05
#> 61       1           7 7.664954e-04
#> 62       2           7 3.712165e-02
#> 63       3           7 9.922373e-01
#> 64       4           7 4.211086e-03
#> 65       5           7 4.268000e-05
#> 66       6           7 2.474868e-02
#> 67       7           7 9.943906e-01
#> 68       8           7 1.119299e-03
#> 69       9           7 2.776794e-06
#> 70      10           7 1.701945e-04
#> 71       1           8 3.764829e-26
#> 72       2           8 5.764542e-26
#> 73       3           8 1.903187e-28
#> 74       4           8 2.854695e-26
#> 75       5           8 2.345888e-26
#> 76       6           8 2.435850e-27
#> 77       7           8 1.185206e-28
#> 78       8           8 8.138601e-25
#> 79       9           8 2.771319e-30
#> 80      10           8 1.044560e-26
#> 81       1           9 2.675200e-07
#> 82       2           9 6.355129e-06
#> 83       3           9 9.154642e-07
#> 84       4           9 1.826955e-05
#> 85       5           9 5.951223e-06
#> 86       6           9 7.939566e-08
#> 87       7           9 3.183078e-07
#> 88       8           9 3.000149e-06
#> 89       9           9 9.997810e-01
#> 90      10           9 1.584673e-04
#> 91       1          10 6.848873e-04
#> 92       2          10 4.961890e-03
#> 93       3          10 4.229089e-05
#> 94       4          10 1.504913e-02
#> 95       5          10 2.887970e-02
#> 96       6          10 6.501569e-05
#> 97       7          10 2.018525e-05
#> 98       8          10 1.169969e-02
#> 99       9          10 1.639550e-04
#> 100     10          10 9.233676e-01
ggplot2::fortify(flows, flows = "destination")
#>   destination         flow
#> A           1 2.779442e+00
#> B           2 1.580877e-16
#> C           3 2.147487e-25
#> D           4 1.236582e+00
#> E           5 1.002205e+00
#> F           6 9.420509e-01
#> G           7 2.054811e+00
#> H           8 9.743527e-25
#> I           9 9.999746e-01
#> J          10 9.849344e-01
ggplot2::fortify(flows, flows = "attractiveness")
#>   destination attractiveness
#> A           1   2.779439e+00
#> B           2   2.096818e-11
#> C           3   4.086791e-17
#> D           4   1.236584e+00
#> E           5   1.002206e+00
#> F           6   9.420511e-01
#> G           7   2.054811e+00
#> H           8   9.002305e-17
#> I           9   9.999746e-01
#> J          10   9.849342e-01
## positions
ggplot2::fortify(flows, flows = "attractiveness", with_positions = TRUE)
#>             X          Y attractiveness
#> 1  -0.9039935  0.1168062      2.7794394
#> 4  -0.5642493 -0.6223264      1.2365844
#> 5  -1.8742053 -0.7093635      1.0022056
#> 6  -0.1429047  0.8714454      0.9420511
#> 7   0.7719040  0.1051380      2.0548107
#> 9  -0.2379155 -3.2131885      0.9999746
#> 10 -1.2221933 -1.2756187      0.9849342
## names and positions
ggplot2::fortify(flows,
  flows = "destination", with_positions = TRUE,
  with_names = TRUE
)
#>             X          Y destination name
#> 1  -0.9039935  0.1168062   2.7794423    A
#> 4  -0.5642493 -0.6223264   1.2365815    D
#> 5  -1.8742053 -0.7093635   1.0022055    E
#> 6  -0.1429047  0.8714454   0.9420509    F
#> 7   0.7719040  0.1051380   2.0548107    G
#> 9  -0.2379155 -3.2131885   0.9999746    I
#> 10 -1.2221933 -1.2756187   0.9849344    J
ggplot2::fortify(flows, with_positions = TRUE, cut_off = 0.1)
#>              X       xend           Y       yend      flow
#> 1   -0.9039935 -0.9039935  0.11680621  0.1168062 0.9833097
#> 2   -0.3904184 -0.9039935 -0.13249963  0.1168062 0.6848593
#> 4   -0.5642493 -0.9039935 -0.62232642  0.1168062 0.1124289
#> 8   -1.1591179 -0.9039935 -0.18693527  0.1168062 0.8898581
#> 32  -0.3904184 -0.5642493 -0.13249963 -0.6223264 0.2493584
#> 34  -0.5642493 -0.5642493 -0.62232642 -0.6223264 0.8638337
#> 45  -1.8742053 -1.8742053 -0.70936346 -0.7093635 0.9377852
#> 56  -0.1429047 -0.1429047  0.87144541  0.8714454 0.9090343
#> 63   0.8140634  0.7719040 -0.03368478  0.1051380 0.9922373
#> 67   0.7719040  0.7719040  0.10513802  0.1051380 0.9943906
#> 89  -0.2379155 -0.2379155 -3.21318853 -3.2131885 0.9997810
#> 100 -1.2221933 -1.2221933 -1.27561870 -1.2756187 0.9233676
```
