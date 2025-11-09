## https://download.geofabrik.de/europe/france.html
## 2025-11-07T21:20:50Z
## 695ac020e33d7631925b0a8ec86f0e75.
## OSRM v6 https://github.com/Project-OSRM/osrm-backend/releases/tag/v6.0.0
## Car model https://github.com/Project-OSRM/osrm-backend/commit/7ee6245489ac95305bac3115abfef1a0edd6e09c
## This works only if a osrm instance is running locally and has been configured
## to accept at least 121 coordinates in its table queries
library(data.table)
library(httr2)

cache_dir <- file.path("data-raw", "cache")

big_cities_geo_file <- file.path(cache_dir, "big_cities_geo.csv.gz")
if (!file.exists(big_cities_geo_file)) {
  cli::cli_abort("I need the city coordinates (see README.md)")
}
big_cities_geo <- fread(big_cities_geo_file, colClasses = list(character = "id"))
setorder(big_cities_geo, "id")

big_cities_distances_file <- file.path(cache_dir, "big_cities_distances_osm.csv.gz")
if (!file.exists(big_cities_distances_file)) {
  all_coordinates <-
    big_cities_geo[, paste(th_longitude, th_latitude, sep = ",")] |>
    paste(collapse = ";")
  osrm_server <- "http://127.0.0.1:5000/"
  osrm_request <-
    request(osrm_server) |>
    req_url_path("table/v1/car/") |>
    req_url_path_append(all_coordinates) |>
    req_url_query(annotations = "distance,duration")
  osrm_resp <- req_perform(osrm_request)
  osrm_resp_json <-
    osrm_resp |>
    resp_body_string() |>
    jsonlite::fromJSON()
  big_cities_distances <- expand.grid(from = big_cities_geo$id, to = big_cities_geo$id)
  setDT(big_cities_distances)
  big_cities_distances[, `:=`(
    distance = as.vector(osrm_resp_json$distances),
    durations = as.vector(osrm_resp_json$durations)
  )]
  setorder(big_cities_distances, from, to)
  fwrite(big_cities_distances, big_cities_distances_file)
}
