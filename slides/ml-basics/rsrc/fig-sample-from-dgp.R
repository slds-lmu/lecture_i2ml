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
cor_xy = 0.9
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
y = seq(-8, 8, length.out = 1000) + theta_0
x = dnorm(y, 0, sd = sqrt((1 - cor_xy^2) * var_y)) * 3
path = data.frame(y, x)

# PLOT 1 -----------------------------------------------------------------------

scene = list(
  camera = list(eye = list(
    x = 0, 
    y = 1, 
    z = 2)
  )
)

my_palette = c("orange", "orangered")

p_1 = plot_ly(x = dens_3d$x, y = dens_3d$y, z = dens_3d$z) %>%
  add_surface(
    showscale = FALSE,
    colors = my_palette) %>% 
  layout(scene = scene)

orca(p_1, "../figure/sample-dgp-3d.png")

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/sample-dgp-2d.pdf", width = 5, height = 3)

p_2 = ggplot(data_2d, aes(x = x, y = y)) +
  geom_point(color = "orange") +
  theme_bw()
p_2 = p_2 + 
  geom_abline(
    slope = 1,
    intercept = 0
  )
p_2 = p_2 + 
  geom_rug()
p_2 = p_2 +
  geom_density(
    data_2d, 
    mapping = aes(x = x, y = stat(scaled) - 8)
    )
p_2 = p_2 +
  geom_density(
    data_2d, 
    mapping = aes(x = stat(scaled) - 8, y = y)
  )
p_2 = p_2 +
  geom_path(
    path,
    mapping = aes(x = x, y = y),
    color = "blue"
  )
p_2

ggsave("../figure/sample-dgp-2d.pdf", width = 5, height = 3)
dev.off()
