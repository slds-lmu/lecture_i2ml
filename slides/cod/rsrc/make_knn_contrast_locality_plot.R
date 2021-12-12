# ------------------------------------------------------------------------------
# FIG: KNN CONTRAST LOCALITY
# ------------------------------------------------------------------------------

library(xtable)
library(gridExtra)
library(grid)
library(data.table)
library(ggplot2)
source("helpers/data_generators.R")
source("helpers/constants.R")
source("helpers/utilities.R")

# DATA -------------------------------------------------------------------------
distances <- readRDS("datasets/distances.rds")

# PLOTS ------------------------------------------------------------------------

distances$contr <- (distances$max - distances$min)/distances$max
distances$local <- ( distances$mean - distances$mean_nn) / distances$mean

plot_df <- melt(distances[, c("dim", "contr", "local")], id.vars = "dim")

p <- ggplot(plot_df, aes(x=dim, y=value)) +
  geom_line(aes(color = variable)) +
  geom_point(aes(color = variable)) +
  labs(color=NULL) +
  ylab(NULL) +
  xlab("p") +
  scale_colour_discrete(name = "", labels = c("c(p)", "l(p)")) +
  theme_minimal()

ggsave(filename = "../figure/knn_contrast_locality_plot.png", plot = p, width = 6, height = 3)
