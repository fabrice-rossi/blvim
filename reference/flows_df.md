# Extract the flow matrix from a spatial interaction model object in data frame format

Extract the flow matrix from a spatial interaction model object in data
frame format

## Usage

``` r
flows_df(sim, ...)
```

## Arguments

- sim:

  a spatial interaction model object

- ...:

  additional parameters (not used currently)

## Value

a data frame of flows between origin locations and destination locations
with additional content if available (see Details).

## Details

This function extracts the flow matrix in a long format. Each row
contains the flow between an origin location and a destination location.
The resulting data frame has at least three columns:

- `origin_idx`: identifies the origin location by its index from 1 to
  the number of origin locations

- `destination_idx`: identifies the destination location by its index
  from 1 to the number of destination locations

- `flow`: the flow between the corresponding location

In addition, if location information is available, it will be included
in the data frame as follows:

- location names are included using columns `origin_name` or
  `destination_name`

- positions are included using 2 or 3 columns (per location type, origin
  or destination) depending on the number of dimensions used for the
  location. The names of the columns are by default `origin_x`,
  `origin_y` and `origin_z` ( and equivalent names for destination
  location) unless coordinate names are specified in the location
  positions. In this latter case, the names are prefixed by `origin_` or
  `destination_`. For instance, if the destination location position
  coordinates are named `"longitude"` and `"latitude"`, the resulting
  columns will be `destination_longitude` and `destination_latitude`.

## See also

[`location_positions()`](https://fabrice-rossi.github.io/blvim/reference/location_positions.md),
[`location_names()`](https://fabrice-rossi.github.io/blvim/reference/location_names.md)

## Examples

``` r
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- c(2, rep(1, 9))
## simple case (no positions and default names)
model <- static_blvim(distances, production, 1.5, 1, attractiveness)
head(flows_df(model))
#>   origin_idx destination_idx      flow origin_name destination_name
#> 1          1               1 0.5157087           1                1
#> 2          2               1 0.1673249           2                1
#> 3          3               1 0.1451588           3                1
#> 4          4               1 0.2120735           4                1
#> 5          5               1 0.2594128           5                1
#> 6          6               1 0.2453039           6                1
## with location data
model <- static_blvim(distances, production, 1.5, 1, attractiveness,
  origin_data = list(positions = positions),
  destination_data = list(positions = positions)
)
head(flows_df(model))
#>   origin_idx destination_idx      flow origin_name     origin_x   origin_y
#> 1          1               1 0.5157087           1  0.239959572 -0.3082114
#> 2          2               1 0.1673249           2  0.060898893  1.0120018
#> 3          3               1 0.1451588           3 -2.177576028 -0.9190516
#> 4          4               1 0.2120735           4 -0.117860143  0.5633801
#> 5          5               1 0.2594128           5  0.112294787  0.3224827
#> 6          6               1 0.2453039           6  0.007886198  0.3666744
#>   destination_name destination_x destination_y
#> 1                1     0.2399596    -0.3082114
#> 2                1     0.2399596    -0.3082114
#> 3                1     0.2399596    -0.3082114
#> 4                1     0.2399596    -0.3082114
#> 5                1     0.2399596    -0.3082114
#> 6                1     0.2399596    -0.3082114
```
