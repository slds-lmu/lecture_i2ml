# ------------------------------------------------------------------------------
# FIG: 2D NORMAL
# ------------------------------------------------------------------------------

library(ggplot2)
library(viridis)
library(tidyverse)
library(mvtnorm)
library(gridExtra)
library(grid)
source("helpers/data_generators.R")
source("helpers/constants.R")
source("helpers/utilities.R")

# DATA -------------------------------------------------------------------------
r_from <- 0.9
r_to <- 1.1

x <- seq(from = 0, to = 4, length.out = 1000)

X <- expand.grid(seq(-2, 2, length.out = 100), seq(-2, 2, length.out = 100))
normal_2d <- dnorm(X[,1])*dnorm(X[,2])

xc <- r_to * cos(seq(0,pi,length.out=50))
yc <- r_to * sin(seq(0,pi,length.out=50))
xc <- c(xc, r_from * cos(seq(pi,0,length.out=50)))
yc <- c(yc, r_from * sin(seq(pi,0,length.out=50)))
xc <- c(xc, r_to * cos(seq(0,-pi,length.out=50)))
yc <- c(yc, r_to * sin(seq(0,-pi,length.out=50)))
xc <- c(xc, r_from * cos(seq(-pi,0,length.out=50)))
yc <- c(yc, r_from * sin(seq(-pi,0,length.out=50)))

# PLOTS ------------------------------------------------------------------------
p_plot  <- ggplot(data.frame(x = x), aes(x)) +
  stat_function(fun = p_r) +
  stat_function(fun = p_r,
                xlim = c(r_from, r_to),
                geom = "area", colour="red" , fill="transparent") +
  ylab("p(r)") + xlab("r") +
  theme_minimal()

d_plot <- ggplot() +
  geom_raster(data = data.frame(x1 = X[,1], x2 = X[,2], z = normal_2d), aes(x1, x2, fill=z)) +
  geom_contour(data = data.frame(x1 = X[,1], x2 = X[,2], z = normal_2d), aes(x1, x2, z = z), colour = "white") +
  geom_polygon(data = data.frame(x=xc, y=yc), fill="red", alpha = 0.7,
               aes(x,y)) +
  labs(fill = "density") +
  theme_minimal() +
  scale_fill_viridis(end = 0.9)

p <- grid.arrange(p_plot, d_plot, ncol=2,
             bottom = textGrob("Example: 2D normal distribution"))

ggsave(filename = "../figure/2d_normal_plot.png", plot = p, width = 7, height = 2)