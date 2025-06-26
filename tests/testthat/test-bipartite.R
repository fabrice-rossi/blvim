test_that("non bipartite status is checked correctly", {
  config <- create_locations(40, 50, seed = 0)
  ## claim to be non bipartite
  expect_error(static_blvim(config$costs, config$X, 1.5, 2, config$Z, bipartite = FALSE))
  config <- create_locations(40, 40, seed = 0, symmetric = TRUE)
  ## non equal location data
  expect_error(static_blvim(config$costs, config$X, 1.5, 2, config$Z,
    bipartite = FALSE,
    origin_data = list(something = 1:40),
    destination_data = list(something_else = 1:40)
  ))
  expect_error(static_blvim(config$costs, config$X, 1.5, 2, config$Z,
    bipartite = FALSE,
    origin_data = list(positions = config$pp),
    destination_data = list(names = 1:40)
  ))
})

test_that("location data are copied in the non bipartite case", {
  config <- create_locations(40, 40, seed = 0, symmetric = TRUE)
  location_data <- list(
    positions = config$pp,
    names = paste(sample(LETTERS, 40, replace = TRUE), 1:40, sep = "_")
  )
  model <- static_blvim(config$costs, config$X, 1.5, 2, config$Z,
    bipartite = FALSE,
    origin_data = location_data
  )
  expect_equal(destination_positions(model), config$pp)
  expect_equal(destination_names(model), location_data$names)
  model <- static_blvim(config$costs, config$X, 1.5, 2, config$Z,
    bipartite = FALSE,
    destination_data = location_data
  )
  expect_equal(origin_positions(model), config$pp)
  expect_equal(origin_names(model), location_data$names)
})
