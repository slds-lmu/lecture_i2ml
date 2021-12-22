# ------------------------------------------------------------------------------
# FIG: LM NOISE
# ------------------------------------------------------------------------------

library(ggplot2)
source("helpers/data_generators.R")
source("helpers/constants.R")
source("helpers/utilities.R")

# DATA -------------------------------------------------------------------------
noise_prop <- readRDS("datasets/cod_lm_noise.rds")

# PLOTS ------------------------------------------------------------------------
p <- ggplot(noise_prop, aes(x=X2, y=value)) +
  geom_boxplot() +
  ylab(expression(kappa)) +
  xlab("Number of noise features added")

ggsave("../figure/lm_noise_plot.png", plot = p, width = 7.5, height= 4)