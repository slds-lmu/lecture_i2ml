

library(knitr)
library(ggplot2)
library(randomForest)
library(colorspace)
library(mlr)
library(mboost)
library(mlbench)

source("rsrc/cim1_optim.R")

source("rsrc/gbm_sine.R")
p1 = doPlot(sd = 0.0, shrinkage = 1) + theme(legend.position = "none")
p2 = doPlot(sd = 0.1, shrinkage = 1)
grid.arrange(p1, p2, nrow = 1, widths = c(0.25, 0.3))
############################################################################