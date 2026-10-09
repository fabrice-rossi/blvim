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
  normalisation = c("none", "origin", "full"),
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
  (`normalisation="none"`, the default value) or they can be normalised,
  either to sum to one for each origin location
  (`normalisation="origin"`) or to sum to one globally
  (`normalisation="full"`).

- ...:

  additional parameters, not used currently

## Value

a data frame, see details

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
#> 1            1               1 3.155229e-09             1
#> 2            2               1 3.685412e-11             1
#> 3            3               1 9.279274e-11             1
#> 4            4               1 6.075743e-11             1
#> 5            5               1 3.267317e-11             1
#> 6            6               1 3.227124e-11             1
#> 7            7               1 3.136417e-09             1
#> 8            8               1 1.768661e-10             1
#> 9            9               1 3.491225e-11             1
#> 10          10               1 3.892352e-11             1
#> 11           1               2 3.243080e-11             1
#> 12           2               2 3.806170e-11             1
#> 13           3               2 2.950296e-11             1
#> 14           4               2 3.805814e-11             1
#> 15           5               2 3.374265e-11             1
#> 16           6               2 2.839797e-11             1
#> 17           7               2 3.234619e-11             1
#> 18           8               2 2.885297e-11             1
#> 19           9               2 3.057205e-11             1
#> 20          10               2 2.997996e-11             1
#> 21           1               3 2.676962e-13             1
#> 22           2               3 9.672130e-14             1
#> 23           3               3 3.227362e-13             1
#> 24           4               3 1.052386e-13             1
#> 25           5               3 9.821583e-14             1
#> 26           6               3 9.309874e-14             1
#> 27           7               3 2.714580e-13             1
#> 28           8               3 3.050959e-13             1
#> 29           9               3 1.195570e-13             1
#> 30          10               3 1.352828e-13             1
#> 31           1               4 1.168412e-14             1
#> 32           2               4 8.317113e-15             1
#> 33           3               4 7.015259e-15             1
#> 34           4               4 2.984358e-14             1
#> 35           5               4 1.234694e-14             1
#> 36           6               4 6.206008e-15             1
#> 37           7               4 1.162036e-14             1
#> 38           8               4 6.646045e-15             1
#> 39           9               4 7.866234e-15             1
#> 40          10               4 7.502569e-15             1
#> 41           1               5 5.495332e-15             1
#> 42           2               5 6.449264e-15             1
#> 43           3               5 5.726061e-15             1
#> 44           4               5 1.079855e-14             1
#> 45           5               5 5.622313e-14             1
#> 46           6               5 5.427731e-15             1
#> 47           7               5 5.482123e-15             1
#> 48           8               5 6.741385e-15             1
#> 49           9               5 1.934080e-14             1
#> 50          10               5 2.115401e-14             1
#> 51           1               6 1.000000e+00             1
#> 52           2               6 1.000000e+00             1
#> 53           3               6 1.000000e+00             1
#> 54           4               6 1.000000e+00             1
#> 55           5               6 1.000000e+00             1
#> 56           6               6 1.000000e+00             1
#> 57           7               6 1.000000e+00             1
#> 58           8               6 1.000000e+00             1
#> 59           9               6 1.000000e+00             1
#> 60          10               6 1.000000e+00             1
#> 61           1               7 3.195576e-14             1
#> 62           2               7 3.745131e-16             1
#> 63           3               7 9.587159e-16             1
#> 64           4               7 6.156564e-16             1
#> 65           5               7 3.320944e-16             1
#> 66           6               7 3.287994e-16             1
#> 67           7               7 4.773232e-14             1
#> 68           8               7 1.919536e-15             1
#> 69           9               7 3.586517e-16             1
#> 70          10               7 4.031445e-16             1
#> 71           1               8 1.480274e-14             1
#> 72           2               8 2.744204e-15             1
#> 73           3               8 8.851272e-15             1
#> 74           4               8 2.892438e-15             1
#> 75           5               8 3.354624e-15             1
#> 76           6               8 2.700929e-15             1
#> 77           7               8 1.576806e-14             1
#> 78           8               8 4.121466e-14             1
#> 79           9               8 4.774361e-15             1
#> 80          10               8 6.475068e-15             1
#> 81           1               9 4.228324e-13             1
#> 82           2               9 4.207686e-13             1
#> 83           3               9 5.019229e-13             1
#> 84           4               9 4.954052e-13             1
#> 85           5               9 1.392714e-12             1
#> 86           6               9 3.908463e-13             1
#> 87           7               9 4.263318e-13             1
#> 88           8               9 6.908888e-13             1
#> 89           9               9 2.116825e-12             1
#> 90          10               9 2.017094e-12             1
#> 91           1              10 1.286495e-14             1
#> 92           2              10 1.126044e-14             1
#> 93           3              10 1.549924e-14             1
#> 94           4              10 1.289464e-14             1
#> 95           5              10 4.157056e-14             1
#> 96           6              10 1.066624e-14             1
#> 97           7              10 1.307800e-14             1
#> 98           8              10 2.557071e-14             1
#> 99           9              10 5.504674e-14             1
#> 100         10              10 1.156532e-13             1
#> 101          1               1 9.440261e-01             2
#> 102          2               1 2.295677e-03             2
#> 103          3               1 1.437724e-02             2
#> 104          4               1 6.214816e-03             2
#> 105          5               1 1.805239e-03             2
#> 106          6               1 1.761176e-03             2
#> 107          7               1 9.433908e-01             2
#> 108          8               1 5.032693e-02             2
#> 109          9               1 2.060615e-03             2
#> 110         10               1 2.560047e-03             2
#> 111          1               2 1.805750e-25             2
#> 112          2               2 4.433383e-24             2
#> 113          3               2 2.631473e-24             2
#> 114          4               2 4.415142e-24             2
#> 115          5               2 3.486025e-24             2
#> 116          6               2 2.469255e-24             2
#> 117          7               2 1.816731e-25             2
#> 118          8               2 2.425003e-24             2
#> 119          9               2 2.860951e-24             2
#> 120         10               2 2.749830e-24             2
#> 121          1               3 3.277573e-29             2
#> 122          2               3 7.626563e-29             2
#> 123          3               3 8.388587e-28             2
#> 124          4               3 8.993437e-29             2
#> 125          5               3 7.867939e-29             2
#> 126          6               3 7.069762e-29             2
#> 127          7               3 3.408594e-29             2
#> 128          8               3 7.223201e-28             2
#> 129          9               3 1.165565e-28             2
#> 130         10               3 1.491608e-28             2
#> 131          1               4 5.322783e-31             2
#> 132          2               4 4.807379e-30             2
#> 133          3               4 3.378776e-30             2
#> 134          4               4 6.165320e-29             2
#> 135          5               4 1.059974e-29             2
#> 136          6               4 2.678060e-30             2
#> 137          7               4 5.324608e-31             2
#> 138          8               4 2.921877e-30             2
#> 139          9               4 4.301294e-30             2
#> 140         10               4 3.910822e-30             2
#> 141          1               5 1.117792e-29             2
#> 142          2               5 2.744164e-28             2
#> 143          3               5 2.137030e-28             2
#> 144          4               5 7.663212e-28             2
#> 145          5               5 2.086571e-26             2
#> 146          6               5 1.944728e-28             2
#> 147          7               5 1.125052e-29             2
#> 148          8               5 2.854040e-28             2
#> 149          9               5 2.468543e-27             2
#> 150         10               5 2.951616e-27             2
#> 151          1               6 5.597387e-02             2
#> 152          2               6 9.977043e-01             2
#> 153          3               6 9.856228e-01             2
#> 154          4               6 9.937852e-01             2
#> 155          5               6 9.981947e-01             2
#> 156          6               6 9.982388e-01             2
#> 157          7               6 5.660922e-02             2
#> 158          8               6 9.496731e-01             2
#> 159          9               6 9.979393e-01             2
#> 160         10               6 9.974399e-01             2
#> 161          1               7 1.740094e-29             2
#> 162          2               7 4.260150e-32             2
#> 163          3               7 2.757907e-31             2
#> 164          4               7 1.146722e-31             2
#> 165          5               7 3.351409e-32             2
#> 166          6               7 3.285380e-32             2
#> 167          7               7 3.926461e-29             2
#> 168          8               7 1.065260e-30             2
#> 169          9               7 3.907859e-32             2
#> 170         10               7 4.935115e-32             2
#> 171          1               8 5.147329e-18             2
#> 172          2               8 3.153167e-18             2
#> 173          3               8 3.240668e-17             2
#> 174          4               8 3.489258e-18             2
#> 175          5               8 4.714280e-18             2
#> 176          6               8 3.056138e-18             2
#> 177          7               8 5.906853e-18             2
#> 178          8               8 6.770019e-16             2
#> 179          9               8 9.546562e-18             2
#> 180         10               8 1.755043e-17             2
#> 181          1               9 1.412974e-10             2
#> 182          2               9 2.494025e-09             2
#> 183          3               9 3.505881e-09             2
#> 184          4               9 3.443705e-09             2
#> 185          5               9 2.733705e-08             2
#> 186          6               9 2.153073e-09             2
#> 187          7               9 1.452764e-10             2
#> 188          8               9 6.400336e-09             2
#> 189          9               9 6.313733e-08             2
#> 190         10               9 5.729955e-08             2
#> 191          1              10 1.601380e-30             2
#> 192          2              10 2.186783e-29             2
#> 193          3              10 4.092837e-29             2
#> 194          4              10 2.856303e-29             2
#> 195          5              10 2.981811e-28             2
#> 196          6              10 1.963137e-29             2
#> 197          7              10 1.673643e-30             2
#> 198          8              10 1.073378e-28             2
#> 199          9              10 5.227097e-28             2
#> 200         10              10 2.306192e-27             2
ggplot2::fortify(all_flows, flows = "destination")
#>    destination         flow configuration
#> 1            1 6.797696e-09             1
#> 2            1 1.968819e+00             2
#> 3            2 3.219454e-10             1
#> 4            2 2.583331e-23             2
#> 5            3 1.815101e-12             1
#> 6            3 2.209335e-27             2
#> 7            4 1.090482e-13             1
#> 8            4 9.531588e-29             2
#> 9            5 1.428384e-13             1
#> 10           5 2.804261e-26             2
#> 11           6 1.000000e+01             1
#> 12           6 8.031181e+00             2
#> 13           7 8.497920e-14             1
#> 14           7 5.831868e-29             2
#> 15           8 1.035784e-13             1
#> 16           8 7.619726e-16             2
#> 17           9 8.875628e-12             1
#> 18           9 1.660575e-07             2
#> 19          10 3.141047e-13             1
#> 20          10 3.348686e-27             2
destination_names(all_flows) <- letters[1:10]
ggplot2::fortify(all_flows, flows = "attractiveness", with_names = TRUE)
#>    destination attractiveness configuration name
#> 1            1   4.622996e-06             1    a
#> 2            1   1.968820e+00             2    a
#> 3            2   1.016003e-06             1    b
#> 4            2   1.308701e-18             2    b
#> 5            3   3.077743e-08             1    c
#> 6            3   6.493424e-22             2    c
#> 7            4   5.643165e-09             1    d
#> 8            4   6.150550e-23             2    d
#> 9            5   6.665194e-09             1    e
#> 10           5   3.502284e-21             2    e
#> 11           6   9.999994e+00             1    f
#> 12           6   8.031177e+00             2    f
#> 13           7   2.478656e-09             1    g
#> 14           7   2.778437e-23             2    g
#> 15           8   4.762372e-09             1    h
#> 16           8   6.854897e-13             2    h
#> 17           9   9.293921e-08             1    i
#> 18           9   3.586064e-06             2    i
#> 19          10   1.061756e-08             1    j
#> 20          10   5.801020e-22             2    j
```
