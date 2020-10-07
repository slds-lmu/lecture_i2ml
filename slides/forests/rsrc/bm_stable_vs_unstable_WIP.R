# PREREQ -----------------------------------------------------------------------

library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(mlr3viz)
library(mlbench)
library(plyr)
library(tidyverse)
library(ggplot2)
library(data.table)

# SIMULATION -------------------------------------------------------------------



# Benchmark experiment
# Reference: Breiman (1996). Bagging Predictors. Machine Learning, 24, 123-140.
# Note: Breiman's approach is more complex than this benchmark here
# Create learners and their respective bagged version

ensemble_size = 50L

learner_rpart = lrn("classif.rpart")
learner_rpart$id = "rpart"

single_rpart = po("subsample", frac = 1, replace = TRUE) %>>% 
  lrn("classif.rpart")

pipeline = ppl("greplicate", single_rpart, ensemble_size)

bagging = pipeline %>>%
  PipeOpClassifAvg$new(innum = ensemble_size)

# single_rpart =  po("learner", lrn("classif.rpart"))
# 
# bagging_rpart = pipeline_bagging(single_rpart, 
#                                  iterations = ensemble_size,
#                                  frac = 0.7,
#                                  averager = po("classifavg"))

baglrn_rpart = GraphLearner$new(bagging_rpart)
baglrn_rpart$id = "rpart.bagged"

# single_rpart = PipeOpSubsample$new(param_vals = list(frac = 0.632)) %>>%
#   PipeOpLearner$new(mlr_learners$get("classif.rpart"))
# ppl_rpart = ppl("greplicate", single_rpart, 50L)
# bagging_rpart = ppl_rpart %>>%
#   PipeOpClassifAvg$new(innum = 50L)
# baglrn_rpart = GraphLearner$new(bagging_rpart)

learner_knn = lrn("classif.kknn")
learner_knn$id = "kknn"

single_knn = PipeOpSubsample$new(param_vals = list (replace = TRUE,
                                                    frac = 1)) %>>%
  PipeOpLearner$new(mlr_learners$get("classif.kknn"))
ppl_knn = ppl("greplicate", single_knn, ensemble_size)
bagging_knn = ppl_knn %>>%
  PipeOpClassifAvg$new(innum = ensemble_size)
baglrn_knn = GraphLearner$new(bagging_knn)
baglrn_knn$id = "kknn.bagged"

learner_rf = lrn("classif.ranger", num.trees = ensemble_size)
learner_rf$id = "rf"

learners = list(
  learner_rpart,
  baglrn_rpart,
  learner_knn,
  baglrn_knn,
  learner_rf
)

# Get some tasks also used by Breiman 1996 and modify them when necessary
# some tasks which Breiman used contain missings and need to much preprocessing
# --> only those are used that are easy to implement

data_wf = as.data.frame(mlbench.waveform(n = 100))
data_wf$classes = mapvalues(data_wf$classes, "3", "1")
task_wf = TaskClassif$new("Waveform", data_wf, target = "classes")

data("Ionosphere")
data_ion = as.data.frame(Ionosphere) %>% select(-c(V2, V3))
task_ion = TaskClassif$new("Ionosphere", data_ion, target = "Class")

data("Glass")
data_gl = as.data.frame(Glass)
task_gl = TaskClassif$new("Glass", data_gl, target = "Type")

task_son = tsk("sonar")
task_son$id = "Sonar"

tasks = list(task_wf, task_ion, task_gl, task_son)
# tasks = list(task_wf, task_ion)

# Specify resampling procedure

rdesc = rsmp("cv", folds = 10)

# Benchmark experiment

design = benchmark_grid(
  tasks = tasks,
  learners = learners,
  resamplings = rdesc
)

set.seed(899)
bmr = benchmark(design)

# PLOT -------------------------------------------------------------------------

pdf("04-random-forest/figure_man/bm_stable_vs_unstable.pdf", w = 8, h = 5.8)

autoplot(bmr) +
  labs(y = "Mean misclassification error")

dev.off()

# TABLE ------------------------------------------------------------------------

# EXTRA: overview table to get some numbers and an impression of the performance
# increase by bagging

perf = bmr$aggregate()

sub1 = subset(perf, learner_id == "rpart")[, c(3, 4, 7)]
sub2 = data.frame(subset(perf, learner_id == "rpart.bagged")$classif.ce)
colnames(sub2) = "mmce_test_bagged"
sub3 = subset(perf, learner_id == "kknn")[, c(3, 4, 7)]
sub4 = data.frame(subset(perf, learner_id == "kknn.bagged")$classif.ce)
colnames(sub4) = "mmce_test_bagged"
sub5 = subset(perf, learner_id == "rf")[, c(3, 4, 7)]

overview = rbind(cbind(sub1, sub2), cbind(sub3, sub4))
colnames(overview)[3] = "mmce_test"

overview$decrease = ((overview$mmce_test - overview$mmce_test_bagged) / 
                       overview$mmce_test) * 100
overview
