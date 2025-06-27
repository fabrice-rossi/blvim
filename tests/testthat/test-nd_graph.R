test_that("nd_graph extracts the correct flows", {
  for (s in 0:3) {
    config <- create_locations(30, 30, seed = 1984 + s, symmetric = TRUE)
    model <- blvim(config$costs, config$X, 1.3, 10 / config$scale, config$Z, bipartite = FALSE)
    Y <- flows(model)
    nd_is_term <- is_terminal(model)
    nd_graph <- nd_graph(model)
    ## all non terminal must be in from and only them
    expect_equal(sort(nd_graph$from), sort(which(!nd_is_term)))
    ## the flow must be the maximal out flow
    expect_equal(apply(Y[nd_graph$from, ], 1, max), nd_graph$flow)
    ## the flow must point to the maximal out flow destination
    expect_equal(apply(Y[nd_graph$from, ], 1, which.max), nd_graph$to)
    ## same thing for RW
    rw_is_term <- is_terminal(model, "RW")
    rw_graph <- nd_graph(model, "RW")
    ## all non terminal must be in from and only them
    expect_equal(sort(rw_graph$from), sort(which(!rw_is_term)))
    ## the flow must be the maximal out flow
    expect_equal(apply(Y[rw_graph$from, ], 1, max), rw_graph$flow)
    ## the flow must point to the maximal out flow destination
    expect_equal(apply(Y[rw_graph$from, ], 1, which.max), rw_graph$to)
  }
})

test_that("nd_graph detects errors", {
  config <- create_locations(40, 40, seed = 0, symmetric = TRUE)
  ## declared as bipartite
  model <- blvim(config$costs, config$X, 1.5, 2, config$Z)
  expect_error(nd_graph(model))
  config <- create_locations(40, 40, seed = 0, symmetric = TRUE)
  model <- blvim(config$costs, config$X, 1.5, 2, config$Z, bipartite = TRUE)
  ## unexpected definition
  expect_error(nd_graph(model, definition = "HD"))
})
