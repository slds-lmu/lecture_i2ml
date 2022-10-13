# ------------------------------------------------------------------------------
# FIG: ADABOOST
# ------------------------------------------------------------------------------

# Purpose: visualize adaboost functionality with toy data

library(ggplot2)
library(mlr3verse)

# DATA -------------------------------------------------------------------------

x_1 <- c(10, 12, 16, 18, 3, 7, 12, 4, 6, 18)
x_2 <- c(19, 22, 18, 20, 12, 13, 11, 5, 2, 5)
class <-  c(1, 1, 1, -1, 1, -1, -1, 1, -1, -1)
label <- seq(1, 10)

# PLOTS ------------------------------------------------------------------------

plot_adaboost <- function(n_baselearners) {

  dt <- data.table::data.table(
  x_1 = x_1,
  x_2 = x_2,
  class = factor(class),
  label = label)

  # Initialize vectors
  
  beta_hat <- c()
  
  # Initialize observation weights: w[1](i) = 1/n
  
  dt[, weights := 1 / nrow(dt)]

  
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
    
  }
  
  mlr3viz::plot_learner_prediction(learner, task) +
      ggplot2::geom_text(
        data = dt,
        aes(label=round(weights, digits = 2)),
        vjust = -1,
        size = 3) +
      ggplot2::geom_point(
        data = dt,
        aes(size=weights, fill=class),
        shape=21) +
      ggplot2::scale_size(range=c(2,5)) +
      ggplot2::ggtitle("") +
      ggplot2::xlab(expression(x[1])) +
      ggplot2::ylab(expression (x[2])) +
      ggplot2::theme_bw() +
      ggplot2::theme(
        text = element_text(size = 20L),
        legend.title = element_blank()) +
      ggplot2::guides(shape = FALSE, alpha = FALSE, size = FALSE) +
      ggplot2::scale_fill_hue() +
      ggplot2::xlim(3, 18) +
      ggplot2::ylim(2, 22.6)
  
}

p1 <- plot_adaboost(1L)
p2 <- plot_adaboost(2L)
p3 <- plot_adaboost(3L)

p23 <- gridExtra::grid.arrange(p2, p3, nrow = 2L)

ggplot2::ggsave(
  "../figure/adaboost_viz_mlr3_1.png",
  p1,
  height = 4L,
  width = 5L)

ggplot2::ggsave(
  "../figure/adaboost_viz_mlr3_2.png",
  p23,
  height = 6L,
  width = 4L)
