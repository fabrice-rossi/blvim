test_that("sim objects print as expected", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_snapshot(model)
})

test_that("static sim objects are not produced by iterations", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  expect_equal(sim_iterations(model), 1L)
  expect_equal(sim_converged(model), NA)
})

test_that("sim object validation detects errors", {
  Y <- matrix(1:(10 * 15), nrow = 10, ncol = 15)
  Z <- 1:15
  ## size mismatch
  expect_error(new_sim(Y, Z[-1]))
  expect_error(new_sim(Y[, -1], Z))
  ## name size mismatch
  expect_error(new_sim(Y, Z, origin_names = letters[1:9]))
  expect_error(new_sim(Y, Z, origin_names = letters[1:11]))
  expect_error(new_sim(Y, Z, destination_names = letters[1:10]))
  expect_error(new_sim(Y, Z, destination_names = letters[1:20]))
})

test_that("flow extraction in long format works", {
  config <- create_locations(40, 50, seed = 0)
  model <- static_blvim(config$costs, config$X, 1.5, 1, config$Z)
  ## no names, no positions
  mf_df <- flows_df(model)
  expect_named(mf_df, c("origin_idx", "destination_idx", "flow"))
  expect_equal(nrow(mf_df), 40 * 50)
  model_flows <- flows(model)
  all_equal <- TRUE
  tested <- matrix(FALSE, ncol = ncol(model_flows), nrow = nrow(model_flows))
  for (k in seq_len(nrow(mf_df))) {
    oidx <- mf_df$origin_idx[k]
    didx <- mf_df$destination_idx[k]
    if (mf_df$flow[k] != model_flows[oidx, didx]) {
      all_equal <- FALSE
      break
    } else {
      tested[oidx, didx] <- TRUE
    }
  }
  expect_true(all_equal)
  expect_true(all(tested))
  ## names
  origin_names(model) <- paste(sample(letters, 40, replace = TRUE), 1:40)
  mf_df <- flows_df(model)
  expect_equal(mf_df$origin_name, origin_names(model)[mf_df$origin_idx])
  expect_null(mf_df$destination_names)
  destination_names(model) <- paste(sample(LETTERS, 50, replace = TRUE), 1:50)
  mf_df <- flows_df(model)
  expect_equal(mf_df$destination_name, destination_names(model)[mf_df$destination_idx])
  ## positions
  destination_positions(model) <- matrix(runif(50 * 3), ncol = 3)
  mf_df <- flows_df(model)
  expect_equal(mf_df$destination_x, destination_positions(model)[mf_df$destination_idx, 1])
  expect_equal(mf_df$destination_y, destination_positions(model)[mf_df$destination_idx, 2])
  expect_equal(mf_df$destination_z, destination_positions(model)[mf_df$destination_idx, 3])
  expect_null(mf_df$origin_x)
  o_pos <- matrix(runif(40 * 2), ncol = 2)
  colnames(o_pos) <- c("alice", "bob")
  origin_positions(model) <- o_pos
  mf_df <- flows_df(model)
  expect_null(mf_df$origin_x)
  expect_equal(mf_df$origin_alice, origin_positions(model)[mf_df$origin_idx, 1])
  expect_equal(mf_df$origin_bob, origin_positions(model)[mf_df$origin_idx, 2])
})
