# Compute the diversity of the destination flows in a spatial interaction model

This function computes the diversity of the destination flows according
to different definitions that all aim at estimating a number of active
destinations, i.e., the number of destination locations that receive a
"significant fraction" of the total flow. The function applies also to a
collection of spatial interaction models as represented by a `sim_list`.

## Usage

``` r
diversity(sim, definition = c("shannon", "renyi", "ND", "RW"), order = 1L, ...)

# S3 method for class 'sim'
diversity(sim, definition = c("shannon", "renyi", "ND", "RW"), order = 1L, ...)

# S3 method for class 'sim_list'
diversity(sim, definition = c("shannon", "renyi", "ND", "RW"), order = 1L, ...)
```

## Arguments

- sim:

  a spatial interaction model object (an object of class `sim`) or a
  collection of spatial interaction models (an object of class
  `sim_list`)

- definition:

  diversity definition `"shannon"` (default), `"renyi"` (see details) or
  a definition supported by
  [`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)

- order:

  order of the Rényi entropy, used only when `definition="renyi"`

- ...:

  additional parameters

## Value

the diversity of destination flows (one value per spatial interaction
model)

## Details

If \\Y\\ is a flow matrix, the destination flows are computed as follows

\$\$\forall j,\quad D_j=\sum\_{i=1}^{n}Y\_{ij},\$\$

for each destination \\j\\ (see
[`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md)).
To compute their diversity using entropy based definitions, the flows
are first normalised to be interpreted as a probability distribution
over the destination locations. We use

\$\$\forall j,\quad p_j=\frac{D_j}{\sum\_{k=1}^n D_k}.\$\$

The most classic diversity index is given by the exponential of
Shannon's entropy (parameter `definition="shannon"`). This gives

\$\$\text{diversity}(p, \text{Shannon})=\exp\left(-\sum\_{k=1}^n p_k\ln
p_k\right).\$\$

Rényi generalized entropy can be used to define a collection of other
diversity metrics. The Rényi diversity of order \\\gamma\\ is the
exponential of the Rényi entropy of order \\\gamma\\ of the \\p\\
distribution, that is

\$\$\text{diversity}(p, \text{Rényi},
\gamma)=\exp\left(\frac{1}{1-\gamma}\ln
\left(\sum\_{k=1}^np_k^\gamma\right)\right).\$\$

This is defined directly only for \\\gamma\in\]0,1\[\cup \]1,\infty\[\\,
but extensions to the limit case are straightforward:

- \\\gamma=1\\ is Shannon's entropy/diversity

- \\\gamma=0\\ is the max-entropy, here \\\ln(n)\\ and thus the
  corresponding diversity is the number of locations

- \\\gamma=\infty\\ is the min-entropy, here \\-\log \max\_{k}p_k\\ and
  thhe corresponding diversity is \\\frac{1}{\max\_{k}p_k}\\

The `definition` parameter specifies the diversity used for calculation.
The default value is `shannon` for Shannon's entropy (in this case the
`order` parameter is not used). Using `renyi` gives access to all Rényi
diversities as specified by the `order` parameter. Large values of
`order` tend to generate underflows in the calculation that will trigger
the use of the min-entropy instead of the exact Rényi entropy.

In addition to those entropy based definition, terminal based
calculations are also provided. Using any definition supported by the
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)
function, the diversity is the number of terminals identified. Notice
this applies only to interaction models in which origin and destination
locations are identical, i.e. when the model is not bipartite. Current
values of definitions are:

- `"ND"` for the original Nystuen and Dacey definition

- `"RW"` for the variant by Rihll and Wilson

See
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md)
for details.

When applied to a collection of spatial interaction models (an object of
class `sim_list`) the function uses the same parameters (`definition`
and `order`) for all models and returns a vector of diversities. This is
completely equivalent to
[`grid_diversity()`](https://fabrice-rossi.github.io/blvim/reference/grid_diversity.md).

## References

Jost, L. (2006), "Entropy and diversity", Oikos, 113: 363-375.
[doi:10.1111/j.2006.0030-1299.14714.x](https://doi.org/10.1111/j.2006.0030-1299.14714.x)

## See also

[`destination_flow()`](https://fabrice-rossi.github.io/blvim/reference/destination_flow.md),
[`terminals()`](https://fabrice-rossi.github.io/blvim/reference/terminals.md),
[`sim_is_bipartite()`](https://fabrice-rossi.github.io/blvim/reference/sim_is_bipartite.md)

## Examples

``` r
distances <- french_cities_distances[1:15, 1:15] / 1000 ## convert to km
production <- log(french_cities$population[1:15])
attractiveness <- rep(1, 15)
flows <- blvim(distances, production, 1.5, 1 / 100, attractiveness,
  bipartite = FALSE
)
diversity(flows)
#> [1] 5.612398
diversity(flows, "renyi", 2)
#> [1] 4.734579
diversity(flows, "RW")
#> [1] 7
```
