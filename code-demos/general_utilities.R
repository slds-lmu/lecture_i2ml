
## @knitr grad_desc_opt-def

gradient_descent_opt_stepsize <- function(Y, X, theta,
                                          risk = risk_quadratic,
                                          gradient = gradient_quadratic,
                                          lambda = 0.005,
                                          epsilon = 0.0001,
                                          max_iterations = 2000,
                                          min_learning_rate = 0,
                                          max_learning_rate = 1000,
                                          plot = TRUE) {
  # initialize storage for visualizations below (with maxiter + 1 slots)
  loss_storage <- data.frame(
    iterations = seq_len(max_iterations) - 1,
    loss = NA
  )
  theta_storage <- matrix(NA, ncol = length(theta), nrow = max_iterations + 1)

  loss_storage[1, "loss"] <- risk(Y, X, theta)
  theta_storage[1, ] <- theta

  #  loop over gradient updates
  for (i in 1:max_iterations) {
    grad <- gradient(Y = Y, X = X, theta = theta)
    lambda_opt <- optim(
      par = lambda, # start value
      fn = function(lambda) risk(Y = Y, X = X, theta = theta - lambda * grad), # to min
      method = "Brent", # 1d minimization
      lower = min_learning_rate,
      upper = max_learning_rate,
    )$par

    theta <- theta - lambda_opt * grad
    loss_storage[i + 1, "loss"] <- risk(Y = Y, X = X, theta = theta)
    theta_storage[i + 1, ] <- t(theta)
    # check if convergence has been reached
    if (i > 1 && sqrt(sum((theta_storage[i, ] - theta_storage[i + 1, ])^2)) < epsilon) {
      break
    }
  }
  if (plot) {
    layout(t(1:(length(theta) + 1)))
    for (i in 1:length(theta)) {
      plot(theta_storage[, i],
        ylab = "coefficient value",
        xlab = "iteration", type = "l", col = "blue",
        main = bquote(theta[.(i - 1)])
      )
    }
    plot(loss_storage[, "loss"],
      ylab = "empirical risk",
      xlab = "iteration", type = "l", col = "red",
      main = expression(R[emp](theta))
    )
  }
  list(theta = theta, risk = risk(Y, X, theta))
}
