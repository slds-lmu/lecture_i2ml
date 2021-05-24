# ------------------------------------------------------------------------------
# FIG: REGRESSION ILLUSTRATION
# ------------------------------------------------------------------------------

# Purpose: visualize boosting for regression with GAM

library(ggplot2)

source("boosting_animation_gam.R")

# DATA -------------------------------------------------------------------------

n_sim <- 50L
x <- seq(0L, 10L, length.out = n_sim)
y_noiseless <- -1L + 0.2 * x + 0.1 * sin(x)

set.seed(31415L)
y_gaussian <- y_noiseless + rnorm(n_sim, sd = 0.1)

set.seed(1L)
y_tdist <- y_noiseless + rt(n_sim, df = 2L)

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
                          alpha = 0.2,
                          height = 3L, 
                          width = 12L) {
  
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
    
    invisible(ggplot2::ggsave(name, plot, height = height, width = width))
    
  }
  
}

# PLOTS ------------------------------------------------------------------------

# Title

p_title <- plot_linear_boosting(
  x = x, 
  y = y_gaussian, 
  iteration = 3L,
  learning_rate = 0.1,
  alpha = 0.2, 
  distribution = "gaussian", 
  basis_fun = basis_trafo)

ggplot2::ggsave(
  "../figure/illustration_title.png", p_title, height = 3L, width = 4.5L)

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

# Boosting animation for L1 & L2 loss

boosting_iters <- c(1L:3L, 10L, 100L)

plot_boosting(
  x = x,
  y = y_gaussian,
  loss = "L2", 
  eps = "gaussian", 
  distribution = "gaussian",
  basis_fun = basis_trafo,
  boosting_iters = boosting_iters)

plot_boosting(
  x = x,
  y = y_gaussian,
  loss = "L1", 
  eps = "gaussian", 
  distribution = "laplace",
  basis_fun = basis_trafo,
  boosting_iters = boosting_iters)

# Boosting animation for Huber loss

plot_boosting(
  x = x,
  y = y_gaussian,
  loss = "huber_02",
  eps = "gaussian",
  distribution = "huber",
  alpha = 0.2,
  basis_fun = basis_trafo,
  boosting_iters = 10L,
  height = 2.5)

plot_boosting(
  x = x,
  y = y_gaussian,
  loss = "huber_2",
  eps = "gaussian",
  distribution = "huber",
  alpha = 2L,
  basis_fun = basis_trafo,
  boosting_iters = 10L,
  height = 2.5)

# Boosting animation for t-distributed errors

plot_boosting(
  x = x,
  y = y_tdist,
  loss = "L2", 
  eps = "tdist", 
  distribution = "gaussian",
  basis_fun = basis_trafo,
  boosting_iters = c(10L, 100L))

plot_boosting(
  x = x,
  y = y_tdist,
  loss = "L1", 
  eps = "tdist", 
  distribution = "laplace",
  basis_fun = basis_trafo,
  boosting_iters = c(10L, 100L))

# Boosting animation for LM

plot_boosting(
  x = x,
  y = y_gaussian,
  loss = "L2_lin", 
  eps = "gaussian", 
  distribution = "gaussian",
  basis_fun = basis_trafo_linear,
  boosting_iters = boosting_iters)

plot_boosting(
  x = x,
  y = y_gaussian,
  loss = "L1_lin", 
  eps = "gaussian", 
  distribution = "laplace",
  basis_fun = basis_trafo_linear,
  boosting_iters = boosting_iters)



plot_linear_boosting(
  x = x, 
  y = y_gaussian, 
  iteration = 100L,
  learning_rate = 0.2,
  alpha = 0.2, 
  distribution = "gaussian", 
  basis_fun = basis_trafo_linear)

plot_boosting(
  x = x,
  y = y_gaussian,
  loss = "L2_lin", 
  eps = "gaussian", 
  distribution = "gaussian",
  basis_fun = basis_trafo_linear,
  boosting_iters = c(1:2),
  learning_rate = 1)
