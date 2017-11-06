# nice report http://www.ritchieng.com/machinelearning-learning-curve/ and
# http://scikit-learn.org/stable/modules/learning_curve.html#learning-curve
# http://www.ritchieng.com/applying-machine-learning/

library(OpenML)
library(data.table)
library(parallelMap)
library(parallel)
setOMLConfig(server = "https://www.openml.org/api/v1", apikey = "c1994bdb7ecb3c6f3c8f3b35f4b47f1f")

#' Does subsampling with 'split' as split rate and 'iters' as number of subsampling iterations
myLearningCurveSplit = function(learner, task, measure, iters = 100, split = 1) {
  rdesc = makeResampleDesc(method = "Subsample",
    iters = iters, split = split, predict = "both", stratify = TRUE)
  res = resample(learner = learner, task = task, resampling = rdesc,
    measures = list(
      test.mean = setAggregation(measure, test.mean),
      train.mean = setAggregation(measure, train.mean),
      test.sd = setAggregation(measure, test.sd),
      train.sd = setAggregation(measure, train.sd)
    ), show.info = FALSE)
  return(as.data.frame(c(percentage = split, as.list(res$aggr))))
}

#' Compute learning curve for many different split rates
myLearningCurve = function(learner, task, measure, iters = 100,
  perc = seq(0.1, 0.9, by = 0.1)) {
  # iterate over all training set percentages from 'perc'
  res = rbindlist(lapply(perc, function(x) {
    myLearningCurveSplit(learner = learner,
      measure = measure, task = task, split = x, iters = iters)
  }))
  # make data frame
  melt(res, id.vars = "percentage", variable.name = "measure",
    value.name = c("mmce", "sd"), measure = patterns("mean", "sd"))
}

set.seed(123)
task = convertOMLDataSetToMlr(getOMLDataSet(847))
lrn.ranger = makeLearner("classif.ranger", num.threads = 1, num.trees = 10)
lrn.rpart = makeLearner("classif.rpart", cp = 0.0025)

parallelStartSocket(20)
clusterSetRNGStream(iseed = 123)
res.ranger = myLearningCurve(learner = lrn.ranger, measure = mmce, task = task, iters = 100)
res.rpart = myLearningCurve(learner = lrn.rpart, measure = mmce, task = task, iters = 100)
res.rpart.small = myLearningCurve(learner = lrn.rpart, measure = mmce, task = task, iters = 20)
parallelStop()

save(res.ranger, res.rpart, res.rpart.small, file = "learning_curve.RData")
