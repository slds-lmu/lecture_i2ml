# ------------------------------------------------------------------------------
# FIG: HIGH DIM CUBE
# ------------------------------------------------------------------------------

library(ggplot2)
library(viridis)
library(tidyverse)
source("helpers/data_generators.R")
source("helpers/constants.R")

# DATA -------------------------------------------------------------------------

df <- expand.grid(p = c(1, 3, 5, 7, 10), x = seq(0, 1, by = .001))
df$edgelen <- with(df, (x)^(1/p))

# PLOTS ------------------------------------------------------------------------
p <- ggplot(df, aes(x = x, y = edgelen, colour = ordered(p), group = ordered(p))) +
  geom_line(show.legend = FALSE) +
  geom_vline(xintercept = .1) +
  theme_minimal() +
  labs(x  = expression("Fraction of Volume"), y = "Edge length of cube") +
  annotate("text", x = rep(.25, 5), color = pal_5, y = c(.3, .67, .79, .85, .91), label = paste0("p=",c(1, 3, 5, 7, 10))) +
  geom_text(aes(x = .13, y = 0, label = "10%"), colour = "black", size = 4) +
  scvd

ggsave(filename = "../figure/high_dim_cube_plot.png", plot = p, width = 9, height = 3)