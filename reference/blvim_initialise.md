# Specify how initial attractivenesses are generated

`blvim_initialise()` creates a reusable specification for generating
initial attractivenesses in
[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md).
The generator is evaluated only after the dimensions, production values,
and conversion factors of the model are known.

## Usage

``` r
blvim_initialise(generator = blvim_simplex_initialise, ...)
```

## Arguments

- generator:

  A function used to generate initial attractivenesses. Its first
  argument must be `context`. The default uses
  [`sample_weighted_simplex()`](https://fabrice-rossi.github.io/blvim/reference/sample_weighted_simplex.md).

- ...:

  Arguments stored in the specification and passed to `generator`.

## Value

An object of class `blvim_initialise`.

## Details

A generator must be a function whose first argument is `context`. It
must return either:

- a numeric vector representing one initial configuration;

- a numeric matrix whose rows represent initial configurations; or

- a list containing one of these objects in a component named `Z`.

The `context` argument is a named list containing:

- `costs`: the cost matrix;

- `X`: the production vector;

- `alpha` and `beta`: the interaction-model parameters;

- `kappa`: the conversion factors expanded to one value per destination;

- `C`: total production, equal to `sum(X)`;

- `bipartite`: whether the model is bipartite;

- `n_origins`: number of origins;

- `n_destinations`: number of destinations.

Some of the parameters are easily deducible from others (`C`,
`n_origins` and `n_destinations`) but are included to simplify the
design of initialisers.

Additional arguments supplied through `...` are stored in the
specification and passed to `generator` when starting points are
generated.

## See also

[`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
for the use of this function, and
[`blvim_simplex_initialise()`](https://fabrice-rossi.github.io/blvim/reference/blvim_simplex_initialise.md)
for the default initialiser.

## Examples

``` r
# Ten starting points from the default simplex generator
initialise <- blvim_initialise(n = 10)

# Emphasise proper faces of the simplex
boundary_initialise <- blvim_initialise(
  n = 100,
  face_fraction = 0.8,
  points_per_face = 5
)

# A custom generator
concentrated_initialise <- function(context, n = 20, concentration = 100) {
  centre <- rep(1 / context$n_destinations, context$n_destinations)
  U <- matrix(
    stats::rgamma(n * context$n_destinations,
      shape = concentration * centre
    ),
    nrow = n, byrow = TRUE
  )
  U <- U / rowSums(U)
  sweep(U * context$C, 2, context$kappa, "/")
}

initialise <- blvim_initialise(
  generator = concentrated_initialise,
  n = 50,
  concentration = 20
)
```
