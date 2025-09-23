test_that("fortify.sim_list returns the expected data frame (destination case)", {
  nb_destinations <- 10
  config <- create_locations(25, nb_destinations, seed = 120)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  for (flows in c("destination", "attractiveness")) {
    destination_names(models) <- LETTERS[1:nb_destinations]
    flow_name <- ifelse(flows == "destination", "flow", "attractiveness")
    models_df <- fortify.sim_list(models, flows = flows)
    ## data frame
    expect_s3_class(models_df, "data.frame")
    ## with the document columns
    expect_named(models_df, c("destination", flow_name, "configuration"))
    ## with the expected configuration indexes
    expect_equal(unique(models_df$configuration), seq_along(models))
    ## with the expected size
    expect_equal(nrow(models_df), length(models) * nb_destinations)
    ## verify content
    for (k in seq_along(models)) {
      ## remove names
      if (flows == "destination") {
        in_flows <- as.numeric(destination_flow(models[[k]]))
      } else {
        in_flows <- as.numeric(attractiveness(models[[k]]))
      }
      in_df <- models_df[models_df$configuration == k, ]
      expect_equal(in_df[[flow_name]], in_flows[in_df$destination])
    }

    ## verify names
    models_df_names <- fortify.sim_list(models, flows = flows, with_names = TRUE)
    expect_s3_class(models_df_names, "data.frame")
    expect_named(models_df_names, c("destination", flow_name, "configuration"))
    expect_equal(unique(models_df_names$configuration), seq_along(models))
    expect_equal(nrow(models_df_names), length(models) * nb_destinations)
    expect_equal(
      models_df_names$destination,
      destination_names(models)[models_df$destination]
    )
    ## make sure missing names does not break the fortify function
    destination_names(models) <- NULL
    expect_no_error(fortify.sim_list(models, flows = flows, with_names = TRUE))
  }
})

test_that("fortify.sim_list returns the expected data frame (full case)", {
  nb_origins <- 15
  nb_destinations <- 10
  config <- create_locations(nb_origins, nb_destinations, seed = 1200)
  alphas <- seq(1.25, 2, by = 0.25)
  betas <- 1 / seq(0.1, 0.5, length.out = 4)
  models <- grid_blvim(config$costs,
    config$X,
    alphas,
    betas,
    config$Z,
    iter_max = 5000,
    epsilon = 0.1,
    precision = .Machine$double.eps^0.5
  )
  models_df <- fortify.sim_list(models, flows = "full", normalisation = "none")
  ## data frame
  expect_s3_class(models_df, "data.frame")
  ## with the document columns
  expect_named(models_df, c("origin_idx", "destination_idx", "flow", "configuration"))
  ## with the expected configuration indexes
  expect_equal(unique(models_df$configuration), seq_along(models))
  ## with the expected size
  expect_equal(nrow(models_df), length(models) * nb_destinations * nb_origins)
  for (k in seq_along(models)) {
    the_flows <- flows(models[[k]])
    in_df <- models_df[models_df$configuration == k, ]
    expect_equal(in_df[["flow"]], the_flows[as.matrix(in_df[1:2])])
  }
  ## test normalisation schemes
  models_df <- fortify.sim_list(models, flows = "full", normalisation = "full")
  for (k in seq_along(models)) {
    the_flows <- flows(models[[k]])
    the_flows <- the_flows / sum(the_flows)
    in_df <- models_df[models_df$configuration == k, ]
    expect_equal(in_df[["flow"]], the_flows[as.matrix(in_df[1:2])])
  }
  models_df <- fortify.sim_list(models, flows = "full", normalisation = "origin")
  for (k in seq_along(models)) {
    the_flows <- flows(models[[k]])
    the_flows <- sweep(the_flows, 1, production(models[[k]]), "/")
    in_df <- models_df[models_df$configuration == k, ]
    expect_equal(in_df[["flow"]], the_flows[as.matrix(in_df[1:2])])
  }
})
