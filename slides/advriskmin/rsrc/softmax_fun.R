# ------------------------------------------------------------------------------
# FIG: SOFTMAX SLOPE
# ------------------------------------------------------------------------------

library(plotly)

# define x and different theta configurations

seq_x <- seq(-10L, 10L, length.out = 100L)
theta <- list(
  theta_1 = c(0.3, 0.3),
  theta_2 = c(0.8, 0.8))

plot_3d <- function(x, theta, eye = list(x = -1.5, y = 3L, z = 1L)) {
  
  # specify softmax operation
  
  compute_softmax <- function(X, theta) 1 / (1 + exp(-(X %*% theta)))
  
  # use akima interpolation to create surface from 3d points
  
  dens <- expand.grid(x_1 = x, x_2 = x)
  dens$z <- apply(as.matrix(dens), 1L, compute_softmax, theta = theta)
  d <- akima::interp(x = dens$x_2, y = dens$x_1, z = dens$z)
  
  # define perspective plot is viewed from
  
  scene = list(
    camera = list(eye = eye),
    xaxis = list(title = "x1"),
    yaxis = list(title = "x2"),
    zaxis = list(title = "s(f(x1,x2))"))
  
  # define color
  
  my_palette = c("cornflowerblue", "blue4")
  
  # plot
  
  plotly::plot_ly(x = d$x, y = d$y, z = d$z) %>%
    add_surface(
      showscale = FALSE,
      colors = my_palette
    ) %>%
    layout(scene = scene)
  
}

# saving plotly objects requires orca installation, which might not work on 
# every device
# here: open the respective plot in your browser (clicking on "show in new 
# window" in the viewer pane) and save snapshot via the camera symbol without 
# zooming

plot_3d(seq_x, theta$theta_1)
plot_3d(seq_x, theta$theta_2)
