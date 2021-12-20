# ------------------------------------------------------------------------------
# FIG: KNN TABLE
# ------------------------------------------------------------------------------

library(xtable)
library(gridExtra)
library(grid)
source("helpers/data_generators.R")
source("helpers/constants.R")
source("helpers/utilities.R")

# DATA -------------------------------------------------------------------------
distances <- readRDS("datasets/distances.rds")

# PLOTS ------------------------------------------------------------------------
colnames(distances) <- c("italic(p)",
                         "min(italic(d)(bold(x),bold(tilde(x))))",
                         "bar(italic(d)(bold(x),bold(tilde(x))))",
                         "max(italic(d)(bold(x),bold(tilde(x))))",
                         "bar(italic(d)[italic(NN1)](bold(x)))",
                         "max(italic(d)[italic(NN1)](bold(x)))")

t <- tableGrob(signif(distances, 2),
           theme = ttheme_default(colhead=list(fg_params = list(parse=TRUE))),
           rows = NULL)

ggsave(filename = "../figure/knn_table.png", plot = t, width = 6, height = 3)
