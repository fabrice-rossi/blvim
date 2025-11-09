# Turn a collection of spatial interaction models into a data frame

This function extracts from a collection of spatial interaction models
(represented by a `sim_list`) a data frame in a long format, with one
flow per row. This can be seen a collection oriented version of
[`fortify.sim()`](https://fabrice-rossi.github.io/blvim/reference/fortify.sim.md).
The resulting data frame is used by
[`autoplot.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_list.md)
to produce summary graphics.

## Usage

``` r
# S3 method for class 'sim_list'
fortify(
  model,
  data,
  flows = c("full", "destination", "attractiveness"),
  with_names = FALSE,
  normalisation = c("origin", "full", "none"),
  ...
)
```

## Arguments

- model:

  a collection of spatial interaction models, a `sim_list`

- data:

  not used

- flows:

  `"full"` (default), `"destination"` or `"attractiveness"`, see
  details.

- with_names:

  specifies whether the extracted data frame includes location names
  (`FALSE` by default), see details.

- normalisation:

  when `flows="full"`, the flows can be reported without normalisation
  (`normalisation="none"`) or they can be normalised, either to sum to
  one for each origin location (`normalisation="origin"`, the default
  value) or to sum to one globally (`normalisation="full"`).

- ...:

  additional parameters, not used currently

## Details

The data frame produced by the method depends on the values of `flows`
and to a lesser extent on the value of `with_names`. In all cases, the
data frame has a `configuration` column that identify from which spatial
interaction model the other values have been extracted: this is the
index of the model in the original `sim_list`. Depending on `flows` we
have the following representations:

- if `flows="full"`: this is the default case for which the full flow
  matrix of each spatial interaction model is extracted. The data frame
  contains 4 columns:

  - `origin_idx`: identifies the origin location by its index from 1 to
    the number of origin locations

  - `destination_idx`: identifies the destination location by its index
    from 1 to the number of destination locations

  - `flow`: the flow between the corresponding location. By default,
    flows are normalised by origin location (when
    `normalisation="origin"`): the total flows originating from each
    origin location is normalised to 1. If `normalisation="full"`, this
    normalisation is global: the sum of all flows in each model is
    normalised to 1. If `normalisation="none"` flows are not normalised.

  - `configuration`: the spatial interaction model index

- if `flows="destination"` or `flows="attractiveness"`, the data frame
  contains 3 or 4 columns:

  - `destination`: identifies the destination location by its index from
    1 to the number of destination locations

  - `flow` or `attractiveness` depending on the value of `"flows"`: this
    contains either the
    [`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)
    or the
    [`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)
    of the destination location

  - `configuration`: the spatial interaction model index

  - `name`: the destination location names if `with_names=TRUE` (the
    column is not present if `with_names=FALSE`)

The normalisation operated when `flows="full"` can improve the
readability of the graphical representation proposed in
[`autoplot.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_list.md)
when the production constraints differ significantly from one origin
location to another.

## See also

[`autoplot.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_list.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
flows_1 <- blvim(distances, production, 1.5, 1, attractiveness)
flows_2 <- blvim(distances, production, 1.25, 2, attractiveness)
all_flows <- sim_list(list(flows_1, flows_2))
ggplot2::fortify(all_flows) ## somewhat similar to a row bind of sim_df results
#>     origin_idx destination_idx         flow configuration
#> 1            1               1 1.000000e+00             1
#> 2            2               1 1.000000e+00             1
#> 3            3               1 1.000000e+00             1
#> 4            4               1 1.000000e+00             1
#> 5            5               1 1.000000e+00             1
#> 6            6               1 1.000000e+00             1
#> 7            7               1 1.000000e+00             1
#> 8            8               1 1.000000e+00             1
#> 9            9               1 1.000000e+00             1
#> 10          10               1 1.000000e+00             1
#> 11           1               2 4.908732e-15             1
#> 12           2               2 3.065194e-13             1
#> 13           3               2 4.952635e-15             1
#> 14           4               2 2.125136e-13             1
#> 15           5               2 1.721903e-14             1
#> 16           6               2 1.180991e-13             1
#> 17           7               2 6.865051e-14             1
#> 18           8               2 6.100038e-15             1
#> 19           9               2 6.425110e-14             1
#> 20          10               2 1.769736e-13             1
#> 21           1               3 1.796322e-18             1
#> 22           2               3 1.812388e-18             1
#> 23           3               3 7.349823e-18             1
#> 24           4               3 1.899211e-18             1
#> 25           5               3 2.873487e-18             1
#> 26           6               3 1.863480e-18             1
#> 27           7               3 1.886538e-18             1
#> 28           8               3 1.801946e-18             1
#> 29           9               3 1.808961e-18             1
#> 30          10               3 1.796616e-18             1
#> 31           1               4 5.225295e-18             1
#> 32           2               4 2.262186e-16             1
#> 33           3               4 5.524588e-18             1
#> 34           4               4 5.986791e-16             1
#> 35           5               4 1.334170e-17             1
#> 36           6               4 8.860709e-17             1
#> 37           7               4 8.442193e-17             1
#> 38           8               4 6.382049e-18             1
#> 39           9               4 5.154620e-17             1
#> 40          10               4 1.306361e-16             1
#> 41           1               5 2.330369e-18             1
#> 42           2               5 8.174555e-18             1
#> 43           3               5 3.727775e-18             1
#> 44           4               5 5.950110e-18             1
#> 45           5               5 1.847528e-16             1
#> 46           6               5 2.408686e-17             1
#> 47           7               5 4.655197e-18             1
#> 48           8               5 2.737105e-18             1
#> 49           9               5 9.965047e-18             1
#> 50          10               5 1.085846e-17             1
#> 51           1               6 5.803502e-18             1
#> 52           2               6 1.396264e-16             1
#> 53           3               6 6.020474e-18             1
#> 54           4               6 9.841194e-17             1
#> 55           5               6 5.998542e-17             1
#> 56           6               6 6.380743e-16             1
#> 57           7               6 4.282736e-17             1
#> 58           8               6 7.288181e-18             1
#> 59           9               6 9.002533e-17             1
#> 60          10               6 1.863636e-16             1
#> 61           1               7 3.942443e-17             1
#> 62           2               7 5.513660e-16             1
#> 63           3               7 4.140443e-17             1
#> 64           4               7 6.369567e-16             1
#> 65           5               7 7.875512e-17             1
#> 66           6               7 2.909354e-16             1
#> 67           7               7 6.369771e-16             1
#> 68           8               7 4.809179e-17             1
#> 69           9               7 2.704393e-16             1
#> 70          10               7 4.236061e-16             1
#> 71           1               8 1.350686e-17             1
#> 72           2               8 1.678486e-17             1
#> 73           3               8 1.354915e-17             1
#> 74           4               8 1.649695e-17             1
#> 75           5               8 1.586431e-17             1
#> 76           6               8 1.696225e-17             1
#> 77           7               8 1.647631e-17             1
#> 78           8               8 1.697605e-17             1
#> 79           9               8 1.696937e-17             1
#> 80          10               8 1.692310e-17             1
#> 81           1               9 4.985272e-16             1
#> 82           2               9 6.525295e-15             1
#> 83           3               9 5.020348e-16             1
#> 84           4               9 4.917843e-15             1
#> 85           5               9 2.131786e-15             1
#> 86           6               9 7.733275e-15             1
#> 87           7               9 3.419742e-15             1
#> 88           8               9 6.263255e-16             1
#> 89           9               9 8.248401e-15             1
#> 90          10               9 7.831046e-15             1
#> 91           1              10 2.577914e-11             1
#> 92           2              10 9.294104e-10             1
#> 93           3              10 2.578335e-11             1
#> 94           4              10 6.444968e-10             1
#> 95           5              10 1.201190e-10             1
#> 96           6              10 8.278266e-10             1
#> 97           7              10 2.769907e-10             1
#> 98           8              10 3.229935e-11             1
#> 99           9              10 4.049480e-10             1
#> 100         10              10 1.281072e-09             1
#> 101          1               1 9.574463e-01             2
#> 102          2               1 1.804980e-02             2
#> 103          3               1 9.537107e-01             2
#> 104          4               1 3.681623e-02             2
#> 105          5               1 5.450179e-02             2
#> 106          6               1 2.251550e-02             2
#> 107          7               1 1.712434e-01             2
#> 108          8               1 9.352148e-01             2
#> 109          9               1 8.795580e-02             2
#> 110         10               1 9.582684e-03             2
#> 111          1               2 1.026989e-10             2
#> 112          2               2 7.549200e-09             2
#> 113          3               2 1.041363e-10             2
#> 114          4               2 7.401602e-09             2
#> 115          5               2 7.193514e-11             2
#> 116          6               2 1.397938e-09             2
#> 117          7               2 3.592645e-09             2
#> 118          8               2 1.549135e-10             2
#> 119          9               2 1.616361e-09             2
#> 120         10               2 1.336032e-09             2
#> 121          1               3 5.515828e-18             2
#> 122          2               3 1.058529e-19             2
#> 123          3               3 9.198103e-17             2
#> 124          4               3 2.370902e-19             2
#> 125          5               3 8.034467e-19             2
#> 126          6               3 1.395915e-19             2
#> 127          7               3 1.088110e-18             2
#> 128          8               3 5.421544e-18             2
#> 129          9               3 5.138669e-19             2
#> 130         10               3 5.522368e-20             2
#> 131          1               4 1.298304e-16             2
#> 132          2               4 4.587427e-15             2
#> 133          3               4 1.445628e-16             2
#> 134          4               4 6.553415e-14             2
#> 135          5               4 4.818073e-17             2
#> 136          6               4 8.779278e-16             2
#> 137          7               4 6.061285e-15             2
#> 138          8               4 1.891785e-16             2
#> 139          9               4 1.160641e-15             2
#> 140         10               4 8.121831e-16             2
#> 141          1               5 2.504260e-03             2
#> 142          2               5 5.809198e-04             2
#> 143          3               5 6.383100e-03             2
#> 144          4               5 6.277764e-04             2
#> 145          5               5 8.960011e-01             2
#> 146          6               5 6.291553e-03             2
#> 147          7               5 1.787334e-03             2
#> 148          8               5 3.374505e-03             2
#> 149          9               5 4.206674e-03             2
#> 150         10               5 5.441755e-04             2
#> 151          1               6 4.556124e-17             2
#> 152          2               6 4.971737e-16             2
#> 153          3               6 4.884035e-17             2
#> 154          4               6 5.037738e-16             2
#> 155          5               6 2.770786e-16             2
#> 156          6               6 1.295165e-14             2
#> 157          7               6 4.437693e-16             2
#> 158          8               6 7.018600e-17             2
#> 159          9               6 1.007151e-15             2
#> 160         10               6 4.702299e-16             2
#> 161          1               7 5.682681e-16             2
#> 162          2               7 2.095367e-15             2
#> 163          3               7 6.243358e-16             2
#> 164          4               7 5.703836e-15             2
#> 165          5               7 1.290852e-16             2
#> 166          6               7 7.277510e-16             2
#> 167          7               7 2.653197e-14             2
#> 168          8               7 8.259641e-16             2
#> 169          9               7 2.456474e-15             2
#> 170         10               7 6.566283e-16             2
#> 171          1               8 2.228188e-19             2
#> 172          2               8 6.486885e-21             2
#> 173          3               8 2.233415e-19             2
#> 174          4               8 1.278131e-20             2
#> 175          5               8 1.749774e-20             2
#> 176          6               8 8.263750e-21             2
#> 177          7               8 5.930104e-20             2
#> 178          8               8 3.438059e-19             2
#> 179          9               8 3.230907e-20             2
#> 180         10               8 3.500866e-21             2
#> 181          1               9 1.073045e-16             2
#> 182          2               9 3.465759e-16             2
#> 183          3               9 1.083952e-16             2
#> 184          4               9 4.015266e-16             2
#> 185          5               9 1.116924e-16             2
#> 186          6               9 6.072035e-16             2
#> 187          7               9 9.030800e-16             2
#> 188          8               9 1.654388e-16             2
#> 189          9               9 2.698546e-15             2
#> 190         10               9 2.650040e-16             2
#> 191          1              10 4.004943e-02             2
#> 192          2              10 9.813693e-01             2
#> 193          3              10 3.990620e-02             2
#> 194          4              10 9.625560e-01             2
#> 195          5              10 4.949707e-02             2
#> 196          6              10 9.711929e-01             2
#> 197          7              10 8.269692e-01             2
#> 198          8              10 6.141071e-02             2
#> 199          9              10 9.078375e-01             2
#> 200         10              10 9.898731e-01             2
ggplot2::fortify(all_flows, flows = "destination")
#>    destination         flow configuration
#> 1            1 1.000000e+01             1
#> 2            1 3.247037e+00             2
#> 3            2 9.801878e-13             1
#> 4            2 2.332746e-08             2
#> 5            3 2.488877e-17             1
#> 6            3 1.058616e-16             2
#> 7            4 1.210583e-15             1
#> 8            4 7.954536e-14             2
#> 9            5 2.572383e-16             1
#> 10           5 9.223014e-01             2
#> 11           6 1.274427e-15             1
#> 12           6 1.631541e-14             2
#> 13           7 3.017956e-15             1
#> 14           7 4.031968e-14             2
#> 15           8 1.605092e-16             1
#> 16           8 9.301070e-19             2
#> 17           9 4.243427e-14             1
#> 18           9 5.714766e-15             2
#> 19          10 4.568725e-09             1
#> 20          10 5.830662e+00             2
destination_names(all_flows) <- letters[1:10]
ggplot2::fortify(all_flows, flows = "attractiveness", with_names = TRUE)
#>    destination attractiveness configuration name
#> 1            1   9.999997e+00             1    a
#> 2            1   3.247041e+00             2    a
#> 3            2   1.134430e-08             1    b
#> 4            2   9.289324e-07             2    b
#> 5            3   2.339854e-11             1    c
#> 6            3   1.603382e-13             2    c
#> 7            4   1.447894e-10             1    d
#> 8            4   2.885433e-11             2    d
#> 9            5   7.475501e-11             1    e
#> 10           5   9.223014e-01             2    e
#> 11           6   1.531636e-10             1    f
#> 12           6   1.207977e-11             2    f
#> 13           7   2.899111e-10             1    g
#> 14           7   1.961416e-11             2    g
#> 15           8   6.059434e-11             1    h
#> 16           8   4.786517e-15             2    h
#> 17           9   1.586066e-09             1    i
#> 18           9   5.268357e-12             2    i
#> 19          10   3.176303e-06             1    j
#> 20          10   5.830657e+00             2    j
```
