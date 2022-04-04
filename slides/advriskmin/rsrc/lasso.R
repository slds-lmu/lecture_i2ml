# ------------------------------------------------------------------------------
# FIG: LASSO LOSS FUNCTION
# ------------------------------------------------------------------------------

library(ggplot2)
library(data.table)
library(plotly)
library(tidyverse)

# DATA -------------------------------------------------------------------------

set.seed(123L)
x_1 <- runif(10L, -3L, 3L)
x_2 <- runif(10L, -5L, 10L)
x <- cbind(x_1, x_2)
y <- x %*% c(1, 1.2) + rnorm(10L)
theta_1 <- seq(-2L, 3L, length.out = 50L)
theta_2 <- seq(-2, 3L, length.out = 50L)
theta <- as.matrix(expand.grid(theta_1 = theta_1, theta_2 = theta_2))
models <- apply(theta, 1L, function(i) x %*% i)
losses <- apply(models, 2L, function(i) (y - i)^2)
dt <- data.table::data.table(theta, losses = apply(losses, 2L, sum))
dt[, penalty := 500 * abs(theta_1) + 500 * abs(theta_2)]
dt[, losses_p := losses + penalty]

d_q <- akima::interp(x = dt$theta_1, y = dt$theta_2, z = dt$losses)
d_l <- akima::interp(x = dt$theta_1, y = dt$theta_2, z = dt$penalty)
d_p <- akima::interp(x = dt$theta_1, y = dt$theta_2, z = dt$losses_p)

# FUNCTIONS --------------------------------------------------------------------

plot_3d <- function(d, eye = list(x =0, y = 1.8L, z = 0.2)) {
  
  scene = list(
    camera = list(eye = eye),
    xaxis = list(title = "theta1"),
    yaxis = list(title = "theta2"),
    zaxis = list(title = "", tickvals = list()))
  
  plotly::plot_ly(x = d$x, y = d$y, z = d$z) %>%
    add_surface(
      showscale = FALSE,
      color = ~ d$z) %>%
    layout(scene = scene)
  
}

plot_3d(d_q)
plot_3d(d_l)
plot_3d(d_p)
