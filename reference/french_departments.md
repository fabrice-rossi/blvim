# French departments

This data set contains the list of all French departments. It can be
joined with the
[french_regions](https://fabrice-rossi.github.io/blvim/reference/french_regions.md)
or the
[french_cities](https://fabrice-rossi.github.io/blvim/reference/french_cities.md)
data set. The data set was extracted from the INSEE open data in
November 2025. These data are distributed under the [French "Open
Licence"](https://www.etalab.gouv.fr/wp-content/uploads/2014/05/Open_Licence.pdf).

## Usage

``` r
french_departments
```

## Format

A `data.frame` with 101 rows and 3 columns

- department:

  The code of the department in the official geographical code of 2025
  (OGC)

- region:

  The code of the region of the city in the OGC (see
  [french_regions](https://fabrice-rossi.github.io/blvim/reference/french_regions.md))

- name:

  The name of the department

## Source

INSEE Official Geographical Code (2025)
<https://www.data.gouv.fr/datasets/code-officiel-geographique-cog/>
<https://www.data.gouv.fr/api/1/datasets/r/91a95bee-c7c8-45f9-a8aa-f14cc4697545>

## See also

[french_cities](https://fabrice-rossi.github.io/blvim/reference/french_cities.md)
and
[french_regions](https://fabrice-rossi.github.io/blvim/reference/french_regions.md)
