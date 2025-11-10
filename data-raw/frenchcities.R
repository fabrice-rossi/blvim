library(data.table)
library(httr2)

cache_dir <- file.path("data-raw", "cache")

## Insee city list
french_cities_insee_file <- file.path(cache_dir, "french_cities_insee.csv.gz")
if (!file.exists(french_cities_insee_file)) {
  cli::cli_abort("I need the city information (see README.md)")
}
french_cities_insee <- fread(french_cities_insee_file)

## Insee geography
code_cities_file <- file.path(cache_dir, "cog", "v_commune_2025.csv")
if (!file.exists(code_cities_file)) {
  cli::cli_abort("I need the official geographical code (see README.md)")
}
code_cities <- fread(code_cities_file)
code_dep <- fread(file.path(cache_dir, "cog", "v_departement_2025.csv"))
code_reg <- fread(file.path(cache_dir, "cog", "v_region_2025.csv"))

french_cities_insee <- code_cities[TYPECOM == "COM", .(id = COM, department = DEP, region = REG)][french_cities_insee, on = "id"]
## we keep only cities in the main metropolitan area
big_cities <- french_cities_insee[!is.na(department) & region >= 11 & population >= 50000 & region != 94, ]

## Coordinates
big_cities_geo_file <- file.path(cache_dir, "big_cities_geo.csv.gz")
if (!file.exists(big_cities_geo_file)) {
  cli::cli_abort("I need the city coordinnates (see README.md)")
}
big_cities_geo <- fread(big_cities_geo_file, colClasses = list(character = "id"))

## Distances
## Replace "big_cities_distances_osm.csv.gz" by "big_cities_distances.csv.gz"
## to use the IGN distance if ign_geoservices.R was used.
big_cities_distances_file <- file.path(cache_dir, "big_cities_distances_osm.csv.gz")
if (!file.exists(big_cities_distances_file)) {
  cli::cli_abort("I need the city distances (see README.md)")
}

full_distances <- fread(big_cities_distances_file,
  colClasses = list(character = c("from", "to"))
)

setorder(full_distances, to, from)
setorder(big_cities, id)
french_cities_distances <- matrix(full_distances$distance, nrow = nrow(big_cities))
rownames(french_cities_distances) <- big_cities$id
colnames(french_cities_distances) <- big_cities$id
french_cities_times <- matrix(full_distances$duration, nrow = nrow(big_cities))
rownames(french_cities_times) <- big_cities$id
colnames(french_cities_times) <- big_cities$id
pop_order <- order(big_cities$population, decreasing = TRUE)
french_cities_distances <- french_cities_distances[pop_order, pop_order]
french_cities_times <- french_cities_times[pop_order, pop_order]

## export
french_cities <- big_cities[big_cities_geo[, .(id, area = surface / 100, th_longitude, th_latitude, centre_longitude = ctr_longitude, centre_latitude = ctr_latitude)],
  on = "id"
][, c(1, 4, 2:3, 5:10)]
Encoding(french_cities$name) <- "UTF-8"
setorder(french_cities, -population)
setDF(french_cities)
french_departments <- code_dep[, .(department = DEP, region = REG, name = NCCENR)]
Encoding(french_departments$name) <- "UTF-8"
french_regions <- code_reg[, .(region = REG, name = NCCENR)]
Encoding(french_regions$name) <- "UTF-8"
setDF(french_departments)
setDF(french_regions)

usethis::use_data(
  french_cities, french_departments, french_regions,
  french_cities_distances, french_cities_times,
  overwrite = TRUE
)
