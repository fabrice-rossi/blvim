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
#> 11           1               2 3.998564e-12             1
#> 12           2               2 6.947762e-11             1
#> 13           3               2 1.609169e-11             1
#> 14           4               2 6.189513e-12             1
#> 15           5               2 4.008898e-12             1
#> 16           6               2 4.611280e-12             1
#> 17           7               2 1.646383e-11             1
#> 18           8               2 6.840952e-11             1
#> 19           9               2 1.265782e-11             1
#> 20          10               2 6.678450e-12             1
#> 21           1               3 5.255685e-12             1
#> 22           2               3 2.115081e-11             1
#> 23           3               3 2.523326e-11             1
#> 24           4               3 5.831823e-12             1
#> 25           5               3 5.366717e-12             1
#> 26           6               3 5.338607e-12             1
#> 27           7               3 1.977611e-11             1
#> 28           8               3 2.098298e-11             1
#> 29           9               3 8.596853e-12             1
#> 30          10               3 5.951459e-12             1
#> 31           1               4 3.836745e-12             1
#> 32           2               4 5.939029e-12             1
#> 33           3               4 4.257336e-12             1
#> 34           4               4 5.849768e-11             1
#> 35           5               4 7.710352e-12             1
#> 36           6               4 1.521488e-11             1
#> 37           7               4 3.840701e-12             1
#> 38           8               4 6.919953e-12             1
#> 39           9               4 1.729293e-11             1
#> 40          10               4 5.818882e-11             1
#> 41           1               5 3.844078e-12             1
#> 42           2               5 3.854013e-12             1
#> 43           3               5 3.925288e-12             1
#> 44           4               5 7.725088e-12             1
#> 45           5               5 1.071495e-11             1
#> 46           6               5 8.511830e-12             1
#> 47           7               5 4.561940e-12             1
#> 48           8               5 3.875872e-12             1
#> 49           9               5 5.099704e-12             1
#> 50          10               5 7.712629e-12             1
#> 51           1               6 5.322323e-12             1
#> 52           2               6 6.137884e-12             1
#> 53           3               6 5.406296e-12             1
#> 54           4               6 2.110604e-11             1
#> 55           5               6 1.178507e-11             1
#> 56           6               6 2.325723e-11             1
#> 57           7               6 5.448717e-12             1
#> 58           8               6 6.462452e-12             1
#> 59           9               6 1.160335e-11             1
#> 60          10               6 2.105631e-11             1
#> 61           1               7 7.823117e-13             1
#> 62           2               7 3.221119e-12             1
#> 63           3               7 2.943686e-12             1
#> 64           4               7 7.831183e-13             1
#> 65           5               7 9.284043e-13             1
#> 66           6               7 8.008899e-13             1
#> 67           7               7 1.539854e-11             1
#> 68           8               7 3.676834e-12             1
#> 69           9               7 1.009678e-12             1
#> 70          10               7 7.848916e-13             1
#> 71           1               8 1.048483e-12             1
#> 72           2               8 1.793799e-11             1
#> 73           3               8 4.185998e-12             1
#> 74           4               8 1.891043e-12             1
#> 75           5               8 1.057154e-12             1
#> 76           6               8 1.273085e-12             1
#> 77           7               8 4.927827e-12             1
#> 78           8               8 6.789079e-11             1
#> 79           9               8 4.289183e-12             1
#> 80          10               8 2.122100e-12             1
#> 81           1               9 2.488088e-12             1
#> 82           2               9 7.876273e-12             1
#> 83           3               9 4.069827e-12             1
#> 84           4               9 1.121428e-11             1
#> 85           5               9 3.300795e-12             1
#> 86           6               9 5.424354e-12             1
#> 87           7               9 3.211213e-12             1
#> 88           8               9 1.017839e-11             1
#> 89           9               9 2.670428e-11             1
#> 90          10               9 1.312073e-11             1
#> 91           1              10 1.566783e-12             1
#> 92           2              10 2.616860e-12             1
#> 93           3              10 1.774201e-12             1
#> 94           4              10 2.376213e-11             1
#> 95           5              10 3.143541e-12             1
#> 96           6              10 6.198545e-12             1
#> 97           7              10 1.571950e-12             1
#> 98           8              10 3.171126e-12             1
#> 99           9              10 8.262305e-12             1
#> 100         10              10 4.368378e-11             1
#> 101          1               1 9.313862e-01             2
#> 102          2               1 9.932474e-02             2
#> 103          3               1 6.281175e-01             2
#> 104          4               1 9.742814e-02             2
#> 105          5               1 8.362329e-01             2
#> 106          6               1 6.003520e-01             2
#> 107          7               1 2.982324e-01             2
#> 108          8               1 1.014760e-01             2
#> 109          9               1 4.748341e-01             2
#> 110         10               1 9.824327e-02             2
#> 111          1               2 2.743720e-02             2
#> 112          2               2 8.833836e-01             2
#> 113          3               2 2.996720e-01             2
#> 114          4               2 6.877005e-03             2
#> 115          5               2 2.476163e-02             2
#> 116          6               2 2.352074e-02             2
#> 117          7               2 1.489425e-01             2
#> 118          8               2 8.749804e-01             2
#> 119          9               2 1.401722e-01             2
#> 120         10               2 8.073395e-03             2
#> 121          1               3 2.191570e-43             2
#> 122          2               3 3.785108e-43             2
#> 123          3               3 3.406863e-42             2
#> 124          4               3 2.822669e-44             2
#> 125          5               3 2.051689e-43             2
#> 126          6               3 1.457568e-43             2
#> 127          7               3 9.935818e-43             2
#> 128          8               3 3.805962e-43             2
#> 129          9               3 2.989426e-43             2
#> 130         10               3 2.964262e-44             2
#> 131          1               4 3.681564e-02             2
#> 132          2               4 9.407299e-03             2
#> 133          3               4 3.056986e-02             2
#> 134          4               4 8.952377e-01             2
#> 135          5               4 1.334911e-01             2
#> 136          6               4 3.731812e-01             2
#> 137          7               4 1.181279e-02             2
#> 138          8               4 1.304807e-02             2
#> 139          9               4 3.812903e-01             2
#> 140         10               4 8.932203e-01             2
#> 141          1               5 7.005723e-46             2
#> 142          2               5 7.509700e-47             2
#> 143          3               5 4.926321e-46             2
#> 144          4               5 2.959580e-46             2
#> 145          5               5 4.887043e-45             2
#> 146          6               5 2.214066e-45             2
#> 147          7               5 3.159313e-46             2
#> 148          8               5 7.759626e-47             2
#> 149          9               5 6.285945e-46             2
#> 150         10               5 2.974723e-46             2
#> 151          1               6 3.774216e-43             2
#> 152          2               6 5.352902e-44             2
#> 153          3               6 2.626243e-43             2
#> 154          4               6 6.208583e-43             2
#> 155          5               6 1.661444e-42             2
#> 156          6               6 4.645326e-42             2
#> 157          7               6 1.266595e-43             2
#> 158          8               6 6.062508e-44             2
#> 159          9               6 9.145412e-43             2
#> 160         10               6 6.231055e-43             2
#> 161          1               7 4.360968e-03             2
#> 162          2               7 7.884323e-03             2
#> 163          3               7 4.164063e-02             2
#> 164          4               7 4.571226e-04             2
#> 165          5               7 5.514359e-03             2
#> 166          6               7 2.946084e-03             2
#> 167          7               7 5.410124e-01             2
#> 168          8               7 1.049554e-02             2
#> 169          9               7 3.703408e-03             2
#> 170         10               7 4.630370e-04             2
#> 171          1               8 2.018362e-24             2
#> 172          2               8 6.300163e-23             2
#> 173          3               8 2.169631e-23             2
#> 174          4               8 6.868059e-25             2
#> 175          5               8 1.842260e-24             2
#> 176          6               8 1.918083e-24             2
#> 177          7               8 1.427619e-23             2
#> 178          8               8 9.220019e-22             2
#> 179          9               8 1.722019e-23             2
#> 180         10               8 8.721305e-25             2
#> 181          1               9 1.976044e-42             2
#> 182          2               9 2.111710e-42             2
#> 183          3               9 3.565563e-42             2
#> 184          4               9 4.199161e-42             2
#> 185          5               9 3.122480e-42             2
#> 186          6               9 6.053928e-42             2
#> 187          7               9 1.053970e-42             2
#> 188          8               9 3.602938e-42             2
#> 189          9               9 1.160483e-40             2
#> 190         10               9 5.796347e-42             2
#> 191          1              10 1.621218e-45             2
#> 192          2              10 4.822947e-46             2
#> 193          3              10 1.401977e-45             2
#> 194          4              10 3.900761e-44             2
#> 195          5              10 5.859486e-45             2
#> 196          6              10 1.635609e-44             2
#> 197          7              10 5.225480e-46             2
#> 198          8              10 7.235763e-46             2
#> 199          9              10 2.298467e-44             2
#> 200         10              10 1.329344e-43             2
ggplot2::fortify(all_flows, flows = "destination")
#>    destination         flow configuration
#> 1            1 1.000000e+01             1
#> 2            1 4.165627e+00             2
#> 3            2 2.085872e-10             1
#> 4            2 2.437821e+00             2
#> 5            3 1.234843e-10             1
#> 6            3 6.086446e-42             2
#> 7            4 1.816984e-10             1
#> 8            4 2.778074e+00             2
#> 9            5 5.982539e-11             1
#> 10           5 9.984963e-45             2
#> 11           6 1.175857e-10             1
#> 12           6 9.346135e-42             2
#> 13           7 3.032947e-11             1
#> 14           7 6.184778e-01             2
#> 15           8 1.066237e-10             1
#> 16           8 1.045534e-21             2
#> 17           9 8.758823e-11             1
#> 18           9 1.475305e-40             2
#> 19          10 9.575123e-11             1
#> 20          10 2.218938e-43             2
destination_names(all_flows) <- letters[1:10]
ggplot2::fortify(all_flows, flows = "attractiveness", with_names = TRUE)
#>    destination attractiveness configuration name
#> 1            1   9.999996e+00             1    a
#> 2            1   4.165632e+00             2    a
#> 3            2   6.459805e-07             1    b
#> 4            2   2.437820e+00             2    b
#> 5            3   5.048593e-07             1    c
#> 6            3   1.142068e-33             2    c
#> 7            4   6.016402e-07             1    d
#> 8            4   2.778072e+00             2    d
#> 9            5   3.418980e-07             1    e
#> 10           5   7.456463e-36             2    e
#> 11           6   4.933886e-07             1    f
#> 12           6   1.636210e-33             2    f
#> 13           7   2.269457e-07             1    g
#> 14           7   6.184764e-01             2    g
#> 15           8   4.102924e-07             1    h
#> 16           8   1.358350e-17             2    h
#> 17           9   4.009758e-07             1    i
#> 18           9   1.262471e-32             2    i
#> 19          10   4.049603e-07             1    j
#> 20          10   9.207347e-35             2    j
```
