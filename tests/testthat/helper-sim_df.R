test_sim_df_modifications <- function(models_df, models) {
  names_before <- names(models_df)
  ## standard modification data.frame style
  models_df$renyi <- grid_diversity(sim_column(models_df), "renyi", 3)
  expect_true(is_sim_df(models_df))
  expect_equal(models_df$renyi, grid_diversity(sim_column(models_df), "renyi", 3))
  expect_equal(names(models_df), c(names_before, "renyi"))
  ## extraction without the sim column
  models_df_nosim <- models_df[c(1:3)]
  expect_true(is_df_not_sim_df(models_df_nosim))
  ## extraction with the sim column
  models_df_sim <- models_df[c("sim", "alpha")]
  expect_true(is_sim_df(models_df_sim))
  ## replacing sim by a non sim_list
  models_df_nosim <- models_df
  models_df_nosim$sim <- NULL
  expect_true(is_df_not_sim_df(models_df_nosim))
  models_df_nosim <- models_df
  models_df_nosim$sim <- grid_diversity(models, "renyi", 1.5)
  expect_true(is_df_not_sim_df(models_df_nosim))
  ## same thing with [[
  models_df_nosim <- models_df
  models_df_nosim[["sim"]] <- NULL
  expect_s3_class(models_df_nosim, "data.frame")
  expect_false(inherits(models_df_nosim, "sim_df"))
  models_df_nosim <- models_df
  models_df_nosim[[6]] <- NULL
  expect_true(is_df_not_sim_df(models_df_nosim))
  models_df_nosim <- models_df
  models_df_nosim[[6]] <- grid_diversity(models, "renyi", 1.5)
  expect_true(is_df_not_sim_df(models_df_nosim))
  ## replacing sim by a sim_list
  models_df_sim <- models_df
  models_df_sim$sim <- models
  expect_true(is_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[[6]] <- models
  expect_true(is_sim_df(models_df_sim))
  ## internal modifications
  models_df_sim <- models_df
  models_df_sim[2, 3] <- 12
  expect_true(is_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, 6] <- models[seq_len(nrow(models_df))]
  expect_true(is_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, "sim"] <- models[seq_len(nrow(models_df))]
  expect_true(is_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, 6] <- models_df$alpha
  expect_true(is_df_not_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, "sim"] <- models_df$beta
  expect_true(is_df_not_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, 6] <- NULL
  expect_true(is_df_not_sim_df(models_df_sim))
  models_df_sim <- models_df
  models_df_sim[, "sim"] <- NULL
  expect_true(is_df_not_sim_df(models_df_sim))
}

test_sim_df_names <- function(models_df, models) {
  expect_equal(sim_column(models_df), models)
  models_df$truc <- models_df$alpha + models_df$beta
  new_names <- paste(names(models_df), "_", sample(letters, ncol(models_df)), sep = "")
  names(models_df) <- new_names
  expect_equal(names(models_df), new_names)
  expect_true(is_sim_df(models_df))
  expect_equal(sim_column(models_df), models)
  models_df_nosim <- models_df
  names(models_df_nosim) <- c(1:5, NA, 7)
  expect_true(is_df_not_sim_df(models_df_nosim))
}
