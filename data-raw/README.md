
# French cities data sets
The French cities data sets are created from several official sources. To
reproduce the production of three scripts have to be
executed in a specific order from the root of the project. Downloaded data and
API query results are saved locally. The scripts will not perform download
operations or API queries if the results are already available.

## Insee open data
The first step consists in downloading the [INSEE](https://www.insee.fr/en/accueil) 
[open data](https://catalogue-donnees.insee.fr/en/catalogue/recherche) from the 
web site and the [melodi API](https://portail-api.insee.fr/catalog/api/a890b735-159c-4c91-90b7-35159c7c9126?aq=ALL). 
This is done in the `insee.R` script. We use

 - the population census [main extraction](https://catalogue-donnees.insee.fr/en/catalogue/recherche/DS_RP_POPULATION_PRINC)
 - the [official geographical code](https://www.insee.fr/fr/information/8377162)
 
## Geo API
The second step consists in retrieving the coordinates of a selection of French
cities using the [Geo API](https://geo.api.gouv.fr/). This is also done in the 
`insee.R` script.

## City distances
### IGN geoservices
While the IGN provides a free to use API to obtain road distances and travel
times between arbitrary location in France, the licence of the 
[geoservice API](https://geoservices.ign.fr/documentation/services/services-geoplateforme/itineraire-gpf)
is not specified explicitly. To avoid redistribution issues, the package does not
include those data. However, the `ign_geoservices.R` script can be run to get them
(after running the `insee.R` script). This is a quite long process as the API is
rate limited. In order to use the downloaded data, the `frenchcities.R` script
must be modified (see the associated comments).

### OSRM
The distances and travel times included in the package have been obtained by
running locally an instance of the [OSRM](https://project-osrm.org/) based on
[OpenStreetMap](https://www.openstreetmap.org) open data. This is extremely fast
on a 2025 computer, especially compared to the IGN API. The `osm_osrm.R` script
queries a local OSRM instance to obtain the data.

## R package data inclusion

Once the `insee.R` and `osm_osrm.R`/`ign_geoservices.R` scripts have been 
successfully run, the `frenchcities.R` can be run to include the data in the 
package. 
