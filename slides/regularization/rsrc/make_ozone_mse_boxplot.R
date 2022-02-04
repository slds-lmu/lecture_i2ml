# ------------------------------------------------------------------------------
# FIG: OZONE MSE BOXPLOT
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

dfp <- df_incdata[nobs == 50, ]


# PLOTS ------------------------------------------------------------------------

p <- ggplot(data = dfp, aes(x = 0, y = value, fill = variable)) +
  geom_boxplot() + labs(colour = " ") +
  scale_colour_discrete(labels = c("Train error", "Test error")) +
  xlab(" ") + ylab("Mean Squared Error") +
  ylim(c(0, 400)) +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_brewer(palette="Dark2")

ggsave("../figure/ozone_mse_boxplot.png", plot=p, width=4, height=2)