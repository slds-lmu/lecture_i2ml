plot_linear_boosting <- function(x, 
                                 y, 
                                 iteration, 
                                 alpha, 
                                 distribution, 
                                 basis_fun, 
                                 learning_rate) {
  
  # Set initial, constant prediction
  
  X <- basis_fun(x)
  
  init_constant <- switch(
    distribution,
    gaussian = mean(y),
    laplace = median(y),
    quantile = quantile(y, probs = alpha),
    huber = median(y))
  
  overall_pred <- rep(init_constant, length(y))
  pseudo_res <- y
  coefs <- matrix(0L, nrow = iteration, ncol = ncol(X))
  ylim <- c(min(y) - mean(y), max(y))
  
  preds <- list(overall_pred)
  
  # Plot boosting procedure
  
  for (i in seq_len(iteration)) {
    
    # Update step
    
    pseudo_res <- switch(
      distribution,
      gaussian = y - overall_pred,
      laplace = sign(y - overall_pred),
      quantile = ifelse(y > overall_pred, alpha, -(1L - alpha)),
      huber = ifelse(
        abs(y - overall_pred) <= alpha, 
        y - overall_pred, 
        alpha * sign(y - overall_pred)))
    
    coefs[i, ] <- learning_rate * 
      tcrossprod(solve(crossprod(X)), X) %*% pseudo_res
    
    baselearner_pred <- X %*% coefs[i, ]
    
    overall_pred <- c(overall_pred + baselearner_pred)
    preds[[i + 1L]] <- overall_pred

  }
  
  cum_y <- data.table::data.table(do.call(cbind, preds))
  names(cum_y) <- sprintf("y_%i", c(0L, seq_len(iteration)))
  
  cum_data <- data.table::melt.data.table(
    data.table::data.table(x = x, cum_y),
    id = c("x"),
    measure = sprintf("y_%i", c(0L, seq_len(iteration))))
  
  alphas <- seq(0.9, 1L, length.out = length(names(cum_y)))
  cum_data$alpha <- c(sapply(alphas, rep, length(x)))
  
  p <- ggplot2::ggplot(data.frame(x = x, y = y), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  
  p <- p + ggplot2::geom_line(
    cum_data,
    mapping = ggplot2::aes(x = x, y = value, group = variable, alpha = variable), 
    col = "blue") +
    ggplot2::scale_alpha_discrete(range = c(0.1, 1L)) +
    ggplot2::guides(alpha = FALSE)

}