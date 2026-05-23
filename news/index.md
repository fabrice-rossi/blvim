# Changelog

## blvim (development version)

### New features

- [`blvim()`](https://fabrice-rossi.github.io/blvim/reference/blvim.md)
  now supports conversion factors between attractivenesses and incoming
  flows, together with the new function
  [`sim_conversion()`](https://fabrice-rossi.github.io/blvim/reference/sim_conversion.md).
- [`sim_potential()`](https://fabrice-rossi.github.io/blvim/reference/sim_potential.md)
  computes the potential of spatial interaction model using the
  definition proposed by Osawa, Akamatsu, and Kogure.
- [`sim_fp_jacobian()`](https://fabrice-rossi.github.io/blvim/reference/sim_fp_jacobian.md)
  computes the Jacobian of the fixed point map with respect to the
  attractivenesses.

### Documentation

- the theoretical vignette has been expanded with new content based on a
  recent paper by Osawa et al.

### Minor improvements and bug fixes

- improved test compatibility between different platforms

## blvim 0.1.1

CRAN release: 2026-01-14

- Simplify examples in
  [`grid_autoplot()`](https://fabrice-rossi.github.io/blvim/reference/grid_autoplot.md)
  to have them run in less than 5 seconds.

## blvim 0.1.0

- Initial CRAN submission.
