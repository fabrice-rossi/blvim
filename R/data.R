#' French cities
#'
#' French cities with 50,000 inhabitants or more.
#'
#' This data set describes all Metropolitan France cities with 50,000 or more
#' inhabitants in 2022, excluding Corsican cities. It contains 121 cities
#' described by 8 variables. The data frame is sorted in decreasing population
#' order, making it straightforward to select the most populated cities. The
#' same order is used for rows and columns in distance matrices
#' [french_cities_distance] and [french_cities_time].
#'
#' The population and administrative information was collected from the INSEE
#' open data in November 2025. These data are distributed under the
#' \href{https://www.etalab.gouv.fr/wp-content/uploads/2014/05/Open_Licence.pdf}{French
#' "Open Licence"}. Geographical coordinates and areas have been obtained from the
#' \href{https://geo.api.gouv.fr/}{Geo API} in November 2025 and are also
#' available under the French "Open Licence".
#'
#' @format A `data.frame` with 121 rows and 9 columns
#' \describe{
#' \item{id}{The INSEE code of the city according to the official geographical
#' code of 2025 (OGC)}
#' \item{name}{The name of the city}
#' \item{department}{The code of the department of the city in the OGC (see [french_departments])}
#' \item{region}{The code of the region of the city in the OGC (see [french_regions])}
#' \item{population}{The population of the city in 2022}
#' \item{area}{Area of the city in squared kilometers}
#' \item{th_latitude}{The latitude of the of town hall the city (epsg:4326)}
#' \item{th_longitude}{The longitude of the town hall of the city (epsg:4326)}
#' \item{center_latitude}{The latitude of the centre of the city (epsg:4326)}
#' \item{center_longitude}{The longitude of the centre of the city (epsg:4326)}
#' }
#' @seealso [french_departments], [french_regions], [french_cities_distance] and
#'   [french_cities_time]
#' @source INSEE Population census - Main extraction (2022)
#'   <https://catalogue-donnees.insee.fr/en/catalogue/recherche/DS_RP_POPULATION_PRINC>
#'
#'   INSEE Official Geographical Code (2025)
#'   <https://www.data.gouv.fr/datasets/code-officiel-geographique-cog/>
#'   <https://www.data.gouv.fr/api/1/datasets/r/91a95bee-c7c8-45f9-a8aa-f14cc4697545>
#'
#'   Geo API (2025) <https://geo.api.gouv.fr/>
#'
"french_cities"

#' French departments
#'
#' This data set contains the list of all French departments. It can be joined
#' with the [french_regions] or the [french_cities] data set. The data set was
#' extracted from the INSEE open data in November 2025. These data are
#' distributed under the
#' \href{https://www.etalab.gouv.fr/wp-content/uploads/2014/05/Open_Licence.pdf}{French
#' "Open Licence"}.
#'
#' @format A `data.frame` with 101 rows and 3 columns
#' \describe{
#' \item{department}{The code of the department in the official geographical
#' code of 2025 (OGC)}
#' \item{region}{The code of the region of the city in the OGC (see [french_regions])}
#' \item{name}{The name of the department}
#' }
#' @seealso [french_cities] and [french_regions]
#' @source INSEE Official Geographical Code (2025)
#'   <https://www.data.gouv.fr/datasets/code-officiel-geographique-cog/>
#'   <https://www.data.gouv.fr/api/1/datasets/r/91a95bee-c7c8-45f9-a8aa-f14cc4697545>
#'
"french_departments"

#' French regions
#'
#' This data set contains the list of all French regions It can be joined with
#' the [french_departments] or the [french_cities] data set. The data set was
#' extracted from the INSEE open data in November 2025. These data are
#' distributed under the
#' \href{https://www.etalab.gouv.fr/wp-content/uploads/2014/05/Open_Licence.pdf}{French
#' "Open Licence"}.
#'
#' @format A `data.frame` with 18 rows and 2 columns
#' \describe{
#' \item{region}{The code of the region in the official geographical
#' code of 2025 (OGC)}
#' \item{name}{The name of the region}
#' }
#' @seealso [french_departments] and [french_cities]
#' @source INSEE Official Geographical Code (2025)
#'   <https://www.data.gouv.fr/datasets/code-officiel-geographique-cog/>
#'   <https://www.data.gouv.fr/api/1/datasets/r/91a95bee-c7c8-45f9-a8aa-f14cc4697545>
#'
"french_regions"

#' French cities distances
#'
#' Distances in meters and in minutes between the French cities with at least
#' 50,000 inhabitants ([french_cities]).
#'
#' Both data sets are square matrices of dimension (121, 121). If `D` is one of
#' the matrix, `D[i,j]` is the distance from city of id `rownames(D)[i]` to city
#' id `colnames(D)[j]` expressed in meters (`french_cities_distance`) or in
#' minutes (`french_cities_time`). The distance is measured along the fastest
#' path from `i` to `j` on the French road networks as computed using
#' \href{https://project-osrm.org/}{OSRM} engine (see details below). Ids in
#' column and row names can be used to get information on the cities in the
#' [french_cities] data set (column `id`). Rows and columns are sorted in
#' decreasing population order, as in [french_cities]. Note that the matrices
#' are not symmetric.
#'
#' @section Distance calculation:
#'
#'   The distances and durations have been computed using the
#'   \href{https://project-osrm.org/}{OSRM} engine in version
#'   \href{https://github.com/Project-OSRM/osrm-backend/releases/tag/v6.0.0}{6.0.0}.
#'
#'   Calculations are based on the `car` profile included in OSRM sources for
#'   the 6.0.0 version.
#'
#'   France roads are provided by
#'   \href{https://www.openstreetmap.org}{OpenStreetMap} under the
#'   \href{https://opendatacommons.org/licenses/odbl/}{Open Data Commons Open
#'   Database License (ODbL)}. \href{https://download.geofabrik.de/europe/france.html}{GeoFabrik}
#'   export dated 2025-11-07T21:20:50Z was used.
#'
#' @format matrices with 121 rows and 121 columns
#' @source Geo API (2025) <https://geo.api.gouv.fr/>
#'
#'   OpenStreetMap <https://www.openstreetmap.org>
#'
#'   GeoFabrik <https://download.geofabrik.de/europe/france.html>
#'
#'   OSRM <https://project-osrm.org/>
"french_cities_distance"

#' French cities time
#' @rdname french_cities_distance
"french_cities_time"
