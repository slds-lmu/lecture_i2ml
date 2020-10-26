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

# DATA -------------------------------------------------------------------------

set.seed(2310)

x_1 = rnorm(1000, 0, 1)

# HELPERS ----------------------------------------------------------------------

plot_basis_fun_2d = function(coeff, center, bandwidth = 1) {
  
  get_basis_fun = function(x, coeff, center, bandwidth = 1) {
    
    coeff * dnorm(x, center, 1 / bandwidth)
    
  }
  
  get_weighted_sum = function(x, coeff, center, bandwidth = 1) {
    
    apply(
      sapply(
        c(1:length(coeff)), 
        function(i) get_basis_fun(x, coeff[[i]], center[[i]])), 
      1, 
      sum)
    
    }
  
  p = ggplot(data.frame(x_1 = c(-5, 5)), aes(x_1)) +
    theme_bw() + 
    theme(
      plot.title = element_text(size = 24),
      axis.title = element_text(size = 18),
      axis.text = element_text(size = 14)
    ) +
    ylim(c(-0.05, 0.32)) +
    labs(
      x = expression(paste(x[1])),
      y = expression(paste(f(x[1]))))
  
  for (i in 1:length(coeff)) {
    
    p = p + stat_function(
      fun = get_basis_fun, 
      args = list(coeff[[i]], center[[i]]),
      linetype = "dashed")
    
    p = p + annotate(
      "point",
      x = center[[i]],
      y = 0,
      color = "orange",
      size = 6
    )
    
    p = p + annotate(
      "text",
      x = center[[i]],
      y = -0.02,
      label = expr(paste(c[!!i], " = ", !!center[[i]])),
      size = 6,
      angle = 45,
      color = "orange"
    )
    
    p = p + geom_segment(
      x = center[[i]],
      xend = center[[i]],
      y = 0,
      yend = coeff[[i]] * dnorm(0, 0, bandwidth),
      size = 1.2,
      color = "blue"
    )
    
    p = p + annotate(
      "text",
      x = center[[i]],
      y = 0.5 * coeff[[i]] * dnorm(0, 0, bandwidth),
      label = expr(paste(a[!!i], " = ", !!coeff[[i]])),
      size = 6,
      color = "blue"
      
    )
    
    p = p + stat_function(
      fun = get_weighted_sum, 
      args = list(coeff, center),
      size = 1.2)
    
  }

  p
  
}

# ------------------------------------------------------------------------------

plot_basis_fun_3d = function(coeff, center) {
  
  get_basis_fun = function(x, coeff, center) {
    
    grid_dens = expand.grid(x_1 = x, x_2 = x)
    
    grid_dens$z = coeff * dmvnorm(
      grid_dens, 
      mean = center, 
      sigma = matrix(c(1, 0, 0, 1), nrow = 2))

    grid_dens$z

  }
  
  seq_x = seq(-5, 5, length.out = 100)
  
  dens = expand.grid(x_1 = seq_x, x_2 = seq_x)
  
  dens$z = apply(
    sapply(
      c(1:length(coeff)), 
      function(i) get_basis_fun(seq_x, coeff[[i]], center[[i]])), 
    1, 
    sum)
  
  d = akima::interp(x = dens$x_1, y = dens$x_2, z = dens$z)

  p = plot_ly(x = d$x, y = d$y, z = d$z) %>%
    add_surface()
  
  # p = ggplot(dens, aes(x = x_1, y = x_2, z = z)) +
  #   xlim(c(-5, 5)) +
  #   ylim(c(-5, 5))
  # p = p + geom_contour_filled()
  # p = p + scale_fill_grey(start = 0.9, end = 0.1)
  # p = p + guides(fill = FALSE)
  
 p
  
}

a = plot_basis_fun_3d(list(0.2, 0.6, 0.4), list(c(-3, -1), c(1, 1), c(3, -1)))
orca(a, "test.png")


# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/ml-basics-hs-rbf-network.pdf", width = 8, height = 4)

p_1 = plot_basis_fun_2d(
  coeff = list(0.4, 0.2, 0.4), 
  center = list(-3, -2, 1)
  ) +
  ggtitle("Exemplary parameter setting")

p_2 = plot_basis_fun_2d(
  coeff = list(0.4, 0.2, 0.4), 
  center = list(-3, -2, 4)
  ) +
  annotate(
    "segment", 
    x = 2, 
    xend = 3.9, 
    y = -0.01, 
    yend = -0.01, 
    colour = "orange", 
    size = 2, 
    alpha = 0.6, 
    arrow = arrow()
  ) +
  ggtitle("Centers altered")

p_3 = plot_basis_fun_2d(
  coeff = list(0.6, 0.2, 0.2), 
  center = list(-3, -2, 1)
  ) +
  annotate(
    "segment", 
    x = -3, 
    xend = -3, 
    y = 0.25, 
    yend = 0.27, 
    colour = "blue", 
    size = 2, 
    alpha = 0.6, 
    arrow = arrow()
  )  +
  annotate(
    "segment", 
    x = 1, 
    xend = 1, 
    y = 0.11, 
    yend = 0.09, 
    colour = "blue", 
    size = 2, 
    alpha = 0.6, 
    arrow = arrow()
  ) +
  ggtitle("Weights altered")

grid.arrange(p_1, p_2, p_3, ncol = 3)

ggsave("../figure/ml-basics-hs-rbf-network.pdf", width = 8, height = 4)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/ml-basics-hs-rbf-network_2.pdf", width = 8, height = 4)

p_4 = plot_basis_fun_3d(
  coeff = list(0.2, 0.6, 0.4), 
  center = list(
    c(-3, -1), 
    c(1, 1), 
    c(3, -1))
  )

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