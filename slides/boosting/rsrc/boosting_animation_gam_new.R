# ------------------------------------------------------------------------------
# FUN: BOOSTING ANIMATION GAM
# ------------------------------------------------------------------------------

# Purpose: perform boosting for regression with GAM

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
  
  # Plot boosting procedure
  
  for (i in seq_len(iteration)) {
    
    if (i == iteration) {
      
      # Pre-define these, otherwise lazy eval will call updated plots in final
      # grid.arrange (where overall_pred is already at i + 1)
      
      df_pred <- data.frame(x = x, y = overall_pred)
      df_seg <- data.frame(x = x, y = y, xend = x, yend = overall_pred)
      
      # Plot model & residuals
      
      p_1 <- ggplot2::ggplot(
        data.frame(x = x, y = y), ggplot2::aes(x, y)) +
        ggplot2::geom_point() +
        ggplot2::geom_line(
          df_pred,
          mapping = ggplot2::aes(x = x, y = y),
          col = "blue",
          size = 1.1) +
        ggplot2::geom_segment(
          df_seg,
          mapping = ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
          col = "blue") +
        ggplot2::ylim(ylim)
        
      # Add earlier models
      
      if (i > 1L) {
        
        p_1 <- p_1 + 
          ggplot2::geom_line(
            mapping = ggplot2::aes(x = x, y = overall_pred),
            col = "blue")
        
        # Create accumulated data in long format (ggplot does not support adding
        # layers via for loops due to lazy eval, only ever adds final layer)
        
        cum_coefs <- apply(coefs[seq_len(i), ], 2L, cumsum)
        alphas <- seq(0.5, 0.9, length.out = nrow(cum_coefs))
        
        cum_y <- data.table::data.table(tcrossprod(X, cum_coefs))
        names(cum_y) <- sprintf("y_%i", seq_len(iteration))

        cum_data <- data.table::melt.data.table(
          data.table::data.table(x = x, cum_y),
          id = c("x"),
          measure = sprintf("y_%i", seq_len(iteration)))

        cum_data$alpha <- c(sapply(alphas, rep, length(x)))
        
        p_1 <- p_1 + 
          ggplot2::geom_line(
            cum_data,
            mapping = ggplot2::aes(
              x = x, 
              y = value, 
              group = variable, 
              alpha = alpha),
            col = "blue") +
          ggplot2::guides(alpha = FALSE)

      }

    }
    
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
    overall_pred <- overall_pred + baselearner_pred
    
    if (i == iteration) {
      
      p_2 <- ggplot2::ggplot(
        data.frame(x = x, y = pseudo_res), ggplot2::aes(x, y)) +
        ggplot2::geom_point(col = "blue", shape = 4L, size = 2L) +
        ggplot2::ylab("residuals of current model") +
        ggplot2::ylim(ylim) +
        ggplot2::geom_line(
          mapping = ggplot2::aes(x = x, y = baselearner_pred / learning_rate),
          color = "darkgray",
          size = 1.2)
      
    }
    
  }
  
  gridExtra::grid.arrange(p_1, p_2, ncol = 2L)
  
}
