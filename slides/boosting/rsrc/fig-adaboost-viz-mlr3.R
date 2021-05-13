# ------------------------------------------------------------------------------
# FIG: ADABOOST
# ------------------------------------------------------------------------------

library(ggplot2)
library(mlr3verse)

# DATA -------------------------------------------------------------------------

x_1 <- c(10, 12, 16, 18, 3, 7, 12, 4, 6, 18)
x_2 <- c(19, 22, 18, 20, 12, 13, 11, 5, 2, 5)
class <-  c(1, 1, 1, -1, 1, -1, -1, 1, -1, -1)
label <- seq(1, 10)

dt <- data.table::data.table(
  x_1 = x_1, 
  x_2 = x_2, 
  class = factor(class), 
  label = label)

# PLOTS ------------------------------------------------------------------------

plot_adaboost <- function(dt, n_baselearners) {

  # Initialize vectors
  
  beta_hat <- c()
  b_hat <- list()
  
  # Initialize observation weights: w[1](i) = 1/n
  
  dt[, weights := 1 / nrow(dt)]
  
  # Initialize plots
  
  plots = list()
  
  # Iterate
  
  for (m in seq_len(n_baselearners)) {
    
    # Update weights
    
    task <- mlr3::TaskClassif$new(
      id = "example",
      backend = dt[, -c("label")],
      target = "class")
    
    task$set_col_roles("weights", "weight")
    
    # Train learner
    
    learner <- mlr3::lrn("classif.rpart", maxdepth = 1L, minsplit = 1L)
    learner$train(task)
    prediction <- data.table::as.data.table(learner$predict(task))
    
    # Calculate weighted in-sample misclassification rate
    
    misclassified <- (!prediction$truth == prediction$response)
    error <- sum(dt[misclassified]$weights)
    beta_hat[m] <- 0.5 * log((1 - error) / error)
    
    # Set new weights
    # Weights <- weights * exp(beta_hat[m] * as.numeric(misclassified))
    
    dt[
      , weights := weights * 
        exp(-beta_hat[m] *
              as.numeric(as.character(prediction$truth)) *
              as.numeric(as.character(prediction$response)))]

    # Normalize weights
    
    dt[, weights := weights / sum(weights)]

    # Plot
    
    print(m) 
    
    plots[[m]] <- mlr3viz::plot_learner_prediction(learner, task) +
      ggplot2::ggtitle("") +
      ggplot2::xlab(expression(x[1])) +
      ggplot2::ylab(expression (x[2])) +
      ggplot2::theme_bw() +
      ggplot2::theme(
        text = element_text(size = 20L),
        legend.title = element_blank()) +
      ggplot2::guides(shape = FALSE, alpha = FALSE)
    
  }
  
  plots
  
}

plots <- plot_adaboost(dt, 3L)

p_1 <- plots[[1]]
p_2 <- do.call(gridExtra::grid.arrange, c(plots[2L:3L], nrow = 2L))

ggplot2::ggsave(
  "../figure/adaboost_viz_mlr3_1.png", 
  p_1, 
  height = 4L, 
  width = 5L)

ggplot2::ggsave(
  "../figure/adaboost_viz_mlr3_2.png", 
  p_2, 
  height = 6L, 
  width = 4L)
