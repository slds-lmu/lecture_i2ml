# ------------------------------------------------------------------------------
# FIG: EXCLAMATION MARKS
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

p <- ggplot(data = df, aes(x = charExclamation, y = 0, colour = type)) +
  theme_minimal() +
  geom_vline(xintercept = c(0, 0.25, 0.5), colour = "grey") +
  geom_jitter(height = 0, size = 1) +
  ylim(c(0, 1)) + xlim(c(0, 0.5)) +
  xlab("Frequency of exclamation marks") +
  theme(axis.title.y = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank()) +
  scvd

ggsave(filename = "../figure/exclamation_marks_plot.png", plot = p, width = 6, height = 2)