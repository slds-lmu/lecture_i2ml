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
  coefs <- matrix(0L, nrow = iteration + 1L, ncol = ncol(X))
  ylim <- c(min(y) - mean(y), max(y))
  
  preds <- list(overall_pred)
  
  # Compute boosting procedure
  
  for (i in (seq_len(iteration) + 1L)) {
    
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
    preds[[i]] <- overall_pred

  }
  
  # Collect predictions
  
  preds_dt <- data.table::data.table(do.call(cbind, preds))
  data.table::setnames(preds_dt, sprintf("y_%i", seq_along(preds)))
  
  dt <- data.table::melt.data.table(
    data.table::data.table(x = x, preds_dt),
    id = c("x"),
    measure = sprintf("y_%i", seq_along(preds)))
  
  # Create plots

  p_1 <- ggplot2::ggplot(data.frame(x = x, y = y), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  
  p_1 <- p_1 + ggplot2::geom_line(
    dt[variable != sprintf("y_%i", iteration + 1L)],
    mapping = ggplot2::aes(
      x = x, y = value, group = variable, alpha = variable), 
    col = "blue", 
    size = 1.05) +
    ggplot2::scale_alpha_discrete(range = c(0.3, 1L)) +
    ggplot2::guides(alpha = FALSE)
  
  res_dt <- data.table::data.table(
    x = x, 
    y = y, 
    xend = x, 
    yend = preds[[iteration]])
  
  p_1 <- p_1 + ggplot2::geom_segment(
    res_dt,
    mapping = ggplot2::aes(x = x, y = y, xend = x, yend = yend),
    col = "darkgray")
  
  p_2 <- ggplot2::ggplot(
    data.frame(x = x, y = pseudo_res), ggplot2::aes(x, y)) +
    ggplot2::geom_point(col = "blue", shape = 4L, size = 2L) +
    ggplot2::ylab("residuals of current model") +
    ggplot2::ylim(ylim) +
    ggplot2::geom_line(
      mapping = ggplot2::aes(x = x, y = baselearner_pred / learning_rate),
      color = "darkgray",
      size = 1.05)
  
  gridExtra::grid.arrange(p_1, p_2, ncol = 2L)

}
