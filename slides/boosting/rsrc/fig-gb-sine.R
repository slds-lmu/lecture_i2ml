# ------------------------------------------------------------------------------
# FIG: OVERFITTING FOR SINUSOIDAL DATA
# ------------------------------------------------------------------------------

# Purpose: visualize how gbm nicely approximates sinusoidal data but overfits 
# when noise is present

library(ggplot2)

# DATA -------------------------------------------------------------------------

n <- 50L
x <- seq(0L, 3 * pi / 2L, length.out = n)
y <- sin(x)
data = data.table::data.table(x = x, y = y)
n_trees = 1000L

# PLOTS ------------------------------------------------------------------------

plot_gbm <- function(data, noise, shrinkage = 0.1) {
  
  set.seed(1L)
  data$y <- data$y + rnorm(nrow(data), sd = noise)
  
  model <- gbm::gbm(
    y ~ ., 
    data = data, 
    distribution = "gaussian",
    verbose = FALSE,
    interaction.depth = 1L, 
    shrinkage = shrinkage,
    bag.fraction = 1L, 
    n.minobsinnode = 2L,
    n.trees = 1000L)
  
  iterations <- c(1L, 10L, 20L, 1000L)
  
  data_pred <- data.frame(x = data$x)

  for (i in iterations) {
    data_pred <- cbind(
      data_pred, 
      predict(model, n.trees = i))
  }

  names(data_pred) <- c("x", as.character(iterations))
  
  data_pred <- data.table::melt.data.table(
    data.table::as.data.table(data_pred), 
    id = c("x"), 
    measure = as.character(iterations))
  
  data.table::setnames(data_pred, c("x", "M", "y"))
  
  ggplot2::ggplot(data, aes(x = x, y = y)) +
    ggplot2::geom_point() +
    ggplot2::geom_step(
      data_pred,
      mapping = aes(x = x, y = y, col = M)) +
    ggplot2::ggtitle(sprintf("y = sin(x) + N(0, %.1f)", noise)) +
    ggplot2::scale_color_manual(
      values = c("darkgray", "red", "orange", "blue")) +
    ggplot2::theme_minimal()

}

p <- gridExtra::grid.arrange(
  plot_gbm(data, noise = 0),
  plot_gbm(data, noise = 0.2),
  nrow = 1L)

ggplot2::ggsave("../figure/gbm_sine.png", p, height = 4L, width = 8L)
ggplot2::ggsave(
  "../figure/gbm_sine_title.png", 
  plot_gbm(data, noise = 0.2) + ggplot2::ggtitle(""), 
  height = 4L, 
  width = 5L)

