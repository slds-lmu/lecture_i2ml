# PREREQ -----------------------------------------------------------------------

library(mlr3)
library(mlr3learners)
library(mlr3tuning)
library(paradox)

# DATA -------------------------------------------------------------------------

set.seed(123222)

# Just run RS on spam for ranger so we can show an example path
# that improves the result

task <- tsk("sonar")
learner <- lrn("classif.ranger", predict_type = "prob")
resampling <- rsmp("cv", folds = 5)
measure <- msr("classif.auc")

tune_ps <- ParamSet$new(list(
  ParamInt$new("num.trees", lower = 3, upper = 200),
  ParamInt$new("mtry", lower = 5, upper = 20),
  ParamInt$new("min.node.size", lower = 2, upper = 20)
))

terminator <- trm("evals", n_evals = 216)

rs_instance <- TuningInstanceSingleCrit$new(
  task = task,
  learner = learner,
  resampling = resampling,
  measure = measure,
  search_space = tune_ps,
  terminator = terminator,
  store_models = TRUE
)

gs_instance <- TuningInstanceSingleCrit$new(
  task = task,
  learner = learner,
  resampling = resampling,
  measure = measure,
  search_space = tune_ps,
  terminator = terminator,
  store_models = TRUE
)

rs_tuner <- tnr("random_search")
rs_tuner$optimize(rs_instance)
rs_tuning <- rs_instance$archive$data

gs_tuner <- tnr("grid_search", resolution=6)
gs_tuner$optimize(gs_instance)
gs_tuning <- gs_instance$archive$data

saveRDS(rs_tuning, "tune_rs_example.rds")
saveRDS(gs_tuning, "tune_gs_example.rds")
