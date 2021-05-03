# classif.boosting is really sloooow, because ada implementation sucks
library(mlr)
library(reshape2)
library(ggplot2)
library(purrr)

set.seed(121)
task = convertMLBenchObjToTask("mlbench.spirals", n = 200)
n.trees = c(1, seq(10, 1000, l = 10))

learners = list(
  rf_stump = makeLearner("classif.randomForest", maxnodes = 2L),
 # rf_fulltree = makeLearner("classif.randomForest"),
  ada = makeLearner("classif.gbm", interaction.depth = 1L, shrinkage = 1, distribution = "adaboost"),
  #gbm = makeLearner("classif.gbm", shrinkage = 0.3, distribution = "bernoulli"),
  #xgb_stump = makeLearner("classif.xgboost", max_depth = 1L, eta = 0.3),
  #xgb = makeLearner("classif.xgboost", eta = 0.3),
  #glmboost = makeLearner("classif.glmboost", nu = 0.3)#,
  # blackboost_stump = makeLearner("classif.blackboost", maxdepth = 1L , nu = 0.3)
)

rin = makeResampleInstance("RepCV", folds = 10, reps = 3, task = task)

paramsets <- list(
  ntree = makeParamSet(makeDiscreteParam("ntree", values = n.trees)),
  ntree = makeParamSet(makeDiscreteParam("ntree", values = n.trees)),
  n.trees = makeParamSet(makeDiscreteParam("n.trees", values = n.trees)),
  n.trees = makeParamSet(makeDiscreteParam("n.trees", values = n.trees)),
  nrounds = makeParamSet(makeDiscreteParam("nrounds", values = n.trees)),
  nrounds = makeParamSet(makeDiscreteParam("nrounds", values = n.trees)),
  mstop = makeParamSet(makeDiscreteParam("mstop", values = n.trees))
  # mstop = makeParamSet(makeDiscreteParam("mstop", values = n.trees))
)

ctrl = makeTuneControlGrid()

# see https://github.com/mlr-org/mlr/issues/2263
tuned = map2(learners, paramsets,
  ~ tuneParams(learner = .x, par.set = .y, task = task, resampling = rin, control = ctrl))

result = map2(tuned, names(tuned), function(.x, .y) {
  tmp <- as.data.frame(.x$opt.path)[,1:2]
  names(tmp) <- c("M", "mmce")
  cbind(learner = .y, tmp)
  }) %>% do.call(rbind, .)

save(result, file = "rsrc/comparing_methods_result.RData")

learnerPredPlot1 = plotLearnerPrediction(
  makeLearner("classif.randomForest", maxnodes = 2L, ntree = 20L), task
)
learnerPredPlot2 = plotLearnerPrediction(
  makeLearner("classif.adaboostm1", I = 20L), task
)

save(learnerPredPlot1, learnerPredPlot2, file = "rsrc/stump_plots.RData")
