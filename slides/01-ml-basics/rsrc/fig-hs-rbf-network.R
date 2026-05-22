# PREREQ -----------------------------------------------------------------------

library(knitr)
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(mvtnorm)
library(plotly)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# HELPER FUNCTIONS  ------------------------------------------------------------

get_basis_fun = function(x, coeff, center, beta = 1, dimension) {
  
  if (dimension == 2) {
    
    return(coeff * dnorm(x, center, 1 / beta))
    
  } else if (dimension == 3) {
    
    # grid_dens = expand.grid(x_1 = x, x_2 = x)
    
    return(coeff * dmvnorm(
      x, 
      mean = center, 
      sigma = matrix(c(beta, 0, 0, beta), nrow = 2)
      )
    )
    
  } else {return(NA)}
  
}

# ------------------------------------------------------------------------------

get_weighted_sum = function(x, coeff, center, beta, dimension) {
  
  apply(
    sapply(
      c(seq_along(coeff)), 
      function(i) get_basis_fun(x, 
                                coeff[[i]], 
                                center[[i]], 
                                dimension = dimension)
      ), 
    1, 
    sum)
  
}

# ------------------------------------------------------------------------------

plot_2d = function(coeff, center, beta = 1) {
  
  p = ggplot(data.frame(x_1 = c(-5, 5)), aes(x_1)) +
    theme_bw() + 
    ylim(c(-0.05, 0.35)) +
    labs(
      x = expression(paste(x)),
      y = expression(paste(f(x))))
  
  for (i in seq_along(coeff)) {
    
    p = p + stat_function(
      fun = get_basis_fun, 
      args = list(coeff[[i]], center[[i]], dimension = 2),
      linetype = "dashed")
    
    p = p + annotate(
      "point",
      x = center[[i]],
      y = 0,
      color = "orange"
    )
    
    p = p + geom_segment(
      x = center[[i]],
      xend = center[[i]],
      y = 0,
      yend = coeff[[i]] * dnorm(0, 0, beta),
      color = "blue"
    )

    p = p + stat_function(
      fun = get_weighted_sum, 
      args = list(coeff, center, dimension = 2)
      )
    
  }

  p
  
}

# ------------------------------------------------------------------------------

plot_3d = function(coeff, center, sd = 1, beta = 1) {
  
  # Center points
  
  center_coords = data.frame(
    t(
      matrix(
        unlist(center), 
        nrow = 2)
    )
  ) %>% 
    rename(x_1 = X1, x_2 = X2)
  
  # Surface
  
  seq_x = seq(-5, 5, length.out = 100)
  dens = rbind(
    expand.grid(x_1 = seq_x, x_2 = seq_x),
    center_coords
    )
  
  dens$z = get_weighted_sum(
    dens, 
    coeff = coeff, 
    center = center,
    beta = beta,
    dimension = 3)
  
  d = akima::interp(x = dens$x_2, y = dens$x_1, z = dens$z)
  
  center_points = dens %>% 
    inner_join(center_coords)
  
  # Plot
  
  scene = list(
    camera = list(eye = list(
      x = 1.5, 
      y = 1.5, 
      z = 1.25)
    ),
    xaxis = list(title = "x1"),
    yaxis = list(title = "x2"),
    zaxis = list(title = "f(x1,x2)")
  )
  
  my_palette = c("cornflowerblue", "blue4")

  p = plot_ly(x = d$x, y = d$y, z = d$z) %>%
    add_surface(
      showscale = FALSE,
      colors = my_palette
    ) %>% 
    add_trace(
      x = center_points$x_1, 
      y = center_points$x_2,
      z = center_points$z, 
      type = "scatter3d",
      showlegend = FALSE,
      colors = "orange"
    ) %>% 
    layout(scene = scene)

  p
  
}

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/hs-rbf-network-2d.pdf", width = 8, height = 2.2)

p_1 = plot_2d(
  coeff = list(0.4, 0.2, 0.4), 
  center = list(-3, -2, 1)
  ) +
  ggtitle("Exemplary setting")

p_2 = plot_2d(
  coeff = list(0.4, 0.2, 0.4), 
  center = list(-3, -2, 4)
  ) +
  annotate(
    "segment", 
    x = 2, 
    xend = 3.9, 
    y = -0.02, 
    yend = -0.02, 
    colour = "orange", 
    alpha = 0.6, 
    arrow = arrow(length = unit(2, "mm"))
  ) +
  ggtitle("Centers altered")

p_3 = plot_2d(
  coeff = list(0.6, 0.2, 0.2), 
  center = list(-3, -2, 1)
  ) +
  annotate(
    "segment", 
    x = -3, 
    xend = -3, 
    y = 0.3, 
    yend = 0.35, 
    colour = "blue", 
    alpha = 0.6, 
    arrow = arrow(length = unit(2, "mm"))
  )  +
  annotate(
    "segment", 
    x = 1, 
    xend = 1, 
    y = 0.14, 
    yend = 0.09, 
    colour = "blue", 
    alpha = 0.6, 
    arrow = arrow(length = unit(2, "mm"))
  ) +
  ggtitle("Weights altered")

grid.arrange(p_1, p_2, p_3, ncol = 3)

ggsave("../figure/hs-rbf-network-2d.pdf", width = 8, height = 2.2)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

p_4 = plot_3d(
  coeff = list(
    0.4, 
    0.2, 
    0.4), 
  center = list(
    c(2, -2), 
    c(0, 0), 
    c(-3, 2)
    )
)
orca(
  p_4, 
  "../figure/hs-rbf-network-3d-1.pdf",
  height = 400,
  width = 450
  )

p_5 = plot_3d(
  coeff = list(
    0.4, 
    0.2, 
    0.4), 
  center = list(
    c(2, -2), 
    c(3, 3), 
    c(-3, 2)
    )
)
orca(
  p_5, 
  "../figure/hs-rbf-network-3d-2.pdf",
  height = 400,
  width = 450
  )

p_6 = plot_3d(
  coeff = list(
    0.2, 
    0.45, 
    0.35), 
  center = list(
    c(2, -2), 
    c(0, 0), 
    c(-3, 2)
    )
)
orca(
  p_6, 
  "../figure/hs-rbf-network-3d-3.pdf",
  height = 400, 
  width = 450
  )
