# French cities distances

Distances in meters and in minutes between the French cities with at
least 50,000 inhabitants
([french_cities](https://fabrice-rossi.github.io/blvim/reference/french_cities.md)).

## Usage

``` r
french_cities_distances

french_cities_times
```

## Format

matrices with 121 rows and 121 columns

An object of class `matrix` (inherits from `array`) with 121 rows and
121 columns.

## Source

Geo API (2025) <https://geo.api.gouv.fr/>

OpenStreetMap <https://www.openstreetmap.org>

GeoFabrik <https://download.geofabrik.de/europe/france.html>

OSRM <https://project-osrm.org/>

## Details

Both data sets are square matrices of dimension (121, 121). If `D` is
one of the matrix, `D[i,j]` is the distance from city of id
`rownames(D)[i]` to city id `colnames(D)[j]` expressed in meters
(`french_cities_distances`) or in minutes (`french_cities_times`). The
distance is measured along the fastest path from `i` to `j` on the
French road networks as computed using [OSRM](https://project-osrm.org/)
engine (see details below). Ids in column and row names can be used to
get information on the cities in the
[french_cities](https://fabrice-rossi.github.io/blvim/reference/french_cities.md)
data set (column `id`). Rows and columns are sorted in decreasing
population order, as in
[french_cities](https://fabrice-rossi.github.io/blvim/reference/french_cities.md).
Note that the matrices are not symmetric.

## Distance calculation

The distances and durations have been computed using the
[OSRM](https://project-osrm.org/) engine in version
[6.0.0](https://github.com/Project-OSRM/osrm-backend/releases/tag/v6.0.0).

Calculations are based on the `car` profile included in OSRM sources for
the 6.0.0 version.

France roads are provided by
[OpenStreetMap](https://www.openstreetmap.org) under the [Open Data
Commons Open Database License
(ODbL)](https://opendatacommons.org/licenses/odbl/) using the
[GeoFabrik](https://download.geofabrik.de/europe/france.html) export
dated 2025-11-07T21:20:50Z was used.
