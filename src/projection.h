#ifndef PROJECTION_H
#define PROJECTION_H

#include <RcppArmadillo.h>

arma::vec project_weighted_simplex(const arma::vec& Y,
                                   const arma::vec& kappa,
                                   double C,
                                   double tol,
                                   int max_iter);
#endif
