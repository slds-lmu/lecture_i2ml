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

# Function for scatterplot with rugs, marginal & conditional densities

create_fancy_scatterplot = function(
  data,
  boundary = 10, 
  npoints = 1000, 
  stretch = 10,
  var_x,
  var_y,
  cor_xy
)
  
{
  
  # HELPER FUNCTIONS -----------------------------------------------------------
  
  # Function to create path for vertical conditional densities in plot
  
  create_conditional_paths = function(offset = 0)  {
    
    y = seq(-boundary, boundary, length.out = npoints)
    
    x = stretch * dnorm(
      y,
      mean = 0,
      sd = sqrt((1 - cor_xy^2) * var_y) 
    ) + 1 / (cor_xy * sqrt(var_y / var_x)) * (offset)
    
    data.frame(y = y + offset, x, offset = offset)
    
  }
  
  # Function to obtain marginal density for stat_function
  
  my_dnorm = function(x, mean, sd, a, b) {
    
    a * dnorm(x, mean = mean, sd = sd) + b
    
  }
  
  # PATHS FOR CONDITIONAL / MARGINAL DENSITIES ---------------------------------
  
  # Compute path for conditional density y|x (amplified for plot)
  
  conditional_paths = list (
    path_1 = create_conditional_paths(),
    path_2 = create_conditional_paths(offset = -2.5),
    path_3 = create_conditional_paths(offset = 2.5)
  )
  
  # Compute path for marginal density of y
  
  marginal_path = data.frame(
    y = seq(-boundary, boundary, length.out = npoints), 
    x = dnorm(
      seq(-boundary, boundary, length.out = npoints), 
      mean = 0, 
      sd = sqrt(var_y)
      ) * stretch
  )
  
  # PLOT -----------------------------------------------------------------------
  
  # Scatterplot
  
  p = ggplot(data, aes(x, y)) +
    geom_point(color = "orange") +
    theme_bw() + 
    theme(
      axis.text = element_text(size = 16),
      axis.title = element_text(size = 16)
    ) +
    xlim(c(-boundary, boundary)) +
    ylim(c(-boundary, boundary))
  
  # Regression line
  
  p = p + 
    geom_abline(
      slope = cor_xy * sqrt(var_y / var_x),
      intercept = 0
    )
  
  # Rug plot
  
  p = p + 
    geom_rug()
  
  # Conditional densities
  
  for (i in 1:length(conditional_paths)) {
    
    p = p +
      geom_path(
        conditional_paths[[i]],
        mapping = aes(x, y),
        color = "blue"
      ) +
      annotate(
        "segment",
        x = conditional_paths[[i]]$offset[1],
        xend = conditional_paths[[i]]$offset[1],
        y = -boundary,
        yend = boundary,
        color = "grey")
  }
  
  p = p +
    geom_path(
      marginal_path,
      mapping = aes(x = x - boundary, y = y)
    )
  
  p = p + 
    stat_function(
      fun = my_dnorm,
      args = list(
        mean = 0, 
        sd = sqrt(var_x), 
        a = stretch, 
        b = -boundary)
    )
  
  p
  
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

create_fancy_scatterplot(
  data = data_2d,
  var_x = var_x,
  var_y = var_y,
  cor_xy = cor_xy
)

ggsave("../figure/sample-dgp-2d.pdf", width = 5, height = 3.5)
dev.off()
