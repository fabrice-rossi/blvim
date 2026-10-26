// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <limits>
#include <numeric>
#include <string>
#include <unordered_set>
#include <vector>

using namespace Rcpp;

// Returns choose(n,k) exactly when it is <= cap, and cap + 1 otherwise.
// The calculation is stopped before size_t overflow can occur.
std::size_t choose_capped(unsigned n, unsigned k, std::size_t cap) {
  if(k > n)
    return 0;  // # nocov
  k = std::min(k, n - k);
  if(k == 0)
    return 1;  // # nocov

  // At each step the binomial recurrence gives an exact integer.
  std::size_t value = 1;
  for(unsigned i = 1; i <= k; ++i) {
    const std::size_t numerator = static_cast<std::size_t>(n - k + i);

    // value * numerator / i > cap iff value * numerator > cap * i.
    // Use long double only for this comparison, then perform checked integer
    // arithmetic when the result is known not to exceed cap.
    const long double candidate =
        static_cast<long double>(value) * numerator / i;
    if(candidate > static_cast<long double>(cap))
      return cap + 1;

    // Reduce before multiplication to avoid intermediate overflow.
    std::size_t a = value;
    std::size_t b = numerator;
    std::size_t den = i;
    const std::size_t g1 = std::gcd(b, den);
    b /= g1;
    den /= g1;
    const std::size_t g2 = std::gcd(a, den);
    a /= g2;
    den /= g2;
    if(den != 1)
      stop("Internal error in binomial coefficient calculation");  // # nocov
    if(b != 0 && a > cap / b)
      return cap + 1;  // # nocov
    value = a * b;
  }
  return value;
}

bool next_combination(std::vector<unsigned>& x, unsigned d) {
  const unsigned k = static_cast<unsigned>(x.size());
  for(unsigned ii = k; ii-- > 0;) {
    const unsigned upper = d - k + ii;
    if(x[ii] < upper) {
      ++x[ii];
      for(unsigned j = ii + 1; j < k; ++j)
        x[j] = x[j - 1] + 1;
      return true;
    }
  }
  return false;  // # nocov
}

std::vector<unsigned> random_subset(unsigned d, unsigned r) {
  // Floyd's algorithm: O(r) expected time and O(r) memory.
  std::unordered_set<unsigned> s;
  s.reserve(2 * r + 1);
  for(unsigned j = d - r; j < d; ++j) {
    unsigned t = (unsigned)std::floor(R::runif(0.0, 1.0) * (j + 1.0));
    if(t > j)
      t = j;  // # nocov
    if(!s.insert(t).second)
      s.insert(j);
  }
  std::vector<unsigned> ans(s.begin(), s.end());
  std::sort(ans.begin(), ans.end());
  return ans;
}

std::vector<unsigned> support_from_zero(unsigned d,
                                        const std::vector<unsigned>& zero) {
  std::vector<unsigned> support;
  support.reserve(d - zero.size());
  std::size_t z = 0;
  for(unsigned j = 0; j < d; ++j) {
    if(z < zero.size() && zero[z] == j) {
      ++z;
    } else {
      support.push_back(j);
    }
  }
  return support;
}

std::string face_key(const std::vector<unsigned>& zero) {
  std::string key(zero.size() * sizeof(std::uint32_t), '\0');
  for(std::size_t i = 0; i < zero.size(); ++i) {
    const std::uint32_t value = static_cast<std::uint32_t>(zero[i]);
    std::memcpy(&key[i * sizeof(value)], &value, sizeof(value));
  }
  return key;
}

void fill_point(arma::mat& Z,
                arma::uword row,
                const std::vector<unsigned>& support,
                const arma::vec& kappa,
                double C) {
  const std::size_t s = support.size();
  std::vector<double> e(s);
  long double total = 0.0L;

  for(std::size_t h = 0; h < s; ++h) {
    const double value = R::rexp(1.0);
    e[h] = value;
    total += value;
  }

  if(!(total > 0.0L) || !std::isfinite(static_cast<double>(total)))
    stop("Failed to normalize simplex coordinates");  // # nocov

  for(std::size_t h = 0; h < s; ++h) {
    const unsigned j = support[h];
    Z(row, j) = C * e[h] / (static_cast<double>(total) * kappa[j]);
  }
}

// Sample a weighted simplex, exhausting low-codimension faces first
//
// @param kappa Positive weights in sum(kappa * Z) = C.
// @param C Positive weighted mass.
// @param face_fraction Fraction of observations allocated to proper faces.
// @param points_per_face If zero, select one face per face point. If positive,
//   select ceiling(n_face_points / points_per_face) faces and distribute the
//   face points as evenly as possible, never exceeding points_per_face.
// @param n Total sample size.
// @param max_partial_attempts Maximum proposals for the last partial layer.
// @return A list containing Z, codim, zero, layer_count, backend, and error.
// [[Rcpp::export]]
Rcpp::List sample_weighted_simplex_low_codim_cpp(const arma::vec& kappa,
                                                 double C,
                                                 int n,
                                                 int n_face_points,
                                                 int n_selected_faces,
                                                 int points_per_face,
                                                 int max_partial_attempts) {
  RNGScope scope;

  const unsigned d = static_cast<unsigned>(kappa.n_elem);
  const int n_interior = n - n_face_points;
  const std::size_t selected_face_count =
      static_cast<std::size_t>(n_selected_faces);

  // Select distinct faces, exhausting low codimensions first.
  std::vector<std::vector<unsigned>> faces;
  faces.reserve(selected_face_count);
  std::vector<std::size_t> layer_count(d, 0);
  std::size_t remaining = selected_face_count;
  unsigned partial_codim = 0;

  for(unsigned k = 1; k < d && remaining > 0; ++k) {
    const std::size_t capacity = choose_capped(d, k, remaining);
    if(capacity <= remaining) {
      layer_count[k] = capacity;
      std::vector<unsigned> zero(k);
      std::iota(zero.begin(), zero.end(), 0u);
      for(std::size_t i = 0; i < capacity; ++i) {
        faces.push_back(zero);
        if(i + 1 < capacity && !next_combination(zero, d))
          stop("Internal error while enumerating faces");  // # nocov
      }
      remaining -= capacity;
    } else {
      layer_count[k] = remaining;
      partial_codim = k;
      std::unordered_set<std::string> seen;
      seen.reserve(static_cast<std::size_t>(remaining * 1.4) + 1);
      std::size_t accepted = 0;
      int attempts = 0;
      while(accepted < remaining) {
        if(++attempts > max_partial_attempts)
          stop("Could not obtain enough unique faces in the partial layer");
        std::vector<unsigned> zero = random_subset(d, k);
        if(!seen.insert(face_key(zero)).second)
          continue;
        faces.push_back(std::move(zero));
        ++accepted;
      }
      remaining = 0;
    }
  }
  if(remaining > 0)
    stop(
        "The requested number of selected faces exceeds the number of proper "
        "positive-dimensional faces");

  // Allocate points fairly, subject to per-face capacities. A vertex has
  // support size one and therefore contains only one distinct simplex point.
  // Every other selected face has capacity points_per_face.
  std::vector<int> face_point_count(selected_face_count, 0);
  std::vector<int> face_capacity(selected_face_count, 0);
  std::size_t total_capacity = 0;

  for(std::size_t f = 0; f < selected_face_count; ++f) {
    const bool is_vertex = faces[f].size() == d - 1;
    face_capacity[f] = is_vertex ? 1 : points_per_face;
    total_capacity += static_cast<std::size_t>(face_capacity[f]);
  }

  if(total_capacity < static_cast<std::size_t>(n_face_points))
    stop("Internal error: selected faces do not have enough point capacity");  // # nocov

  // Progressive round-robin allocation keeps counts within one whenever the
  // capacities allow it, while vertices are automatically frozen at one.
  int points_left = n_face_points;
  while(points_left > 0) {
    bool allocated = false;
    for(std::size_t f = 0; f < selected_face_count && points_left > 0; ++f) {
      if(face_point_count[f] < face_capacity[f]) {
        ++face_point_count[f];
        --points_left;
        allocated = true;
      }
    }
    if(!allocated)
      stop("Internal error while allocating points to selected faces");  // # nocov
  }

  arma::mat Z(n, d, arma::fill::zeros);
  IntegerVector codim(n);
  IntegerVector face_id(
      n, 0);  // 0 for interior, 1..selected_face_count for faces.
  List zero_list(n);
  arma::uword row = 0;
  std::vector<unsigned> all(d);
  std::iota(all.begin(), all.end(), 0u);

  for(int i = 0; i < n_interior; ++i, ++row) {
    fill_point(Z, row, all, kappa, C);
    codim[row] = 0;
    zero_list[row] = IntegerVector(0);
  }

  List face_zero(selected_face_count);
  IntegerVector face_codim(selected_face_count);
  IntegerVector points_on_face(selected_face_count);

  for(std::size_t f = 0; f < selected_face_count; ++f) {
    const std::vector<unsigned>& zero = faces[f];
    const std::vector<unsigned> support = support_from_zero(d, zero);
    IntegerVector zero_R(zero.size());
    for(std::size_t h = 0; h < zero.size(); ++h)
      zero_R[h] = static_cast<int>(zero[h]) + 1;
    face_zero[f] = zero_R;
    face_codim[f] = static_cast<int>(zero.size());
    points_on_face[f] = face_point_count[f];

    for(int q = 0; q < face_point_count[f]; ++q, ++row) {
      fill_point(Z, row, support, kappa, C);
      codim[row] = static_cast<int>(zero.size());
      face_id[row] = static_cast<int>(f) + 1;
      zero_list[row] = clone(zero_R);
    }
  }

  if(row != static_cast<arma::uword>(n))
    stop("Internal error: generated sample size differs from n");  // # nocov

  const arma::vec mass = Z * kappa;
  const double max_error = n == 0 ? 0.0 : arma::max(arma::abs(mass - C));
  const double tolerance = 128.0 * std::numeric_limits<double>::epsilon() *
                           std::max(1.0, std::abs(C)) * d;
  if(max_error > tolerance)
    warning("Weighted-simplex equality has a larger residual than expected");  // # nocov

  IntegerVector layer_count_R(d - 1);
  for(unsigned k = 1; k < d; ++k) {
    if(layer_count[k] >
       static_cast<std::size_t>(std::numeric_limits<int>::max()))
      stop("A layer count exceeds R's integer range");  // # nocov
    layer_count_R[k - 1] = static_cast<int>(layer_count[k]);
  }

  IntegerVector pcodim(1);
  pcodim(0) = partial_codim == 0 ? NA_INTEGER : static_cast<int>(partial_codim);

  return List::create(
      _["Z"] = Z, _["codim"] = codim, _["zero"] = zero_list,
      _["face_id"] = face_id,
      _["faces"] = List::create(_["codim"] = face_codim, _["zero"] = face_zero,
                                _["count"] = points_on_face),
      _["n_interior"] = n_interior, _["n_face_points"] = n_face_points,
      _["selected_face_count"] = static_cast<double>(selected_face_count),
      _["points_per_face"] = points_per_face, _["layer_count"] = layer_count_R,
      _["partial_codim"] = pcodim, _["max_constraint_error"] = max_error);
}
