# Package index

## Creating spatial interaction models

Functions for creating spatial interaction models and extracting their
parameters.

- [`static_blvim()`](https://fabrice-rossi.github.io/blvim/reference/static_blvim.md)
  : Compute flows between origin and destination locations
- [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
  : Compute an equilibrium solution of the Harris and Wilson model
- [`blvim_gradient_control()`](https://fabrice-rossi.github.io/blvim/reference/blvim_gradient_control.md)
  : Control parameters for the blvim gradient algorithms
- [`blvim_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_initialise.md)
  : Specify how initial attractivenesses are generated
- [`costs()`](https://fabrice-rossi.github.io/blvim/reference/costs.md)
  : Extract the cost matrix used to compute a model
- [`inverse_cost()`](https://fabrice-rossi.github.io/blvim/reference/inverse_cost.md)
  : Extract the inverse cost scale parameter used to compute a model
- [`return_to_scale()`](https://fabrice-rossi.github.io/blvim/reference/return_to_scale.md)
  : Extract the return to scale parameter used to compute a model
- [`sim_conversion()`](https://fabrice-rossi.github.io/blvim/reference/sim_conversion.md)
  : Return the conversion factors between attractivenesses and incoming
  flows
- [`sim_is_bipartite()`](https://fabrice-rossi.github.io/blvim/reference/sim_is_bipartite.md)
  : Report whether a spatial interaction model is bipartite
- [`location_names()`](https://fabrice-rossi.github.io/blvim/reference/location_names.md)
  [`` `location_names<-`() ``](https://fabrice-rossi.github.io/blvim/reference/location_names.md)
  : Names of origin and destination locations in a spatial interaction
  model
- [`location_positions()`](https://fabrice-rossi.github.io/blvim/reference/location_positions.md)
  [`` `location_positions<-`() ``](https://fabrice-rossi.github.io/blvim/reference/location_positions.md)
  : Positions of origin and destination locations in a spatial
  interaction model
- [`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)
  : Compute the incoming flow at each destination location
- [`destination_names()`](https://fabrice-rossi.github.io/blvim/reference/destination_names.md)
  [`` `destination_names<-`() ``](https://fabrice-rossi.github.io/blvim/reference/destination_names.md)
  : Names of destination locations in a spatial interaction model
- [`destination_positions()`](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md)
  [`` `destination_positions<-`() ``](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md)
  : Positions of destination locations in a spatial interaction model
- [`origin_names()`](https://fabrice-rossi.github.io/blvim/reference/origin_names.md)
  [`` `origin_names<-`() ``](https://fabrice-rossi.github.io/blvim/reference/origin_names.md)
  : Names of origin locations in a spatial interaction model
- [`origin_positions()`](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md)
  [`` `origin_positions<-`() ``](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md)
  : Positions of origin locations in a spatial interaction model

## Using spatial interaction models

Functions for getting properties of spatial interaction models.

- [`attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/attractiveness.md)
  : Extract the attractivenesses from a spatial interaction model object
- [`initial_attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/initial_attractiveness.md)
  : Extract the initial attractivenesses from a spatial interaction
  model object
- [`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)
  : Compute the incoming flow at each destination location
- [`diversity()`](https://fabrice-rossi.github.io/blvim/reference/diversity.md)
  : Compute the diversity of the destination locations in a spatial
  interaction model
- [`flows()`](https://fabrice-rossi.github.io/blvim/reference/flows.md)
  : Extract the flow matrix from a spatial interaction model object
- [`flows_df()`](https://fabrice-rossi.github.io/blvim/reference/flows_df.md)
  : Extract the flow matrix from a spatial interaction model object in
  data frame format
- [`production()`](https://fabrice-rossi.github.io/blvim/reference/production.md)
  : Extract the production constraints from a spatial interaction model
  object
- [`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md)
  : Compute the potential of a spatial interaction model
- [`sim_residual_jacobian()`](https://fabrice-rossi.github.io/blvim/reference/sim_residual_jacobian.md)
  : Compute the Jacobian of the residual map G

## Monitoring the construction of spatial interaction models

Functions for getting diagnostics of the algorithms used to build the
models.

- [`sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/sim_converged.md)
  : Report whether the construction of a spatial interaction model
  converged
- [`sim_diagnostic()`](https://fabrice-rossi.github.io/blvim/reference/sim_diagnostic.md)
  : Return a full diagnostic of the algorithm used to build a spatial
  interaction model
- [`sim_iterations()`](https://fabrice-rossi.github.io/blvim/reference/sim_iterations.md)
  : Return the number of iterations used to produce a spatial
  interaction model
- [`sim_logs()`](https://fabrice-rossi.github.io/blvim/reference/sim_logs.md)
  : Extract summaries of individual algorithm runs
- [`sim_runs()`](https://fabrice-rossi.github.io/blvim/reference/sim_runs.md)
  : Extract spatial interaction models produced by individual runs

## Non-bipartite models

Functions that apply only to non-bipartite models.

- [`is_terminal()`](https://fabrice-rossi.github.io/blvim/reference/is_terminal.md)
  : Report whether locations are terminals
- [`nd_graph()`](https://fabrice-rossi.github.io/blvim/reference/nd_graph.md)
  : Compute the Nystuen and Dacey graph for a spatial interaction model
- [`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)
  : Compute terminals for a spatial interaction model

## Multiple models

Functions to create and use multiple spatial interaction models using a
grid of parameters.

- [`costs(`*`<sim_list>`*`)`](https://fabrice-rossi.github.io/blvim/reference/costs.sim_list.md)
  : Extract the common cost matrix from a collection of spatial
  interaction models
- [`grid_attractiveness()`](https://fabrice-rossi.github.io/blvim/reference/grid_attractiveness.md)
  : Extract all the attractivenesses from a collection of spatial
  interaction models
- [`grid_autoplot()`](https://fabrice-rossi.github.io/blvim/reference/grid_autoplot.md)
  : Create a complete ggplot for spatial interaction models in a data
  frame
- [`grid_blvim()`](https://fabrice-rossi.github.io/blvim/reference/grid_blvim.md)
  : Compute a collection of Boltzmann-Lotka-Volterra model solutions
- [`grid_destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/grid_destination_flow.md)
  : Extract all the destination flows from a collection of spatial
  interaction models
- [`grid_diversity()`](https://fabrice-rossi.github.io/blvim/reference/grid_diversity.md)
  : Compute diversities for a collection of spatial interaction models
- [`grid_is_terminal()`](https://fabrice-rossi.github.io/blvim/reference/grid_is_terminal.md)
  : Extract all terminal statuses from a collection of spatial
  interaction models
- [`grid_sim_converged()`](https://fabrice-rossi.github.io/blvim/reference/grid_sim_converged.md)
  : Report the convergence statuses of a collection of spatial
  interaction models
- [`grid_sim_iterations()`](https://fabrice-rossi.github.io/blvim/reference/grid_sim_iterations.md)
  : Return the numbers of iterations used to produce a collection of
  spatial interaction models
- [`grid_sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/grid_sim_potential.md)
  : Compute the potentials of a collection of spatial interaction models
- [`grid_var_autoplot()`](https://fabrice-rossi.github.io/blvim/reference/grid_var_autoplot.md)
  : Create a complete variability plot for spatial interaction models in
  a data frame
- [`median(`*`<sim_list>`*`)`](https://fabrice-rossi.github.io/blvim/reference/median.sim_list.md)
  : Compute the "median" of a collection of spatial interaction models
- [`quantile(`*`<sim_list>`*`)`](https://fabrice-rossi.github.io/blvim/reference/quantile.sim_list.md)
  : Compute quantiles of the flows in a collection of spatial
  interaction models
- [`sim_df()`](https://fabrice-rossi.github.io/blvim/reference/sim_df.md)
  : Create a spatial interaction models data frame from a collection of
  interaction models
- [`` `$<-`( ``*`<sim_df>`*`)`](https://fabrice-rossi.github.io/blvim/reference/sim_df_extract.md)
  [`` `[[<-`( ``*`<sim_df>`*`)`](https://fabrice-rossi.github.io/blvim/reference/sim_df_extract.md)
  [`` `[`( ``*`<sim_df>`*`)`](https://fabrice-rossi.github.io/blvim/reference/sim_df_extract.md)
  [`` `[<-`( ``*`<sim_df>`*`)`](https://fabrice-rossi.github.io/blvim/reference/sim_df_extract.md)
  : Extract or replace parts of a SIM data frame
- [`` `names<-`( ``*`<sim_df>`*`)`](https://fabrice-rossi.github.io/blvim/reference/names-set-.sim_df.md)
  : Set the column names of a SIM data frame
- [`sim_column()`](https://fabrice-rossi.github.io/blvim/reference/sim_column.md)
  : Get the collection of spatial interaction models from a SIM data
  frame
- [`sim_distance()`](https://fabrice-rossi.github.io/blvim/reference/sim_distance.md)
  : Compute all pairwise distances between the spatial interaction
  models in a collection
- [`sim_list()`](https://fabrice-rossi.github.io/blvim/reference/sim_list.md)
  : Create a sim_list object from a list of spatial interaction models
- [`c(`*`<sim_list>`*`)`](https://fabrice-rossi.github.io/blvim/reference/c.sim_list.md)
  : Combine multiple sim_list objects into a single one
- [`as.data.frame(`*`<sim_list>`*`)`](https://fabrice-rossi.github.io/blvim/reference/as.data.frame.sim_list.md)
  : Coerce a collection of spatial interaction models to a data frame
- [`summary(`*`<sim_list>`*`)`](https://fabrice-rossi.github.io/blvim/reference/summary.sim_list.md)
  [`print(`*`<summary_sim_list>`*`)`](https://fabrice-rossi.github.io/blvim/reference/summary.sim_list.md)
  : Summary of a collection of spatial interaction models

## Graphical representations

Functions that provide graphical representations of spatial interaction
models.

- [`autoplot(`*`<sim>`*`)`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim.md)
  : Create a complete ggplot for a spatial interaction model
- [`autoplot(`*`<sim_df>`*`)`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_df.md)
  : Create a complete ggplot for a spatial interaction models data frame
- [`autoplot(`*`<sim_list>`*`)`](https://fabrice-rossi.github.io/blvim/reference/autoplot.sim_list.md)
  : Create a complete variability plot for a collection of spatial
  interaction models
- [`fortify(`*`<sim>`*`)`](https://fabrice-rossi.github.io/blvim/reference/fortify.sim.md)
  : Turn a spatial interaction model into a data frame
- [`fortify(`*`<sim_list>`*`)`](https://fabrice-rossi.github.io/blvim/reference/fortify.sim_list.md)
  : Turn a collection of spatial interaction models into a data frame
- [`grid_autoplot()`](https://fabrice-rossi.github.io/blvim/reference/grid_autoplot.md)
  : Create a complete ggplot for spatial interaction models in a data
  frame
- [`grid_var_autoplot()`](https://fabrice-rossi.github.io/blvim/reference/grid_var_autoplot.md)
  : Create a complete variability plot for spatial interaction models in
  a data frame

## Helper functions

- [`sample_weighted_simplex()`](https://fabrice-rossi.github.io/blvim/reference/sample_weighted_simplex.md)
  : Sample points from a weighted simplex
- [`blvim_simplex_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_simplex_initialise.md)
  : Generate initial attractivenesses from the weighted simplex

## Data sets

- [`french_cities`](https://fabrice-rossi.github.io/blvim/reference/french_cities.md)
  : French cities
- [`french_cities_distances`](https://fabrice-rossi.github.io/blvim/reference/french_cities_distances.md)
  [`french_cities_times`](https://fabrice-rossi.github.io/blvim/reference/french_cities_distances.md)
  : Distances and travel times between French cities
- [`french_departments`](https://fabrice-rossi.github.io/blvim/reference/french_departments.md)
  : French departments
- [`french_regions`](https://fabrice-rossi.github.io/blvim/reference/french_regions.md)
  : French regions
