# ------------------------------------------------------------------------------
# FIG: CAPITAL LETTERS
# ------------------------------------------------------------------------------

library(ggplot2)
library(mlr3)
library(viridis)
library(tidyverse)
source("helpers/data_generators.R")
source("helpers/constants.R")

# DATA -------------------------------------------------------------------------

df <- make_spam_df()

# PLOTS ------------------------------------------------------------------------

p <- ggplot(data = df, aes(x = charExclamation, y = capitalAve, colour = type)) +
  theme_minimal() +
  geom_jitter() +
  ylim(c(0, 5)) + xlim(c(0, 0.5)) +
  xlab("Frequency of exclamation marks") +
  ylab("Longest sequence of capital letters") +
  geom_vline(xintercept = c(0, 0.25, 0.5), color = "grey") +
  geom_hline(yintercept = c(0, 2.5, 5), color = "grey") +
  scvd

ggsave(filename = "../figure/capital_letters_plot.png", plot = p, width = 6, height = 3)