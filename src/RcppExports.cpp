// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// blv
Rcpp::List blv(const arma::mat& costs, const arma::vec& X, double alpha, double beta, const arma::vec& Z_init, double epsilon, int iter_max, int conv_check, double precision, bool quadratic);
RcppExport SEXP _blvim_blv(SEXP costsSEXP, SEXP XSEXP, SEXP alphaSEXP, SEXP betaSEXP, SEXP Z_initSEXP, SEXP epsilonSEXP, SEXP iter_maxSEXP, SEXP conv_checkSEXP, SEXP precisionSEXP, SEXP quadraticSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::mat& >::type costs(costsSEXP);
    Rcpp::traits::input_parameter< const arma::vec& >::type X(XSEXP);
    Rcpp::traits::input_parameter< double >::type alpha(alphaSEXP);
    Rcpp::traits::input_parameter< double >::type beta(betaSEXP);
    Rcpp::traits::input_parameter< const arma::vec& >::type Z_init(Z_initSEXP);
    Rcpp::traits::input_parameter< double >::type epsilon(epsilonSEXP);
    Rcpp::traits::input_parameter< int >::type iter_max(iter_maxSEXP);
    Rcpp::traits::input_parameter< int >::type conv_check(conv_checkSEXP);
    Rcpp::traits::input_parameter< double >::type precision(precisionSEXP);
    Rcpp::traits::input_parameter< bool >::type quadratic(quadraticSEXP);
    rcpp_result_gen = Rcpp::wrap(blv(costs, X, alpha, beta, Z_init, epsilon, iter_max, conv_check, precision, quadratic));
    return rcpp_result_gen;
END_RCPP
}
// we_oc
arma::mat we_oc(const arma::mat& costs, const arma::vec& X, double alpha, double beta, const arma::vec& Z);
RcppExport SEXP _blvim_we_oc(SEXP costsSEXP, SEXP XSEXP, SEXP alphaSEXP, SEXP betaSEXP, SEXP ZSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::mat& >::type costs(costsSEXP);
    Rcpp::traits::input_parameter< const arma::vec& >::type X(XSEXP);
    Rcpp::traits::input_parameter< double >::type alpha(alphaSEXP);
    Rcpp::traits::input_parameter< double >::type beta(betaSEXP);
    Rcpp::traits::input_parameter< const arma::vec& >::type Z(ZSEXP);
    rcpp_result_gen = Rcpp::wrap(we_oc(costs, X, alpha, beta, Z));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_blvim_blv", (DL_FUNC) &_blvim_blv, 10},
    {"_blvim_we_oc", (DL_FUNC) &_blvim_we_oc, 5},
    {NULL, NULL, 0}
};

RcppExport void R_init_blvim(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
