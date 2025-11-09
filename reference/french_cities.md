# French cities

French cities with 50,000 inhabitants or more.

## Usage

``` r
french_cities
```

## Format

A `data.frame` with 121 rows and 9 columns

- id:

  The INSEE code of the city according to the official geographical code
  of 2025 (OGC)

- name:

  The name of the city

- department:

  The code of the department of the city in the OGC (see
  [french_departments](https://fabrice-rossi.github.io/blvim/reference/french_departments.md))

- region:

  The code of the region of the city in the OGC (see
  [french_regions](https://fabrice-rossi.github.io/blvim/reference/french_regions.md))

- population:

  The population of the city in 2022

- area:

  Area of the city in squared kilometers

- th_latitude:

  The latitude of the of town hall the city (epsg:4326)

- th_longitude:

  The longitude of the town hall of the city (epsg:4326)

- center_latitude:

  The latitude of the centre of the city (epsg:4326)

- center_longitude:

  The longitude of the centre of the city (epsg:4326)

## Source

INSEE Population census - Main extraction (2022)
<https://catalogue-donnees.insee.fr/en/catalogue/recherche/DS_RP_POPULATION_PRINC>

INSEE Official Geographical Code (2025)
<https://www.data.gouv.fr/datasets/code-officiel-geographique-cog/>
<https://www.data.gouv.fr/api/1/datasets/r/91a95bee-c7c8-45f9-a8aa-f14cc4697545>

Geo API (2025) <https://geo.api.gouv.fr/>

## Details

This data set describes all Metropolitan France cities with 50,000 or
more inhabitants in 2022, excluding Corsican cities. It contains 121
cities described by 8 variables. The data frame is sorted in decreasing
population order, making it straightforward to select the most populated
cities. The same order is used for rows and columns in distance matrices
[french_cities_distance](https://fabrice-rossi.github.io/blvim/reference/french_cities_distance.md)
and
[french_cities_time](https://fabrice-rossi.github.io/blvim/reference/french_cities_distance.md).

The population and administrative information was collected from the
INSEE open data in November 2025. These data are distributed under the
[French "Open
Licence"](https://www.etalab.gouv.fr/wp-content/uploads/2014/05/Open_Licence.pdf).
Geographical coordinates and areas have been obtained from the [Geo
API](https://geo.api.gouv.fr/) in November 2025 and are also available
under the French "Open Licence".

## See also

[french_departments](https://fabrice-rossi.github.io/blvim/reference/french_departments.md),
[french_regions](https://fabrice-rossi.github.io/blvim/reference/french_regions.md),
[french_cities_distance](https://fabrice-rossi.github.io/blvim/reference/french_cities_distance.md)
and
[french_cities_time](https://fabrice-rossi.github.io/blvim/reference/french_cities_distance.md)
