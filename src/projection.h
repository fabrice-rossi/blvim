#ifndef PROJECTION_H
#define PROJECTION_H

#include <RcppArmadillo.h>

arma::vec project_weighted_simplex(const arma::vec& y,
                                   const arma::vec& kappa,
                                   double sum_kappa_sq,
                                   double C,
                                   double tol,
                                   int max_iter);

arma::vec project_simplex(const arma::vec& y, double tol, int max_iter);

#endif
