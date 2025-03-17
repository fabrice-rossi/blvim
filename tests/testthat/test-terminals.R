test_that("terminals detects errors", {
  config <- create_locations(40, 50, seed = 0)
  model <- blvim(config$costs, config$X, 1.5, 2, config$Z)
  ## not a square model
  expect_error(terminals(model))
  config <- create_locations(40, 40, seed = 0, symmetric = TRUE)
  model <- blvim(config$costs, config$X, 1.5, 2, config$Z)
  ## unexpected definition
  expect_error(terminals(model, definition = "HD"))
})

test_that("terminals returns only terminals", {
  for (s in 0:3) {
    config <- create_locations(30, 30, seed = s, symmetric = TRUE)
    model <- blvim(config$costs, config$X, 1.3, 10 / config$scale, config$Z)
    Y <- flows(model)
    D <- destination_flow(model)
    nd_term <- terminals(model, "ND")
    for (k in nd_term) {
      ## max_k is the location to which k is sending the most
      max_k <- which.max(Y[k, ])
      ## k should be more important
      expect_gte(D[k], D[max_k])
    }
    rw_term <- terminals(model, "RW")
    ## RW terminals are less demanding than ND terminals
    expect_contains(rw_term, nd_term)
    for (k in rw_term) {
      expect_gte(D[k], max(Y[k, ]))
    }
  }
})

test_that("terminals returns all terminals", {
  for (s in 0:3) {
    config <- create_locations(30, 30, seed = s + 4)
    model <- blvim(config$costs, config$X, 1.3, 10 / config$scale, config$Z)
    Y <- flows(model)
    D <- destination_flow(model)
    nd_term <- terminals(model, "ND")
    for (k in setdiff(1:length(D), nd_term)) {
      ## max_k is the location to which k is sending the most
      max_k <- which.max(Y[k, ])
      ## k should be less important
      expect_lt(D[k], D[max_k])
    }
    rw_term <- terminals(model, "RW")
    for (k in setdiff(1:length(D), rw_term)) {
      expect_lt(D[k], max(Y[k, ]))
    }
  }
})
