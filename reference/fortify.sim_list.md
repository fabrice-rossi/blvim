# Turn a collection of spatial interaction models into a data frame

This function extracts from a collection of spatial interaction models
(represented by a `sim_list`) a data frame in a long format, with one
flow per row. This can be seen as a collection-oriented version of
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
data frame has a `configuration` column that identifies from which
spatial interaction model the other values have been extracted: this is
the index of the model in the original `sim_list`. Depending on `flows`
we have the following representations:

- if `flows="full"`: this is the default case for which the full flow
  matrix of each spatial interaction model is extracted. The data frame
  contains 4 columns:

  - `origin_idx`: identifies the origin location by its index from 1 to
    the number of origin locations

  - `destination_idx`: identifies the destination location by its index
    from 1 to the number of destination locations

  - `flow`: the flow between the corresponding locations. By default
    (`normalisation="none"`), flows are not normalised. If
    `normalisation="origin"`, flows are normalised by origin location:
    the total flow originating from each origin location is normalised
    to 1. If `normalisation="full"`, this normalisation is global: the
    sum of all flows in each model is normalised to 1.

  - `configuration`: the spatial interaction model index

- if `flows="destination"` or `flows="attractiveness"`, the data frame
  contains 3 or 4 columns:

  - `destination`: identifies the destination location by its index from
    1 to the number of destination locations

  - `flow` or `attractiveness` depending on the value of `flows`: this
    contains either the
    [`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)
    or the
    [`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)
    of the destination location

  - `configuration`: the spatial interaction model index

  - `name`: the destination location names if `with_names=TRUE` (the
    column is not present if `with_names=FALSE`)

The normalisation applied when `flows="full"` can improve the
readability of the graphical representation proposed in
[`autoplot.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_list.md)
when the production constraints differ significantly from one origin
location to another.

## See also

[`autoplot.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_list.md),
[`quantile.sim_list()`](https://fabrice-rossi.github.io/blvim/reference/quantile.sim_list.md),
[`fortify.sim()`](https://fabrice-rossi.github.io/blvim/reference/fortify.sim.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
flows_1 <- blvim(distances, production, 1.5, 1, attractiveness)
flows_2 <- blvim(distances, production, 1.25, 2, attractiveness)
all_flows <- sim_list(list(flows_1, flows_2))
ggplot2::fortify(all_flows) ## somewhat similar to row-binding flows_df() results
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
#> 11           1               2 2.741840e-12             1
#> 12           2               2 7.544906e-11             1
#> 13           3               2 1.561789e-11             1
#> 14           4               2 1.815946e-11             1
#> 15           5               2 5.947458e-11             1
#> 16           6               2 2.235736e-11             1
#> 17           7               2 4.354964e-12             1
#> 18           8               2 2.904389e-12             1
#> 19           9               2 1.094792e-11             1
#> 20          10               2 2.154257e-11             1
#> 21           1               3 2.081817e-13             1
#> 22           2               3 1.185831e-12             1
#> 23           3               3 1.323237e-11             1
#> 24           4               3 1.792668e-12             1
#> 25           5               3 9.934641e-13             1
#> 26           6               3 1.842881e-12             1
#> 27           7               3 3.464954e-13             1
#> 28           8               3 2.341647e-13             1
#> 29           9               3 3.075233e-13             1
#> 30          10               3 3.852498e-13             1
#> 31           1               4 7.663280e-12             1
#> 32           2               4 5.075461e-11             1
#> 33           3               4 6.598907e-11             1
#> 34           4               4 8.743908e-11             1
#> 35           5               4 4.000964e-11             1
#> 36           6               4 8.279350e-11             1
#> 37           7               4 1.307311e-11             1
#> 38           8               4 7.714667e-12             1
#> 39           9               4 1.465148e-11             1
#> 40          10               4 1.872042e-11             1
#> 41           1               5 1.125249e-12             1
#> 42           2               5 2.440833e-11             1
#> 43           3               5 5.369802e-12             1
#> 44           4               5 5.874876e-12             1
#> 45           5               5 2.814428e-10             1
#> 46           6               5 7.247038e-12             1
#> 47           7               5 1.660882e-12             1
#> 48           8               5 1.379557e-12             1
#> 49           9               5 7.677830e-12             1
#> 50          10               5 4.204952e-11             1
#> 51           1               6 8.139672e-12             1
#> 52           2               6 6.637206e-11             1
#> 53           3               6 7.205459e-11             1
#> 54           4               6 8.794040e-11             1
#> 55           5               6 5.242262e-11             1
#> 56           6               6 1.103585e-10             1
#> 57           7               6 1.384103e-11             1
#> 58           8               6 8.151971e-12             1
#> 59           9               6 1.713051e-11             1
#> 60          10               6 2.303668e-11             1
#> 61           1               7 2.586502e-12             1
#> 62           2               7 4.108236e-12             1
#> 63           3               7 4.304946e-12             1
#> 64           4               7 4.412422e-12             1
#> 65           5               7 3.817711e-12             1
#> 66           6               7 4.398195e-12             1
#> 67           7               7 4.415646e-12             1
#> 68           8               7 2.600436e-12             1
#> 69           9               7 3.184192e-12             1
#> 70          10               7 3.241253e-12             1
#> 71           1               8 2.548481e-13             1
#> 72           2               8 2.699566e-13             1
#> 73           3               8 2.866555e-13             1
#> 74           4               8 2.565570e-13             1
#> 75           5               8 3.124441e-13             1
#> 76           6               8 2.552331e-13             1
#> 77           7               8 2.562210e-13             1
#> 78           8               8 1.261036e-12             1
#> 79           9               8 4.065356e-13             1
#> 80          10               8 4.545472e-13             1
#> 81           1               9 1.236237e-12             1
#> 82           2               9 4.936183e-12             1
#> 83           3               9 1.826153e-12             1
#> 84           4               9 2.363571e-12             1
#> 85           5               9 8.435127e-12             1
#> 86           6               9 2.601749e-12             1
#> 87           7               9 1.521907e-12             1
#> 88           8               9 1.972055e-12             1
#> 89           9               9 1.170391e-11             1
#> 90          10               9 1.170350e-11             1
#> 91           1              10 6.653935e-13             1
#> 92           2              10 5.227980e-12             1
#> 93           3              10 1.231341e-12             1
#> 94           4              10 1.625472e-12             1
#> 95           5              10 2.486514e-11             1
#> 96           6              10 1.883179e-12             1
#> 97           7              10 8.338322e-13             1
#> 98           8              10 1.186796e-12             1
#> 99           9              10 6.299301e-12             1
#> 100         10              10 9.555125e-11             1
#> 101          1               1 9.207627e-01             2
#> 102          2               1 1.424281e-01             2
#> 103          3               1 1.316637e-01             2
#> 104          4               1 9.242237e-02             2
#> 105          5               1 1.857529e-02             2
#> 106          6               1 6.074735e-02             2
#> 107          7               1 8.023004e-01             2
#> 108          8               1 9.176099e-01             2
#> 109          9               1 6.518806e-01             2
#> 110         10               1 3.124288e-02             2
#> 111          1               2 1.623622e-68             2
#> 112          2               2 1.901763e-66             2
#> 113          3               2 7.532931e-68             2
#> 114          4               2 7.148845e-68             2
#> 115          5               2 1.541173e-67             2
#> 116          6               2 7.122318e-68             2
#> 117          7               2 3.569105e-68             2
#> 118          8               2 1.815602e-68             2
#> 119          9               2 1.832670e-67             2
#> 120         10               2 3.400941e-68             2
#> 121          1               3 2.085544e-14             2
#> 122          2               3 1.046714e-13             2
#> 123          3               3 1.204836e-11             2
#> 124          4               3 1.552257e-13             2
#> 125          5               3 9.581345e-15             2
#> 126          6               3 1.078223e-13             2
#> 127          7               3 5.034061e-14             2
#> 128          8               3 2.629587e-14             2
#> 129          9               3 3.221890e-14             2
#> 130         10               3 2.423386e-15             2
#> 131          1               4 1.022076e-70             2
#> 132          2               4 6.935098e-70             2
#> 133          3               4 1.083718e-69             2
#> 134          4               4 1.335655e-69             2
#> 135          5               4 5.620449e-71             2
#> 136          6               4 7.870926e-70             2
#> 137          7               4 2.591796e-70             2
#> 138          8               4 1.032282e-70             2
#> 139          9               4 2.645070e-70             2
#> 140         10               4 2.069609e-71             2
#> 141          1               5 6.972632e-04             2
#> 142          2               5 5.074850e-02             2
#> 143          3               5 2.270568e-03             2
#> 144          4               5 1.907771e-03             2
#> 145          5               5 8.799692e-01             2
#> 146          6               5 1.908095e-03             2
#> 147          7               5 1.323629e-03             2
#> 148          8               5 1.044454e-03             2
#> 149          9               5 2.298247e-02             2
#> 150         10               5 3.303885e-02             2
#> 151          1               6 7.723279e-02             2
#> 152          2               6 7.943401e-01             2
#> 153          3               6 8.654255e-01             2
#> 154          4               6 9.048868e-01             2
#> 155          5               6 6.462690e-02             2
#> 156          6               6 9.366537e-01             2
#> 157          7               6 1.945872e-01             2
#> 158          8               6 7.720111e-02             2
#> 159          9               6 2.421861e-01             2
#> 160         10               6 2.099090e-02             2
#> 161          1               7 5.960402e-77             2
#> 162          2               7 2.325994e-77             2
#> 163          3               7 2.361042e-77             2
#> 164          4               7 1.741139e-77             2
#> 165          5               7 2.619653e-78             2
#> 166          6               7 1.137047e-77             2
#> 167          7               7 1.513657e-76             2
#> 168          8               7 6.004166e-77             2
#> 169          9               7 6.395416e-77             2
#> 170         10               7 3.175990e-78             2
#> 171          1               8 4.120899e-75             2
#> 172          2               8 7.152622e-76             2
#> 173          3               8 7.455354e-76             2
#> 174          4               8 4.192050e-76             2
#> 175          5               8 1.249574e-76             2
#> 176          6               8 2.726987e-76             2
#> 177          7               8 3.629511e-75             2
#> 178          8               8 1.005530e-73             2
#> 179          9               8 7.424151e-75             2
#> 180         10               8 4.448265e-76             2
#> 181          1               9 2.094793e-65             2
#> 182          2               9 5.166160e-65             2
#> 183          3               9 6.536277e-66             2
#> 184          4               9 7.686068e-66             2
#> 185          5               9 1.967472e-65             2
#> 186          6               9 6.121358e-66             2
#> 187          7               9 2.766325e-65             2
#> 188          8               9 5.312340e-65             2
#> 189          9               9 1.329291e-63             2
#> 190         10               9 6.370479e-65             2
#> 191          1              10 1.307292e-03             2
#> 192          2              10 1.248335e-02             2
#> 193          3              10 6.401635e-04             2
#> 194          4              10 7.830760e-04             2
#> 195          5              10 3.682861e-02             2
#> 196          6              10 6.908412e-04             2
#> 197          7              10 1.788802e-03             2
#> 198          8              10 4.144559e-03             2
#> 199          9              10 8.295081e-02             2
#> 200         10              10 9.147274e-01             2
ggplot2::fortify(all_flows, flows = "destination")
#>    destination         flow configuration
#> 1            1 1.000000e+01             1
#> 2            1 3.769633e+00             2
#> 3            2 2.335500e-10             1
#> 4            2 2.561281e-66             2
#> 5            3 2.052883e-11             1
#> 6            3 1.255780e-11             2
#> 7            4 3.888089e-10             1
#> 8            4 4.705999e-69             2
#> 9            5 3.782359e-10             1
#> 10           5 9.958908e-01             2
#> 11           6 4.594480e-10             1
#> 12           6 4.178131e+00             2
#> 13           7 3.706954e-11             1
#> 14           7 4.164134e-76             2
#> 15           8 4.014035e-12             1
#> 16           8 1.184500e-73             2
#> 17           9 4.830039e-11             1
#> 18           9 1.586411e-63             2
#> 19          10 1.393697e-10             1
#> 20          10 1.056345e+00             2
destination_names(all_flows) <- letters[1:10]
ggplot2::fortify(all_flows, flows = "attractiveness", with_names = TRUE)
#>    destination attractiveness configuration name
#> 1            1   9.999996e+00             1    a
#> 2            1   3.769636e+00             2    a
#> 3            2   5.855114e-07             1    b
#> 4            2   3.316606e-53             2    b
#> 5            3   1.387807e-07             1    c
#> 6            3   1.254849e-09             2    c
#> 7            4   8.663174e-07             1    d
#> 8            4   2.844695e-55             2    d
#> 9            5   6.748134e-07             1    e
#> 10           5   9.958910e-01             2    e
#> 11           6   9.552301e-07             1    f
#> 12           6   4.178128e+00             2    f
#> 13           7   2.229486e-07             1    g
#> 14           7   6.407108e-61             2    g
#> 15           8   6.781175e-08             1    h
#> 16           8   4.448024e-59             2    h
#> 17           9   2.412386e-07             1    i
#> 18           9   4.350236e-51             2    i
#> 19          10   3.951314e-07             1    j
#> 20          10   1.056345e+00             2    j
```
