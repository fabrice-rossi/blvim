library(data.table)
library(httr2)

download_dir <- file.path("data-raw", "download")
cache_dir <- file.path("data-raw", "cache")
if (!dir.exists(download_dir)) {
  dir.create(download_dir)
}
if (!dir.exists(cache_dir)) {
  dir.create(cache_dir)
}

## Insee city information
## https://catalogue-donnees.insee.fr/en/catalogue/recherche/DS_RP_POPULATION_PRINC
french_cities_insee_file <- file.path(cache_dir, "french_cities_insee.csv.gz")
if (!file.exists(french_cities_insee_file)) {
  melodi_url <- "https://api.insee.fr/melodi/"
  melodi_req <- request(melodi_url)

  catalog_req <- melodi_req |>
    req_url_path_append("catalog/DS_RP_POPULATION_PRINC")
  catalog_resp <- req_perform(catalog_req)
  catalog_json <- catalog_resp |>
    resp_body_string() |>
    jsonlite::fromJSON()

  pop_meta_req <- melodi_req |>
    req_url_path_append("range/DS_RP_POPULATION_PRINC")
  pop_meta_resp <- req_perform(pop_meta_req)
  pop_meta_json <- pop_meta_resp |>
    resp_body_string() |>
    jsonlite::fromJSON()
  pop_meta_raw <- pop_meta_json$range$values[[1]]
  pop_meta_code <- pop_meta_raw$code[pop_meta_raw$type$code == "COM"]
  pop_meta_name <- pop_meta_raw$label$fr[pop_meta_raw$type$code == "COM"]
  pop_meta_id <- pop_meta_raw$id[pop_meta_raw$type$code == "COM"]
  pop_meta <- data.table(id = pop_meta_id, code = pop_meta_code, name = pop_meta_name)

  pop_content_geo <- character(0)
  pop_content_pop <- numeric(0)

  page <- 1
  repeat {
    print(page)
    pop_content_req <- melodi_req |>
      req_url_path_append("data/DS_RP_POPULATION_PRINC") |>
      req_url_query(TIME_PERIOD = "2022", SEX = "_T", AGE = "_T", GEO = "COM", page = page)
    pop_content_resp <- req_perform(pop_content_req)
    pop_content_json <- pop_content_resp |>
      resp_body_string() |>
      jsonlite::fromJSON()
    pop_content_geo <- c(pop_content_geo, pop_content_json$observations$dimensions$GEO)
    pop_content_pop <- c(pop_content_pop, pop_content_json$observations$measures$OBS_VALUE_NIVEAU$value)
    if (pop_content_json$paging$isLast) {
      break
    }
    page <- page + 1
  }

  french_cities <- data.table(id = pop_content_geo, population = pop_content_pop)
  french_cities <- pop_meta[french_cities, on = "id"][, .(id = code, name, population)]
  Encoding(french_cities$name) <- "UFT-8"
  fwrite(french_cities, french_cities_insee_file)
}
french_cities_insee <- fread(french_cities_insee_file)

## Insee geography
## https://www.insee.fr/fr/information/8377162
code_cities_file <- file.path(cache_dir, "cog", "v_commune_2025.csv")
if (!file.exists(code_cities_file)) {
  zip_file <- file.path(download_dir, "cog_ensemble_2025_csv.zip")
  if (!file.exists(zip_file)) {
    download.file("https://www.insee.fr/fr/statistiques/fichier/8377162/cog_ensemble_2025_csv.zip",
      destfile = zip_file
    )
  }
  unzip(zip_file, exdir = file.path(cache_dir, "cog"))
}
code_cities <- fread(code_cities_file)
code_dep <- fread(file.path(cache_dir, "cog", "v_departement_2025.csv"))
code_reg <- fread(file.path(cache_dir, "cog", "v_region_2025.csv"))

french_cities_insee <- code_cities[TYPECOM == "COM", .(id = COM, department = DEP, region = REG)][french_cities_insee, on = "id"]
## we keep only cities in the main metropolitan area
big_cities <- french_cities_insee[!is.na(department) & region >= 11 & population >= 50000 & region != 94, ]

## Coordinates
## https://geo.api.gouv.fr/
big_cities_geo_file <- file.path(cache_dir, "big_cities_geo.csv.gz")
if (!file.exists(big_cities_geo_file)) {
  big_cities_geo <- data.frame(
    name = rep("", nrow(big_cities)),
    id = rep("", nrow(big_cities)),
    surface = rep(0, nrow(big_cities)),
    th_longitude = rep(0, nrow(big_cities)),
    th_latitude = rep(0, nrow(big_cities)),
    ctr_longitude = rep(0, nrow(big_cities)),
    ctr_latitude = rep(0, nrow(big_cities))
  )

  geo_api_req <- request("https://geo.api.gouv.fr") |> req_url_path("communes")
  geo_api_params_th <- list(
    format = "geojson", geometry = "mairie",
    fields = "surface"
  )
  geo_api_params_ctr <- list(format = "geojson", geometry = "centre")
  for (k in seq_len(nrow(big_cities))) {
    th_req <- geo_api_req |>
      req_url_query(code = big_cities$id[k], !!!geo_api_params_th)
    before_th <- Sys.time()
    th_answer <- req_perform(th_req)
    th_answer_json <- th_answer |>
      resp_body_string() |>
      jsonlite::fromJSON()
    big_cities_geo[k, "name"] <- th_answer_json$features$properties$nom
    big_cities_geo[k, "id"] <- as.character(th_answer_json$features$properties$code)
    big_cities_geo[k, "surface"] <- th_answer_json$features$properties$surface
    big_cities_geo[k, c("th_longitude", "th_latitude")] <-
      th_answer_json$features$geometry$coordinates[[1]]
    after_th <- Sys.time()
    delta_th <- difftime(after_th, before_th, units = "secs")[[1]]
    if (delta_th < 0.5) {
      Sys.sleep(1 - delta_th)
    }
    ctr_req <- geo_api_req |>
      req_url_query(code = big_cities$id[k], !!!geo_api_params_ctr)
    before_ctr <- Sys.time()
    ctr_answer <- req_perform(ctr_req)
    ctr_answer_json <- ctr_answer |>
      resp_body_string() |>
      jsonlite::fromJSON()
    big_cities_geo[k, c("ctr_longitude", "ctr_latitude")] <-
      ctr_answer_json$features$geometry$coordinates[[1]]
    after_ctr <- Sys.time()
    delta_ctr <- difftime(after_ctr, before_ctr, units = "secs")[[1]]
    if (delta_ctr < 0.5) {
      Sys.sleep(1 - delta_ctr)
    }
  }
  big_cities_validation <- big_cities_geo[big_cities, on = "id"]
  if (nrow(big_cities_validation[name != i.name, ]) > 0) {
    print(paste(
      "Potential naming issue:",
      big_cities_validation[name != i.name, .(name, i.name)]
    ))
  }
  fwrite(big_cities_geo, big_cities_geo_file)
}
