# Compute terminals for a spatial interaction model

This function identifies terminals in the locations underlying the given
spatial interaction model. Terminals are locally dominating locations
that essentially send less to other locations than they receive (see
details for formal definitions). As we compare incoming flows to
outgoing flows, terminal computation is restricted to interaction models
in which origin and destination locations are identical, i.e. models
that are not `bipartite`.

## Usage

``` r
terminals(sim, definition = c("ND", "RW"), ...)
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

a vector containing the indexes of the terminals identified from the
flow matrix of the interaction model.

## Details

The notion of terminal used in this function is based on seminal work by
J. D. Nystuen and M. F. Dacey (Nystuen & Dacey, 1961), as well as on the
follow up variation from Rihll & Wislon (1987 and 1991). We assume given
a square flow matrix \\(Y\_{ij})\_{1\leq i\leq n, 1\leq j\leq n}\\. The
incoming flow at location \\j\\ is given by

\$\$D_j=\sum\_{j=i}^{p}Y\_{ij},\$\$

and is used as a measure of importance of this location. Then in Nystuen
& Dacey (1961), location \\j\\ is a "terminal point" (or a "central
city") if

\$\$D_j \geq D\_{m(j)},\$\$

where \\m(j)\\ is such that

\$\$\forall l,\quad Y\_{jl}\leq Y\_{jm(j)}.\$\$

In words, \\j\\ is a terminal if the location \\m(j)\\ to which it sends
its largest flow is less important than \\j\\ itself, in terms of
incoming flows. This is the definition used by the function when
`definition` is `"ND"`.

Rihll & Wilson (1987) use a modified version of this definition
described in details in Rihll and Wilson (1991). With this relaxed
version, location \\j\\ is a terminal if

\$\$\forall i,\quad D_j \geq Y\_{ij}.\$\$

In words, \\j\\ is a terminal if it receives more flows than it is
sending to each other location. It is easy to see that each Nystuen &
Dacey terminal is a Rihll & Wilson terminal, but the reverse is false in
general. The function use the Rihll & Wilson definition when
`definition` is `"RW"`

## References

Nystuen, J.D. and Dacey, M.F. (1961), "A graph theory interpretation of
nodal regions", Papers and Proceedings of the Regional Science
Association 7: 29-42.
[doi:10.1007/bf01969070](https://doi.org/10.1007/bf01969070)

Rihll, T.E., and Wilson, A.G. (1987). "Spatial interaction and
structural models in historical analysis: some possibilities and an
example", Histoire & Mesure 2: 5-32.
[doi:10.3406/hism.1987.1300](https://doi.org/10.3406/hism.1987.1300)

Rihll, T., and Wilson, A. (1991), "Modelling settlement structures in
ancient Greece: new approaches to the polis", In City and Country in the
Ancient World, Vol. 3, Edited by J. Rich and A. Wallace-Hadrill, 58-95.
London: Routledge.

## See also

[`sim_is_bipartite()`](https://fabrice-rossi.github.io/blvim/reference/sim_is_bipartite.md),
[`is_terminal()`](https://fabrice-rossi.github.io/blvim/reference/is_terminal.md),
[`grid_is_terminal()`](https://fabrice-rossi.github.io/blvim/reference/grid_is_terminal.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- blvim(distances, production, 1.3, 1 / 250, attractiveness,
  bipartite = FALSE
)
destination_names(model) <- french_cities$name[1:10]
terminals(model)
#>       Paris Montpellier 
#>           1           7 
dist_times <- french_cities_times[1:10, 1:10]
tmodel <- blvim(dist_times, production, 1.3, 1 / 5000, attractiveness,
  bipartite = FALSE
)
destination_names(tmodel) <- french_cities$name[1:10]
terminals(tmodel)
#>       Paris        Nice      Nantes Montpellier  Strasbourg    Bordeaux 
#>           1           5           6           7           8           9 
#>       Lille 
#>          10 
terminals(tmodel, definition = "RW")
#>       Paris        Nice      Nantes Montpellier  Strasbourg    Bordeaux 
#>           1           5           6           7           8           9 
#>       Lille 
#>          10 
```
