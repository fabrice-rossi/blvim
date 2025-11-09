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
#> 1        1           1 9.363958e-01
#> 2        2           1 5.512397e-02
#> 3        3           1 1.206557e-03
#> 4        4           1 1.296843e-03
#> 5        5           1 5.786431e-04
#> 6        6           1 4.567323e-03
#> 7        7           1 1.641468e-03
#> 8        8           1 3.283131e-05
#> 9        9           1 2.302359e-05
#> 10      10           1 3.077053e-05
#> 11       1           2 5.461723e-02
#> 12       2           2 9.414542e-01
#> 13       3           2 9.967551e-05
#> 14       4           2 8.458140e-05
#> 15       5           2 1.382951e-04
#> 16       6           2 2.910898e-03
#> 17       7           2 2.359157e-04
#> 18       8           2 2.203771e-06
#> 19       9           2 1.458340e-06
#> 20      10           2 6.980003e-05
#> 21       1           3 1.222071e-03
#> 22       2           3 1.018939e-04
#> 23       3           3 9.141074e-01
#> 24       4           3 2.621905e-03
#> 25       5           3 1.605526e-05
#> 26       6           3 1.884277e-03
#> 27       7           3 7.675235e-02
#> 28       8           3 2.118452e-04
#> 29       9           3 2.119384e-04
#> 30      10           3 7.354367e-08
#> 31       1           4 9.093927e-04
#> 32       2           4 5.986178e-05
#> 33       3           4 1.815232e-03
#> 34       4           4 8.071021e-01
#> 35       5           4 1.975006e-03
#> 36       6           4 2.864014e-05
#> 37       7           4 2.556197e-04
#> 38       8           4 2.034551e-02
#> 39       9           4 1.375795e-02
#> 40      10           4 2.023025e-06
#> 41       1           5 5.426861e-04
#> 42       2           5 1.309048e-04
#> 43       3           5 1.486642e-05
#> 44       4           5 2.641450e-03
#> 45       5           5 9.954067e-01
#> 46       6           5 2.963299e-06
#> 47       7           5 4.545358e-06
#> 48       8           5 4.193536e-04
#> 49       9           5 1.274669e-04
#> 50      10           5 5.920146e-04
#> 51       1           6 4.354675e-03
#> 52       2           6 2.801121e-03
#> 53       3           6 1.773740e-03
#> 54       4           6 3.894083e-05
#> 55       5           6 3.012531e-06
#> 56       6           6 9.740781e-01
#> 57       7           6 1.510499e-02
#> 58       8           6 1.259804e-06
#> 59       9           6 1.135260e-06
#> 60      10           6 2.332195e-07
#> 61       1           7 1.711273e-03
#> 62       2           7 2.482302e-04
#> 63       3           7 7.900049e-02
#> 64       4           7 3.800296e-04
#> 65       5           7 5.052626e-06
#> 66       6           7 1.651632e-02
#> 67       7           7 9.058140e-01
#> 68       8           7 2.136019e-05
#> 69       9           7 2.103401e-05
#> 70      10           7 5.950504e-08
#> 71       1           8 2.357968e-18
#> 72       2           8 1.597449e-19
#> 73       3           8 1.502171e-17
#> 74       4           8 2.083791e-15
#> 75       5           8 3.211383e-17
#> 76       6           8 9.489835e-20
#> 77       7           8 1.471525e-18
#> 78       8           8 6.291643e-14
#> 79       9           8 7.423137e-15
#> 80      10           8 1.955709e-20
#> 81       1           9 2.180733e-04
#> 82       2           9 1.394117e-05
#> 83       3           9 1.981939e-03
#> 84       4           9 1.858314e-01
#> 85       5           9 1.287327e-03
#> 86       6           9 1.127796e-05
#> 87       7           9 1.911017e-04
#> 88       8           9 9.789654e-01
#> 89       9           9 9.858559e-01
#> 90      10           9 8.619352e-07
#> 91       1          10 2.875530e-05
#> 92       2          10 6.583386e-05
#> 93       3          10 6.785462e-08
#> 94       4          10 2.696002e-06
#> 95       5          10 5.898987e-04
#> 96       6          10 2.285881e-07
#> 97       7          10 5.333960e-08
#> 98       8          10 2.544705e-07
#> 99       9          10 8.504095e-08
#> 100     10          10 9.993042e-01
ggplot2::fortify(flows, flows = "destination")
#>   destination         flow
#> A           1 1.000897e+00
#> B           2 9.996143e-01
#> C           3 9.971298e-01
#> D           4 8.462513e-01
#> E           5 9.998830e-01
#> F           6 9.981572e-01
#> G           7 1.003718e+00
#> H           8 7.247460e-14
#> I           9 2.154357e+00
#> J          10 9.999920e-01
ggplot2::fortify(flows, flows = "attractiveness")
#>   destination attractiveness
#> A           1   1.000897e+00
#> B           2   9.996143e-01
#> C           3   9.971298e-01
#> D           4   8.462535e-01
#> E           5   9.998829e-01
#> F           6   9.981572e-01
#> G           7   1.003718e+00
#> H           8   1.674466e-09
#> I           9   2.154355e+00
#> J          10   9.999920e-01
## positions
ggplot2::fortify(flows, flows = "attractiveness", with_positions = TRUE)
#>             x          y attractiveness
#> 1  -0.1740864 -0.3561244      1.0008972
#> 2  -0.2217445 -1.0644642      0.9996143
#> 3  -1.0095287  1.0771165      0.9971298
#> 4   0.4807253  1.1815756      0.8462535
#> 5   1.6044073  0.1983921      0.9998829
#> 6  -1.5150245 -0.4004052      0.9981572
#> 7  -1.4160239  0.6161543      1.0037179
#> 9   0.6241324  1.8846623      2.1543552
#> 10  2.1122773 -1.5886205      0.9999920
## names and positions
ggplot2::fortify(flows,
  flows = "destination", with_positions = TRUE,
  with_names = TRUE
)
#>             x          y destination name
#> 1  -0.1740864 -0.3561244   1.0008973    A
#> 2  -0.2217445 -1.0644642   0.9996143    B
#> 3  -1.0095287  1.0771165   0.9971298    C
#> 4   0.4807253  1.1815756   0.8462513    D
#> 5   1.6044073  0.1983921   0.9998830    E
#> 6  -1.5150245 -0.4004052   0.9981572    F
#> 7  -1.4160239  0.6161543   1.0037178    G
#> 9   0.6241324  1.8846623   2.1543573    I
#> 10  2.1122773 -1.5886205   0.9999920    J
ggplot2::fortify(flows, with_positions = TRUE, cut_off = 0.1)
#>              x       xend          y       yend      flow
#> 1   -0.1740864 -0.1740864 -0.3561244 -0.3561244 0.9363958
#> 12  -0.2217445 -0.2217445 -1.0644642 -1.0644642 0.9414542
#> 23  -1.0095287 -1.0095287  1.0771165  1.0771165 0.9141074
#> 34   0.4807253  0.4807253  1.1815756  1.1815756 0.8071021
#> 45   1.6044073  1.6044073  0.1983921  0.1983921 0.9954067
#> 56  -1.5150245 -1.5150245 -0.4004052 -0.4004052 0.9740781
#> 67  -1.4160239 -1.4160239  0.6161543  0.6161543 0.9058140
#> 84   0.4807253  0.6241324  1.1815756  1.8846623 0.1858314
#> 88   0.8767773  0.6241324  1.9741567  1.8846623 0.9789654
#> 89   0.6241324  0.6241324  1.8846623  1.8846623 0.9858559
#> 100  2.1122773  2.1122773 -1.5886205 -1.5886205 0.9993042
```
