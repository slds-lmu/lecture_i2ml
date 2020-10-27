# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mvtnorm)
library(ggplot2)
library(tidyverse)
library(plotly)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# HELPER FUNCTIONS -------------------------------------------------------------

# Function to create path for vertical conditional densities in plot
# Offset determines shift from origin, stretch stretching for better visibility

create_conditional_paths = function(
  boundary = 10, 
  npoints = 1000, 
  offset = 0,
  stretch = 10,
  var_x,
  var_y,
  cor_xy
) 
  
  {
  # 
  # y = seq(
  #   -boundary - 1 / (cor_xy * sqrt(var_y / var_x)) * offset, 
  #   boundary - 1 / (cor_xy * sqrt(var_y / var_x)) * offset, 
  #   length.out = npoints
  #   )
  y = seq(-boundary, boundary, length.out = npoints)  #+ 
    #1 / (cor_xy * sqrt(var_y / var_x)) * (offset)
  
  x = stretch * dnorm(
    y,
    mean = 0,
    sd = sqrt((1 - cor_xy^2) * var_y) 
  ) + 1 / (cor_xy * sqrt(var_y / var_x)) * (offset)
  
  data.frame(y = y + offset, x, offset = offset)
  
}

# DATA -------------------------------------------------------------------------

# Create data as bivariate Gaussian

set.seed(1026)

mu_x = mu_y = 0
mu = c(mu_x, mu_y)
var_x = 4
var_y = 9
cor_xy = 2/3
cov_xy = cor_xy * sqrt(var_x) * sqrt(var_y)
Sigma = matrix(c(
  var_x,
  cov_xy,
  cov_xy,
  var_y), 
  ncol = 2)

dens = expand.grid(
  x = seq(-5, 5, length.out = 100),
  y = seq(-5, 5, length.out = 100)
  )

dens$z = dmvnorm(
  x = cbind(dens$x, dens$y), 
  mean = mu, 
  sigma = Sigma
  )

# Perform spatial transformation for surface plot

dens_3d = akima::interp(x = dens$x, y = dens$y, z = dens$z)

# Sample data from bivariate distribution

data_2d = rmvnorm(1000, mean = mu, sigma = Sigma) %>% 
  as.data.frame() %>% 
  rename(x = V1, y = V2)

# Compute path for conditional density y|x (amplified for plot)

# y_1 = seq(-8, 8, length.out = 1000)
# y_2 = y_1 - 2.5
# y_3 = y_1 + 2.5
# x_1 = dnorm(y_1, 0, sd = sqrt((1 - cor_xy^2) * var_y)) * 10
# x_2 = x_1 - 1 / (cor_xy * sqrt(var_y / var_x)) * 2.5
# x_3 = x_1 + 1 / (cor_xy * sqrt(var_y / var_x)) * 2.5
# 
# path_1 = data.frame(y_1, x_1)
# path_2 = data.frame(y_2, x_2)
# path_3 = data.frame(y_3, x_3)

conditional_paths = list (
  
  path_1 = create_conditional_paths(
    var_x = var_x, 
    var_y = var_y, 
    cor_xy = cor_xy),
  
  path_2 = create_conditional_paths(
    offset = -2.5,
    var_x = var_x, 
    var_y = var_y, 
    cor_xy = cor_xy),
  
  path_3 = create_conditional_paths(
    offset = 2.5,
    var_x = var_x, 
    var_y = var_y, 
    cor_xy = cor_xy)
  
)

# Compute path for marginal density of y
# 
# y_4 = seq(-10, 10, length.out = 1000)
# x_4 = dnorm(y_4, 0, sd = sqrt(var_y)) * 10

marginal_path = data.frame(
  y = seq(-10, 10, length.out = 1000), 
  x = dnorm(y_4, 0, sd = sqrt(var_y)) * 10
  )

# PLOT 1 -----------------------------------------------------------------------

scene = list(
  camera = list(eye = list(
    x = 0, 
    y = 1.4, 
    z = 2)
  )
)

my_palette = c("orange", "orangered")

p_1 = plot_ly(x = dens_3d$x, y = dens_3d$y, z = dens_3d$z) %>%
  add_surface(
    showscale = FALSE,
    colors = my_palette) %>% 
  layout(scene = scene)

orca(p_1, "../figure/sample-dgp-3d.png", width = 400, height = 300)

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/sample-dgp-2d.pdf", width = 5, height = 3.5)

# Scatterplot

p_2 = ggplot(data_2d, aes(x, y)) +
  geom_point(color = "orange") +
  theme_bw() + 
  theme(
    axis.text = element_text(size = 16),
    axis.title = element_text(size = 16)
    ) +
  xlim(c(-10, 10)) +
  ylim(c(-10, 10))

# Regression line

p_2 = p_2 + 
  geom_abline(
    slope = cor_xy * sqrt(var_y / var_x),
    intercept = 0
  )

# Rug plot

p_2 = p_2 + 
  geom_rug()

# Conditional densities

for (i in 1:length(conditional_paths)) {
  
  p_2 = p_2 +
    geom_path(
      conditional_paths[[i]],
      mapping = aes(x, y),
      color = "blue"
    ) +
    annotate(
      "segment",
      x = conditional_paths[[i]]$offset[1],
      xend = conditional_paths[[i]]$offset[1],
      y = -10,
      yend = 10,
      color = "grey")# +
    # annotate(
    #   "segment",
    #   x = conditional_paths[[i]]$offset[1],
    #   xend = conditional_paths[[i]]$offset[1] + max(conditional_paths[[i]]$x),
    #   y = cor_xy * sqrt(var_y / var_x) * conditional_paths[[i]]$offset[1],
    #   yend = cor_xy * sqrt(var_y / var_x) * conditional_paths[[i]]$offset[1],
    #   color = "grey"
    # )
  
}

# p_2 = p_2 +
#   geom_path(
#     path_1,
#     mapping = aes(x, y),
#     color = "blue"
#   )
# 
# p_2 = p_2 +
#   geom_path(
#     path_2,
#     mapping = aes(x, y),
#     color = "blue"
#   )
# 
# p_2 = p_2 +
#   geom_path(
#     path_3,
#     mapping = aes(x, y),
#     color = "blue"
#   )

# Marginal densities

my_dnorm = function(x, mean, sd, a, b) {
  
  a * dnorm(x, mean = mean, sd = sd) + b
  
}

p_2 = p_2 +
  geom_path(
    marginal_path,
    mapping = aes(x = x - 10, y = y)
  )

p_2 = p_2 + 
  stat_function(
    fun = my_dnorm,
    args = list(
      mean = 0, 
      sd = sqrt(var_x), 
      a = 10, 
      b = -10)
  )

p_2

ggsave("../figure/sample-dgp-2d.pdf", width = 5, height = 3.5)
dev.off()
