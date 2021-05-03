

library(ggplot2)
library(randomForest)
library(colorspace)
library(mlr)

##############################################################

err = seq(0.01, 1, .01)
beta = log((1-err)/err)
qplot(err, beta, geom = "line",
      xlab = expression(err^m), ylab = expression(beta^m))