test_that("fortify.sim remove values before the cut off", {
  config <- create_locations(20, 15, seed = 412)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z)
  colnames(config$pp) <- c("from_X", "from_Y")
  origin_positions(model) <- config$pp
  colnames(config$pd) <- c("bli", "foo")
  destination_positions(model) <- config$pd
  ## flows
  ### everything
  m_flows <- ggplot2::fortify(model, with_positions = TRUE, cut_off = 0)
  expect_s3_class(m_flows, "data.frame")
  ### dimension 20*15 rows (all the flows) and 5 columns
  expect_equal(dim(m_flows), c(nrow(config$pp) * nrow(config$pd), 5))
  ### column names
  expect_named(m_flows, c("from_X", "xend", "from_Y", "yend", "flow"))
  ### values (we rely on flows_df which is tested in test-sim)
  expect_equal(m_flows$flow, flows_df(model)$flow)
  ### filtering
  for (co in 10^(-5:0)) {
    sub_m_flows <- ggplot2::fortify(model, with_positions = TRUE, cut_off = co)
    expect_true(all(sub_m_flows$flow >= co))
    expect_equal(m_flows[m_flows$flow >= co, ], sub_m_flows)
  }
  ## destination/attractiveness flows
  for (what in c("destination", "attractiveness")) {
    d_flows <- ggplot2::fortify(model,
      flows = what, with_positions = TRUE,
      cut_off = 0
    )
    expect_s3_class(m_flows, "data.frame")
    ### dimension 15 rows (as many as destinations) and 3 columns
    expect_equal(dim(d_flows), c(nrow(config$pd), 3))
    ### column names (from position)
    expect_named(d_flows, c(colnames(destination_positions(model)), what))
    ### values
    if (what == "destination") {
      expect_equal(d_flows[[what]], destination_flow(model))
    } else {
      expect_equal(d_flows[[what]], attractiveness(model))
    }
    ### filtering
    for (co in 10^(-3:1)) {
      sub_d_flows <- ggplot2::fortify(model,
        flows = what,
        with_positions = TRUE, cut_off = co
      )
      expect_true(all(sub_d_flows[[what]] >= co))
      expect_equal(d_flows[d_flows[[what]] >= co, ], sub_d_flows)
    }
  }
})


test_that("fortify.sim warns about unused parameters", {
  config <- create_locations(20, 15, seed = 412)
  model <- blvim(config$costs, config$X, 1.2, 5, config$Z)
  origin_positions(model) <- config$pp
  colnames(config$pd) <- c("bli", "foo")
  destination_positions(model) <- config$pd
  ## no position
  expect_warning(ggplot2::fortify(model, cut_off = 1))
  ## with names
  expect_warning(ggplot2::fortify(model, with_names = TRUE, cut_off = 1))
})
