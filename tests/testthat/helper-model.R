norm_2 <- function(x) {
  tmp <- max(abs(x))
  tmp * sqrt(sum((abs(x) / tmp)^2))
}

r_blvim <- function(costs, X, alpha, beta, Z_init,
                    epsilon = 0.01,
                    iter_max = 50000,
                    conv_check = 100,
                    precision = 1e-6,
                    quadratic = FALSE) {
  exp_costs <- exp(-beta * costs)
  Z <- Z_init
  for (iter in 1:iter_max) {
    Z_alpha <- Z**alpha
    XZeC <- outer(X, Z_alpha) * exp_costs
    Y_norm <- exp_costs %*% Z_alpha
    Y <- sweep(XZeC, 1, Y_norm[, 1], "/")
    D <- colSums(Y)
    if (quadratic) {
      delta_Z <- (D - Z) * Z
    } else {
      delta_Z <- (D - Z)
    }
    Z <- Z + epsilon * delta_Z
    if (iter %% conv_check == 0) {
      delta_norm <- norm_2(delta_Z)
      if (delta_norm < precision * (norm_2(Z) + precision)) {
        break
      }
    }
  }
  new_sim(Y, Z, iteration = iter)
}
