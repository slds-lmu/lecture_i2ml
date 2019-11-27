library(mlr)
set.seed(12322)

library(parallelMap)
parallelStartMulticore(15)

# just run RS on spam for ranger so we can show an example path
# that improves the result

task = sonar.task
learner = makeLearner("classif.ranger", predict.type = "prob")

params = makeParamSet(
  makeIntegerParam("num.trees", lower = 3, upper = 200),
  makeIntegerParam("mtry", lower = 5, upper = 20),
  makeIntegerParam("min.node.size", lower = 2, upper = 20)
)
ctrl = makeTuneControlRandom(maxit = 150L)
tuning = tuneParams(learner, task = task, par.set = params, resampling = cv5,
  control = ctrl, measures = mlr::auc)

BBmisc::save2("tune_example.RData", tune_example_res = tuning)

parallelStop()
