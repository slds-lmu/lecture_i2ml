library(mlr)
set.seed(123)

# just run RS on spam for gbm so we can show an example path
# that improves the result

task = spam.task
lrn = makeLearner("classif.gbm", predict.type="prob", distribution = "bernoulli")

ps = makeParamSet(
  makeIntegerParam("n.trees", lower = 3, upper = 500),
  makeNumericParam("shrinkage", lower = 0, upper = 1),
  makeIntegerParam("interaction.depth", lower = 1, upper = 5),
  makeNumericParam("bag.fraction", lower = 0.2, upper = 0.9)
)
ctrl = makeTuneControlRandom(maxit = 50L)
tr = tuneParams(lrn, task = sonar.task, par.set = ps, resampling = cv5,
  control = ctrl, measures = mlr::auc)

save2("tune_example.RData", tune_example_res = tr)