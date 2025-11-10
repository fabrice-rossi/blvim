library(data.table)
library(httr2)

# In this script, we get the distances from the IGN geoservice:
# https://geoservices.ign.fr/documentation/services/services-geoplateforme/itineraire-gpf
# Unfortunately, the licence of the API is not clear enough to be sure that
# redistribution is allowed and if so, under which licence.

cache_dir <- file.path("data-raw", "cache")
big_cities_geo_file <- file.path(cache_dir, "big_cities_geo.csv.gz")
if (!file.exists(big_cities_geo_file)) {
  cli::cli_abort("I need the city coordinates (see README.md)")
}
big_cities_geo <- fread(big_cities_geo_file, colClasses = list(character = "id"))
setorder(big_cities_geo, "id")
## Distances
## https://geoservices.ign.fr/documentation/services/services-geoplateforme/itineraire-gpf
big_cities_distances_file <- file.path(cache_dir, "big_cities_distances.csv.gz")
if (!file.exists(big_cities_distances_file)) {
  big_cities_distances <- expand.grid(from = big_cities_geo$id, to = big_cities_geo$id)
  setDT(big_cities_distances)
  big_cities_distances <- big_cities_distances[from != to, ]
  big_cities_distances <- big_cities_distances[big_cities_geo[, .(id, long_from = th_longitude, lat_from = th_latitude)], on = list(from = id)]
  big_cities_distances <- big_cities_distances[big_cities_geo[, .(id, long_to = th_longitude, lat_to = th_latitude)], on = list(to = id)]
  big_cities_distances[, distance := rep(0, nrow(big_cities_distances))]
  big_cities_distances[, duration := rep(0, nrow(big_cities_distances))]

  geopf_api_params <- list(
    resource = "bdtopo-osrm", profile = "car", optimization = "fastest",
    geometryFormat = "geojson", getSteps = "false"
  )
  geopf_api_req <- request("https://data.geopf.fr/") |>
    req_url_path("navigation/itineraire") |>
    req_url_query(!!!geopf_api_params)

  cli::cli_progress_bar("Computing distances", total = nrow(big_cities_distances))
  for (k in seq_len(nrow(big_cities_distances))) {
    my_req <- geopf_api_req |>
      req_url_query(
        start = big_cities_distances[k, c(long_from, lat_from)],
        end = big_cities_distances[k, c(long_to, lat_to)],
        .multi = "comma"
      )
    before_req <- Sys.time()
    req_answer <- req_perform(my_req)
    req_answer_json <- req_answer |>
      resp_body_string() |>
      jsonlite::fromJSON()
    big_cities_distances$duration[k] <- req_answer_json$duration
    big_cities_distances$distance[k] <- req_answer_json$distance
    after_req <- Sys.time()
    delta_req <- difftime(after_req, before_req, units = "secs")[[1]]
    if (delta_req < 0.2) {
      Sys.sleep(1 - delta_req)
    }
    cli::cli_progress_update()
  }
  cli::cli_progress_done()
  self_distances <- data.table(
    from = big_cities_geo$id,
    to = big_cities_geo$id,
    distance = rep(0, nrow(big_cities_geo)),
    duration = rep(0, nrow(big_cities_geo))
  )
  full_distances <- rbind(
    big_cities_distances[, .(from, to, distance, duration)],
    self_distances
  )
  setorder(full_distances, from, to)
  fwrite(full_distances, big_cities_distances_file)
}
