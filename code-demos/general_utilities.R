## @knitr knn-plot_2D_classif

# function for a general classification method with two features to visualize 
# class boundaries X1 and X2 are the names of the two features to use. 
plot_2D_classify <- function(to_classify_labels,
                             to_classify_data, 
                             classify_method, 
                             X1, X2,
                             lengthX1 = 100, lengthX2 = 100,
                             title = "") {
  gridX1 <- seq(
    min(to_classify_data[, X1]),
    max(to_classify_data[, X1]),
    length.out = lengthX1
  )
  gridX2 <- seq(
    min(to_classify_data[, X2]),
    max(to_classify_data[, X2]),
    length.out = lengthX2
  )
  
  # compute grid coordinates with cartesian product
  grid_data <- expand.grid(gridX1, gridX2)
  names(grid_data) <- c(X1, X2)
  
  # assign grid cells to classes based on classification rule:
  grid_result <- classify_method(
    to_classify_data = grid_data
  )
  grid_data$prediction <- grid_result$prediction
  
  # assign data to be classified based on classification rule & check these 
  # "predictions"
  to_check_result <- classify_method(
    to_classify_data = to_classify_data[, c(X1, X2)]
  )
  to_classify_data$class <- to_classify_labels
  to_classify_data$correct <- (to_check_result$prediction == to_classify_labels)
  
  
  ggplot() +
    geom_raster(
      data = grid_data, 
      aes_string(x = X1, y = X2, fill = "prediction"), 
      alpha = .8
    ) +
    geom_point(
      data = to_classify_data, 
      aes_string(x = X1, y = X2, shape = "class", color = "correct"),
      alpha = .8
    ) +
    scale_color_manual(
      values = c("TRUE" = "darkgray", "FALSE" = "white"), 
      guide = FALSE
    ) +
    labs(
      fill = "Class", shape = "Class",
      title = paste0(
        title, ": ",
        100 * round(mean(to_classify_data$correct), 4),
        "% correctly classified"
      )
    ) + 
    theme(plot.title = element_text(size=16))
}

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
