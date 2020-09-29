# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mlbench)
library(plyr)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(kernlab)
library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(600000)
data = as.data.frame(mlbench.2dnormals(n = 200, cl = 3))
data$classes = mapvalues(data$classes, "3", "1")

task = TaskClassif$new("example", data, target = "classes")

learner_of = lrn("classif.svm", 
                 type = "C-classification", 
                 kernel = "radial", 
                 gamma = 100, 
                 cost = 1,
                 predict_type = "prob")

learner_nof = lrn("classif.svm", 
                  type = "C-classification", 
                  kernel = "radial", 
                  gamma = 1, 
                  cost = 1,
                  predict_type = "prob")

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/eval_ofit_1.pdf", width = 8, height = 6)

plot_learner_prediction(learner_of, task) +
  guides(shape = FALSE, alpha = FALSE)

ggsave("../figure/eval_ofit_1.pdf", width = 8, height = 6)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/eval_ofit_2.pdf", width = 8, height = 6)

plot_learner_prediction(learner_nof, task) +
  guides(shape = FALSE, alpha = FALSE)

ggsave("../figure/eval_ofit_2.pdf", width = 8, height = 6)
dev.off()