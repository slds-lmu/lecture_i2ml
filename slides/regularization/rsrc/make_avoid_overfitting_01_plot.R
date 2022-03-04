# ------------------------------------------------------------------------------
# FIG: AVOID OVERFITTING 01
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
library(data.table)

# DATA -------------------------------------------------------------------------

load("ozone_example.RData")

dfp <- setDT(df_incdata)[, .(mean.mse = median(value)), by = c("nobs", "variable")]

# PLOTS ------------------------------------------------------------------------

p <- ggplot(data = dfp, aes(x = nobs, y = mean.mse, colour = variable)) +
  geom_line(lwd = 1.2) + ylim(c(0, 100)) + labs(colour = " ") +
  scale_colour_discrete(labels = c("Train error", "Test error")) +
  xlab("Size of data set") + ylab("MSE") +
  scale_color_brewer(palette="Dark2")

ggsave("../figure/avoid_overfitting_01.png", plot=p, width=5, height=2.5)