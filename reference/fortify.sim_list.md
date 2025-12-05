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
#> 1            1               1 8.509339e-10             1
#> 2            2               1 2.572445e-11             1
#> 3            3               1 6.235402e-11             1
#> 4            4               1 3.442526e-11             1
#> 5            5               1 2.777892e-10             1
#> 6            6               1 4.296214e-11             1
#> 7            7               1 8.242618e-11             1
#> 8            8               1 2.799070e-11             1
#> 9            9               1 8.407042e-11             1
#> 10          10               1 2.112047e-10             1
#> 11           1               2 1.000000e+00             1
#> 12           2               2 1.000000e+00             1
#> 13           3               2 1.000000e+00             1
#> 14           4               2 1.000000e+00             1
#> 15           5               2 1.000000e+00             1
#> 16           6               2 1.000000e+00             1
#> 17           7               2 1.000000e+00             1
#> 18           8               2 1.000000e+00             1
#> 19           9               2 1.000000e+00             1
#> 20          10               2 1.000000e+00             1
#> 21           1               3 2.220061e-12             1
#> 22           2               3 9.158965e-13             1
#> 23           3               3 1.591429e-11             1
#> 24           4               3 3.685904e-12             1
#> 25           5               3 1.417747e-12             1
#> 26           6               3 9.182637e-13             1
#> 27           7               3 1.056243e-12             1
#> 28           8               3 3.771146e-12             1
#> 29           9               3 1.566964e-11             1
#> 30          10               3 2.899355e-12             1
#> 31           1               4 1.079962e-10             1
#> 32           2               4 8.070068e-11             1
#> 33           3               4 3.247692e-10             1
#> 34           4               4 3.874550e-10             1
#> 35           5               4 8.954724e-11             1
#> 36           6               4 8.240556e-11             1
#> 37           7               4 8.197393e-11             1
#> 38           8               4 3.036609e-10             1
#> 39           9               4 3.221922e-10             1
#> 40          10               4 1.320041e-10             1
#> 41           1               5 5.200193e-14             1
#> 42           2               5 4.815597e-15             1
#> 43           3               5 7.454226e-15             1
#> 44           4               5 5.343491e-15             1
#> 45           5               5 7.342192e-14             1
#> 46           6               5 9.677459e-15             1
#> 47           7               5 1.909658e-14             1
#> 48           8               5 4.820562e-15             1
#> 49           9               5 8.685409e-15             1
#> 50          10               5 2.170480e-14             1
#> 51           1               6 2.839103e-13             1
#> 52           2               6 1.699971e-13             1
#> 53           3               6 1.704364e-13             1
#> 54           4               6 1.735884e-13             1
#> 55           5               6 3.416274e-13             1
#> 56           6               6 4.738483e-13             1
#> 57           7               6 3.764195e-13             1
#> 58           8               6 2.017431e-13             1
#> 59           9               6 1.714031e-13             1
#> 60          10               6 2.255247e-13             1
#> 61           1               7 7.997509e-13             1
#> 62           2               7 2.495949e-13             1
#> 63           3               7 2.878413e-13             1
#> 64           4               7 2.535328e-13             1
#> 65           5               7 9.897858e-13             1
#> 66           6               7 5.526706e-13             1
#> 67           7               7 1.090667e-12             1
#> 68           8               7 2.555222e-13             1
#> 69           9               7 3.030622e-13             1
#> 70          10               7 5.441490e-13             1
#> 71           1               8 5.370207e-15             1
#> 72           2               8 4.935411e-15             1
#> 73           3               8 2.032124e-14             1
#> 74           4               8 1.857099e-14             1
#> 75           5               8 4.940500e-15             1
#> 76           6               8 5.857074e-15             1
#> 77           7               8 5.052617e-15             1
#> 78           8               8 9.714557e-14             1
#> 79           9               8 2.319624e-14             1
#> 80          10               8 6.369812e-15             1
#> 81           1               9 1.667798e-14             1
#> 82           2               9 5.103245e-15             1
#> 83           3               9 8.730899e-14             1
#> 84           4               9 2.037437e-14             1
#> 85           5               9 9.204211e-15             1
#> 86           6               9 5.145453e-15             1
#> 87           7               9 6.196444e-15             1
#> 88           8               9 2.398505e-14             1
#> 89           9               9 3.304426e-13             1
#> 90          10               9 2.087660e-14             1
#> 91           1              10 1.564473e-13             1
#> 92           2              10 1.905507e-14             1
#> 93           3              10 6.032057e-14             1
#> 94           4              10 3.116884e-14             1
#> 95           5              10 8.588476e-14             1
#> 96           6              10 2.527919e-14             1
#> 97           7              10 4.154251e-14             1
#> 98           8              10 2.459313e-14             1
#> 99           9              10 7.795139e-14             1
#> 100         10              10 2.045152e-13             1
#> 101          1               1 5.500529e-01             2
#> 102          2               1 1.059915e-02             2
#> 103          3               1 1.816389e-03             2
#> 104          4               1 6.401649e-03             2
#> 105          5               1 8.221099e-02             2
#> 106          6               1 6.744779e-03             2
#> 107          7               1 6.520746e-03             2
#> 108          8               1 1.132778e-03             2
#> 109          9               1 3.372016e-03             2
#> 110         10               1 1.206569e-01             2
#> 111          1               2 6.336403e-33             2
#> 112          2               2 1.336008e-31             2
#> 113          3               2 3.896815e-33             2
#> 114          4               2 4.505752e-32             2
#> 115          5               2 8.886463e-33             2
#> 116          6               2 3.048077e-32             2
#> 117          7               2 8.005655e-33             2
#> 118          8               2 1.206000e-32             2
#> 119          9               2 3.979542e-33             2
#> 120         10               2 2.256185e-32             2
#> 121          1               3 3.019484e-02             2
#> 122          2               3 1.083583e-01             2
#> 123          3               3 9.542120e-01             2
#> 124          4               3 5.918556e-01             2
#> 125          5               3 1.726979e-02             2
#> 126          6               3 2.484970e-02             2
#> 127          7               3 8.635450e-03             2
#> 128          8               3 1.658267e-01             2
#> 129          9               3 9.447379e-01             2
#> 130         10               3 1.833740e-01             2
#> 131          1               4 1.902716e-36             2
#> 132          2               4 2.240154e-35             2
#> 133          3               4 1.058215e-35             2
#> 134          4               4 1.741504e-34             2
#> 135          5               4 1.834627e-36             2
#> 136          6               4 5.329096e-36             2
#> 137          7               4 1.385042e-36             2
#> 138          8               4 2.863121e-35             2
#> 139          9               4 1.063598e-35             2
#> 140         10               4 1.012194e-35             2
#> 141          1               5 5.320370e-43             2
#> 142          2               5 9.619872e-44             2
#> 143          3               5 6.723185e-45             2
#> 144          4               5 3.994641e-44             2
#> 145          5               5 1.487444e-42             2
#> 146          6               5 8.863572e-44             2
#> 147          7               5 9.065012e-44             2
#> 148          8               5 8.701678e-45             2
#> 149          9               5 9.321242e-45             2
#> 150         10               5 3.300245e-43             2
#> 151          1               6 4.822450e-46             2
#> 152          2               6 3.645477e-45             2
#> 153          3               6 1.068802e-46             2
#> 154          4               6 1.281951e-45             2
#> 155          5               6 9.792573e-46             2
#> 156          6               6 6.462002e-45             2
#> 157          7               6 1.071035e-45             2
#> 158          8               6 4.634550e-46             2
#> 159          9               6 1.103908e-46             2
#> 160         10               6 1.083492e-45             2
#> 161          1               7 4.185453e-01             2
#> 162          2               7 8.595485e-01             2
#> 163          3               7 3.334312e-02             2
#> 164          4               7 2.991066e-01             2
#> 165          5               7 8.990866e-01             2
#> 166          6               7 9.614991e-01             2
#> 167          7               7 9.834939e-01             2
#> 168          8               7 8.131954e-02             2
#> 169          9               7 3.774738e-02             2
#> 170         10               7 6.899228e-01             2
#> 171          1               8 1.206946e-03             2
#> 172          2               8 2.149408e-02             2
#> 173          3               8 1.062854e-02             2
#> 174          4               8 1.026362e-01             2
#> 175          5               8 1.432630e-03             2
#> 176          6               8 6.906381e-03             2
#> 177          7               8 1.349873e-03             2
#> 178          8               8 7.517210e-01             2
#> 179          9               8 1.414267e-02             2
#> 180         10               8 6.046319e-03             2
#> 181          1               9 3.260434e-36             2
#> 182          2               9 6.436462e-36             2
#> 183          3               9 5.495069e-35             2
#> 184          4               9 3.460041e-35             2
#> 185          5               9 1.392668e-36             2
#> 186          6               9 1.492859e-36             2
#> 187          7               9 5.686269e-37             2
#> 188          8               9 1.283436e-35             2
#> 189          9               9 8.038421e-34             2
#> 190         10               9 1.819029e-35             2
#> 191          1              10 5.049045e-37             2
#> 192          2              10 1.579284e-37             2
#> 193          3              10 4.616056e-38             2
#> 194          4              10 1.425079e-37             2
#> 195          5              10 2.133985e-37             2
#> 196          6              10 6.341364e-38             2
#> 197          7              10 4.497929e-38             2
#> 198          8              10 2.374681e-38             2
#> 199          9              10 7.872472e-38             2
#> 200         10              10 3.072246e-36             2
ggplot2::fortify(all_flows, flows = "destination")
#>    destination         flow configuration
#> 1            1 1.699881e-09             1
#> 2            1 7.895083e-01             2
#> 3            2 1.000000e+01             1
#> 4            2 2.748658e-31             2
#> 5            3 4.846855e-11             1
#> 6            3 3.029314e+00             2
#> 7            4 1.912705e-09             1
#> 8            4 2.669747e-34             2
#> 9            5 2.070220e-13             1
#> 10           5 2.689683e-42             2
#> 11           6 2.588498e-12             1
#> 12           6 1.568619e-44             2
#> 13           7 5.326577e-12             1
#> 14           7 5.263613e+00             2
#> 15           8 1.917597e-13             1
#> 16           8 9.175646e-01             2
#> 17           9 5.253150e-13             1
#> 18           9 9.375689e-34             2
#> 19          10 7.267579e-13             1
#> 20          10 4.348010e-36             2
destination_names(all_flows) <- letters[1:10]
ggplot2::fortify(all_flows, flows = "attractiveness", with_names = TRUE)
#>    destination attractiveness configuration name
#> 1            1   2.769395e-06             1    a
#> 2            1   7.895118e-01             2    a
#> 3            2   9.999994e+00             1    b
#> 4            2   3.612304e-25             2    b
#> 5            3   2.418320e-07             1    c
#> 6            3   3.029315e+00             2    c
#> 7            4   3.118916e-06             1    d
#> 8            4   1.209023e-27             2    d
#> 9            5   7.000467e-09             1    e
#> 10           5   6.168977e-34             2    e
#> 11           6   4.275584e-08             1    f
#> 12           6   1.155311e-35             2    f
#> 13           7   6.416200e-08             1    g
#> 14           7   5.263609e+00             2    g
#> 15           8   7.748491e-09             1    h
#> 16           8   9.175648e-01             2    h
#> 17           9   1.178373e-08             1    i
#> 18           9   3.573178e-27             2    i
#> 19          10   1.557927e-08             1    j
#> 20          10   4.369959e-29             2    j
```
