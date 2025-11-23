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
#> 11           1               2 1.104365e-12             1
#> 12           2               2 6.899788e-11             1
#> 13           3               2 2.314275e-12             1
#> 14           4               2 2.798931e-12             1
#> 15           5               2 1.372524e-12             1
#> 16           6               2 2.439628e-11             1
#> 17           7               2 3.693015e-12             1
#> 18           8               2 7.414763e-12             1
#> 19           9               2 1.118326e-12             1
#> 20          10               2 3.832577e-12             1
#> 21           1               3 9.061601e-12             1
#> 22           2               3 1.898922e-11             1
#> 23           3               3 2.106861e-11             1
#> 24           4               3 1.051223e-11             1
#> 25           5               3 9.337054e-12             1
#> 26           6               3 2.056720e-11             1
#> 27           7               3 2.013086e-11             1
#> 28           8               3 2.106683e-11             1
#> 29           9               3 9.356684e-12             1
#> 30          10               3 1.067615e-11             1
#> 31           1               4 2.466629e-12             1
#> 32           2               4 6.251485e-12             1
#> 33           3               4 2.861500e-12             1
#> 34           4               4 2.480810e-11             1
#> 35           5               4 5.103467e-12             1
#> 36           6               4 4.323998e-12             1
#> 37           7               4 2.741202e-12             1
#> 38           8               4 3.299700e-12             1
#> 39           9               4 5.232469e-12             1
#> 40          10               4 2.480762e-11             1
#> 41           1               5 5.791423e-12             1
#> 42           2               5 7.197679e-12             1
#> 43           3               5 5.967470e-12             1
#> 44           4               5 1.198248e-11             1
#> 45           5               5 1.269721e-11             1
#> 46           6               5 6.464047e-12             1
#> 47           7               5 5.822318e-12             1
#> 48           8               5 6.061108e-12             1
#> 49           9               5 9.972129e-12             1
#> 50          10               5 1.207277e-11             1
#> 51           1               6 2.275792e-12             1
#> 52           2               6 5.027398e-11             1
#> 53           3               6 5.165386e-12             1
#> 54           4               6 3.989460e-12             1
#> 55           5               6 2.540105e-12             1
#> 56           6               6 7.688077e-11             1
#> 57           7               6 9.918371e-12             1
#> 58           8               6 2.048196e-11             1
#> 59           9               6 2.296341e-12             1
#> 60          10               6 4.720867e-12             1
#> 61           1               7 3.708303e-12             1
#> 62           2               7 1.240062e-11             1
#> 63           3               7 8.238205e-12             1
#> 64           4               7 4.121093e-12             1
#> 65           5               7 3.728085e-12             1
#> 66           6               7 1.616155e-11             1
#> 67           7               7 2.194102e-11             1
#> 68           8               7 1.824007e-11             1
#> 69           9               7 4.341861e-12             1
#> 70          10               7 4.209094e-12             1
#> 71           1               8 4.663712e-12             1
#> 72           2               8 3.131239e-11             1
#> 73           3               8 1.084241e-11             1
#> 74           4               8 6.238817e-12             1
#> 75           5               8 4.880884e-12             1
#> 76           6               8 4.197308e-11             1
#> 77           7               8 2.293945e-11             1
#> 78           8               8 4.737464e-11             1
#> 79           9               8 4.929524e-12             1
#> 80          10               8 6.671153e-12             1
#> 81           1               9 7.590745e-13             1
#> 82           2               9 7.686704e-13             1
#> 83           3               9 7.837931e-13             1
#> 84           4               9 1.610227e-12             1
#> 85           5               9 1.307034e-12             1
#> 86           6               9 7.659286e-13             1
#> 87           7               9 8.887612e-13             1
#> 88           8               9 8.023385e-13             1
#> 89           9               9 6.851523e-12             1
#> 90          10               9 1.866700e-12             1
#> 91           1              10 7.381716e-13             1
#> 92           2              10 2.561742e-12             1
#> 93           3              10 8.696953e-13             1
#> 94           4              10 7.424009e-12             1
#> 95           5              10 1.538788e-12             1
#> 96           6              10 1.531252e-12             1
#> 97           7              10 8.378585e-13             1
#> 98           8              10 1.055909e-12             1
#> 99           9              10 1.815296e-12             1
#> 100         10              10 2.853617e-11             1
#> 101          1               1 9.899518e-01             2
#> 102          2               1 2.090871e-01             2
#> 103          3               1 9.587421e-01             2
#> 104          4               1 7.859073e-01             2
#> 105          5               1 9.801338e-01             2
#> 106          6               1 1.021724e-01             2
#> 107          7               1 8.701361e-01             2
#> 108          8               1 6.142623e-01             2
#> 109          9               1 9.777996e-01             2
#> 110         10               1 2.123718e-01             2
#> 111          1               2 6.272335e-15             2
#> 112          2               2 5.171165e-12             2
#> 113          3               2 2.667603e-14             2
#> 114          4               2 3.198491e-14             2
#> 115          5               2 9.592127e-15             2
#> 116          6               2 3.159150e-13             2
#> 117          7               2 6.165082e-14             2
#> 118          8               2 1.754438e-13             2
#> 119          9               2 6.352967e-15             2
#> 120         10               2 1.620571e-14             2
#> 121          1               3 6.683601e-47             2
#> 122          2               3 6.199090e-47             2
#> 123          3               3 3.499132e-46             2
#> 124          4               3 7.140809e-47             2
#> 125          5               3 7.025733e-47             2
#> 126          6               3 3.553616e-47             2
#> 127          7               3 2.899334e-46             2
#> 128          8               3 2.241500e-46             2
#> 129          9               3 7.038504e-47             2
#> 130         10               3 1.990274e-47             2
#> 131          1               4 1.265186e-42             2
#> 132          2               4 1.716430e-42             2
#> 133          3               4 1.649004e-42             2
#> 134          4               4 1.015993e-40             2
#> 135          5               4 5.362266e-42             2
#> 136          6               4 4.012702e-43             2
#> 137          7               4 1.373415e-42             2
#> 138          8               4 1.404867e-42             2
#> 139          9               4 5.623357e-42             2
#> 140         10               4 2.745361e-41             2
#> 141          1               5 8.366020e-48             2
#> 142          2               5 2.729270e-48             2
#> 143          3               5 8.602339e-48             2
#> 144          4               5 2.843145e-47             2
#> 145          5               5 3.981403e-47             2
#> 146          6               5 1.075665e-48             2
#> 147          7               5 7.432129e-48             2
#> 148          8               5 5.685809e-48             2
#> 149          9               5 2.449965e-47             2
#> 150         10               5 7.799106e-48             2
#> 151          1               6 7.613417e-03             2
#> 152          2               6 7.847193e-01             2
#> 153          3               6 3.798463e-02             2
#> 154          4               6 1.857377e-02             2
#> 155          5               6 9.390513e-03             2
#> 156          6               6 8.967463e-01             2
#> 157          7               6 1.271067e-01             2
#> 158          8               6 3.826464e-01             2
#> 159          9               6 7.656375e-03             2
#> 160         10               6 7.028148e-03             2
#> 161          1               7 5.400076e-46             2
#> 162          2               7 1.275409e-45             2
#> 163          3               7 2.581085e-45             2
#> 164          4               7 5.294579e-46             2
#> 165          5               7 5.403714e-46             2
#> 166          6               7 1.058608e-45             2
#> 167          7               7 1.661637e-44             2
#> 168          8               7 8.106667e-45             2
#> 169          9               7 7.312015e-46             2
#> 170         10               7 1.492483e-46             2
#> 171          1               8 3.983098e-36             2
#> 172          2               8 3.792305e-35             2
#> 173          3               8 2.084958e-35             2
#> 174          4               8 5.658735e-36             2
#> 175          5               8 4.319424e-36             2
#> 176          6               8 3.329804e-35             2
#> 177          7               8 8.470262e-35             2
#> 178          8               8 2.550288e-34             2
#> 179          9               8 4.395450e-36             2
#> 180         10               8 1.748405e-36             2
#> 181          1               9 1.552843e-45             2
#> 182          2               9 3.363198e-46             2
#> 183          3               9 1.603428e-45             2
#> 184          4               9 5.547413e-45             2
#> 185          5               9 4.558313e-45             2
#> 186          6               9 1.631755e-46             2
#> 187          7               9 1.871122e-45             2
#> 188          8               9 1.076500e-45             2
#> 189          9               9 1.249594e-43             2
#> 190         10               9 2.014608e-45             2
#> 191          1              10 2.434833e-03             2
#> 192          2              10 6.193536e-03             2
#> 193          3              10 3.273231e-03             2
#> 194          4              10 1.955190e-01             2
#> 195          5              10 1.047572e-02             2
#> 196          6              10 1.081352e-03             2
#> 197          7              10 2.757205e-03             2
#> 198          8              10 3.091344e-03             2
#> 199          9              10 1.454404e-02             2
#> 200         10              10 7.806001e-01             2
ggplot2::fortify(all_flows, flows = "destination")
#>    destination         flow configuration
#> 1            1 1.000000e+01             1
#> 2            1 6.700564e+00             2
#> 3            2 1.170429e-10             1
#> 4            2 5.821259e-12             2
#> 5            3 1.507664e-10             1
#> 6            3 1.260313e-45             2
#> 7            4 8.189617e-11             1
#> 8            4 1.478487e-40             2
#> 9            5 8.402863e-11             1
#> 10           5 1.344355e-46             2
#> 11           6 1.785430e-10             1
#> 12           6 2.279466e+00             2
#> 13           7 9.708991e-11             1
#> 14           7 3.212842e-44             2
#> 15           8 1.818261e-10             1
#> 16           8 4.519072e-34             2
#> 17           9 1.640405e-11             1
#> 18           9 1.436831e-43             2
#> 19          10 4.690889e-11             1
#> 20          10 1.019970e+00             2
destination_names(all_flows) <- letters[1:10]
ggplot2::fortify(all_flows, flows = "attractiveness", with_names = TRUE)
#>    destination attractiveness configuration name
#> 1            1   9.999996e+00             1    a
#> 2            1   6.700570e+00             2    a
#> 3            2   4.197130e-07             1    b
#> 4            2   7.939796e-10             2    b
#> 5            3   5.700546e-07             1    c
#> 6            3   1.508026e-36             2    c
#> 7            4   3.901232e-07             1    d
#> 8            4   1.285200e-32             2    d
#> 9            5   4.147634e-07             1    e
#> 10           5   2.729036e-37             2    e
#> 11           6   5.537153e-07             1    f
#> 12           6   2.279462e+00             2    f
#> 13           7   4.289895e-07             1    g
#> 14           7   1.693717e-35             2    g
#> 15           8   5.984973e-07             1    h
#> 16           8   2.045897e-27             2    h
#> 17           9   1.715244e-07             1    i
#> 18           9   5.527898e-35             2    i
#> 19          10   2.734136e-07             1    j
#> 20          10   1.019968e+00             2    j
```
