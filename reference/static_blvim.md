# Compute flows between origin and destination locations

This function computes flows between origin locations and destination
locations according to the production constrained entropy maximising
model proposed by A. Wilson.

## Usage

``` r
static_blvim(
  costs,
  X,
  alpha,
  beta,
  Z,
  bipartite = TRUE,
  origin_data = NULL,
  destination_data = NULL
)
```

## Arguments

- costs:

  a cost matrix

- X:

  a vector of production constraints

- alpha:

  the return to scale parameter

- beta:

  the inverse cost scale parameter

- Z:

  a vector of destination attractivenesses

- bipartite:

  when `TRUE` (default value), the origin and destination locations are
  considered to be distinct. When `FALSE`, a single set of locations
  plays the both roles. This has only consequences in functions specific
  to this latter case such as
  [`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md).

- origin_data:

  `NULL` or a list of additional data about the origin locations (see
  details)

- destination_data:

  `NULL` or a list of additional data about the destination locations
  (see details)

## Value

an object of class `sim` (and `sim_wpc`) for spatial interaction model
that contains the matrix of flows from the origin locations to the
destination locations (see \\(Y\_{ij})\_{1\leq i\leq n, 1\leq j\leq p}\\
above) and the attractivenesses of the destination locations.

## Details

The model computes flows using the following parameters:

- `costs` (\\c\\) is a \\n\times p\\ matrix whose \\(i,j )\\ entry is
  the cost of having a "unitary" flow from origin location \\i\\ to
  destination location \\j\\

- `X` (\\X\\) is a vector of size \\n\\ containing non negative
  production constraints for the \\n\\ origin locations

- `alpha` (\\\alpha\\) is a return to scale parameter that enhance (or
  reduce if smaller that 1) the attractivenesses of destination
  locations when they are larger than 1

- `beta` (\\\beta\\) is the inverse of a cost scale parameter, i.e.,
  costs are multiplied by `beta` in the model

- `Z` (\\Z\\) is a vector of size \\p\\ containing the positive
  attractivenesses of the \\p\\ destination locations

According to Wilson's model, the flow from origin location \\i\\ to
destination location \\j\\, \\Y\_{ij}\\, is given by

\$\$Y\_{ij}=\frac{X_iZ_j^{\alpha}\exp(-\beta
c\_{ij})}{\sum\_{k=1}^pZ_k^{\alpha}\exp(-\beta c\_{ik})}.\$\$

The model is production constrained because

\$\$\forall i,\quad X_i=\sum\_{j=1}^{p}Y\_{ij},\$\$

that is the origin location \\i\\ sends a total flow of exactly \\X_i\\.

## Location data

While models in this package do not use location data beyond `X` and
`Z`, additional data can be stored and used when analysing spatial
interaction models.

### Origin and destination location names

Spatial interaction models can store names for origin and destination
locations, using
[`origin_names<-()`](https://fabrice-rossi.github.io/blvim/reference/origin_names.md)
and
[`destination_names<-()`](https://fabrice-rossi.github.io/blvim/reference/destination_names.md).
Names are taken by default from names of the cost matrix `costs`. More
precisely, `rownames(costs)` is used for origin location names and
`colnames(costs)` for destination location names.

### Origin and destination location positions

Spatial interaction models can store the positions of the origin and
destination locations, using
[`origin_positions<-()`](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md)
and
[`destination_positions<-()`](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md).

### Specifying location data

In addition to the functions mentioned above, location data can be
specified directly using the `origin_data` and `destination_data`
parameters. Data are given by a list whose components are not
interpreted excepted the following ones:

- `names` is used to specify location names and its content has to
  follow the restrictions documented in
  [`origin_names<-()`](https://fabrice-rossi.github.io/blvim/reference/origin_names.md)
  and
  [`destination_names<-()`](https://fabrice-rossi.github.io/blvim/reference/destination_names.md)

- `positions` is used to specify location positions and its content has
  to follow the restrictions documented in
  [`origin_positions<-()`](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md)
  and
  [`destination_positions<-()`](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md)

## References

Wilson, A. (1971), "A family of spatial interaction models, and
associated developments", Environment and Planning A: Economy and Space,
3(1), 1-32 [doi:10.1068/a030001](https://doi.org/10.1068/a030001)

## See also

[`origin_names()`](https://fabrice-rossi.github.io/blvim/reference/origin_names.md),
[`destination_names()`](https://fabrice-rossi.github.io/blvim/reference/destination_names.md),
[`origin_positions()`](https://fabrice-rossi.github.io/blvim/reference/origin_positions.md),
[`destination_positions()`](https://fabrice-rossi.github.io/blvim/reference/destination_positions.md)

## Examples

``` r
positions <- as.matrix(french_cities[1:10, c("th_longitude", "th_latitude")])
distances <- french_cities_distances[1:10, 1:10] / 1000 ## convert to km
production <- rep(1, 10)
attractiveness <- log(french_cities$area[1:10])
model <- static_blvim(distances, production, 1.5, 1 / 500, attractiveness,
  origin_data = list(
    names = french_cities$name[1:10],
    positions = positions
  ),
  destination_data = list(
    names = french_cities$name[1:10],
    positions = positions
  )
)
model
#> Spatial interaction model with 10 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.5 and inverse cost scale (beta) =
#> 0.002
location_names(model)
#> $origin
#>  [1] "Paris"       "Marseille"   "Lyon"        "Toulouse"    "Nice"       
#>  [6] "Nantes"      "Montpellier" "Strasbourg"  "Bordeaux"    "Lille"      
#> 
#> $destination
#>  [1] "Paris"       "Marseille"   "Lyon"        "Toulouse"    "Nice"       
#>  [6] "Nantes"      "Montpellier" "Strasbourg"  "Bordeaux"    "Lille"      
#> 
location_positions(model)
#> $origin
#>    th_longitude th_latitude
#> 1        2.3525     48.8564
#> 2        5.3699     43.2966
#> 3        4.8350     45.7676
#> 4        1.4442     43.6046
#> 5        7.2715     43.6960
#> 6       -1.5543     47.2184
#> 7        3.8968     43.5985
#> 8        7.7520     48.5733
#> 9       -0.5794     44.8379
#> 10       3.0713     50.6305
#> 
#> $destination
#>    th_longitude th_latitude
#> 1        2.3525     48.8564
#> 2        5.3699     43.2966
#> 3        4.8350     45.7676
#> 4        1.4442     43.6046
#> 5        7.2715     43.6960
#> 6       -1.5543     47.2184
#> 7        3.8968     43.5985
#> 8        7.7520     48.5733
#> 9       -0.5794     44.8379
#> 10       3.0713     50.6305
#> 
```
