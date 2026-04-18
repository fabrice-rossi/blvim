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
#> 1            1               1 2.714174e-13             1
#> 2            2               1 5.945526e-15             1
#> 3            3               1 5.901383e-15             1
#> 4            4               1 1.391955e-14             1
#> 5            5               1 6.423293e-15             1
#> 6            6               1 1.251223e-14             1
#> 7            7               1 6.063859e-15             1
#> 8            8               1 6.128930e-15             1
#> 9            9               1 3.038287e-14             1
#> 10          10               1 2.107453e-14             1
#> 11           1               2 4.151848e-14             1
#> 12           2               2 1.944265e-11             1
#> 13           3               2 4.121023e-14             1
#> 14           4               2 2.214755e-13             1
#> 15           5               2 8.806428e-13             1
#> 16           6               2 4.570985e-14             1
#> 17           7               2 7.019235e-13             1
#> 18           8               2 5.286362e-14             1
#> 19           9               2 4.123344e-14             1
#> 20          10               2 4.888602e-14             1
#> 21           1               3 1.000000e+00             1
#> 22           2               3 1.000000e+00             1
#> 23           3               3 1.000000e+00             1
#> 24           4               3 1.000000e+00             1
#> 25           5               3 1.000000e+00             1
#> 26           6               3 1.000000e+00             1
#> 27           7               3 1.000000e+00             1
#> 28           8               3 1.000000e+00             1
#> 29           9               3 1.000000e+00             1
#> 30          10               3 1.000000e+00             1
#> 31           1               4 1.499115e-15             1
#> 32           2               4 3.415736e-15             1
#> 33           3               4 6.355705e-16             1
#> 34           4               4 4.321129e-14             1
#> 35           5               4 1.446189e-15             1
#> 36           6               4 1.275102e-15             1
#> 37           7               4 3.448825e-15             1
#> 38           8               4 8.383444e-16             1
#> 39           9               4 1.093552e-15             1
#> 40          10               4 7.216083e-16             1
#> 41           1               5 4.377507e-15             1
#> 42           2               5 8.594443e-14             1
#> 43           3               5 4.021823e-15             1
#> 44           4               5 9.151331e-15             1
#> 45           5               5 1.020487e-13             1
#> 46           6               5 4.136593e-15             1
#> 47           7               5 3.150294e-14             1
#> 48           8               5 4.924472e-15             1
#> 49           9               5 4.173933e-15             1
#> 50          10               5 5.396782e-15             1
#> 51           1               6 3.607098e-13             1
#> 52           2               6 1.887043e-13             1
#> 53           3               6 1.701285e-13             1
#> 54           4               6 3.413171e-13             1
#> 55           5               6 1.749834e-13             1
#> 56           6               6 4.374418e-13             1
#> 57           7               6 2.084536e-13             1
#> 58           8               6 1.936778e-13             1
#> 59           9               6 3.470015e-13             1
#> 60          10               6 2.466627e-13             1
#> 61           1               7 1.104990e-14             1
#> 62           2               7 1.831673e-13             1
#> 63           3               7 1.075383e-14             1
#> 64           4               7 5.835398e-14             1
#> 65           5               7 8.423475e-14             1
#> 66           6               7 1.317636e-14             1
#> 67           7               7 2.205345e-13             1
#> 68           8               7 1.428597e-14             1
#> 69           9               7 1.105848e-14             1
#> 70          10               7 1.118298e-14             1
#> 71           1               8 2.447776e-10             1
#> 72           2               8 3.023379e-10             1
#> 73           3               8 2.356898e-10             1
#> 74           4               8 3.108848e-10             1
#> 75           5               8 2.885875e-10             1
#> 76           6               8 2.683142e-10             1
#> 77           7               8 3.131032e-10             1
#> 78           8               8 3.194236e-10             1
#> 79           9               8 2.456560e-10             1
#> 80          10               8 2.358306e-10             1
#> 81           1               9 4.647445e-14             1
#> 82           2               9 9.031998e-15             1
#> 83           3               9 9.026913e-15             1
#> 84           4               9 1.553156e-14             1
#> 85           5               9 9.368320e-15             1
#> 86           6               9 1.841169e-14             1
#> 87           7               9 9.282639e-15             1
#> 88           8               9 9.408618e-15             1
#> 89           9               9 4.664145e-14             1
#> 90          10               9 2.488832e-14             1
#> 91           1              10 1.507755e-14             1
#> 92           2              10 5.008483e-15             1
#> 93           3              10 4.222081e-15             1
#> 94           4              10 4.793628e-15             1
#> 95           5              10 5.665503e-15             1
#> 96           6              10 6.121431e-15             1
#> 97           7              10 4.390570e-15             1
#> 98           8              10 4.224603e-15             1
#> 99           9              10 1.164080e-14             1
#> 100         10              10 1.896183e-14             1
#> 101          1               1 8.091214e-01             2
#> 102          2               1 3.816432e-05             2
#> 103          3               1 2.013369e-03             2
#> 104          4               1 1.542206e-03             2
#> 105          5               1 8.116154e-04             2
#> 106          6               1 8.940367e-03             2
#> 107          7               1 9.873783e-04             2
#> 108          8               1 2.162465e-03             2
#> 109          9               1 5.061851e-02             2
#> 110         10               1 2.501502e-02             2
#> 111          1               2 4.391688e-05             2
#> 112          2               2 9.466695e-01             2
#> 113          3               2 2.277383e-04             2
#> 114          4               2 9.056365e-04             2
#> 115          5               2 3.538707e-02             2
#> 116          6               2 2.767679e-04             2
#> 117          7               2 3.068847e-02             2
#> 118          8               2 3.731675e-04             2
#> 119          9               2 2.162525e-04             2
#> 120         10               2 3.122228e-04             2
#> 121          1               3 1.884013e-01             2
#> 122          2               3 1.851921e-02             2
#> 123          3               3 9.916565e-01             2
#> 124          4               3 1.365331e-01             2
#> 125          5               3 3.374274e-01             2
#> 126          6               3 9.795607e-01             2
#> 127          7               3 4.606075e-01             2
#> 128          8               3 9.874733e-01             2
#> 129          9               3 9.405831e-01             2
#> 130         10               3 9.661188e-01             2
#> 131          1               4 1.412590e-03             2
#> 132          2               4 7.208644e-04             2
#> 133          3               4 1.336445e-03             2
#> 134          4               4 8.505401e-01             2
#> 135          5               4 2.354468e-03             2
#> 136          6               4 5.313531e-03             2
#> 137          7               4 1.827829e-02             2
#> 138          8               4 2.315435e-03             2
#> 139          9               4 3.752653e-03             2
#> 140         10               4 1.678402e-03             2
#> 141          1               5 5.956608e-04             2
#> 142          2               5 2.256937e-02             2
#> 143          3               5 2.646480e-03             2
#> 144          4               5 1.886548e-03             2
#> 145          5               5 5.797711e-01             2
#> 146          6               5 2.765530e-03             2
#> 147          7               5 7.542142e-02             2
#> 148          8               5 3.950992e-03             2
#> 149          9               5 2.703644e-03             2
#> 150         10               5 4.642604e-03             2
#> 151          1               6 2.798128e-40             2
#> 152          2               6 7.527556e-42             2
#> 153          3               6 3.276296e-40             2
#> 154          4               6 1.815607e-40             2
#> 155          5               6 1.179348e-40             2
#> 156          6               6 2.139635e-39             2
#> 157          7               6 2.284638e-40             2
#> 158          8               6 4.228176e-40             2
#> 159          9               6 1.292789e-39             2
#> 160         10               6 6.709731e-40             2
#> 161          1               7 4.251428e-04             2
#> 162          2               7 1.148293e-02             2
#> 163          3               7 2.119443e-03             2
#> 164          4               7 8.592374e-03             2
#> 165          5               7 4.424836e-02             2
#> 166          6               7 3.143087e-03             2
#> 167          7               7 4.140170e-01             2
#> 168          8               7 3.724597e-03             2
#> 169          9               7 2.125798e-03             2
#> 170         10               7 2.232954e-03             2
#> 171          1               8 1.832859e-40             2
#> 172          2               8 2.748588e-41             2
#> 173          3               8 8.944266e-40             2
#> 174          4               8 2.142589e-40             2
#> 175          5               8 4.562860e-40             2
#> 176          6               8 1.145040e-39             2
#> 177          7               8 7.331752e-40             2
#> 178          8               8 1.635917e-39             2
#> 179          9               8 9.216241e-40             2
#> 180         10               8 8.724340e-40             2
#> 181          1               9 2.458784e-36             2
#> 182          2               9 9.128471e-39             2
#> 183          3               9 4.882560e-37             2
#> 184          4               9 1.990104e-37             2
#> 185          5               9 1.789417e-37             2
#> 186          6               9 2.006441e-36             2
#> 187          7               9 2.398180e-37             2
#> 188          8               9 5.281837e-37             2
#> 189          9               9 1.236372e-35             2
#> 190         10               9 3.616010e-36             2
#> 191          1              10 3.167023e-40             2
#> 192          2              10 3.435112e-42             2
#> 193          3              10 1.307135e-40             2
#> 194          4              10 2.319917e-41             2
#> 195          5              10 8.008721e-41             2
#> 196          6              10 2.714208e-40             2
#> 197          7              10 6.565666e-41             2
#> 198          8              10 1.303176e-40             2
#> 199          9              10 9.424730e-40             2
#> 200         10              10 2.568603e-39             2
ggplot2::fortify(all_flows, flows = "destination")
#>    destination         flow configuration
#> 1            1 3.797696e-13             1
#> 2            1 9.012505e-01             2
#> 3            2 2.151812e-11             1
#> 4            2 1.015101e+00             2
#> 5            3 1.000000e+01             1
#> 6            3 6.006881e+00             2
#> 7            4 5.758534e-14             1
#> 8            4 8.877028e-01             2
#> 9            5 2.556785e-13             1
#> 10           5 6.969534e-01             2
#> 11           6 2.669081e-12             1
#> 12           6 5.669144e-39             2
#> 13           7 6.177980e-13             1
#> 14           7 4.921116e-01             2
#> 15           8 2.764605e-09             1
#> 16           8 7.083933e-39             2
#> 17           9 1.980660e-13             1
#> 18           9 2.208829e-35             2
#> 19          10 8.010648e-14             1
#> 20          10 4.532608e-39             2
destination_names(all_flows) <- letters[1:10]
ggplot2::fortify(all_flows, flows = "attractiveness", with_names = TRUE)
#>    destination attractiveness configuration name
#> 1            1   1.158330e-08             1    a
#> 2            1   9.012507e-01             2    a
#> 3            2   9.195095e-08             1    b
#> 4            2   1.015101e+00             2    b
#> 5            3   9.999996e+00             1    c
#> 6            3   6.006879e+00             2    c
#> 7            4   2.986910e-09             1    d
#> 8            4   8.877027e-01             2    d
#> 9            5   7.357190e-09             1    e
#> 10           5   6.969511e-01             2    e
#> 11           6   4.164227e-08             1    f
#> 12           6   3.293185e-31             2    f
#> 13           7   1.320226e-08             1    g
#> 14           7   4.921164e-01             2    g
#> 15           8   4.180297e-06             1    h
#> 16           8   4.406074e-31             2    h
#> 17           9   7.420028e-09             1    i
#> 18           9   1.989296e-28             2    i
#> 19          10   4.266817e-09             1    j
#> 20          10   2.466802e-31             2    j
```
