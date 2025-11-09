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
positions <- matrix(rnorm(10 * 2), ncol = 2)
distances <- as.matrix(dist(positions))
production <- rep(1, 10)
attractiveness <- rep(1, 10)
model <- blvim(distances, production, 1.3, 2, attractiveness, bipartite = FALSE)
is_terminal(model)
#>     1     2     3     4     5     6     7     8     9    10 
#> FALSE  TRUE FALSE  TRUE FALSE FALSE FALSE  TRUE  TRUE  TRUE 
```
