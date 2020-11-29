# PREREQ -----------------------------------------------------------------------

# remotes::install_github("mlr-org/mlr3keras")

library(knitr)
library(mlbench)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(mlr3keras)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(600000)

data = data.frame(mlbench.spirals(1000))
task = TaskClassif$new("spirals", data, target = "classes")

learner = LearnerClassifKerasFF$new()

learner$param_set$values$epochs = 50
learner$param_set$values$layer_units = 12

learner$train(task)
learner$predict(task)

learners = lapply(num_trees, 
                  function (i) {lrn("classif.ranger",
                                    num.trees = i, 
                                    predict_type = "prob")}) 

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/nnet_1.pdf", width = 8, height = 5.5)

plot_learner_prediction()

ggsave("../figure/nnet_1.pdf", width = 8, height = 5.5)
dev.off()
