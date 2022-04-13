# ------------------------------------------------------------------------------
# FIG: AVOID OVERFITTING 02
# ------------------------------------------------------------------------------

library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(tidyr)
library(colorspace)
library(gridExtra)
library(BBmisc)
library(reshape)

# DATA -------------------------------------------------------------------------

load("ozone_example.RData")

# PLOTS ------------------------------------------------------------------------
p <- ggplot(data = df_incfeatures, aes(x = type, y = mean.mse, colour = variable)) +
  geom_line(lwd = 1.2) + labs(colour = " ") +
  scale_colour_discrete(labels = c("Train error", "Test error")) +
  xlab("Number of features") + ylab("Mean Squared Error") +
  ylim(c(0, 150)) +
  scale_x_continuous(breaks = 0:12) +
  scale_color_brewer(palette="Dark2")

ggsave("../figure/avoid_overfitting_02.png", plot=p, width=5, height=2.5)