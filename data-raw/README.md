
# French cities data sets
The French cities data sets are created from several official sources. To
reproduce the production of the data set a collection of scripts has to be
executed in a specific order from the root of the project. Downloaded data and
API query results are saved locally. The scripts will not perform download
operations or API queries is the results are already available.

## Insee open data
The first step consists in downloading the INSEE open data from the web site and
the melodi API. This is done in the `insee.R` script.

## Geo API
The second step consists in retrieving the coordinates of a selection of French
cities using the Geo API. This is also done in the `insee.R` script.

## City distances
### IGN geoservices
While the IGN provides a free to use API to obtain road distances and travel
times between arbitrary location in France, the licence of the API is not
specified explicitly. To avoid redistribution issues, the package does not
include those data. However, the `ign_geoservices.R` could be run to get them
(after running the `insee.R` script). This is a quite long process as the API is
rate limited.

### OSRM
The distances and travel times included in the package have been obtained by
running locally an instance of the [OSRM](https://project-osrm.org/) based on
[OpenStreetMap](https://www.openstreetmap.org) open data. This is extremely fast
on a 2025 computer, especially compared to the IGN API. The `osm_osrm.R` script
queries a local OSRM instance to obtain the data.

## R package data inclusion

Once the `insee.R` and `osm_osrm.R` scripts have been successfully run, the
`frenchcities.R` can be run to include the data in the project. 
