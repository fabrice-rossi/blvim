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
#> 1        1           1 9.934629e-01
#> 2        2           1 4.758235e-05
#> 3        3           1 3.599678e-03
#> 4        4           1 5.331483e-06
#> 5        5           1 1.784127e-05
#> 6        6           1 5.041930e-04
#> 7        7           1 4.995837e-05
#> 8        8           1 4.762121e-06
#> 9        9           1 5.179469e-05
#> 10      10           1 5.952812e-09
#> 11       1           2 6.512247e-03
#> 12       2           2 9.986429e-01
#> 13       3           2 9.904316e-01
#> 14       4           2 3.692884e-03
#> 15       5           2 1.963306e-01
#> 16       6           2 9.930425e-01
#> 17       7           2 9.827297e-01
#> 18       8           2 1.572764e-02
#> 19       9           2 9.635391e-01
#> 20      10           2 6.193199e-05
#> 21       1           3 2.579574e-16
#> 22       2           3 5.185897e-16
#> 23       3           3 3.395363e-13
#> 24       4           3 3.248358e-16
#> 25       5           3 1.111398e-16
#> 26       6           3 9.971488e-16
#> 27       7           3 6.372109e-16
#> 28       8           3 8.172925e-18
#> 29       9           3 1.949775e-15
#> 30      10           3 5.340187e-19
#> 31       1           4 5.394118e-06
#> 32       2           4 2.729940e-05
#> 33       3           4 4.586189e-03
#> 34       4           4 9.961182e-01
#> 35       5           4 2.487264e-05
#> 36       6           4 2.944421e-05
#> 37       7           4 8.170939e-05
#> 38       8           4 1.172720e-06
#> 39       9           4 1.489159e-03
#> 40      10           4 1.642503e-04
#> 41       1           5 1.443706e-05
#> 42       2           5 1.160797e-03
#> 43       3           5 1.254984e-03
#> 44       4           5 1.989310e-05
#> 45       5           5 7.572885e-01
#> 46       6           5 5.338374e-03
#> 47       7           5 1.586517e-02
#> 48       8           5 3.559950e-02
#> 49       9           5 3.277142e-02
#> 50      10           5 7.450542e-06
#> 51       1           6 8.400590e-69
#> 52       2           6 1.208915e-67
#> 53       3           6 2.318401e-67
#> 54       4           6 4.848868e-70
#> 55       5           6 1.099180e-67
#> 56       6           6 3.146733e-66
#> 57       7           6 2.269769e-67
#> 58       8           6 1.716636e-68
#> 59       9           6 1.468239e-67
#> 60      10           6 8.670399e-72
#> 61       1           7 5.740551e-67
#> 62       2           7 8.250771e-65
#> 63       3           7 1.021749e-64
#> 64       4           7 9.279933e-67
#> 65       5           7 2.252875e-64
#> 66       6           7 1.565360e-64
#> 67       7           7 1.297039e-63
#> 68       8           7 1.385092e-65
#> 69       9           7 7.772355e-64
#> 70      10           7 4.666852e-68
#> 71       1           8 5.014900e-06
#> 72       2           8 1.210153e-04
#> 73       3           8 1.201033e-04
#> 74       4           8 1.220629e-06
#> 75       5           8 4.632897e-02
#> 76       6           8 1.084993e-03
#> 77       7           8 1.269390e-03
#> 78       8           8 9.486661e-01
#> 79       9           8 2.005034e-03
#> 80      10           8 8.896170e-07
#> 81       1           9 2.284044e-48
#> 82       2           9 3.104586e-46
#> 83       3           9 1.199829e-45
#> 84       4           9 6.490643e-47
#> 85       5           9 1.785918e-45
#> 86       6           9 3.886002e-46
#> 87       7           9 2.982816e-45
#> 88       8           9 8.396131e-47
#> 89       9           9 1.074030e-43
#> 90      10           9 6.322049e-48
#> 91       1          10 5.957179e-09
#> 92       2          10 4.528439e-07
#> 93       3          10 7.457455e-06
#> 94       4          10 1.624622e-04
#> 95       5          10 9.214109e-06
#> 96       6          10 5.207684e-07
#> 97       7          10 4.064407e-06
#> 98       8          10 8.453951e-07
#> 99       9          10 1.434687e-04
#> 100     10          10 9.997655e-01
ggplot2::fortify(flows, flows = "destination")
#>   destination         flow
#> A           1 9.977440e-01
#> B           2 5.150711e+00
#> C           3 3.443417e-13
#> D           4 1.002528e+00
#> E           5 8.493205e-01
#> F           6 4.009244e-66
#> G           7 2.656180e-63
#> H           8 9.996027e-01
#> I           9 1.142281e-43
#> J          10 1.000094e+00
ggplot2::fortify(flows, flows = "attractiveness")
#>   destination attractiveness
#> A           1   9.977441e-01
#> B           2   5.150709e+00
#> C           3   2.868542e-09
#> D           4   1.002528e+00
#> E           5   8.493240e-01
#> F           6   3.705056e-44
#> G           7   2.436146e-42
#> H           8   9.996017e-01
#> I           9   1.662452e-29
#> J          10   1.000094e+00
## positions
ggplot2::fortify(flows, flows = "attractiveness", with_positions = TRUE)
#>              X           Y attractiveness
#> 1  -0.93584735 -1.91008747      0.9977441
#> 2  -0.01595031 -0.27923724      5.1507086
#> 4  -1.51239965  1.06730788      1.0025277
#> 5   0.93536319  0.07003485      0.8493240
#> 8   1.62354888 -0.25148344      0.9996017
#> 10 -0.13399701  2.75541758      1.0000940
## names and positions
ggplot2::fortify(flows,
  flows = "destination", with_positions = TRUE,
  with_names = TRUE
)
#>              X           Y destination name
#> 1  -0.93584735 -1.91008747   0.9977440    A
#> 2  -0.01595031 -0.27923724   5.1507111    B
#> 4  -1.51239965  1.06730788   1.0025277    D
#> 5   0.93536319  0.07003485   0.8493205    E
#> 8   1.62354888 -0.25148344   0.9996027    H
#> 10 -0.13399701  2.75541758   1.0000940    J
ggplot2::fortify(flows, with_positions = TRUE, cut_off = 0.1)
#>               X        xend           Y        yend      flow
#> 1   -0.93584735 -0.93584735 -1.91008747 -1.91008747 0.9934629
#> 12  -0.01595031 -0.01595031 -0.27923724 -0.27923724 0.9986429
#> 13  -0.82678895 -0.01595031 -0.31344598 -0.27923724 0.9904316
#> 15   0.93536319 -0.01595031  0.07003485 -0.27923724 0.1963306
#> 16   0.17648861 -0.01595031 -0.63912332 -0.27923724 0.9930425
#> 17   0.24368546 -0.01595031 -0.04996490 -0.27923724 0.9827297
#> 19   0.11203808 -0.01595031  0.44479712 -0.27923724 0.9635391
#> 34  -1.51239965 -1.51239965  1.06730788  1.06730788 0.9961182
#> 45   0.93536319  0.93536319  0.07003485  0.07003485 0.7572885
#> 78   1.62354888  1.62354888 -0.25148344 -0.25148344 0.9486661
#> 100 -0.13399701 -0.13399701  2.75541758  2.75541758 0.9997655
```
