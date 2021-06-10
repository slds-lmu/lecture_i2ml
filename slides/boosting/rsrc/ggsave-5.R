

library(knitr)
library(ggplot2)
library(randomForest)
library(colorspace)
library(mlr)
library(mboost)
library(mlbench)

source("rsrc/cim1_optim.R")
  

load("rsrc/gbm_spam_results_long.RData")

ggd = error.df
ggd$shrinkage = as.factor(ggd$shrinkage)
ggplot(data = ggd, aes(x = M, y = err, col = max.tree.depth)) +
  geom_line(alpha= .8) + facet_grid(~ shrinkage, labeller = label_both) + #coord_cartesian(ylim = c(0, 0.20)) +
  ylab("mmce (test data)") + scale_x_continuous("iterations M [1000]",
                                                c(1, 5, 10, 15, 20) * 1e3,
                                                labels = c("1", "5", "10", "15", "20")) +
  scale_y_continuous(trans = "log2")

gbm.perf(mod$learner.model, method = "OOB")

plot.gbm(mod$learner.model, 52)
plot.gbm(mod$learner.model, 25)
######################################################