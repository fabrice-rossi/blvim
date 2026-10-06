## only exported for testing purposes
R_project_simplex <- function(Y, tol = 1e-9, max_iter = 50L) {
  project_simplex(as.double(Y), tol, max_iter)[, 1]
}

R_project_weighted_simplex <- function(Y, kappa, X_tot, tol = 1e-9, max_iter = 50L) {
  project_weighted_simplex(
    as.double(Y), as.double(kappa), sum(kappa^2),
    as.double(X_tot), tol, max_iter
  )[, 1]
}

number_of_faces_capped <- function(d, cap) {
  if (cap <= 0L) {
    return(0L)
  }
  # The number of proper nonempty faces is 2^d - 2.
  # We only need to know whether it reaches `cap`.
  if (d >= 31L || d * log(2) >= log(as.double(cap) + 2)) {
    return(as.integer(cap))
  }
  as.integer(min(2^d - 2, cap))
}

number_of_nonvertex_faces_capped <- function(d, cap) {
  if (cap <= 0L) {
    return(0L)
  }
  # Proper faces excluding the d vertices: 2^d - d - 2.
  if (d >= 31L || d * log(2) >= log(as.double(cap) + d + 2)) {
    return(as.integer(cap))
  }
  as.integer(min(2^d - d - 2, cap))
}

#' Sample points from a weighted simplex
#'
#' @description
#' Generates random points in the weighted simplex
#'
#' \deqn{
#'   \mathcal{S}
#'   =
#'   \left\{
#'     Z \in \mathbb{R}_{+}^{d} :
#'     \sum_{j=1}^{d} \kappa_j Z_j = C
#'   \right\}.
#' }
#'
#' The sample is divided between points in the relative interior of the
#' simplex and points lying on proper faces, that is, points having at least
#' one coordinate equal to zero.
#'
#' Interior points are sampled uniformly after mapping the weighted simplex
#' to the standard simplex. Points on faces are allocated preferentially to
#' faces of increasing codimension: codimension-one faces are selected first,
#' followed by codimension-two faces, and so on.
#'
#' @details
#' The number of points allocated to proper faces is
#'
#' \deqn{
#'   n_{\mathrm{face}}
#'   =
#'   \operatorname{round}(n\,p),
#' }
#'
#' where \eqn{p} is `face_fraction`. The remaining points are sampled in the
#' relative interior.
#'
#' The `points_per_face` argument controls the tradeoff between covering many
#' distinct faces and sampling each selected face more thoroughly:
#'
#' * If `points_per_face = 0`, the function selects as many different faces as
#'   possible. If the number of requested face points does not exceed the
#'   number of available faces, one point is generated on each selected face.
#'   Otherwise, all available faces are selected and the remaining points are
#'   distributed as evenly as possible among the nonvertex faces.
#'
#' * If `points_per_face > 0`, the function attempts to generate at most
#'   `points_per_face` points on each selected nonvertex face. It selects the
#'   smallest number of faces that provides sufficient capacity, prioritizing
#'   low-codimension faces.
#'
#' A vertex has support size one and consists of a single point. Consequently,
#' a selected vertex can receive only one sample point, irrespective of the
#' value of `points_per_face`.
#'
#' If the requested positive value of `points_per_face` is too small to
#' accommodate all face points, even after selecting all available faces, the
#' function increases it to the smallest feasible value and issues a warning.
#' The adjusted value is returned in the `points_per_face` component.
#'
#' For each selected nonvertex face, points are sampled uniformly with respect
#' to the intrinsic Lebesgue measure on that face. If \eqn{S} is the support
#' of the selected face, independent standard exponential variables
#' \eqn{E_j}, \eqn{j \in S}, are generated and transformed according to
#'
#' \deqn{
#'   Z_j =
#'   \frac{C E_j}
#'        {\kappa_j \sum_{\ell \in S} E_\ell},
#'   \qquad j \in S,
#' }
#'
#' with \eqn{Z_j=0} for \eqn{j \notin S}.
#'
#' @param kappa A numeric vector of length at least two containing finite,
#'   strictly positive weights. These weights define the simplex constraint
#'   \eqn{\sum_j \kappa_j Z_j=C}. The length of `kappa` is the ambient
#'   dimension \eqn{d}.
#'
#' @param C A finite, strictly positive numeric scalar giving the right-hand
#'   side of the weighted-simplex constraint.
#'
#' @param n A finite positive integer giving the total number of sample points.
#'
#' @param face_fraction A finite numeric scalar in \eqn{[0,1]}. The number of
#'   points allocated to proper faces is `round(n * face_fraction)`. The
#'   remaining points are sampled in the relative interior.
#'
#' @param points_per_face A nonnegative integer controlling the allocation of
#'   face points.
#'
#'   If zero, the function maximizes the number of distinct selected faces.
#'   If positive, it is the requested maximum number of points on each selected
#'   nonvertex face. The function may increase this value, with a warning, when
#'   the requested value is incompatible with the number and capacities of the
#'   available faces.
#'
#' @param max_partial_attempts A positive integer giving the maximum number of
#'   random proposals allowed when selecting distinct faces in the final,
#'   partially covered codimension layer. Increasing this value may be
#'   necessary when most faces in that layer must be selected.
#'
#' @return
#' A list with the following components:
#'
#' * `Z`: An `n` by `length(kappa)` numeric matrix. Each row is nonnegative and
#'   satisfies `sum(kappa * Z[i, ]) = C`, up to floating-point error.
#'
#' * `codim`: An integer vector of length `n`. The value for a point is the
#'   number of coordinates constrained to zero. Interior points have
#'   codimension zero.
#'
#' * `zero`: A list of length `n`. Each element contains the one-based indices
#'   of the zero coordinates of the corresponding row of `Z`.
#'
#' * `face_id`: An integer vector of length `n`. Interior points have identifier
#'   zero. Face points have a positive identifier referring to an entry in
#'   `faces`.
#'
#' * `faces`: A list describing the selected faces, with components:
#'   * `codim`: codimension of each selected face;
#'   * `zero`: one-based zero-coordinate indices for each selected face;
#'   * `count`: number of sample points generated on each selected face.
#'
#' * `n_interior`: Number of points sampled in the relative interior.
#'
#' * `n_face_points`: Number of points allocated to proper faces.
#'
#' * `selected_face_count`: Number of distinct selected faces.
#'
#' * `points_per_face`: Effective maximum number of points per selected
#'   nonvertex face. This may be larger than the value requested by the user.
#'
#' * `layer_count`: Integer vector whose `k`th element is the number of selected
#'   codimension-`k` faces.
#'
#' * `partial_codim`: Codimension of the final partially selected face layer,
#'   or `NA_integer_` if all selected codimension layers are complete.
#'
#' * `max_constraint_error`: Maximum absolute residual
#'   \eqn{|\sum_j\kappa_jZ_j-C|} over the generated points.
#'
#' @section Face counts:
#' In dimension \eqn{d}, there are
#'
#' \deqn{
#'   2^d-2
#' }
#'
#' proper nonempty faces, including the \eqn{d} vertices. There are therefore
#'
#' \deqn{
#'   2^d-d-2
#' }
#'
#' proper nonvertex faces.
#'
#' The number of codimension-\eqn{k} faces is
#'
#' \deqn{
#'   {d \choose k}.
#' }
#'
#' The function exhausts these layers in increasing order of \eqn{k}. Only the
#' final selected codimension layer can be partial.
#'
#' @section Reproducibility:
#' Sampling uses R's random-number generator. Use [set.seed()] before calling
#' the function to obtain reproducible results.
#'
#' @section Numerical considerations:
#' Coordinates outside the selected support are set exactly to zero. Positive
#' coordinates are generated using normalized exponential random variables.
#' The weighted equality constraint is satisfied up to floating-point
#' roundoff.
#'
#' @examples
#' # Mix interior points and face points.
#' set.seed(123)
#'
#' sample <- sample_weighted_simplex(
#'   kappa = c(1, 2, 3, 4, 5),
#'   C = 2,
#'   n = 1000,
#'   face_fraction = 0.4,
#'   points_per_face = 16
#' )
#'
#' dim(sample$Z)
#' sample$n_interior
#' sample$n_face_points
#' sample$selected_face_count
#'
#' # Verify the weighted equality constraint.
#' max(abs(drop(sample$Z %*% c(1, 2, 3, 4, 5)) - 2))
#'
#' # Maximize coverage across distinct faces.
#' set.seed(123)
#'
#' broad_sample <- sample_weighted_simplex(
#'   kappa = rep(1, 5),
#'   n = 100,
#'   face_fraction = 1,
#'   points_per_face = 0
#' )
#'
#' broad_sample$selected_face_count
#' broad_sample$faces$count
#'
#' # Inspect the selected codimension layers.
#' broad_sample$layer_count
#'
#' @export
sample_weighted_simplex <- function(
  kappa,
  C = 1,
  n = 1000L,
  face_fraction = 0.5,
  points_per_face = 0L,
  max_partial_attempts = 1000000L
) {
  n <- as.integer(n)
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || !is.finite(n) || n <= 0) {
    cli::cli_abort(
      c("{.arg n} must be a finite positive integer",
        "x" = "{.arg n} is {.val {head(n)}}"
      )
    )
  }
  if (!is.numeric(face_fraction) || length(face_fraction) != 1 || is.na(face_fraction) || face_fraction < 0 || face_fraction > 1) {
    cli::cli_abort(
      c("{.arg face_fraction} must be a number between 0 and 1",
        "x" = "{.arg face_fraction} is {.val {qmin}}"
      )
    )
  }
  n_face_points <- as.integer(round(n * face_fraction))
  d <- length(kappa)
  if (n_face_points == 0L) {
    n_selected_faces <- 0L
    effective_points_per_face <- 0L
  } else {
    total_faces <- number_of_faces_capped(d, n_face_points)
    nonvertex_faces <- number_of_nonvertex_faces_capped(d, n_face_points)
    vertices <- min(d, total_faces)

    if (nonvertex_faces == 0L && n_face_points > vertices) {
      cli::cli_abort(c(
        "The requested face-point budget is impossible in dimension {d}.",
        "i" = "All proper faces are vertices, so at most {vertices} distinct points can be generated on them.",
        "i" = "Reduce {.arg face_fraction} so that at most {vertices} points are allocated to faces."
      ))
    }

    if (points_per_face == 0L) {
      # Maximize the number of selected faces. Vertices can receive only one
      # point; the remaining points are spread over nonvertex faces.
      n_selected_faces <- min(n_face_points, total_faces)
      selected_vertices <- max(0L, n_selected_faces - nonvertex_faces)
      selected_nonvertices <- n_selected_faces - selected_vertices
      remaining_nonvertex_points <- n_face_points - selected_vertices
      if (selected_nonvertices > 0L) {
        effective_points_per_face <- as.integer(ceiling(remaining_nonvertex_points / selected_nonvertices))
      } else {
        effective_points_per_face <- 1L
      }
    } else {
      effective_points_per_face <- points_per_face

      capacity_with <- function(m, ppf) {
        nv <- min(m, nonvertex_faces)
        v <- max(0L, m - nonvertex_faces)
        nv * ppf + v
      }

      # Increase points_per_face only when even all proper faces do not provide
      # sufficient capacity. Vertex capacity remains exactly one.
      max_capacity <- capacity_with(total_faces, effective_points_per_face)
      if (max_capacity < n_face_points) {
        old <- effective_points_per_face
        effective_points_per_face <- as.integer(ceiling(
          (n_face_points - vertices) / nonvertex_faces
        ))
        cli::cli_warn(c(
          "{.arg points_per_face} is too small for the available nonvertex faces.",
          "i" = "Vertices can contribute only one point each.",
          "i" = "Increasing {.arg points_per_face} from {old} to {effective_points_per_face}."
        ))
      }

      # Smallest number of low-codimension-first faces with sufficient capacity.
      if (n_face_points <= nonvertex_faces * effective_points_per_face) {
        n_selected_faces <- as.integer(ceiling(
          n_face_points / effective_points_per_face
        ))
      } else {
        n_selected_faces <- as.integer(
          nonvertex_faces + n_face_points -
            nonvertex_faces * effective_points_per_face
        )
      }
    }
  }

  sample_weighted_simplex_low_codim_cpp(
    kappa, C, n, n_face_points, n_selected_faces,
    effective_points_per_face, max_partial_attempts
  )
}
