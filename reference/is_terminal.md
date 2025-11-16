# Report whether locations are terminal sites or not

This function returns a logical vector whose length equals the number of
locations. The value in position `i` is `TRUE` if location number `i` is
a terminal and `FALSE` if it is not. For the definition of terminals,
see
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md).

## Usage

``` r
is_terminal(sim, definition = c("ND", "RW"), ...)
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

a logical vector with `TRUE` at the positions of locations that are
terminals and `FALSE` for other locations.

## See also

[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)

## Examples

``` r
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- blvim(distances, production, 1.3, 1 / 500, attractiveness,
  bipartite = FALSE
)
destination_names(model) <- french_cities$name[1:10]
is_terminal(model)
#>       Paris   Marseille        Lyon    Toulouse        Nice      Nantes 
#>       FALSE       FALSE        TRUE       FALSE       FALSE       FALSE 
#> Montpellier  Strasbourg    Bordeaux       Lille 
#>       FALSE       FALSE       FALSE       FALSE 
dist_times <- french_cities_times[1:10, 1:10]
tmodel <- blvim(dist_times, production, 1.3, 1 / 10000, attractiveness,
  bipartite = FALSE
)
destination_names(tmodel) <- french_cities$name[1:10]
is_terminal(tmodel)
#>       Paris   Marseille        Lyon    Toulouse        Nice      Nantes 
#>        TRUE       FALSE       FALSE       FALSE       FALSE       FALSE 
#> Montpellier  Strasbourg    Bordeaux       Lille 
#>        TRUE       FALSE       FALSE       FALSE 
```
