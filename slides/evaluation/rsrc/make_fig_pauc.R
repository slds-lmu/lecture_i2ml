# ------------------------------------------------------------------------------
# FIG: PARTIAL AUC
# ------------------------------------------------------------------------------

# https://www.medcalc.org/manual/roc-curve-partial-area.php

library(data.table)
library(ggforce)
library(ggplot2)

# PLOT -------------------------------------------------------------------------

p <- ggplot() +
  geom_arc(aes(x0 = 1, y0 = 0, r = 1, start = -2, end = 0)) +
  xlim(c(0, 1)) +
  ylim(c(0, 1)) +
  geom_rect(
    mapping = aes(xmin = 0.25, xmax = 0.5, ymin = 0, ymax = 1), 
    fill = NA,
    col = "blue") +
  theme_minimal() +
  labs(x = "FPR", y = "TPR")

dt_highlight <- data.table(
  x = c(rep(0.25, 4), rep(0.5, 4)),
  y = c(0, 0.3, 0.67, 1, 0, 0.4, 0.87, 1), 
  text = c("A", "h", "D", "f", "B", "g", "C", "e"))

p <- p + geom_label(
  dt_highlight, 
  mapping = aes(x = x, y = y, label = text), 
  col = "blue")

ggsave("../figure/fig_pauc.png", p, height = 4L, width = 4L)
