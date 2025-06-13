
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Boltzmann–Lotka–Volterra Interaction Model

<!-- badges: start -->

[![R-CMD-check](https://github.com/fabrice-rossi/blvim/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/fabrice-rossi/blvim/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/fabrice-rossi/blvim/graph/badge.svg)](https://app.codecov.io/gh/fabrice-rossi/blvim)

<!-- badges: end -->

`blvim` implements A. Wilson’s Boltzmann–Lotka–Volterra (BLV)
interaction model. The model is described in [Wilson, A. (2008),
“Boltzmann, Lotka and Volterra and spatial structural evolution: an
integrated methodology for some dynamical systems”, J. R. Soc.
Interface.5865–871](http://dx.doi.org/10.1098/rsif.2007.1288)

## Installation

You can install the development version of `blvim` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("fabrice-rossi/blvim")
```

## Spatial interaction models

Spatial interaction models try to estimate flows between locations, for
instance workers commuting from residential zones to employment zones.
The focus of the `blvim` package is on maximum entropy models developed
by Alan Wilson. See `vignette("theory")` for a theoretical background.

In practice, if we have $n$ origin locations and $p$ destination
locations, the aim is to compute a matrix of flows
$(Y_{ij})_{1\leq i\leq n, 1\leq j\leq p}$, where $Y_{ij}$ is the flow
from origin $i$ to destination $j$. This is done using characteristics
of the origin and destination locations, together with a matrix of
exchange difficulties, a *cost matrix*,
$(c_{ij})_{1\leq i\leq n, 1\leq j\leq p}$. For instance $c_{ij}$ can be
the distance between origin $i$ and destination $j$.

## Usage

The package is loaded in a standard way.

``` r
library(blvim)
```

### Input data

To compute a spatial interaction model with `blvim`, one needs at least
a cost matrix. In this example, we use the distance between some random
locations.

``` r
set.seed(42)
## random origin locations
origins <- matrix(runif(2 * 30), ncol = 2)
## random destination locations
destinations <- matrix(runif(2 * 10), ncol = 2)
## cost matrix
full_costs <- as.matrix(dist(rbind(origins, destinations)))
cost_matrix <- full_costs[1:nrow(origins), (nrow(origins) + 1):(nrow(origins) + nrow(destinations))]
```

In addition, we focus on production constrained models which means that
we need to specify the production of each origin location (a vector of
positive values $(X_i)_{1\leq i\leq n}$). In this example we assume a
common unitary production.

``` r
X <- rep(1, nrow(origins))
```

Finally, the simple *static* model needs an attractiveness value of each
destination location, a vector of positive values
$(Z_j)_{1\leq j\leq p}$. We assume again a common unitary
attractiveness.

``` r
Z <- rep(1, nrow(destinations))
```

### Static models

In Wilson’s production constrained maximum entropy model, the flows are
given by

$$Y_{ij} = \frac{X_iZ_j^{\alpha}\exp(-\beta c_{ij})}{\sum_{k=1}^pZ_k^{\alpha}\exp(-\beta c_{ik})},$$

where $\alpha$ is a return to scale parameter and $\beta$ is the inverse
of a cost scale parameter. Notice that the flow matrix is *production
constrained*, which means that the total outgoing flow from any origin
location is equal to the production of this location, i.e.

$$\forall i,\quad X_i=\sum_{j=1}^{p}Y_{ij}.$$

The model is obtained using the `static_blvim()` function as follows:

``` r
a_model <- static_blvim(cost_matrix, X, alpha = 1.1, beta = 2, Z)
a_model
#> Spatial interaction model with 30 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.1 and inverse cost scale (beta) = 2
```

Several functions are provided to extract parts of the result. In
particular `flows()` returns the flow matrix $Y$.

``` r
a_model_flows <- flows(a_model)
```

which can be displayed using, e.g., the `image()` function.

``` r
par(mar = rep(0.1, 4))
image(t(a_model_flows),
  col = gray.colors(20, start = 1, end = 0),
  axes = FALSE,
  frame = TRUE
)
```

<img src="man/figures/README-a_flow-1.png" width="25%" style="display: block; margin: auto;" />

In this representation, each row gives the flows from one origin
location to all the destination location. The package provides a
`ggplot2::autoplot()` function that can be used as follows

``` r
library(ggplot2)
autoplot(a_model, "full") +
  scale_fill_viridis_c() +
  coord_fixed()
```

<img src="man/figures/README-a_flow_ggplot2-1.png" width="40%" style="display: block; margin: auto;" />

``` r
b_model <- static_blvim(cost_matrix, X, alpha = 1.1, beta = 15, Z)
b_model
#> Spatial interaction model with 30 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.1 and inverse cost scale (beta) = 15
```

``` r
autoplot(b_model) +
  scale_fill_viridis_c() +
  coord_fixed()
```

<img src="man/figures/README-b_flow-1.png" width="40%" style="display: block; margin: auto;" />

Different values of the parameters $\alpha$ and $\beta$ lead to more or
less concentrated flows as exemplified by the two above figures.

### Dynamic models

A. Wilson’s Boltzmann–Lotka–Volterra (BLV) interaction model is based on
the production constrained maximum entropy model. The main idea consists
in updating the attractivenesses of the destination locations based on
their incoming flows. In the limit we want to have

$$Z_j =\sum_{i=1}^{n}Y_{ij}, $$

where the flows are given by the equations above. The model is estimated
using the `blvim()` function as follows.

``` r
a_blv_model <- blvim(cost_matrix, X, alpha = 1.1, beta = 2, Z)
a_blv_model
#> Spatial interaction model with 30 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.1 and inverse cost scale (beta) = 2
#> ℹ The BLV model converged after 5800 iterations.
```

Notice that we start with some initial values of the attractivenesses
but the final values are different. They can be obtained using the
`attractiveness()` function as follows (we show the values using a bar
plot).

``` r
par(mar = c(0.1, 4, 1, 0))
a_final_Z <- attractiveness(a_blv_model)
barplot(a_final_Z)
```

<img src="man/figures/README-a_blv_Z-1.png" width="80%" style="display: block; margin: auto;" />
In this example, one destination location acts as a global attractor of
all the flows. This can be seen also on the final flow matrix.

``` r
autoplot(a_blv_model) +
  scale_fill_viridis_c()
```

<img src="man/figures/README-a_blv_flow-1.png" width="40%" style="display: block; margin: auto;" />

The `autoplot()` function can also be used to show the destination flows
or the attractivenesses as follows.

``` r
autoplot(a_blv_model, "attractiveness")
```

<img src="man/figures/README-a_blv_Z_ggplot2-1.png" width="100%" />

Results are of course strongly influenced by the parameters, as shown by
this second example.

``` r
b_blv_model <- blvim(cost_matrix, X, alpha = 1.1, beta = 15, Z)
b_blv_model
#> Spatial interaction model with 30 origin locations and 10 destination locations
#> • Model: Wilson's production constrained
#> • Parameters: return to scale (alpha) = 1.1 and inverse cost scale (beta) = 15
#> ℹ The BLV model converged after 13300 iterations.
```

``` r
autoplot(b_blv_model, "attractiveness")
```

<img src="man/figures/README-b_blv_Z-1.png" width="100%" />

``` r
autoplot(b_blv_model) +
  scale_fill_viridis_c()
```

<img src="man/figures/README-b_blv_flow-1.png" width="40%" style="display: block; margin: auto;" />
