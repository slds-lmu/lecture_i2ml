# ------------------------------------------------------------------------------
# FIG: CAUCHY LOSS
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

source("loss_functions.R")

df <- data.frame(res = seq(-10L, 10L, length.out = 800L))

losses <- list(
  "C2" = function(res) cauchy(res, c = 2L),
  "C1" = function(res) cauchy(res, c = 1L),
  "C05" = function(res) cauchy(res, c = 0.5))

# PLOTS ------------------------------------------------------------------------

p <- plotLoss(df, losses) + scale_color_viridis_d(
  end = 0.9,
  name = "c", 
  labels = c(2, 1, 0.5)) +
  theme(text = element_text(size = 20L))

ggplot2::ggsave("../figure/loss_cauchy.png", p, width = 6L, height = 4L)
