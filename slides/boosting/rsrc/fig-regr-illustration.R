# ------------------------------------------------------------------------------
# FIG: REGRESSION ILLUSTRATION
# ------------------------------------------------------------------------------

# Purpose: visualize boosting for regression with GAM

library(ggplot2)

# DATA -------------------------------------------------------------------------

n_sim <- 50L

set.seed(31415L)
x <- seq(0L, 10L, length.out = n_sim)
y_gaussian <- 4L + 3L * x + 5L * sin(x) + rnorm(n_sim, 2L)
y_tdist <- 4L + 3L * x + 5L * sin(x) + rnorm(n_sim, 1L)

# FUNCTIONS --------------------------------------------------------------------

# Transformations for different models

basis_trafo <- function(x) {
  margin <- 0.1 * (max(x) - min(x))
  splines::splineDesign(
    knots = seq(min(x) - margin, max(x) + margin, length.out = 40L), 
    x = x)
}

basis_trafo_linear <- function(x) cbind(1L, x)

# Animated plots

plot_boosting <- function(x, 
                          y,
                          loss, 
                          eps, 
                          distribution, 
                          basis_fun, 
                          boosting_iters,
                          learning_rate = 0.1,
                          alpha = 0.2) {
  
  for (iteration in boosting_iters) {
    
    name <- sprintf("../figure/illustration_%s_%s_%i.png", eps, loss, iteration)
    
    plot <- plot_linear_boosting(
      x = x, 
      y = y, 
      iteration = iteration,
      learning_rate = learning_rate,
      alpha = alpha, 
      distribution = distribution, 
      basis_fun = basis_fun)
    
    invisible(ggplot2::ggsave(name, plot, height = 4L, width = 12L))
    
  }
  
}

# PLOTS ------------------------------------------------------------------------

# Data

p_1 <- ggplot2::ggplot(data.frame(x = x, y = y_gaussian), ggplot2::aes(x, y)) +
  ggplot2::geom_point() +
  ggplot2::theme_minimal() +
  ggplot2::theme(text = ggplot2::element_text(size = 20L))

ggplot2::ggsave(
  "../figure/illustration_data_normal.png", 
  p_1, 
  height = 3L, 
  width = 6L)

# Scaled data

p_2 <- ggplot2::ggplot(
  data.frame(x = x, y = scale(y_gaussian)), 
  ggplot2::aes(x, y)) +
  ggplot2::geom_point() +
  ggplot2::theme_minimal() +
  ggplot2::theme(text = ggplot2::element_text(size = 20L))

ggplot2::ggsave(
  "../figure/illustration_data_normal_scaled.png", 
  p_2, 
  height = 3L, 
  width = 6L)

# Boosting animation for L1 & L2 loss

boosting_iters <- c(1L:3L, 10L)

plot_boosting(
  x = x,
  y = scale(y_gaussian),
  loss = "L2", 
  eps = "gaussian", 
  distribution = "gaussian",
  basis_fun = basis_trafo,
  boosting_iters = boosting_iters,
  learning_rate = 0.1)

plot_boosting(
  x = x,
  y = scale(y_gaussian),
  loss = "L1", 
  eps = "gaussian", 
  distribution = "laplace",
  basis_fun = basis_trafo,
  boosting_iters = boosting_iters,
  learning_rate = 0.1)
