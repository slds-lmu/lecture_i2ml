# ------------------------------------------------------------------------------
# FIG: CURSED DIM FRACTION EDGE
# ------------------------------------------------------------------------------

library(ggplot2)
library(viridis)
library(tidyverse)
source("helpers/data_generators.R")
source("helpers/constants.R")

# DATA -------------------------------------------------------------------------

df <- expand.grid(p = c(1, 2, 5, 20), eps = seq(0,1,by=.01))
df$vol <- with(df, 1-(1-eps)^p)

# PLOTS ------------------------------------------------------------------------
p <- ggplot(df, aes(x = eps, y = vol, colour = ordered(p), group = ordered(p))) +
  geom_line(show.legend = FALSE) +
  theme_minimal() +
  scale_x_continuous(breaks = seq(0, 1,l = 6)) + labs(x  = expression("Edge length"~epsilon), y = "Covered volume") +
  annotate("text", x = c(.5, .35, .21, .11), color = pal_4, y = c(.42, .5, .6, .75), label = paste0("p=",c(1, 2, 5, 20))) +
  geom_vline(xintercept = 0.2, lty = 2) +
  scvd

ggsave(filename = "../figure/cursed_dim_fraction_edge_plot.png", plot = p, width = 6, height = 3)