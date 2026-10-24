# Sample points from a weighted simplex

Generates random points in the weighted simplex

\$\$ \mathcal{S} = \left\\ Z \in \mathbb{R}\_{+}^{d} : \sum\_{j=1}^{d}
\kappa_j Z_j = C \right\\. \$\$

The sample is divided between points in the relative interior of the
simplex and points lying on proper faces, that is, points having at
least one coordinate equal to zero.

Interior points are sampled uniformly after mapping the weighted simplex
to the standard simplex. Points on faces are allocated preferentially to
faces of increasing codimension: codimension-one faces are selected
first, followed by codimension-two faces, and so on.

## Usage

``` r
sample_weighted_simplex(
  kappa,
  C = 1,
  n = 1000L,
  face_fraction = 0.5,
  points_per_face = 0L,
  max_partial_attempts = 1000000L
)
```

## Arguments

- kappa:

  A numeric vector of length at least two containing finite, strictly
  positive weights. These weights define the simplex constraint \\\sum_j
  \kappa_j Z_j=C\\. The length of `kappa` is the ambient dimension
  \\d\\.

- C:

  A finite, strictly positive numeric scalar giving the right-hand side
  of the weighted-simplex constraint.

- n:

  A finite positive integer giving the total number of sample points.

- face_fraction:

  A finite numeric scalar in \\\[0,1\]\\. The number of points allocated
  to proper faces is `round(n * face_fraction)`. The remaining points
  are sampled in the relative interior.

- points_per_face:

  A nonnegative integer controlling the allocation of face points.

  If zero, the function maximises the number of distinct selected faces.
  If positive, it is the requested maximum number of points on each
  selected nonvertex face. The function may increase this value, with a
  warning, when the requested value is incompatible with the number and
  capacities of the available faces.

- max_partial_attempts:

  A positive integer giving the maximum number of random proposals
  allowed when selecting distinct faces in the final, partially covered
  codimension layer. Increasing this value may be necessary when most
  faces in that layer must be selected.

## Value

A list with the following components:

- `Z`: An `n` by `length(kappa)` numeric matrix. Each row is nonnegative
  and satisfies `sum(kappa * Z[i, ]) = C`, up to floating-point error.

- `codim`: An integer vector of length `n`. The value for a point is the
  number of coordinates constrained to zero. Interior points have
  codimension zero.

- `zero`: A list of length `n`. Each element contains the one-based
  indices of the zero coordinates of the corresponding row of `Z`.

- `face_id`: An integer vector of length `n`. Interior points have
  identifier zero. Face points have a positive identifier referring to
  an entry in `faces`.

- `faces`: A list describing the selected faces, with components:

  - `codim`: codimension of each selected face;

  - `zero`: one-based zero-coordinate indices for each selected face;

  - `count`: number of sample points generated on each selected face.

- `n_interior`: Number of points sampled in the relative interior.

- `n_face_points`: Number of points allocated to proper faces.

- `selected_face_count`: Number of distinct selected faces.

- `points_per_face`: Effective maximum number of points per selected
  nonvertex face. This may be larger than the value requested by the
  user.

- `layer_count`: Integer vector whose `k`th element is the number of
  selected codimension-`k` faces.

- `partial_codim`: Codimension of the final partially selected face
  layer, or `NA_integer_` if all selected codimension layers are
  complete.

- `max_constraint_error`: Maximum absolute residual
  \\\|\sum_j\kappa_jZ_j-C\|\\ over the generated points.

## Details

The number of points allocated to proper faces is

\$\$ n\_{\mathrm{face}} = \operatorname{round}(n\\p), \$\$

where \\p\\ is `face_fraction`. The remaining points are sampled in the
relative interior.

The `points_per_face` argument controls the trade-off between covering
many distinct faces and sampling each selected face more thoroughly:

- If `points_per_face = 0`, the function selects as many different faces
  as possible. If the number of requested face points does not exceed
  the number of available faces, one point is generated on each selected
  face. Otherwise, all available faces are selected and the remaining
  points are distributed as evenly as possible among the nonvertex
  faces.

- If `points_per_face > 0`, the function attempts to generate at most
  `points_per_face` points on each selected nonvertex face. It selects
  the smallest number of faces that provides sufficient capacity,
  prioritising low-codimension faces.

A vertex has support size one and consists of a single point.
Consequently, a selected vertex can receive only one sample point,
irrespective of the value of `points_per_face`.

If the requested positive value of `points_per_face` is too small to
accommodate all face points, even after selecting all available faces,
the function increases it to the smallest feasible value and issues a
warning. The adjusted value is returned in the `points_per_face`
component.

For each selected nonvertex face, points are sampled uniformly with
respect to the intrinsic Lebesgue measure on that face. If \\S\\ is the
support of the selected face, independent standard exponential variables
\\E_j\\, \\j \in S\\, are generated and transformed according to

\$\$ Z_j = \frac{C E_j} {\kappa_j \sum\_{\ell \in S} E\_\ell}, \qquad j
\in S, \$\$

with \\Z_j=0\\ for \\j \notin S\\.

## Face counts

In dimension \\d\\, there are

\$\$ 2^d-2 \$\$

proper nonempty faces, including the \\d\\ vertices. There are therefore

\$\$ 2^d-d-2 \$\$

proper nonvertex faces.

The number of codimension-\\k\\ faces is

\$\$ {d \choose k}. \$\$

The function exhausts these layers in increasing order of \\k\\. Only
the final selected codimension layer can be partial.

## Reproducibility

Sampling uses R's random-number generator. Use
[`set.seed()`](https://rdrr.io/r/base/Random.html) before calling the
function to obtain reproducible results.

## Numerical considerations

Coordinates outside the selected support are set exactly to zero.
Positive coordinates are generated using normalised exponential random
variables. The weighted equality constraint is satisfied up to
floating-point roundoff.

## See also

[`blvim_simplex_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_simplex_initialise.md)
and
[`blvim_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_initialise.md),
which use this function to generate starting points for
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).

## Examples

``` r
# Mix interior points and face points.
set.seed(123)

sample <- sample_weighted_simplex(
  kappa = c(1, 2, 3, 4, 5),
  C = 2,
  n = 1000,
  face_fraction = 0.4,
  points_per_face = 16
)

dim(sample$Z)
#> [1] 1000    5
sample$n_interior
#> [1] 600
sample$n_face_points
#> [1] 400
sample$selected_face_count
#> [1] 25

# Verify the weighted equality constraint.
max(abs(drop(sample$Z %*% c(1, 2, 3, 4, 5)) - 2))
#> [1] 4.440892e-16

# Maximise coverage across distinct faces.
set.seed(123)

broad_sample <- sample_weighted_simplex(
  kappa = rep(1, 5),
  n = 100,
  face_fraction = 1,
  points_per_face = 0
)

broad_sample$selected_face_count
#> [1] 30
broad_sample$faces$count
#>  [1] 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 3 3 3 3 3 1 1 1 1 1

# Inspect the selected codimension layers.
broad_sample$layer_count
#> [1]  5 10 10  5
```
