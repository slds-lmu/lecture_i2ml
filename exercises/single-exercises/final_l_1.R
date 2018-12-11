library(mlr)
library(OpenML)
library(parallelMap)


setOMLConfig(apikey = "c1994bdb7ecb3c6f3c8f3b35f4b47f1f", arff.reader="farff")

task = getOMLDataSet(data.id = 1471)

task = convertOMLDataSetToMlr(task)

base.learners = list(
  makeLearner("classif.xgboost"),
  makeLearner("classif.ranger"),
  makeFilterWrapper(makeLearner("classif.ksvm", kernel = "rbfdot", C = 2, sigma = 1),
                    fw.method = "chi.squared")
)

lrn = makeModelMultiplexer(base.learners)

ps = makeModelMultiplexerParamSet(lrn,
  classif.xgboost = makeParamSet(
    makeIntegerParam("nrounds", lower = 1L, upper = 2000L),
    makeIntegerParam("max_depth", lower = 1L, upper = 8L)),
  classif.ranger = makeParamSet(
    makeIntegerParam("num.trees", lower = 1L, upper = 1000L),
    makeIntegerParam("mtry", lower = 2, upper = 12)),
  classif.ksvm.filtered = makeParamSet(
    makeNumericParam("sigma", lower = -12, upper = 12, trafo = function(x) 2^x),
    makeNumericParam("C", lower = -12, upper = 12, trafo = function(x) 2^x),
    makeNumericParam("fw.perc", lower = 0.01, upper = 1)), .check = FALSE
)


#ctrl = makeTuneControlIrace(maxExperiments = 200L)
ctrl = makeTuneControlRandom(maxit = 100L)

rdesc = makeResampleDesc("Holdout")

#for linux
parallelStartMulticore(cpus = 2)
res = tuneParams(learner = lrn, task = task,
  resampling = rdesc, measures =  mmce,
  par.set = ps, control =  ctrl)
parallelStop()

#for windows
# parallelStartSocket(cpus = 2)
# res = tuneParams(learner = lrn, task = task,
#   resampling = rdesc, measures =  mmce,
#   par.set = ps, control =  ctrl)
# parallelStop()


#upload to OpenML Server:
res$x
lrn = setHyperPars(makeLearner("classif.xgboost"), par.vals = list(nrounds = res$x$classif.xgboost.nrounds,
  max_depth = res$x$classif.xgboost.max_depth))
task = getOMLTask(9983)
run.mlr = runTaskMlr(task, lrn) # Run the learner on the task, yields an mlr run
run.id = uploadOMLRun(run.mlr)

