# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mvtnorm)
library(ggplot2)
library(tidyverse)
library(plotly)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

# Create data as bivariate Gaussian

set.seed(1026)

mu_x = mu_y = 0
mu = c(mu_x, mu_y)
var_x = var_y = 4
cor_xy = 0.7
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

data_2d = rmvnorm(300, mean = mu, sigma = Sigma) %>% 
  as.data.frame() %>% 
  rename(x = V1, y = V2)

# Compute path for conditional density y|x (amplified for plot)

reg = lm(y ~ x, data = data_2d)
theta_0 = coef(reg)[1]
y_1 = seq(-8, 8, length.out = 1000) + theta_0
y_2 = y_1 - 2
y_3 = y_1 + 2
x_1 = dnorm(y_4, 0, sd = sqrt((1 - cor_xy^2) * var_y)) * 3
x_2 = x_1 - 1 / cor_xy * 3
x_3 = x_1 + 1 / cor_xy * 3

path_1 = data.frame(y_1, x_1)
path_2 = data.frame(y_2, x_2)
path_3 = data.frame(y_3, x_3)

# Compute path for marginal density of y

y_4 = y_1
x_4 = dnorm(y_4, 0, sd = sqrt(var_y)) * 5

path_4 = data.frame(y_4, x_4)

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

p_2 = ggplot(data_2d, aes(x = x, y = y)) +
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
    slope = cor_xy,
    intercept = 0
  )

# Rug plot

p_2 = p_2 + 
  geom_rug()

# Conditional densities

p_2 = p_2 +
  geom_path(
    path_1,
    mapping = aes(x = x_1, y = y_1),
    color = "blue"
  )

p_2 = p_2 +
  geom_path(
    path_2,
    mapping = aes(x = x_2, y = y_2),
    color = "blue"
  )

p_2 = p_2 +
  geom_path(
    path_3,
    mapping = aes(x = x_3, y = y_3),
    color = "blue"
  )

# Marginal densities

my_dnorm = function(x, mean, sd, a, b) {
  
  a * dnorm(x, mean = mean, sd = sd) + b
  
}

p_2 = p_2 +
  geom_path(
    path_4,
    mapping = aes(x = x_4 - 10, y = y_4)
  )

p_2 = p_2 + 
  stat_function(
    fun = my_dnorm,
    args = list(
      mean = 0, 
      sd = sqrt(var_x), 
      a = 5, 
      b = -10)
  )

p_2

ggsave("../figure/sample-dgp-2d.pdf", width = 5, height = 3.5)
dev.off()
