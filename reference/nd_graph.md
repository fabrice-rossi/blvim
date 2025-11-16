# Compute the Nystuen and Dacey graph for a spatial interaction model

This function computes the most important flows in a spatial interaction
model according to the approach outlined by J. D. Nystuen and M. F.
Dacey (Nystuen & Dacey, 1961. In this work, a *nodal flow* is the
largest flow sent from a non terminal location (based on the definition
of terminals recalled in
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)).
The *nodal structure* is the collection of those flows. They form an
oriented graph that has interesting properties. In particular each
weakly connected component contains a single terminal location which can
be seen as the dominant location of the component. Notice that because
nodal flows are based on terminals, this function applies only to the
non bipartite setting.

## Usage

``` r
nd_graph(sim, definition = c("ND", "RW"), ...)
```

## Arguments

- sim:

  a spatial interaction model object

- definition:

  terminal definition, either `"ND"` (for Nystuen & Dacey, default) or
  `"RW"` (for Rihll & Wilson), see details.

- ...:

  additional parameters

## Value

a data frame describing the Nystuen and Dacey graph a.k.a. the nodal
structure of a spatial interaction model

## Details

In practice, the function computes first the terminals and non terminals
according to either Nystuen & Dacey (1961) or Rihll and Wilson (1991).
Then it extracts the nodal flows. The result of the analysis is returned
as a data frame with three columns:

- `from`: the index of the non terminal origin location

- `to`: the index of destination location of the nodal flow of `from`

- `flow`: the value of the nodal flow

An important aspect of the node structure is that is does not contain
isolated terminals. If a location is a terminal but is never the
receiver of a nodal flow it will not appear in the collection of nodal
flows. It constitutes a a trivial connected component in itself.

## References

Nystuen, J.D. and Dacey, M.F. (1961), "A graph theory interpretation of
nodal regions", Papers and Proceedings of the Regional Science
Association 7: 29-42.
[doi:10.1007/bf01969070](https://doi.org/10.1007/bf01969070)

Rihll, T., and Wilson, A. (1991), "Modelling settlement structures in
ancient Greece: new approaches to the polis", In City and Country in the
Ancient World, Vol. 3, Edited by J. Rich and A. Wallace-Hadrill, 58-95.
London: Routledge.

## See also

[`sim_is_bipartite()`](https://fabrice-rossi.github.io/blvim/reference/sim_is_bipartite.md),
[`is_terminal()`](https://fabrice-rossi.github.io/blvim/reference/is_terminal.md),
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- blvim(distances, production, 1.3, 1 / 250, attractiveness,
  bipartite = FALSE
)
destination_names(model) <- french_cities$name[1:10]
nd_graph(model)
#>            from to      flow
#> Marseille     2  7 0.9488844
#> Lyon          3  7 0.7594037
#> Toulouse      4  7 0.9046308
#> Nice          5  7 0.9488844
#> Nantes        6  1 0.7793698
#> Strasbourg    8  1 0.6655188
#> Bordeaux      9  7 0.7106013
#> Lille        10  1 0.9291846
dist_times <- french_cities_times[1:15, 1:15]
tmodel <- blvim(dist_times, rep(1, 15), 1.3, 1 / 5000, rep(1, 15),
  bipartite = FALSE
)
destination_names(tmodel) <- french_cities$name[1:15]
terminals(tmodel, definition = "RW")
#>      Paris  Marseille       Lyon   Toulouse Strasbourg   Bordeaux     Rennes 
#>          1          2          3          4          8          9         11 
nd_graph(tmodel, "RW")
#>               from to      flow
#> Nice             5  2 0.9620972
#> Nantes           6 11 0.5920218
#> Montpellier      7  2 0.8707174
#> Lille           10  1 0.9551241
#> Toulon          12  2 0.9727568
#> Reims           13  1 0.9308482
#> Saint-Étienne   14  3 0.5062502
#> Le Havre        15  1 0.8529081
```
