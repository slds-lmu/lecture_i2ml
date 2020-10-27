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
    # theme(
    #   plot.title = element_text(size = 24),
    #   axis.title = element_text(size = 18),
    #   axis.text = element_text(size = 14)
    # ) +
    ylim(c(-0.05, 0.35)) +
    labs(
      x = expression(paste(x[1])),
      y = expression(paste(f(x[1]))))
  
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
      # size = 6
    )
    
    # p = p + annotate(
    #   "text",
    #   x = center[[i]],
    #   y = -0.03,
    #   label = expr(paste(c[!!i], " = ", !!center[[i]])),
    #   # size = 6,
    #   angle = 45,
    #   color = "orange"
    # )
    
    p = p + geom_segment(
      x = center[[i]],
      xend = center[[i]],
      y = 0,
      yend = coeff[[i]] * dnorm(0, 0, beta),
      # size = 1.2,
      color = "blue"
    )
    
    # p = p + annotate(
    #   "text",
    #   x = center[[i]] - 0.5,
    #   y = 0.5 * coeff[[i]] * dnorm(0, 0, bandwidth),
    #   label = expr(paste(a[!!i], " = ", !!coeff[[i]])),
    #   # size = 6,
    #   color = "blue",
    #   angle = 90
    # )
    
    p = p + stat_function(
      fun = get_weighted_sum, 
      args = list(coeff, center, dimension = 2))
      # size = 1.2)
    
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
 
  # center_coords$z = get_weighted_sum(
  #   center_coords, 
  #   coeff = coeff, 
  #   center = center,
  #   beta = beta,
  #   dimension = 3)
  
  foo = dens %>% 
    inner_join(center_coords)
  
  # Plot
  
  my_palette = c("cornflowerblue", "blue4")
  
  p = plot_ly(x = d$x, y = d$y, z = d$z) %>%
    add_surface(
      showscale = FALSE,
      colors = my_palette
    ) %>% 
    add_trace(
      x = foo$x_1, 
      y = foo$x_2,
      z = foo$z, 
      type = "scatter3d",
      showlegend = FALSE,
      colors = "orange"
    )

  # p = plot_ly(x = d$x, y = d$y, z = d$z) %>%
  #   add_surface() %>% 
  #   add_trace(data = center_coords,
  #     x = c(2), 
  #     y = c(2), 
  #     z = c(0.05), 
  #     name = "z", 
  #     type = "scatter3d",
  #     color = "red"
  #   )

  p
  
}

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/ml-basics-hs-rbf-network.pdf", width = 8, height = 3.5)

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
    # size = 2, 
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
    # size = 2, 
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
    # size = 2, 
    alpha = 0.6, 
    arrow = arrow(length = unit(2, "mm"))
  ) +
  ggtitle("Weights altered")

grid.arrange(p_1, p_2, p_3, ncol = 3)

ggsave("../figure/ml-basics-hs-rbf-network.pdf", width = 8, height = 3.5)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/ml-basics-hs-rbf-network_2.pdf", width = 8, height = 4)

p_4 = plot_3d(
  coeff = list(1, 0.5, 0.7), 
  center = list(c(-2, -2), c(2, 3), c(-1, -2))
)
orca(p4, "../figure/ml-basics-hs-rbf-network.pdf")

p_5 = plot_basis_fun_3d(
  coeff = list(0.2, 0.6, 0.4), 
  center = list(
    
    c(-3, 3), 
    c(1, 1), 
    c(4, -3))
)

p_6 = plot_basis_fun_3d(
  coeff = list(0.1, 0.3, 0.6), 
  center = list(
    c(-3, -1), 
    c(1, 1), 
    c(3, -1))
)

grid.arrange(p_4, p_5, p_6, ncol = 3)

ggsave("../figure/ml-basics-hs-rbf-network_2.pdf", width = 8, height = 4)
dev.off()