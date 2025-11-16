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
[`location_names()`](https://fabrice-rossi.github.io/blvim/reference/location_names.md),
[`flows()`](https://fabrice-rossi.github.io/blvim/reference/flows.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- log(french_cities$population[1:10])
attractiveness <- log(french_cities$area[1:10])
## rescale to production
attractiveness <- attractiveness / sum(attractiveness) * sum(production)
## simple case (no positions and default names)
model <- static_blvim(distances, production, 1.5, 1 / 500, attractiveness)
head(flows_df(model))
#>   origin_idx destination_idx      flow origin_name destination_name
#> 1          1               1 4.0969692       75056            75056
#> 2          2               1 0.7071741       13055            75056
#> 3          3               1 1.3143837       69123            75056
#> 4          4               1 0.8712958       31555            75056
#> 5          5               1 0.5849998       06088            75056
#> 6          6               1 1.9685175       44109            75056
## with location data
positions <- as.matrix(french_cities[1:10, c("th_longitude", "th_latitude")])
model <- static_blvim(distances, production, 1.5, 1 / 500, attractiveness,
  origin_data = list(positions = positions),
  destination_data = list(positions = positions)
)
head(flows_df(model))
#>   origin_idx destination_idx      flow origin_name origin_th_longitude
#> 1          1               1 4.0969692       75056              2.3525
#> 2          2               1 0.7071741       13055              5.3699
#> 3          3               1 1.3143837       69123              4.8350
#> 4          4               1 0.8712958       31555              1.4442
#> 5          5               1 0.5849998       06088              7.2715
#> 6          6               1 1.9685175       44109             -1.5543
#>   origin_th_latitude destination_name destination_th_longitude
#> 1            48.8564            75056                   2.3525
#> 2            43.2966            75056                   2.3525
#> 3            45.7676            75056                   2.3525
#> 4            43.6046            75056                   2.3525
#> 5            43.6960            75056                   2.3525
#> 6            47.2184            75056                   2.3525
#>   destination_th_latitude
#> 1                 48.8564
#> 2                 48.8564
#> 3                 48.8564
#> 4                 48.8564
#> 5                 48.8564
#> 6                 48.8564
## with names
origin_names(model) <- french_cities$name[1:10]
destination_names(model) <- french_cities$name[1:10]
head(flows_df(model))
#>   origin_idx destination_idx      flow origin_name origin_th_longitude
#> 1          1               1 4.0969692       Paris              2.3525
#> 2          2               1 0.7071741   Marseille              5.3699
#> 3          3               1 1.3143837        Lyon              4.8350
#> 4          4               1 0.8712958    Toulouse              1.4442
#> 5          5               1 0.5849998        Nice              7.2715
#> 6          6               1 1.9685175      Nantes             -1.5543
#>   origin_th_latitude destination_name destination_th_longitude
#> 1            48.8564            Paris                   2.3525
#> 2            43.2966            Paris                   2.3525
#> 3            45.7676            Paris                   2.3525
#> 4            43.6046            Paris                   2.3525
#> 5            43.6960            Paris                   2.3525
#> 6            47.2184            Paris                   2.3525
#>   destination_th_latitude
#> 1                 48.8564
#> 2                 48.8564
#> 3                 48.8564
#> 4                 48.8564
#> 5                 48.8564
#> 6                 48.8564
```
