# PREREQ -----------------------------------------------------------------------

library(knitr)
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(mvtnorm)

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
      sapply(c(1:3), function(i) get_basis_fun(x, coeff[[i]], center[[i]])), 
      1, 
      sum)
    
    }
  
  p = ggplot(data.frame(x_1 = c(-5, 5)), aes(x_1)) +
    theme_bw() + 
    ylim(c(-0.05, 0.3)) +
    labs(
      x = expression(paste(x[1])),
      y = expression(paste(f(x[1]))))
  
  for (i in 1:length(coeff)) {
    
    p = p + stat_function(
      fun = get_basis_fun, 
      args = list(coeff[[i]], center[[i]]),
      linetype = "dashed")
    
    p = p + geom_segment(
      x = center[[i]],
      xend = center[[i]],
      y = 0,
      yend = coeff[[i]] * dnorm(0, 0, bandwidth),
      size = 1.4,
      color = "orange"
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
    
    p = p + annotate(
      "text",
      x = center[[i]],
      y = coeff[[i]] * dnorm(0, 0, bandwidth) + 0.01,
      label = expr(paste(a[!!i], " = ", !!coeff[[i]])),
      size = 6,
      color = "blue"
      
    )
    
    p = p + stat_function(
      fun = get_weighted_sum, 
      args = list(coeff, center))
    
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

    grid_dens

  }
  
  seq_x = seq(-5, 5, length.out = 100)
  
  df = data.frame(
    x_1 = seq_x,
    x_2 = seq_x
  )
  
  p = ggplot(df, aes(x = x_1, y = x_2))
  
  p = p + geom_contour(a, mapping = aes(x = x_1, y = x_2, z = z))
  
  for (i in 1:length(coeff)) {
    
    dens_i = get_basis_fun(
      x = seq_x, coeff = coeff[[i]], center = center[[i]])
    
    p = p + geom_contour(
      dens_i,
      mapping = aes(x = x_1, y = x_2, z = z)
    )
    
  }
  
 p
  
}

plot_basis_fun_3d(list(0.2, 0.4), list(c(1, 1), c(2, 2)))

# PLOT -------------------------------------------------------------------------

pdf("../figure/ml-basics-hs-rbf-network.pdf", width = 8, height = 4)

p_1 = plot_basis_fun_2d(list(0.2, 0.5, 0.3), list(-3, 0, 2))
p_2 = plot_basis_fun_2d(list(0.2, 0.5, 0.3), list(-2, 1, 2))
p_3 = plot_basis_fun_2d(list(0.6, 0.2, 0.2), list(-3, 0, 2))
grid.arrange(p_1, p_2, p_3, ncol = 3)

ggsave("../figure/ml-basics-hs-rbf-network.pdf", width = 8, height = 4)
dev.off()


x = dmvnorm(seq(-2, 2, length.out = 1000), c(0, 0), matrix(1, 0, 0, 1))

dmvnorm(x=c(0,0))
dmvnorm(x=c(0,0), mean=c(1,1))
x <- rmvnorm(n=100, mean=c(1,1))
plot(x)


