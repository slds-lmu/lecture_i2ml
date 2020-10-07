# PREREQ -----------------------------------------------------------------------

library(mlr3)
library(mlr3learners)
library(mlr3tuning)
library(paradox)
library(parallelMap)

parallelStartMulticore(15)

# DATA -------------------------------------------------------------------------

set.seed(123222)

# Just run RS on spam for ranger so we can show an example path
# that improves the result

task = tsk("sonar")
learner = lrn("classif.ranger", predict_type = "prob")
resampling = rsmp("cv", folds = 5)
measure = msr("classif.auc")

tune_ps = ParamSet$new(list(
  ParamInt$new("num.trees", lower = 3, upper = 200),
  ParamInt$new("mtry", lower = 5, upper = 20),
  ParamInt$new("min.node.size", lower = 2, upper = 20)
))

terminator = trm("evals", n_evals = 150)

instance = TuningInstanceSingleCrit$new(
  task = task,
  learner = learner,
  resampling = resampling,
  measure = measure,
  search_space = tune_ps,
  terminator = terminator,
  store_models = TRUE
)

tuner = tnr("random_search")
tuner$optimize(instance)
tuning = instance$archive

BBmisc::save2("tune_example.RData", tune_example_res = tuning)

parallelStop()
