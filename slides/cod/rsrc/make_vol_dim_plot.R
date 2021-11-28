# ------------------------------------------------------------------------------
# FIG: VOL DIM
# ------------------------------------------------------------------------------

library(ggplot2)
library(viridis)
library(tidyverse)
source("helpers/data_generators.R")
source("helpers/constants.R")

# DATA -------------------------------------------------------------------------

df <- data.frame(p = seq(2,20))
df$vol <- with(df, pi^(p/2)/(2^p*gamma(p/2+1)))

# PLOTS ------------------------------------------------------------------------
p <- ggplot(df, aes(x=p, y=vol)) +
  geom_point() +
  geom_line() +
  xlab("Dimension p") +
  ylab(expression('Volume fraction' ~ 'S'[p](r)/'C'[p](r))) +
  theme_minimal()

ggsave(filename = "../figure/vol_dim_plot.png", plot = p, width = 6, height = 3)