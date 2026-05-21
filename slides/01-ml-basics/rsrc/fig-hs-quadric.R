# PREREQ -----------------------------------------------------------------------

library(knitr)
library(tidyverse)
library(ggplot2)
library(plotly)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# HELPER FUNCTIONS  ------------------------------------------------------------

make_quadratic_form = function(x, theta_0, P, Q) {
  
  theta_0 + tcrossprod(P, x) + x %*% Q %*% x
  
}

plot_quadric = function(boundary = 10, npoints = 100, theta_0, P, Q) {
  
  # Surface
  
  seq_x = seq(
    -boundary, 
    boundary, 
    length.out = npoints
    )
  dens = expand.grid(x_1 = seq_x, x_2 = seq_x)
  
  dens$z = apply(
    dens, 
    1, 
    make_quadratic_form, 
    theta_0 = theta_0,
    P = P, 
    Q = Q
    )
  
  d = akima::interp(x = dens$x_2, y = dens$x_1, z = dens$z)
  
  # Plot
  
  scene = list(
    camera = list(eye = list(
      x = 0, 
      y = 2.2, 
      z = 1)
    ),
    xaxis = list(title = "x1"),
    yaxis = list(title = "x2"),
    zaxis = list(title = "f(x1,x2)")
  )
  
  my_palette = c("cornflowerblue", "blue4")
  
  plot_ly(x = d$x, y = d$y, z = d$z) %>%
    add_surface(
      showscale = FALSE,
      colors = my_palette
    ) %>% 
    layout(scene = scene)
  
}

# PLOT 1 -----------------------------------------------------------------------

p_1 = plot_quadric(
  theta_0 = 3,
  P = t(matrix(c(2, 4))),
  Q = matrix(rep(0, 4), ncol = 2)
  )
p_1
orca(p_1, "../figure/hs-quadric-1.pdf")

p_2 = plot_quadric(
  theta_0 = 3,
  P = t(matrix(c(2, 4))),
  Q = matrix(c(1, 0, 0, 1), ncol = 2)
)
p_2
orca(p_2, "../figure/hs-quadric-2.pdf")

p_3 = plot_quadric(
  theta_0 = 3,
  P = t(matrix(c(2, 4))),
  Q = matrix(c(1, 2, 2, 1), ncol = 2)
)
p_3
orca(p_3, "../figure/hs-quadric-3.pdf")
