# ------------------------------------------------------------------------------
# FIG: CAPITAL LETTERS 3D
# ------------------------------------------------------------------------------

library(ggplot2)
library(mlr3)
library(viridis)
library(tidyverse)
library(scatterplot3d)
source("helpers/data_generators.R")

# DATA -------------------------------------------------------------------------

df <- make_spam_df()

# PLOTS ------------------------------------------------------------------------
png(filename = "../figure/capital_letters_3d_plot.png", width = 8, height = 4, units = "in", res = 300)
colors <- c('#bbdf27', '#440154')
colors <- colors[as.numeric(df$type)]
p <- scatterplot3d(df[, c("charExclamation", "capitalAve", "your")],
              xlim = c(0, 0.5), ylim = c(0, 5), zlim = c(0, 2),
              pch = 16, color=colors, xlab = "Frequency of exclamation marks",
              ylab = "Longest sequence of capital letters", zlab = "Frequency of word 'your'")
dev.off()